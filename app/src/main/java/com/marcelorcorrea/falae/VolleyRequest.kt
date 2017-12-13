package com.marcelorcorrea.falae

import android.content.Context
import android.graphics.Bitmap
import android.util.LruCache
import com.android.volley.Request
import com.android.volley.RequestQueue
import com.android.volley.toolbox.HurlStack
import com.android.volley.toolbox.ImageLoader
import com.android.volley.toolbox.Volley

/**
 * Created by corream on 11/12/2017.
 */
class VolleyRequest(context: Context) {
    private val mRequestQueue: RequestQueue = Volley.newRequestQueue(context.applicationContext,
            HurlStack(null, getSSLContext(context.applicationContext).socketFactory))
    private val mImageLoader: ImageLoader

    init {
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
        mRequestQueue.add(req)
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