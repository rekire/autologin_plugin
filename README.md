# Autologin plugin for Flutter

Experimental autologin plugin for Flutter. This library should log in the user if the login data are already known by the operating system of the device e.g. on the first run.

You can check it yourself on the [github page](https://rekire.github.io/autologin_plugin/index.html) in supported browsers.

## Supported platforms
### Android
On Android CredentialManager is used. The documentation is not very clear, but it seems that with the PlayServices devices back to Android 4.4 are supported.
There is currently no documentation how or if it works on non Google Play certificated devices.

On Android your MainActivity must be a [`FlutterFragmentActivity`](https://api.flutter.dev/javadoc/io/flutter/app/FlutterFragmentActivity.html).

#### Change your app to use `FlutterFragmentActivity`
TODO: Explain how to do that. See also the example app. 

#### Important notes on digital asset links
Digital asset links is a way to link your app with a website also called [App Links](https://developer.android.com/training/app-links/index.html).
In order to provide a full example, the example app needs to be signed correctly. Right now the signing key is not checked in, but might be the CI
will get the ability to sign the example app in the future so that you can test it by your own.

For the demo you need to publish a `.well-known/assetlinks.json` which is mirrored in `example/web/.well-known/assetlinks.json`.
However since this is published on github.io the folder will be visible at `https://rekire.github.io/autologin_plugin/.well-known/assetlinks.json`
instead of `https://rekire.github.io/.well-known/assetlinks.json`, therefore I uploaded that file in a second repository
[rekire/rekire.github.io](https://github.com/rekire/rekire.github.io) where the latest version is actually hosted. In order to publish "dot"
directories I had also to define a [`_config.yaml`](https://github.com/rekire/rekire.github.io/blob/main/_config.yaml).

If you want to test your own setup use the [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator).

As simple check if the linking works fine check [this link](https://rekire.github.io/autologin_plugin/demo), if that opens in chrome the example app
without an intent chooser then this works.

### iOS
On iOS [AutoFill](https://developer.apple.com/videos/play/wwdc2018/204/) is used.
### Web
On Web [Credential Management API](https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API), but beware that just Chrome, Edge and Opera support this feature ([Source](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential#browser_compatibility)).

## TODO

- [ ] Add documentation how to use it. In the mean time you can use the [example app](./example)
- [ ] Upload the final version to pub.dev
- [ ] Windows Support #8
- [ ] MacOs Support #11
- [ ] Build and sign the Android sample app and publish it as artifact
