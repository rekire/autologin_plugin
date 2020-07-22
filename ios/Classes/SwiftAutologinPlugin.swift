import Flutter
import UIKit

public class SwiftAutologinPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "autologin_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftAutologinPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isPlatformSupported":
      result(false)
      break
    case "getLoginData":
      checkSafariCredentialsWithCompletion(completion: {username, password in
        result([username, password])
      })
      break
    default:
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
        DispatchQueue.main.async {
          completion(username, password)
        }
      } else {
        DispatchQueue.main.async {
          completion(nil, nil)
        }
      }
    });
  }
}
