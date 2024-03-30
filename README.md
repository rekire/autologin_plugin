# Autologin plugin for Flutter

Experimental autologin plugin for Flutter. This library should log in the user if the login data are already known by
the operating system of the device e.g. on the first run.

You can check it yourself on the [github page](https://rekire.github.io/autologin_plugin/index.html) in supported
browsers (basically all expect Firefox and Safari).

## Supported platforms
### Android
On Android [CredentialManager] is used. The documentation is not very clear, but it seems that with the PlayServices
devices back to Android 4.4 are supported. There is currently no documentation how or if it works on non Google Play
certificated devices.

#### Change your app to use `FlutterFragmentActivity`
The Android implementation uses the [CredentialManager] API to query the credentials. This API requires native
asynchronous code. This code is written in [Kotlin](https://kotlinlang.org) and uses
[Coroutines](https://kotlinlang.org/docs/coroutines-guide.html). Since the CredentialManager starts a System Activity
the [Activity lifecycle](https://developer.android.com/guide/components/activities/activity-lifecycle) needs to be
maintained, this is managed with the [Android Jetpack](https://developer.android.com/jetpack)'s
[`Lifecycle`](https://developer.android.com/reference/androidx/lifecycle/Lifecycle) API.

The simplest way to add to your MainActivity the
[`LiveCycleOwner` interface](https://developer.android.com/reference/androidx/lifecycle/LifecycleOwner) is to change the
base class of your MainActivity to
[`FlutterFragmentActivity`](https://api.flutter.dev/javadoc/io/flutter/embedding/android/FlutterFragmentActivity.html).
If you MainActivity is empty you can directly reference the base class in your [AndroidManifest], then you can **delete
your MainActivity** entirely. In that case you can simply replace in your AndroidManifest (the default path is
`android/app/main/src/AndroidManifest.xml`) the line: `android:name=".MainActivity"` by
`android:name="io.flutter.embedding.android.FlutterFragmentActivity"`. 

#### Important notes on digital asset links
Digital asset links is a way to link your app with a website also called [App Links]. In order to provide a full
example, the example app needs to be signed correctly. Right now the signing key is not checked in, but might be the CI
will get the ability to sign the example app in the future so that you can test it by your own.

For the demo you need to publish a `.well-known/assetlinks.json` which is mirrored in
`example/web/.well-known/assetlinks.json`. However since this is published on github.io the folder will be visible at
`https://rekire.github.io/autologin_plugin/.well-known/assetlinks.json` instead of
`https://rekire.github.io/.well-known/assetlinks.json`, therefore I uploaded that file in a second repository
[rekire/rekire.github.io](https://github.com/rekire/rekire.github.io) where the latest version is actually hosted. In
order to publish "dot" directories I had also to define a
[`_config.yaml`](https://github.com/rekire/rekire.github.io/blob/main/_config.yaml).

If you want to test your own setup use the
[Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator).

As simple check if the linking works fine check [this link](https://rekire.github.io/autologin_plugin/demo), if that
opens in chrome the example app without an intent chooser then this works.

### iOS and MacOS
For storing credentials the
[Shared Web Credentials](https://developer.apple.com/documentation/security/shared_web_credentials) are used. In order
to make this working you need to setup the [Associated Domains
Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains).
The main documentation can be found on the
[Apple Developer site](https://developer.apple.com/documentation/xcode/supporting-associated-domains). At least the 
`apple-app-site-association` file must be reachable at `https://<your-domain>/.well-known/apple-app-site-association`
and must contain something like:
```json
{"webcredentials":{"apps":["<your-team-id>.<your-bundle-id>"]}}
```
Your team id can be found e.g. in `ios/Runner.xcodeproj/project.pbxproj` look for the key `DEVELOPMENT_TEAM`, the bundle
id is there too look for `PRODUCT_BUNDLE_IDENTIFIER`. Apple is caching that requests to the file above with their CDN,
but you can check the cached value here: `https://app-site-association.cdn-apple.com/a/v1/<your-domain>`
If you have not setup your app check https://developer.apple.com/account/resources/identifiers/list

In order to use the zero touch login on iOS and MacOS you need to add the iCloud capability and configure [iCloud
Key-Value Storage](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_ubiquity-kvstore-identifier)
in your Xcode project. Here is a step per step guide:

1. Open your Xcode project.
2. Select your project in the Project Navigator to open the project settings. 
3. Select your target under "Targets." 
4. Go to the "Signing & Capabilities" tab. 
5. Click the "+ Capability" button. 
6. Scroll down and select "iCloud." 
7. In the iCloud section, enable the "Key-Value storage" checkbox.

### Web
On Web [Credential Management API](https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API), but
be aware that just Chrome, Edge and Opera support this feature
([Source](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential#browser_compatibility)).

Autologin is not supported yet, since I am not aware of any API for that.

### Linux
On Linux the [D-Bus](https://freedesktop.org/wiki/Software/dbus/) is used to save an query the password of your app. The
native code uses for that like the [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) plugin
[libsecret](https://gnome.pages.gitlab.gnome.org/libsecret/). Based on a
[Blog entry](https://avaldes.co/2020/01/28/secret-service-keepassxc.html) you can store your secrets also directly in
[KeepassXC](https://keepassxc.org/), however I was unable to test this integration.

Autologin is not supported yet, since I am not aware of any API for that. 

## TODO

- [ ] Add documentation how to use it. In the mean time you can use the [example app](./autologin/example)
- [ ] Upload the final version to pub.dev
- [ ] Windows Support #8
- [ ] Build and sign the Android sample app and publish it as artifact (ideally via GitHub Action)

[CredentialManager]: https://developer.android.com/reference/kotlin/androidx/credentials/CredentialManager
[AndroidManifest]: https://developer.android.com/guide/topics/manifest/manifest-intro
[App Links]: https://developer.android.com/training/app-links/index.html
