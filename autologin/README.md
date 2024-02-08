# autologin

The autologin public interface

# Compatibility checks

If you want to check if the platform you are currently using is supported you can
call `AutologinPlugin.isPlatformSupported`. If you need a full report of all capabilities you can
call `await AutologinPlugin.performCompatibilityChecks()` this will return the `Compatibilities` with the fields:

- `isPlatformSupported`
- `canSafeSecrets`
- `canEncryptSecrets`
- `hasZeroTouchSupport`
- `hasOneClickSupport`

So you can know if the required feature is usable at your current platform at runtime. Even if you call the possible
unsupported methods of the next API they should not crash, instead they just do nothing or may return `null`.

# Credentials

Credentials can be saved by using `saveCredentials(...)` and requested by `requestCredentials()`.

TODO: Add more details

# License
MIT License
