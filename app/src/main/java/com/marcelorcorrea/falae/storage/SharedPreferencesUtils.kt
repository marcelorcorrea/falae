package com.marcelorcorrea.falae.storage

import android.content.Context
import android.content.SharedPreferences

import com.marcelorcorrea.falae.R

/**
 * Created by bellini on 26/05/2017.
 */

object SharedPreferencesUtils {

    private var sharedPreferences: SharedPreferences? = null
    private var editor: SharedPreferences.Editor? = null

    fun storeBooleanPreferences(key: String, value: Boolean?, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor!!.putBoolean(key, value!!)
        editor!!.apply()
    }

    fun storeStringPreferences(key: String, value: String, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor!!.putString(key, value)
        editor!!.apply()
    }

    fun storeIntPreferences(key: String, value: Int, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        editor = sharedPreferences!!.edit()
        editor!!.putInt(key, value)
        editor!!.apply()
    }

    fun getBooleanPreferences(key: String, context: Context): Boolean {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences!!.getBoolean(key, false)
    }

    fun getStringPreferences(key: String, context: Context): String {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences!!.getString(key, "")
    }

    fun getIntPreferences(key: String, context: Context): Int {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences!!.getInt(key, 0)
    }
}
