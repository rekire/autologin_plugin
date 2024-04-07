The Android implementation of [`autologin`](https://pub.dev/packages/autologin].

On Android [CredentialManager] is used. The documentation is not very clear,
but it seems that with the PlayServices devices back to Android 4.4 are
supported. There is currently no documentation how or if it works on non Google
Play certificated devices.

# Usage
This package is [endorsed][endorsed_link], which means you can simply use
`autologin` normally. This package will be automatically included in your app
when you do, so you do not need to add it to your pubspec.yaml.

However, if you import this package to use any of its APIs directly, you should
add it to your pubspec.yaml as usual.

# Installation
## Change your app to use `FlutterFragmentActivity`
The Android implementation uses the [CredentialManager] API to query the
credentials. This API requires native asynchronous code. This code is written in
[Kotlin] and uses [Coroutines]. Since the CredentialManager starts a System
Activity the [Activity lifecycle] needs to be maintained, this is managed with
the [Android Jetpack]'s [`Lifecycle`][lifecycle-api] API.

The simplest way to add to your MainActivity the
[`LiveCycleOwner` interface][LifecycleOwner] is to change the
base class of your MainActivity to
[`FlutterFragmentActivity`][FlutterFragmentActivity].
If you MainActivity is empty you can directly reference the base class in your
[AndroidManifest], then you can **delete your MainActivity** entirely. In that
case you can simply replace in your AndroidManifest (the default path is
`android/app/main/src/AndroidManifest.xml`) the line:
`android:name=".MainActivity"` by
`android:name="io.flutter.embedding.android.FlutterFragmentActivity"`.

## Important notes on digital asset links
Digital asset links is a way to link your app with a website also called
[App Links]. In order to provide a full example, the example app needs to be
signed correctly. Right now the signing key is not checked in, but might be the
CI will get the ability to sign the example app in the future so that you can
test it by your own.

For the demo you need to publish a `.well-known/assetlinks.json` which is
mirrored in `example/web/.well-known/assetlinks.json`. However since this is
published on github.io the folder will be visible at
`https://rekire.github.io/autologin_plugin/.well-known/assetlinks.json` instead
of `https://rekire.github.io/.well-known/assetlinks.json`, therefore I uploaded
that file in a second repository
[rekire/rekire.github.io](https://github.com/rekire/rekire.github.io) where the
latest version is actually hosted. In order to publish "dot" directories I had
also to define a [`_config.yaml`][config-yaml].

If you want to test your own setup use the
[Statement List Generator and Tester][asset-links-generator].

As simple check if the linking works fine check [this link][test-deeplink], if
that opens in chrome the example app without an intent chooser then this works.


[endorsed_link]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[CredentialManager]: https://developer.android.com/reference/kotlin/androidx/credentials/CredentialManager
[AndroidManifest]: https://developer.android.com/guide/topics/manifest/manifest-intro
[App Links]: https://developer.android.com/training/app-links/index.html
[Kotlin]: https://kotlinlang.org
[Coroutines]: https://kotlinlang.org/docs/coroutines-guide.html
[Android Jetpack]: https://developer.android.com/jetpack
[lifecycle-api]: https://developer.android.com/reference/androidx/lifecycle/Lifecycle
[LifecycleOwner]: https://developer.android.com/reference/androidx/lifecycle/LifecycleOwner
[FlutterFragmentActivity]: https://api.flutter.dev/javadoc/io/flutter/embedding/android/FlutterFragmentActivity.html
[config-yaml]: https://github.com/rekire/rekire.github.io/blob/main/_config.yaml
[asset-links-generator]: https://developers.google.com/digital-asset-links/tools/generator
[test-deeplink]: https://rekire.github.io/autologin_plugin/demo
