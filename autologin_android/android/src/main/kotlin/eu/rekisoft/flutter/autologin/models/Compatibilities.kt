package eu.rekisoft.flutter.autologin.models

data class Compatibilities(
 val isPlatformSupported: Boolean = true,
 val canSafeSecrets: Boolean = true,
 val canEncryptSecrets: Boolean = true,
 val hasZeroTouchSupport: Boolean = false,
) {
    fun toMap() = mapOf(
        "isPlatformSupported" to isPlatformSupported,
        "canSafeSecrets" to canSafeSecrets,
        "canEncryptSecrets" to canEncryptSecrets,
        "hasZeroTouchSupport" to hasZeroTouchSupport,
    )
}
