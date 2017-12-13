package com.marcelorcorrea.falae.task

import com.android.volley.*
import com.android.volley.toolbox.HttpHeaderParser
import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import org.json.JSONObject
import java.io.UnsupportedEncodingException

/**
 * Created by corream on 06/06/2017.
 */

class GsonRequest<T>(url: String,
                     private val clazz: Class<T>,
                     private val headers: Map<String, String>?,
                     private val jsonRequest: JSONObject,
                     private val listener: Response.Listener<T>,
                     errorListener: Response.ErrorListener) : Request<T>(Request.Method.POST, url, errorListener) {

    private val gson = Gson()

    @Throws(AuthFailureError::class)
    override fun getHeaders(): Map<String, String> = headers ?: super.getHeaders()

    @Throws(AuthFailureError::class)
    override fun getBody(): ByteArray? {
        return try {
            jsonRequest.toString().toByteArray(charset(PROTOCOL_CHARSET))
        } catch (uee: UnsupportedEncodingException) {
            null
        }

    }

    override fun getBodyContentType(): String = PROTOCOL_CONTENT_TYPE

    override fun deliverResponse(response: T) {
        listener.onResponse(response)
    }

    override fun parseNetworkResponse(response: NetworkResponse): Response<T> {
        return try {
            val charSet = HttpHeaderParser.parseCharset(response.headers)
            val json = response.data.toString(charset(charSet))
            Response.success(
                    gson.fromJson(json, clazz),
                    HttpHeaderParser.parseCacheHeaders(response))
        } catch (e: UnsupportedEncodingException) {
            Response.error(ParseError(e))
        } catch (e: JsonSyntaxException) {
            Response.error(ParseError(e))
        }

    }

    companion object {
        private val PROTOCOL_CHARSET = "utf-8"
        private val PROTOCOL_CONTENT_TYPE = String.format("application/json; charset=%s", PROTOCOL_CHARSET)
    }
}
