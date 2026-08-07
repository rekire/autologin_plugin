import Foundation
import os
import AuthenticationServices

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif

public class AutologinPlugin: NSObject, FlutterPlugin {
    static var macosRegistrar: FlutterPluginRegistrar?

    private var activeController: Any?
    private var activeResult: FlutterResult?

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
        macosRegistrar = registrar
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestCredentials":
            if #available(iOS 13.0, macOS 10.15, *) {
                if activeResult != nil {
                    result(FlutterError(code: "ALREADY_ACTIVE",
                                        message: "Another request is already in progress",
                                        details: nil))
                    return
                }
                activeResult = result

                let passwordProvider = ASAuthorizationPasswordProvider()
                let request = passwordProvider.createRequest()
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.presentationContextProvider = self
                authorizationController.delegate = self
                activeController = authorizationController
                authorizationController.performRequests()
            } else {
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
                                    return
                                }
                            }
                            result(nil)
                        } else {
                            result(nil)
                        }
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Argument must be a string", details: nil))
                }
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

@available(iOS 13.0, macOS 10.15, *)
extension AutologinPlugin: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
#if os(iOS)
        let window: UIWindow?
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = windowScene.windows.first(where: { $0.isKeyWindow })
            } else {
                window = UIApplication.shared.keyWindow
            }
        } else {
            window = UIApplication.shared.keyWindow
        }
        return window ?? UIWindow()
#elseif os(macOS)
        return AutologinPlugin.macosRegistrar?.view?.window ?? NSWindow()
#endif
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer {
            activeController = nil
            activeResult = nil
        }
        if let credential = authorization.credential as? ASPasswordCredential {
            let password = credential.password
            let username = credential.user
            activeResult?(["username": username, "password": password])
        } else {
            activeResult?(FlutterError(code: "UNAVAILABLE",
                                      message: "Unknown credential type",
                                      details: nil))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer {
            activeController = nil
            activeResult = nil
        }
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            activeResult?(nil)
            return
        }
        activeResult?(FlutterError(code: "UNAVAILABLE",
                                  message: "Could not fetch credentials from keychain: \(error.localizedDescription)",
                                  details: nil))
    }
}
