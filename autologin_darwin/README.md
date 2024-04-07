The iOS and MacOS implementation
of [`autologin`](https://pub.dev/packages/autologin).

# Usage

This package is [endorsed][endorsed_link], which means you can simply use
`autologin` normally. This package will be automatically included in your app
when you do, so you do not need to add it to your pubspec.yaml.

However, if you import this package to use any of its APIs directly, you should
add it to your pubspec.yaml as usual.

# Installation

For storing credentials the
[Shared Web Credentials][shared_web_credentials] are used. In order
to make this working you need to setup the [Associated Domains
Entitlement][associated-domains].
The main documentation can be found on the
[Apple Developer site][supporting-associated-domains]. At least the
`apple-app-site-association` file must be reachable at
`https://<your-domain>/.well-known/apple-app-site-association`
and must contain something like:

```json
{
  "webcredentials": {
    "apps": [
      "<your-team-id>.<your-bundle-id>"
    ]
  }
}
```

Your team id can be found e.g. in `ios/Runner.xcodeproj/project.pbxproj` look
for the key `DEVELOPMENT_TEAM`, the bundle id is there too look for
`PRODUCT_BUNDLE_IDENTIFIER`. Apple is caching that requests to the file above
with their CDN, but you can check the cached value here:
`https://app-site-association.cdn-apple.com/a/v1/<your-domain>`

If you have not setup your app check
https://developer.apple.com/account/resources/identifiers/list

In order to use the zero touch login on iOS and MacOS you need to add the iCloud
capability and configure [iCloud Key-Value Storage][kvstore]
in your Xcode project. Here is a step per step guide:

1. Open your Xcode project.
2. Select your project in the Project Navigator to open the project settings.
3. Select your target under "Targets."
4. Go to the "Signing & Capabilities" tab.
5. Click the "+ Capability" button.
6. Scroll down and select "iCloud."
7. In the iCloud section, enable the "Key-Value storage" checkbox.

[endorsed_link]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[shared_web_credentials]: https://developer.apple.com/documentation/security/shared_web_credentials
[associated-domains]: https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains
[supporting-associated-domains]: https://developer.apple.com/documentation/xcode/supporting-associated-domains
[kvstore]: https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_ubiquity-kvstore-identifier
