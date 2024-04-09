This package helps the user to login quickly. When the user has saved in the
platform specific password manager credentials will be filled out by a simple
confirmation or account chooser depending on the platform. You can also save the
users credentials with a simply API call. On supported platforms those
credentials will be synced on all your devices.

On Android and Apple devices you can also store a login token to sign in
seamlessly without any interaction. So when your user uses your app on a new
device for the first time your user will be already signed in.

<p>
  <img src="https://github.com/rekire/autologin_plugin/blob/main/docs/android-demo.gif?raw=true"
   alt="An animated image of the Android login flow with autologin" height="400"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/rekire/autologin_plugin/blob/main/docs/ios-demo.gif?raw=true"
    alt="An animated image of the iOS login flow with autologin" height="400"/>
</p>

You can check the web example app on the [GitHub page][web-demo] in supported
(Chromium based) browsers.

# Features and compatibilities

You can safe and request Credentials and store and read Login Tokens for
automatic logins without any user interaction.

|                 | [Android] | [iOS] | [MacOS] | [Windows] | [Linux] | [Web] |
|-----------------|-----------|-------|---------|-----------|---------|-------|
| **Credentials** | ✅         | ✅     | ✅*      | ✅**       | ✅       | ✅***  |
| **LoginToken**  | ✅         | ✅     | ✅       |           |         |       |

*) It seems that saving is just supported on iOS  
**) The documentation of the API mentions that a "pro" version is required  
***) Just on chromium based browsers

The technical implementation details can be found in the corresponding package.

## Compatibility checks

If you want to check if the platform you are currently using is supported you
can call `AutologinPlugin.isPlatformSupported`. If you need a full report of all
capabilities you can call `await AutologinPlugin.performCompatibilityChecks()`
this will return the `Compatibilities` with the fields:

- `isPlatformSupported`
- `canSafeSecrets`
- `canEncryptSecrets`
- `hasZeroTouchSupport`
- `hasOneClickSupport`

So you can know if the required feature is usable at your current platform at
runtime. Even if you call the possible unsupported methods of the next API they
should not crash, instead they just do nothing or may return `null`.

## Credentials

Credentials can be saved by using `AutologinPlugin.saveCredentials(...)` and
requested by `AutologinPlugin.requestCredentials()`.

## Login Token

The Login Token can be a refresh token or anything else which you can use to
identify the user. You should validate that this token is still valid before
authenticating the user. Depending on your use case asking for a second factor
would be a good idea.

The Login Token can be requested with `AutologinPlugin.requestLoginToken()` and
saved with `AutologinPlugin.saveLoginToken('yourToken');`.

[web-demo]: https://rekire.github.io/autologin_plugin/
[Android]: https://pub.dev/packages/autologin_android
[iOS]: https://pub.dev/packages/autologin_darwin
[MacOS]: https://pub.dev/packages/autologin_darwin
[Windows]: https://pub.dev/packages/autologin_windows
[Linux]: https://pub.dev/packages/autologin_linux
[Web]: https://pub.dev/packages/autologin_web
