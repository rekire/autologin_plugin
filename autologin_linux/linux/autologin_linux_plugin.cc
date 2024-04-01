#include "include/autologin_linux/autologin_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <libsecret/secret.h>
#include <cstring>

const SecretSchema *getSchema(const char *serviceName) {
  static const SecretSchema autologinSchema = {
    serviceName, SECRET_SCHEMA_NONE,
    {
      {"username", SECRET_SCHEMA_ATTRIBUTE_STRING},
      {"nullptr"},
    },
    // Fixing compile warning with a zero and nullptrs
    0,    // reserved
    nullptr, // reserved1
    nullptr, // reserved2
    nullptr, // reserved3
    nullptr, // reserved4
    nullptr, // reserved5
    nullptr, // reserved6
    nullptr, // reserved7
  };
  return &autologinSchema;
}

const char kChannelName[] = "autologin_plugin";

struct _FlAutologinPlugin {
  GObject parent_instance;

  FlPluginRegistrar *registrar;

  // Connection to Flutter engine.
  FlMethodChannel *channel;
};

G_DEFINE_TYPE(FlAutologinPlugin, fl_autologin_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call, gpointer user_data) {
  const gchar *method = fl_method_call_get_name(method_call);
  //g_print("Got native call for %s\n", method);
  g_autoptr(FlMethodResponse)
  response = nullptr;
  if (strcmp(method, "performCompatibilityChecks") == 0) {
    g_autoptr(FlValue)
    map = fl_value_new_map();
    fl_value_set_string_take(map, "isPlatformSupported", fl_value_new_bool(TRUE));
    fl_value_set_string_take(map, "canSafeSecrets", fl_value_new_bool(TRUE));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(map));

  } else if (strcmp(method, "requestCredentials") == 0) {
    FlValue *args = fl_method_call_get_args(method_call);

    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("Bad arguments", "args given to function is not a map", nullptr)
      );
    } else {
      FlValue *appIdArg = fl_value_lookup_string(args, "appId");
      const gchar *appId = appIdArg == nullptr ? nullptr : fl_value_get_string(appIdArg);
      FlValue *appNameArg = fl_value_lookup_string(args, "appName");
      const gchar *appName = appNameArg == nullptr ? nullptr : fl_value_get_string(appNameArg);
      if (appId == nullptr || appName == nullptr) {
        response = FL_METHOD_RESPONSE(
          fl_method_error_response_new(
            "Bad arguments",
            "appId or appName are missing. A check on dart has failed please file a bug.",
            nullptr
          )
        );
      } else {
        g_print("Found appId: %s, appName: %s\n", appId, appName);

        GError *error = nullptr;
// FIXME the line below crashs
        GList *items = secret_password_search_sync(getSchema(appId), SECRET_SEARCH_ALL, nullptr, &error, nullptr);

        if (error != nullptr) {
          g_error("Error retrieving secret: %s", error->message);
          g_error_free(error);
          response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
        } else if (g_list_length(items) > 0) {
          /* The attributes used to lookup the password should conform to the schema. */
          gchar *password = secret_password_lookup_sync(getSchema(appId), nullptr, &error, nullptr);

          if (error != nullptr) {
            /* ... handle the failure here */
            g_error("Query password failed: %s\n", error->message);
            g_error_free(error);
            response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
          } else if (password == nullptr) {
            /* password will be null, if no matching password found */
            g_print("No password found\n");
            response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
          } else {
            GHashTable *attributes = secret_retrievable_get_attributes((SecretRetrievable *) items->data);
            const gchar *username = (const gchar *) g_hash_table_lookup(attributes, "username");

            g_autoptr(FlValue)
            map = fl_value_new_map();
            fl_value_set_string_take(map, "username", fl_value_new_string(username));
            fl_value_set_string_take(map, "password", fl_value_new_string(password));
            response = FL_METHOD_RESPONSE(fl_method_success_response_new(map));

            g_hash_table_unref(attributes);
            g_list_free_full(items, g_object_unref);
            secret_password_free(password);
          }
        }
      }
    }

  } else if (strcmp(method, "saveCredentials") == 0) {
    GError *error = nullptr;
    FlValue *args = fl_method_call_get_args(method_call);

    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
      response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("Bad arguments", "args given to function is not a map", nullptr)
      );
    } else {
      FlValue *usernameArg = fl_value_lookup_string(args, "username");
      const gchar *username = usernameArg == nullptr ? nullptr : fl_value_get_string(usernameArg);
      FlValue *passwordArg = fl_value_lookup_string(args, "password");
      const gchar *password = passwordArg == nullptr ? nullptr : fl_value_get_string(passwordArg);
      FlValue *appIdArg = fl_value_lookup_string(args, "appId");
      const gchar *appId = appIdArg == nullptr ? nullptr : fl_value_get_string(appIdArg);
      FlValue *appNameArg = fl_value_lookup_string(args, "appName");
      const gchar *appName = appNameArg == nullptr ? nullptr : fl_value_get_string(appNameArg);
      if (username == nullptr || password == nullptr || appId == nullptr || appName == nullptr) {
        response = FL_METHOD_RESPONSE(
          fl_method_error_response_new("Bad arguments", "username, password, appId or appName missing", nullptr)
        );
      } else {
        //g_print("Username: %s\nPassword: %s\n", username, password);
        secret_password_store_sync(getSchema(appId),
                                   SECRET_COLLECTION_DEFAULT,
                                   appName, password, nullptr, &error,
                                   "username", username, nullptr);

        if (error != nullptr) {
          response = FL_METHOD_RESPONSE(fl_method_error_response_new("Libsecret error", error->message, nullptr));
          g_error_free(error);
        } else {
          g_print("Password saved!\n");
          response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(TRUE)));
        }
      }
    }
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  g_autoptr(GError)
  error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error)) {
    g_warning("Failed to send method call response: %s", error->message);
  }
}

static void fl_autologin_plugin_dispose(GObject *object) {
  G_OBJECT_CLASS(fl_autologin_plugin_parent_class)->dispose(object);
}

static void fl_autologin_plugin_class_init(FlAutologinPluginClass *klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_autologin_plugin_dispose;
}

FlAutologinPlugin *fl_autologin_plugin_new(FlPluginRegistrar *registrar) {
  FlAutologinPlugin * self = FL_AUTOLOGIN_PLUGIN(g_object_new(fl_autologin_plugin_get_type(), nullptr));

  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec)
  codec = fl_standard_method_codec_new();
  self->channel = fl_method_channel_new(
    fl_plugin_registrar_get_messenger(registrar),
    kChannelName,
    FL_METHOD_CODEC(codec)
  );
  fl_method_channel_set_method_call_handler(self->channel, method_call_cb, g_object_ref(self), g_object_unref);
  return self;
}

static void fl_autologin_plugin_init(FlAutologinPlugin * self) {}

void autologin_plugin_register_with_registrar(FlPluginRegistrar *registrar) {
  FlAutologinPlugin * plugin = fl_autologin_plugin_new(registrar);
  g_object_unref(plugin);
}
