package eu.rekisoft.flutter.autologin.models

data class Compatibilities(
 val isPlatformSupported: Boolean = true,
 val canSafeSecrets: Boolean = true,
 val canEncryptSecrets: Boolean = true,
 val hasZeroTouchSupport: Boolean = false,
) : JsonSerializable
