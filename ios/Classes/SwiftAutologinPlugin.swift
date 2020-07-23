import Flutter
import UIKit
import os

public class SwiftAutologinPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "autologin_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftAutologinPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isPlatformSupported":
      print("isPlatformSupported via print()")
      if #available(iOS 10.0, *) {
        os_log("isPlatformSupported via os_log()")
      }
      result(false)
      break
    case "getLoginData":
      print("getLoginData via print()")
      //os_log("getLoginData via os_log()")
      checkSafariCredentialsWithCompletion(completion: {username, password in
        print("completion \(String(describing: username)) via print()")
        //os_log("completion \(username) via os_log()")
        result([username, password])
      })
      break
    default:
      print("Unsupported method \(call.method) via print()")
      //os_log("Unsupported method \(call.method) via os_log()")
      result(FlutterMethodNotImplemented)
    }
  }

  private func checkSafariCredentialsWithCompletion(completion: @escaping ((_ username: String?, _ password: String?) -> Void)) {
    SecRequestSharedWebCredential(.none, .none, {
        (credentials: CFArray!, error: CFError?) -> Void in

      if let error = error {
        print("error: \(error)")
        completion(nil, nil)
      } else if CFArrayGetCount(credentials) > 0 {
        let unsafeCred = CFArrayGetValueAtIndex(credentials, 0)
        let credential: CFDictionary = unsafeBitCast(unsafeCred, to: CFDictionary.self)
        let dict: Dictionary<String, String> = credential as! Dictionary<String, String>
        let username = dict[kSecAttrAccount as String]
        let password = dict[kSecSharedPassword as String]

        print("CFArrayGetCount \(String(describing: username)) via print()")
        //os_log("CFArrayGetCount \(username) via os_log()")
        DispatchQueue.main.async {
          completion(username, password)
        }
      } else {
        DispatchQueue.main.async {
          print("Nothing found via print()")
          //os_log("Nothing found via os_log()")
          completion(nil, nil)
        }
      }
    });
  }
}
