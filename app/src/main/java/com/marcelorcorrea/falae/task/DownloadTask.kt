package com.marcelorcorrea.falae.task

import android.app.ProgressDialog
import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.ContextWrapper
import android.graphics.Bitmap
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.net.Uri
import android.os.AsyncTask
import android.os.Build
import android.util.Log
import android.widget.ImageView
import android.widget.Toast
import com.android.volley.toolbox.ImageRequest
import com.marcelorcorrea.falae.BuildConfig
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.VolleyRequest
import com.marcelorcorrea.falae.model.User
import com.marcelorcorrea.falae.storage.FileHandler
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit


/**
 * Created by corream on 15/05/2017.
 */

class DownloadTask(val context: Context, private val onSyncComplete: (user: User) -> Unit) : AsyncTask<User, Void, User>() {
    private val executor: ThreadPoolExecutor
    private val numberOfCores: Int = Runtime.getRuntime().availableProcessors()
    private var pDialog: ProgressDialog? = null

    init {
        executor = ThreadPoolExecutor(
                numberOfCores * 2,
                numberOfCores * 2,
                60L,
                TimeUnit.SECONDS,
                LinkedBlockingQueue()
        )
    }

    override fun onPreExecute() {
        try {
            if (pDialog != null) {
                pDialog = null
            }
            pDialog = ProgressDialog(context)
            pDialog!!.setMessage(context.getString(R.string.synchronize_message))
            pDialog!!.isIndeterminate = false
            pDialog!!.setCancelable(false)
            pDialog!!.show()
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    override fun doInBackground(vararg params: User): User? {
        if (!hasNetworkConnection()) {
            return null
        }
        val user = params[0]
        println(user)
        val folder = FileHandler.createUserFolder(context, user.email)
        user.spreadsheets
                .flatMap { it.pages }
                .flatMap { it.items }
                .forEach {
                    executor.execute {
                        Log.d("DEBUG", "Downloading item: " + it.name)
//                        val uri = download(folder, user.authToken, it.name, it.imgSrc)
//                        it.imgSrc = uri
                        val imgSrc = "${BuildConfig.BASE_URL}${it.imgSrc}"
                        println(imgSrc)
                        val imageRequest = object : ImageRequest(imgSrc,
                                { bitmap ->
                                    val file = FileHandler.createImg(folder, it.name, imgSrc)
                                    FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.JPEG, 100, it) }
                                    it.imgSrc = Uri.parse(file.absolutePath).toString()
                                }, 0, 0, ImageView.ScaleType.CENTER_CROP, Bitmap.Config.RGB_565,
                                { error ->
                                    error.printStackTrace()
                                }) {
                            override fun getHeaders(): MutableMap<String, String> {
                                return mutableMapOf("Authorization" to "Token ${user.authToken}")
                            }
                        }
                        VolleyRequest.getInstance(context).addToRequestQueue(imageRequest)
                    }
                }
        executor.shutdown()
        try {
            executor.awaitTermination(java.lang.Long.MAX_VALUE, TimeUnit.NANOSECONDS)
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
        return user
    }

//    private fun download(folder: File, token: String, name: String, imgSrc: String): String {
//        val file = FileHandler.createImg(folder, name, imgSrc)
//        val url = URL(imgSrc)
//        try {
//            with(url.openConnection()) {
//                if (this is HttpsURLConnection) {
//                    sslSocketFactory = getSSLContext()?.socketFactory
//                }
//                connectTimeout = TIME_OUT
//                readTimeout = TIME_OUT
//                doOutput = true
//                setRequestProperty("Authorization", "Token $token")
//                connect()
//                url.openStream().toFile(file.absolutePath)
//            }
//        } catch (ex: IOException) {
//            ex.printStackTrace()
//        }
//
//        return Uri.fromFile(file).toString()
//    }

    override fun onPostExecute(user: User?) {
        if (user != null) {
            onSyncComplete(user)
        } else {
            Toast.makeText(context, context.getString(R.string.download_failed), Toast.LENGTH_LONG).show()
        }
        if (pDialog != null && pDialog!!.isShowing) {
            pDialog!!.dismiss()
        }
    }

    private fun hasNetworkConnection(): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val allNetworks = cm.allNetworks
            allNetworks
                    .map { cm.getNetworkInfo(it) }
                    .filter { isConnected(it) }
                    .forEach { return true }
        } else {
            val netInfo = cm.allNetworkInfo
            netInfo
                    .filter { isConnected(it) }
                    .forEach { return true }
        }
        return false
    }

    private fun isConnected(networkInfo: NetworkInfo): Boolean =
            (networkInfo.type == ConnectivityManager.TYPE_WIFI || networkInfo.type == ConnectivityManager.TYPE_MOBILE) && networkInfo.isConnected

    // Custom method to save a bitmap into internal storage
    fun saveImageToInternalStorage(bitmap: Bitmap): Uri {
        val wrapper = ContextWrapper(context)

        var file = wrapper.getDir("Images", MODE_PRIVATE)
        // Create a file to save the image
        file = File(file, "UniqueFileName" + ".jpg")

        // If the output file exists, it can be replaced or appended to it
        val stream = FileOutputStream(file)
        // Compress the bitmap
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        // Flushes the stream
        stream.flush()
        // Closes the stream
        stream.close()

        // Parse the gallery image url to uri
        return Uri.parse(file.absolutePath)
    }

//    private fun getSSLContext(): SSLContext? {
//        // Load CAs from an InputStream
//        // (could be from a resource or ByteArrayInputStream or ...)
//        val cf = CertificateFactory.getInstance("X.509")
//        var ca: Certificate? = null
//        context.resources.openRawResource(R.raw.certificate).use { caInput ->
//            ca = cf.generateCertificate(caInput)
//            //                System.out.println("ca=" + ((X509Certificate) ca).getSubjectDN());
//        }
//
//        // Create a KeyStore containing our trusted CAs
//        val keyStoreType = KeyStore.getDefaultType()
//        val keyStore = KeyStore.getInstance(keyStoreType)
//        keyStore.load(null, null)
//        keyStore.setCertificateEntry("ca", ca)
//
//        // Create a TrustManager that trusts the CAs in our KeyStore
//        val tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm()
//        val tmf = TrustManagerFactory.getInstance(tmfAlgorithm)
//        tmf.init(keyStore)
//
//        val hostnameVerifier = HostnameVerifier { hostname, session ->
//            Log.e("CipherUsed", session.cipherSuite)
//            println(hostname)
//            hostname.compareTo("192.168.1.10") == 0 //The Hostname of your server
//            true
//        }
//        HttpsURLConnection.setDefaultHostnameVerifier(hostnameVerifier)
//
//        // Create an SSLContext that uses our TrustManager
//        val context = SSLContext.getInstance("TLS")
//        context.init(null, tmf.trustManagers, null)
//        return context
//    }

    companion object {

        private val TIME_OUT = 6000
    }
}
