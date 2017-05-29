package com.marcelorcorrea.falae.service;

import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.speech.tts.TextToSpeech;

import java.util.Locale;

public class TextToSpeechService extends Service implements TextToSpeech.OnInitListener {

    private TextToSpeech mTextToSpeech;
    public static final String TEXT_TO_SPEECH_MESSAGE = "TextToSpeechMessage";

    @Override
    public IBinder onBind(Intent arg0) {
        return null;
    }

    @Override
    public void onCreate() {
        mTextToSpeech = new TextToSpeech(this, this, "com.google.android.tts");
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String message = intent.getStringExtra(TEXT_TO_SPEECH_MESSAGE);
            if (message != null) {
                speak(message);
            }
        }
        return START_STICKY;
    }

    private void speak(String msg) {
        if (mTextToSpeech != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                mTextToSpeech.speak(msg, TextToSpeech.QUEUE_FLUSH, null, null);
            } else {
                mTextToSpeech.speak(msg, TextToSpeech.QUEUE_FLUSH, null);
            }
        }
    }

    @Override
    public void onDestroy() {
        if (mTextToSpeech != null) {
            mTextToSpeech.stop();
            mTextToSpeech.shutdown();
        }
        super.onDestroy();
    }

    @Override
    public void onInit(int status) {
        if (status == TextToSpeech.SUCCESS) {
            Locale currentLocation = Locale.getDefault();
            if (currentLocation == null) {
                currentLocation = new Locale("pt", "BR");
            }
            mTextToSpeech.setLanguage(currentLocation);
        }
    }

    public void onTaskRemoved(Intent rootIntent) {
        stopSelf();
    }
}