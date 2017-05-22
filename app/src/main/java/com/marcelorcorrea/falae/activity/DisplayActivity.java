package com.marcelorcorrea.falae.activity;

import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.fragment.PageFragment;
import com.marcelorcorrea.falae.fragment.ViewPagerItemFragment;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

import java.util.Locale;

public class DisplayActivity extends AppCompatActivity implements PageFragment.OnFragmentInteractionListener, ViewPagerItemFragment.OnFragmentInteractionListener {

    public static final String SPREADSHEET = "SpreadSheet";

    private SpreadSheet currentSpreadSheet;
    private TextToSpeech textToSpeech;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display);

        currentSpreadSheet = getIntent().getParcelableExtra(SPREADSHEET);
        if (currentSpreadSheet != null) {
            openPage(currentSpreadSheet.getInitialPage());
        }

        textToSpeech = new TextToSpeech(this, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status != TextToSpeech.ERROR) {
                    textToSpeech.setLanguage(new Locale("pt", "BR"));
                }
            }
        }, "com.google.android.tts");
    }

    @Override
    public void openPage(String linkTo) {
        Page page = getPage(linkTo);
        Fragment fragment = PageFragment.newInstance(page);
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager
                .beginTransaction()
                .setCustomAnimations(R.anim.enter_from_right, R.anim.exit_to_left,
                        R.anim.enter_from_left, R.anim.exit_to_right)
                .replace(R.id.page_container, fragment);
        if (!currentSpreadSheet.getInitialPage().equals(linkTo)) {
            fragmentTransaction.addToBackStack(null);
        } else if (fragmentManager.getBackStackEntryCount() > 0) {
            fragmentManager.popBackStackImmediate();
        }
        fragmentTransaction.commit();
        fragmentManager.executePendingTransactions();
    }

    public Page getPage(String name) {
        for (Page page : currentSpreadSheet.getPages()) {
            if (page.getName().equals(name)) {
                return page;
            }
        }
        return null;
    }

    @Override
    public void speak(String msg) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            textToSpeech.speak(msg, TextToSpeech.QUEUE_FLUSH, null, null);
        } else {
            textToSpeech.speak(msg, TextToSpeech.QUEUE_FLUSH, null);
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.enter_from_left, R.anim.exit_to_right);
    }

    @Override
    protected void onDestroy() {
        textToSpeech.shutdown();
        super.onDestroy();
    }
}
