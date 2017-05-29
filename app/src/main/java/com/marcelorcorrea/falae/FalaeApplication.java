package com.marcelorcorrea.falae;

import android.app.Application;
import android.content.Intent;

import com.marcelorcorrea.falae.service.TextToSpeechService;

/**
 * Created by corream on 29/05/2017.
 */

public class FalaeApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        startService(new Intent(this, TextToSpeechService.class));
    }
}
