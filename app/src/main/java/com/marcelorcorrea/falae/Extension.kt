package com.marcelorcorrea.falae

import android.content.res.Resources
import com.google.gson.Gson
import com.marcelorcorrea.falae.model.User
import java.io.File
import java.io.InputStream
import java.nio.charset.Charset

fun InputStream.toFile(path: String): File {
    val file = File(path)
    use { input ->
        file.outputStream().use { input.copyTo(it) }
    }
    return file
}

fun Resources.loadUser(id: Int): User {
    val raw = openRawResource(id)
    return Gson().fromJson(raw.readText(), User::class.java)
}

fun InputStream.readText(charset: Charset = Charsets.UTF_8): String =
        bufferedReader(charset).use { it.readText() }