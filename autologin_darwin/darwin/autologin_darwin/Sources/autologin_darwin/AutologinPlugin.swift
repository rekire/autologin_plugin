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
            name: "autologin_plugin",
            binaryMessenger: messenger)
        let instance = AutologinPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestCredentials":
            // possible migration: https://developer.apple.com/forums/thread/692844
            if let domain = call.arguments as? String {
                SecRequestSharedWebCredential(domain as CFString, nil) { (credentials, error) in
                    if let error = error {
                        result(FlutterError(code: "UNAVAILABLE",
                                            message: "Could not fetch credentials from keychain: \(error)",
                                            details: nil))
                    } else if let credentials = credentials as? [[String: Any]] {
                        for credential in credentials {
                            if let account = credential[kSecAttrAccount as String] as? String,
                               let password = credential[kSecSharedPassword as String] as? String {
                                result(["username": account, "password": password])
                            }
                        }
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Argument must be a string", details: nil))
            }
        case "saveCredentials":
            guard let arguments = call.arguments as? [String: Any],
                  let username = arguments["username"] as? String,
                  let password = arguments["password"] as? String,
                  let domain = arguments["domain"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
                return
            }

            SecAddSharedWebCredential(domain as CFString, username as CFString, password as CFString) { (error) in
                if let error = error {
                    result(FlutterError(code: "FAILED",
                                        message: "Could not save credentials: \(error)",
                                        details: nil))
                } else {
                    result(true)
                }
            }
        case "requestLoginToken":
            let keyValueStore = NSUbiquitousKeyValueStore.default
            result(keyValueStore.string(forKey: "login-token"))
        case "saveLoginToken":
            if let loginToken = call.arguments as? String {
                let keyValueStore = NSUbiquitousKeyValueStore.default
                keyValueStore.set(loginToken, forKey: "login-token")
                keyValueStore.synchronize()
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Argument must be a string", details: nil))
            }
        case "deleteLoginToken":
            let keyValueStore = NSUbiquitousKeyValueStore.default
            keyValueStore.removeObject(forKey: "login-token")
            keyValueStore.synchronize()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
