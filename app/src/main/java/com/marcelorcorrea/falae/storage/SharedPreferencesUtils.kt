package com.marcelorcorrea.falae.storage

import android.content.Context
import android.content.SharedPreferences

import com.marcelorcorrea.falae.R

/**
 * Created by bellini on 26/05/2017.
 */

object SharedPreferencesUtils {

    private var sharedPreferences: SharedPreferences? = null

    fun storeBoolean(key: String, value: Boolean, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        sharedPreferences?.edit()?.putBoolean(key, value)?.apply()
    }

    fun storeString(key: String, value: String, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        sharedPreferences?.edit()?.putString(key, value)?.apply()
    }

    fun storeInt(key: String, value: Int, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        sharedPreferences?.edit()?.putInt(key, value)?.apply()
    }

    fun getBoolean(key: String, context: Context): Boolean {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences?.getBoolean(key, false)!!
    }

    fun getString(key: String, context: Context): String {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences?.getString(key, "")!!
    }

    fun getInt(key: String, context: Context): Int {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        return sharedPreferences?.getInt(key, 0)!!
    }

    fun remove(key: String, context: Context) {
        sharedPreferences = context.getSharedPreferences(context.getString(R.string.app_name), Context.MODE_PRIVATE)
        sharedPreferences?.edit()?.remove(key)?.apply()
    }
}
