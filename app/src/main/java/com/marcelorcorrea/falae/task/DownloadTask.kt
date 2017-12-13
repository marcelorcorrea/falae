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
import com.marcelorcorrea.falae.BuildConfig
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.getSSLContext
import com.marcelorcorrea.falae.model.User
import com.marcelorcorrea.falae.storage.FileHandler
import com.marcelorcorrea.falae.toFile
import java.io.File
import java.io.IOException
import java.net.URL
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit
import javax.net.ssl.HttpsURLConnection


/**
 * Created by corream on 15/05/2017.
 */

class DownloadTask(val context: Context, private val onSyncComplete: (user: User) -> Unit) : AsyncTask<User, Void, User>() {
    private val NUMBER_OF_CORES: Int = Runtime.getRuntime().availableProcessors()
    private val executor: ThreadPoolExecutor
    private var pDialog: ProgressDialog? = null

    init {
        executor = ThreadPoolExecutor(
                NUMBER_OF_CORES * 2,
                NUMBER_OF_CORES * 2,
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
                        val imgSrc = "${BuildConfig.BASE_URL}${it.imgSrc}"
                        Log.d("DEBUG", "Downloading item: " + it.name)
                        val uri = download(folder, user.authToken, it.name, imgSrc)
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
                    sslSocketFactory = getSSLContext(context).socketFactory
                }
                connectTimeout = TIME_OUT
                readTimeout = TIME_OUT
                setRequestProperty("Authorization", "Token $token")
                connect()
                inputStream.toFile(file.absolutePath)
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
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            cm.allNetworks
                    .map { cm.getNetworkInfo(it) }
                    .firstOrNull { isConnected(it) } != null
        } else {
            cm.allNetworkInfo.firstOrNull { isConnected(it) } != null
        }
    }

    private fun isConnected(networkInfo: NetworkInfo): Boolean =
            (networkInfo.type == ConnectivityManager.TYPE_WIFI ||
                    networkInfo.type == ConnectivityManager.TYPE_MOBILE) && networkInfo.isConnected

    companion object {

        private val TIME_OUT = 6000
    }
}
