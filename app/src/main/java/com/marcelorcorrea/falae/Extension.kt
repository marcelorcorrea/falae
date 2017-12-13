package com.marcelorcorrea.falae

import android.content.Context
import android.content.res.Resources
import com.google.gson.Gson
import com.marcelorcorrea.falae.model.User
import java.io.File
import java.io.InputStream
import java.nio.charset.Charset
import java.security.KeyStore
import java.security.cert.Certificate
import java.security.cert.CertificateFactory
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory

fun InputStream.toFile(path: String): File {
    val file = File(path)
    use { input ->
        file.outputStream().use { input.copyTo(it) }
    }
    return file
}

fun Resources.loadUser(name: String): User {
    val asset = assets.open(name)
    return Gson().fromJson(asset.readText(), User::class.java)
}

fun InputStream.readText(charset: Charset = Charsets.UTF_8): String =
        bufferedReader(charset).use { it.readText() }

fun getSSLContext(context: Context): SSLContext {
    // Load CAs from an InputStream
    // (could be from a resource or ByteArrayInputStream or ...)
    val cf = CertificateFactory.getInstance("X.509")
    val ca: Certificate = context.resources.openRawResource(R.raw.certificate).use { caInput ->
        cf.generateCertificate(caInput)
    }

    // Create a KeyStore containing our trusted CAs
    val keyStore = KeyStore.getDefaultType().let { keyStoreType ->
        KeyStore.getInstance(keyStoreType).apply {
            load(null, null);
            setCertificateEntry("ca", ca)
        }
    }

    // Create a TrustManager that trusts the CAs in our KeyStore
    val tmf = TrustManagerFactory.getDefaultAlgorithm().let {
        TrustManagerFactory.getInstance(it).apply {
            init(keyStore)
        }
    }

    val hostnameVerifier = HostnameVerifier { hostname, _ ->
        hostname.compareTo("187.86.153.89") == 0
    }
    HttpsURLConnection.setDefaultHostnameVerifier(hostnameVerifier)

    // Create an SSLContext that uses our TrustManager
    return SSLContext.getInstance("TLS").apply { init(null, tmf.trustManagers, null) }
}