package com.marcelorcorrea.falae

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import android.util.LruCache
import com.android.volley.Request
import com.android.volley.RequestQueue
import com.android.volley.toolbox.HurlStack
import com.android.volley.toolbox.ImageLoader
import com.android.volley.toolbox.Volley
import java.security.KeyStore
import java.security.cert.Certificate
import java.security.cert.CertificateFactory
import javax.net.ssl.HostnameVerifier
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory

/**
 * Created by corream on 11/12/2017.
 */
class VolleyRequest(context: Context) {
    private var mRequestQueue: RequestQueue? = null
    private var mImageLoader: ImageLoader? = null

    init {
        mRequestQueue = Volley.newRequestQueue(context.applicationContext, HurlStack(null, getSSLContext(context.applicationContext)?.socketFactory))
        mImageLoader = ImageLoader(mRequestQueue,
                object : ImageLoader.ImageCache {
                    private val cache = LruCache<String, Bitmap>(20)

                    override fun getBitmap(url: String): Bitmap {
                        return cache.get(url)
                    }

                    override fun putBitmap(url: String, bitmap: Bitmap) {
                        cache.put(url, bitmap)
                    }
                })
    }

    fun <T> addToRequestQueue(req: Request<T>) {
        mRequestQueue?.add(req)
    }

    private fun getSSLContext(context: Context): SSLContext? {
        // Load CAs from an InputStream
        // (could be from a resource or ByteArrayInputStream or ...)
        val cf = CertificateFactory.getInstance("X.509")
        val ca: Certificate = context.resources.openRawResource(R.raw.certificate).use { caInput ->
            cf.generateCertificate(caInput)
        }

        // Create a KeyStore containing our trusted CAs
        val keyStoreType = KeyStore.getDefaultType()
        val keyStore = KeyStore.getInstance(keyStoreType)
        keyStore.load(null, null)
        keyStore.setCertificateEntry("ca", ca)

        // Create a TrustManager that trusts the CAs in our KeyStore
        val tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm()
        val tmf = TrustManagerFactory.getInstance(tmfAlgorithm)
        tmf.init(keyStore)

        val hostnameVerifier = HostnameVerifier { hostname, session ->
            println("hostname.compareTo(\"187.86.153.89\") == 0 ${hostname.compareTo("187.86.153.89") == 0}")
            hostname.compareTo("187.86.153.89") == 0
        }
        HttpsURLConnection.setDefaultHostnameVerifier(hostnameVerifier)

        // Create an SSLContext that uses our TrustManager
        val sslContext = SSLContext.getInstance("TLS")
        sslContext.init(null, tmf.trustManagers, null)
        return sslContext
    }


    companion object {

        @Volatile private var INSTANCE: VolleyRequest? = null

        fun getInstance(context: Context): VolleyRequest =
                INSTANCE ?: synchronized(this) {
                    INSTANCE ?: buildVolleyRequest(context).also { INSTANCE = it }
                }

        private fun buildVolleyRequest(context: Context) = VolleyRequest(context)
    }
}