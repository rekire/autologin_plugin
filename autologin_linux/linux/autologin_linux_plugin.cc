#include "include/autologin_linux/autologin_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <libsecret/secret.h>
#include <cstring>

const SecretSchema* getAutologinSchema(const char* serviceName){
    static const SecretSchema autologinSchema = {
        serviceName, SECRET_SCHEMA_NONE,
        {
            {  "username", SECRET_SCHEMA_ATTRIBUTE_STRING },
            {  "NULL" },
        },
	// Fixing compile warning with a zero and NULLs
	0,    // reserved
	NULL, // reserved1
	NULL, // reserved2
	NULL, // reserved3
	NULL, // reserved4
	NULL, // reserved5
	NULL, // reserved6
	NULL, // reserved7
    };
    return &autologinSchema;
}

const char kChannelName[] = "autologin_linux";

struct _FlAutologinPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;

  // Connection to Flutter engine.
  FlMethodChannel* channel;
};

G_DEFINE_TYPE(FlAutologinPlugin, fl_autologin_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method, "performCompatibilityChecks") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("{\"isPlatformSupported\":true,\"canSafeSecrets\":true}")));
  } else if (strcmp(method, "requestCredentials") == 0) {
    const char* jsonTemplate = "{\"username\":\"%s\",\"password\":\"%s\"}";
    GError *error = NULL;
    GList *items = secret_password_search_sync(getAutologinSchema("eu.rekisoft.flutter.autologin.example"), SECRET_SEARCH_ALL, NULL, &error, NULL);

    if (error != NULL) {
      g_error("Error retrieving secret: %s", error->message);
      g_error_free(error);
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    } else if (g_list_length(items) > 0) {
      /* The attributes used to lookup the password should conform to the schema. */
      gchar *password = secret_password_lookup_sync(getAutologinSchema("eu.rekisoft.flutter.autologin.example"), NULL, &error, NULL);

      if (error != NULL) {
        /* ... handle the failure here */
        printf("Query password failed.\n");
        g_error_free (error);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      } else if (password == NULL) {
        /* password will be null, if no matching password found */
        g_print("No password found\n");
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      } else {
        GHashTable *attributes = secret_retrievable_get_attributes((SecretRetrievable*)items->data);
        const gchar *username = (const gchar*)g_hash_table_lookup(attributes, "username");

        char *json = (char*)malloc(strlen(jsonTemplate)+strlen(username)+strlen(password)-3);
        sprintf(json, jsonTemplate, username, password);
        response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(json)));

        free(json);
        g_hash_table_unref(attributes);
        g_list_free_full(items, g_object_unref);
        secret_password_free(password);
      }
    } else {
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
  } else if (strcmp(method, "saveCredentials") == 0) {
    GError *error = NULL;
    FlValue *args = fl_method_call_get_args(method_call);

    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
        "Bad arguments", "args given to function is not a map", nullptr));
    } else {
      FlValue *usernameArg = fl_value_lookup_string(args, "username");
      const gchar *username = usernameArg == nullptr ? nullptr : fl_value_get_string(usernameArg);
      FlValue *passwordArg = fl_value_lookup_string(args, "password");
      const gchar *password = passwordArg == nullptr ? nullptr : fl_value_get_string(passwordArg);
      if (username != nullptr && password != nullptr) {
        //g_print("Username: %s\nPassword: %s\n", username, password);
        secret_password_store_sync (getAutologinSchema("eu.rekisoft.flutter.autologin.example"),
			    SECRET_COLLECTION_DEFAULT,
                            "DemoApp", password, NULL, &error,
                            "username", username, NULL);

        if (error != NULL) {
          response = FL_METHOD_RESPONSE(fl_method_error_response_new("Libsecret error", nullptr/*error*/, nullptr));
          g_error_free(error);
        } else {
          g_print("Password saved!\n");
          response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("false")));
        }
      } else {
        response = FL_METHOD_RESPONSE(fl_method_error_response_new(
           "Bad arguments", "username or password missing", nullptr));
      }
    }
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error))
    g_warning("Failed to send method call response: %s", error->message);
}

static void fl_autologin_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(fl_autologin_plugin_parent_class)->dispose(object);
}

static void fl_autologin_plugin_class_init(FlAutologinPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_autologin_plugin_dispose;
}

FlAutologinPlugin* fl_autologin_plugin_new(FlPluginRegistrar* registrar) {
  FlAutologinPlugin* self = FL_AUTOLOGIN_PLUGIN(
      g_object_new(fl_autologin_plugin_get_type(), nullptr));

  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kChannelName, FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->channel, method_call_cb,
                                            g_object_ref(self), g_object_unref);
  return self;
}

static void fl_autologin_plugin_init(FlAutologinPlugin* self) {}

void autologin_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlAutologinPlugin* plugin = fl_autologin_plugin_new(registrar);
  g_object_unref(plugin);
}
