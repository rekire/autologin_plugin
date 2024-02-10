import Foundation
import os
import AuthenticationServices

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

public class AutologinPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Workaround for https://github.com/flutter/flutter/issues/118103.
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        let channel = FlutterMethodChannel(
            name: "autologin_darwin",
            binaryMessenger: messenger)
        let instance = AutologinPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestCredentials":
            SecRequestSharedWebCredential(nil, nil) { (credentials, error) in
            if let error = error {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Could not fetch credentials from keychain: \(error)",
                                    details: nil))
            } else if let credentials = credentials as? [[String: Any]] {
                for credential in credentials {
                    if let account = credential[kSecAttrAccount as String] as? String,
                       let passwordData = credential[kSecSharedPassword as String] as? Data,
                       let password = String(data: passwordData, encoding: .utf8) {
                        let jsonCredentials = ["username": account, "password": password]
                        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonCredentials, options: []),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            result(jsonString)
                        }
                    }
                }
            }
        }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
