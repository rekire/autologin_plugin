package eu.rekisoft.flutter.autologin.models

data class Compatibilities(
 val isPlatformSupported: Boolean = true,
 val canSafeSecrets: Boolean = true,
 val canEncryptSecrets: Boolean = false,
 val hasZeroTouchSupport: Boolean = false,
 val hasOneClickSupport: Boolean = false,
) : JsonSerializable
