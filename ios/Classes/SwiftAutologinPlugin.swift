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
        result(["hallo", "welt"])
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
