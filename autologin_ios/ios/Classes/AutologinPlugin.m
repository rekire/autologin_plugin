#import "AutologinPlugin.h"
#if __has_include(<autologin_plugin/autologin_plugin-Swift.h>)
#import <autologin_plugin/autologin_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "autologin_plugin-Swift.h"
#endif

@implementation AutologinPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAutologinPlugin registerWithRegistrar:registrar];
}
@end
