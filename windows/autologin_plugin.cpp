#include "include/autologin_plugin/auto_login_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <iostream>

#include <wincred.h>
#include <wchar.h>
#include <tchar.h>

#pragma comment(lib, "Advapi32.lib")
#pragma comment(lib, "Version.lib")


namespace {

typedef struct {
	WORD language;
	WORD code_page;
} LanguageAndCodePage;

class AutologinPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AutologinPlugin();

  virtual ~AutologinPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::basic_string<TCHAR> productName;
};

// static
void AutologinPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "autologin_plugin",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutologinPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutologinPlugin::AutologinPlugin() {
  LPTSTR productName2 = (LPTSTR)_T("FlutterApp");
  DWORD fileInfoSize = 0;
  TCHAR moduleName[MAX_PATH] = { '\0', };

  char* fileInfoData = NULL;

  GetModuleFileName(NULL, moduleName, MAX_PATH);

  fileInfoSize = GetFileVersionInfoSize(moduleName, 0);

  fileInfoData = new char[fileInfoSize];

  if (fileInfoSize && GetFileVersionInfo(moduleName, 0, fileInfoSize, fileInfoData) != 0) {
    UINT dataLength = 0;
    LanguageAndCodePage* translate = NULL;
    BOOL queryResult = VerQueryValue(fileInfoData, L"\\VarFileInfo\\Translation", (LPVOID*)&translate, &dataLength);

    if (queryResult && translate && dataLength) {
        wchar_t productNameBlock[MAX_PATH];
        _snwprintf_s(productNameBlock, MAX_PATH, MAX_PATH, L"\\StringFileInfo\\%04x%04x\\ProductName", translate->language, translate->code_page);
      queryResult = VerQueryValue(fileInfoData, productNameBlock, (LPVOID*)&productName2, &dataLength);
      if (!queryResult || !productName2 || !dataLength) {
          productName2 = (LPTSTR)_T("FlutterApp");
        }
    }
  }

  productName = std::basic_string<TCHAR>(productName2);
  delete[] fileInfoData;
}

AutologinPlugin::~AutologinPlugin() {}

std::optional<std::string> getStringArg(
      const std::string &param,
      const flutter::EncodableMap *args) {
  auto p = args->find(param);
  if (p == args->end())
    return std::nullopt;
  return std::get<std::string>(p->second);
}

void AutologinPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("isPlatformSupported") == 0) {
    //MessageBox(NULL, getProductName().c_str(), NULL, 0);
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name().compare("getLoginData") == 0) {

    PCREDENTIALW pcred;
    BOOL ok = ::CredRead((LPTSTR)(productName.c_str()), CRED_TYPE_GENERIC, 0, &pcred);
    wprintf (L"CredRead() - errno %d\n", ok ? 0 : ::GetLastError());

    if(!ok) {
      result->Error("Read Error", "Cannot read data...");
      return;
    }

    //wchar_t hint[MAX_PATH];
    //_snwprintf_s(hint, MAX_PATH, MAX_PATH, L"User: %s; Password: %s", pcred->UserName, (LPTSTR)pcred->CredentialBlob);
    //MessageBox(NULL, hint, NULL, 0);

    flutter::EncodableList list;

    int size = WideCharToMultiByte(CP_UTF8, 0, pcred->UserName, -1, NULL, 0, NULL, NULL);
    std::string username;
    username.reserve(size);
    WideCharToMultiByte(CP_UTF8, 0, pcred->UserName, -1, &username[0], size, NULL, NULL);

    size = WideCharToMultiByte(CP_UTF8, 0, (LPTSTR)pcred->CredentialBlob, -1, NULL, 0, NULL, NULL);
    std::string password;
    password.reserve(size);
    WideCharToMultiByte(CP_UTF8, 0, (LPTSTR)pcred->CredentialBlob, -1, &password[0], size, NULL, NULL);

    list.push_back(flutter::EncodableValue(username.c_str()));
    list.push_back(flutter::EncodableValue(password.c_str()));

    result->Success(flutter::EncodableValue(list));
    // Memory allocated by CredRead() must be freed!
    ::CredFree (pcred);
  } else if (method_call.method_name().compare("saveLoginData") == 0) {
    const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());

    if (!args) {
      result->Error("Invalid arguments", "Invalid argument type.");
      return;
    }

    auto argUser = getStringArg("username", args);
    wchar_t* username;
    //TODO convert to wstring
    //std::wstring username;
    //username.reserve(size);
    if (argUser.has_value()) {
      int wchars_num = MultiByteToWideChar(CP_UTF8, 0, argUser.value().c_str(), -1, NULL, 0);
      username = new wchar_t[wchars_num];
      MultiByteToWideChar(CP_UTF8, 0, argUser.value().c_str(), -1, username, wchars_num);
    } else {
      result->Error("Missing arguments", "Required argument username is missing.");
      return;
    }

    auto argPass = getStringArg("password", args);
    wchar_t* password;
    int passwordLength = 0;
    if (argPass.has_value()) {
      passwordLength = MultiByteToWideChar(CP_UTF8, 0, argPass.value().c_str(), -1, NULL, 0);
      password = new wchar_t[passwordLength];
      MultiByteToWideChar(CP_UTF8, 0, argPass.value().c_str(), -1, password, passwordLength);
    } else {
      result->Error("Missing arguments", "Required argument password is missing.");
      delete[] username;
      return;
    }

    CREDENTIALW cred = {0};
    cred.Type = CRED_TYPE_GENERIC;
    cred.TargetName = (LPTSTR)(productName.c_str());
    cred.CredentialBlobSize = passwordLength * sizeof(TCHAR); // Works, but I'm not sure about it...
    cred.CredentialBlob = (LPBYTE)password;
    cred.Persist = CRED_PERSIST_LOCAL_MACHINE;
    cred.UserName = username;

    BOOL ok = ::CredWriteW (&cred, 0);
    //wprintf (L"CredWrite() - errno %d\n", ok ? 0 : ::GetLastError());

    delete[] username;
    delete[] password;

    result->Success(flutter::EncodableValue(ok));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void AutoLoginPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
  AutologinPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}