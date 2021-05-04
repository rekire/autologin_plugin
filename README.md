# Autologin plugin for Flutter

Experimental autologin plugin for Flutter. This library should log in the user if the login data are already known by the operating system of the device e.g. on the first run.

You can check it yourself on the [github page](https://rekire.github.io/autologin_plugin/index.html) in supported browsers.

## Supported platforms
### Android
On Android [Smartlock for Passwords](https://developers.google.com/identity/smartlock-passwords/android) is used, so you need the play services.
### iOS
On iOS [AutoFill](https://developer.apple.com/videos/play/wwdc2018/204/) is used.
### Web
On Web [Credential Management API](https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API), but beware that just Chrome, Edge and Opera support this feature ([Source](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential#browser_compatibility)).

## TODO

- [ ] Add documentation how to use it. In the mean time you can use the [example app](./example)
- [ ] Upload the final version to pub.dev
- [ ] Windows Support #8
- [ ] MacOs Support #11
