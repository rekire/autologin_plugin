package eu.rekisoft.flutter.autologin.models

data class Credential(
    val username: String,
    val password: String?,
) : JsonSerializable
