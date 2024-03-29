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
                                let jsonCredentials = ["username": account, "password": password]
                                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonCredentials, options: []),
                                   let jsonString = String(data: jsonData, encoding: .utf8) {
                                    result(jsonString)
                                }
                            }
                        }
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Argument must be a string", details: nil))
            }
        case "saveCredentials":
            if let args = call.arguments as? String {
                if let jsonData = args.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            let username = json["username"] as! CFString
                            let password = json["password"] as! CFString
                            let domain = json["domain"] as! CFString
                            SecAddSharedWebCredential(domain, username, password) { (error) in
                                if let error = error {
                                    result(FlutterError(code: "FAILED",
                                                        message: "Could not save credentials: \(error)",
                                                        details: nil))
                                } else {
                                    result(true)
                                }
                            }
                        } else {
                            result(FlutterError(code: "INVALID_ARGUMENT", message: "Unable to parse arguments as JSON", details: nil))
                        }
                    } catch {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: error.localizedDescription, details: nil))
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Unable to convert JSON string to data", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Argument must be a string", details: nil))
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
