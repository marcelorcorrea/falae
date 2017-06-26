package com.marcelorcorrea.falae.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.widget.Toast;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.fragment.PageFragment;
import com.marcelorcorrea.falae.fragment.ViewPagerItemFragment;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.service.TextToSpeechService;

public class DisplayActivity extends AppCompatActivity implements PageFragment.OnFragmentInteractionListener, ViewPagerItemFragment.OnFragmentInteractionListener {

    public static final String SPREADSHEET = "SpreadSheet";

    private SpreadSheet currentSpreadSheet;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_display);

        currentSpreadSheet = getIntent().getParcelableExtra(SPREADSHEET);
        if (currentSpreadSheet != null) {
            openPage(currentSpreadSheet.getInitialPage());
        }
    }

    @Override
    public void openPage(String linkTo) {
        Page page = getPage(linkTo);
        if (page != null) {
            Fragment fragment = PageFragment.newInstance(page);
            FragmentManager fragmentManager = getSupportFragmentManager();
            FragmentTransaction fragmentTransaction = fragmentManager
                    .beginTransaction()
                    .setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out,
                            android.R.anim.fade_in, android.R.anim.fade_out)
                    .replace(R.id.page_container, fragment);
            if (!currentSpreadSheet.getInitialPage().equals(linkTo)) {
                fragmentTransaction.addToBackStack(null);
            } else if (fragmentManager.getBackStackEntryCount() > 0) {
                fragmentManager.popBackStackImmediate();
            }
            fragmentTransaction.commit();
            fragmentManager.executePendingTransactions();
        } else {
            Toast.makeText(this, getString(R.string.page_not_found), Toast.LENGTH_SHORT).show();
        }
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
        Intent intent = new Intent(this, TextToSpeechService.class);
        intent.putExtra(TextToSpeechService.TEXT_TO_SPEECH_MESSAGE, msg);
        startService(intent);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(R.anim.enter_from_left, R.anim.exit_to_right);
    }
}
