package com.marcelorcorrea.falae

import android.app.Application
import android.content.Intent

import com.marcelorcorrea.falae.service.TextToSpeechService

/**
 * Created by corream on 29/05/2017.
 */

class FalaeApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        startService(Intent(this, TextToSpeechService::class.java))
    }
}
