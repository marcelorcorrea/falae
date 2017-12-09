package com.marcelorcorrea.falae.task

import android.app.ProgressDialog
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.net.Uri
import android.os.AsyncTask
import android.os.Build
import android.util.Log
import android.widget.Toast
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.model.User
import com.marcelorcorrea.falae.storage.FileHandler
import com.marcelorcorrea.falae.toFile
import java.io.File
import java.io.IOException
import java.net.URL
import java.security.KeyManagementException
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.NoSuchAlgorithmException
import java.security.cert.Certificate
import java.security.cert.CertificateException
import java.security.cert.CertificateFactory
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManagerFactory


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
        val folder = FileHandler.createUserFolder(context, user.email)
        user.spreadsheets
                .flatMap { it.pages }
                .flatMap { it.items }
                .forEach {
                    executor.execute {
                        Log.d("DEBUG", "Downloading item: " + it.name)
                        val uri = download(folder, user.authToken, it.name, it.imgSrc)
                        it.imgSrc = uri
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

    private fun download(folder: File, token: String, name: String, imgSrc: String): String {
        val file = FileHandler.createImg(folder, name, imgSrc)
        val url = URL(imgSrc)
        try {
            with(url.openConnection()) {
                if (this is HttpsURLConnection) {
                    sslSocketFactory = getSSLContext()?.socketFactory
                }
                connectTimeout = TIME_OUT
                readTimeout = TIME_OUT
                doOutput = true
                setRequestProperty("Authorization", "Token $token")
                connect()
                url.openStream().toFile(file.absolutePath)
            }
        } catch (ex: IOException) {
            ex.printStackTrace()
        }

        return Uri.fromFile(file).toString()
    }

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


    protected fun getSSLContext(): SSLContext? {
        try {
            // Load CAs from an InputStream
            // (could be from a resource or ByteArrayInputStream or ...)
            val cf = CertificateFactory.getInstance("X.509")
            var ca: Certificate? = null
            context.resources.openRawResource(R.raw.certificate).use { caInput ->
                ca = cf.generateCertificate(caInput)
                //                System.out.println("ca=" + ((X509Certificate) ca).getSubjectDN());
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

            // Create an SSLContext that uses our TrustManager
            val context = SSLContext.getInstance("TLS")
            context.init(null, tmf.trustManagers, null)
            return context
        } catch (e: CertificateException) {
            e.printStackTrace()
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: KeyManagementException) {
            e.printStackTrace()
        } catch (e: KeyStoreException) {
            e.printStackTrace()
        }

        return null
    }
    companion object {

        private val TIME_OUT = 6000
    }
}
