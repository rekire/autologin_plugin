import Foundation
import os
import AuthenticationServices

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

public class AutologinPlugin: NSObject, FlutterPlugin {
    static var macosRegistrar: FlutterPluginRegistrar?;

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Workaround for https://github.com/flutter/flutter/issues/118103.
#if os(iOS)
        let messenger = registrar.messenger()
#elseif os(macOS)
        let messenger = registrar.messenger
#endif
        let channel = FlutterMethodChannel(
            name: "autologin_plugin",
            binaryMessenger: messenger)
        let instance = AutologinPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        macosRegistrar = registrar;
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestCredentials":
            let passwordProvider = ASAuthorizationPasswordProvider()
            let request = passwordProvider.createRequest()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
#if os(macOS)
            authorizationController.presentationContextProvider = { (controller: ASAuthorizationController) in
              return AutologinPlugin.macosRegistrar!.view!
            } as? ASAuthorizationControllerPresentationContextProviding;
#endif
            authorizationController.delegate = { (controller: ASAuthorizationController, authorization: ASAuthorization) in
                if let credential = authorization.credential as? ASPasswordCredential {
                    let password = credential.password
                    let username = credential.user
                    result(["username": username, "password": password])
                }
                else if let error = authorization.credential as? ASAuthorizationError {
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "Could not fetch credentials from keychain: \(error)",
                                        details: nil))
                }
            } as? ASAuthorizationControllerDelegate
            authorizationController.performRequests()
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
