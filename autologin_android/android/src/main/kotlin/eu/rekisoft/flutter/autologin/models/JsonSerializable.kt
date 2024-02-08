package eu.rekisoft.flutter.autologin.models

import com.google.gson.Gson

interface JsonSerializable

internal val gson = Gson()

fun JsonSerializable.toJSON(): String = gson.toJson(this)
