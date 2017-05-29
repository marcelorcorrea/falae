package com.marcelorcorrea.falae.storage;

import android.content.Context;
import android.content.SharedPreferences;
import android.support.v4.hardware.fingerprint.FingerprintManagerCompat;

/**
 * Created by bellini on 26/05/2017.
 */

public class SharedPreferencesUtils {

    private static SharedPreferences sharedPreferences;
    private static SharedPreferences.Editor editor;

    public static void storeBooleanPreferences(String key, Boolean value, Context context) {

        sharedPreferences = context.getSharedPreferences("user_pref", Context.MODE_PRIVATE);
        editor = sharedPreferences.edit();
        editor.putBoolean(key, value);
        editor.apply();
    }

    public static boolean getBooleanPreferences(String key, Context context) {

        sharedPreferences = context.getSharedPreferences("user_pref", Context.MODE_PRIVATE);
        Boolean result = sharedPreferences.getBoolean(key, false);
        return result;
    }
}
