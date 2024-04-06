package eu.rekisoft.flutter.autologin.models

data class Credential(
    val username: String,
    val password: String?,
) {
    fun toMap() = mapOf(
        "username" to username,
        "password" to password,
    )
}
