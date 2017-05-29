package com.marcelorcorrea.falae.activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.speech.tts.TextToSpeech;
import android.support.design.widget.NavigationView;
import android.support.v4.app.Fragment;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.database.UserDbHelper;
import com.marcelorcorrea.falae.fragment.AddUserFragment;
import com.marcelorcorrea.falae.fragment.SpreadSheetFragment;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;
import com.marcelorcorrea.falae.task.DownloadTask;

import java.util.List;

public class NavigationActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener,
        SpreadSheetFragment.OnFragmentInteractionListener,
        AddUserFragment.OnFragmentInteractionListener {

    private DrawerLayout mDrawer;
    private NavigationView mNavigationView;
    private User mUser;
    private UserDbHelper dbHelper;
    private boolean doubleBackToExitPressedOnce;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        setContentView(R.layout.activity_navigation);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mDrawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, mDrawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        mDrawer.addDrawerListener(toggle);
        toggle.syncState();
        mDrawer.openDrawer(GravityCompat.START);
        mNavigationView = (NavigationView) findViewById(R.id.nav_view);
        mNavigationView.setNavigationItemSelectedListener(this);


        dbHelper = new UserDbHelper(this);
        List<User> users = dbHelper.read();
        for (final User u : users) {
            addUserToMenu(u);
        }
    }

    private void addUserToMenu(final User user) {
        MenuItem userItem = mNavigationView.getMenu().add(R.id.users_group, Menu.NONE, 0, user.getName());
        userItem.setIcon(R.drawable.ic_person_black_24dp);
        userItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                mUser = dbHelper.findByEmail(user.getEmail());
                onNavigationItemSelected(item);
                return true;
            }
        });
    }

    @Override
    public void onBackPressed() {
        if (mDrawer.isDrawerOpen(GravityCompat.START)) {
            mDrawer.closeDrawer(GravityCompat.START);
        } else {
            if (doubleBackToExitPressedOnce) {
                super.onBackPressed();
            } else {
                this.doubleBackToExitPressedOnce = true;
                Toast.makeText(this, R.string.exit_app_msg, Toast.LENGTH_SHORT).show();
                new Handler().postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        doubleBackToExitPressedOnce = false;
                    }
                }, 2000);
            }
        }
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        Fragment fragment;
        String tag;
        int id = item.getItemId();
        if (id == R.id.add_user) {
            fragment = AddUserFragment.newInstance();
            tag = AddUserFragment.class.getSimpleName();
        } else if (id == R.id.voice_item) {
            openTTSLanguageSettings();
            return false;
        } else {
            fragment = SpreadSheetFragment.newInstance(mUser);
            tag = SpreadSheetFragment.class.getSimpleName();
        }
        getSupportFragmentManager().beginTransaction()
                .setCustomAnimations(R.anim.enter_from_right, R.anim.exit_to_left,
                        R.anim.enter_from_left, R.anim.exit_to_right)
                .replace(R.id.container, fragment, tag)
                .commit();

        item.setChecked(true);
        setTitle(item.getTitle());
        mDrawer.closeDrawer(GravityCompat.START);
        return true;
    }

    @Override
    protected void onDestroy() {
        dbHelper.close();
        super.onDestroy();
    }

    @Override
    public void onFragmentInteraction(final User user) {
        new DownloadTask(this, new DownloadTask.Callback() {
            @Override
            public void onSyncComplete(User u) {
                if (!dbHelper.doesUserExists(u)) {
                    addUserToMenu(u);
                }
                dbHelper.insertOrUpdate(u);
                Toast.makeText(NavigationActivity.this, R.string.success_user_added, Toast.LENGTH_SHORT).show();
            }
        }).execute(user);
    }

    private void openTTSLanguageSettings() {
        Intent installTts = new Intent();
        installTts.setAction(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA);
        startActivity(installTts);
    }

    @Override
    public void displayActivity(SpreadSheet spreadSheet) {
        Intent intent = new Intent(this, DisplayActivity.class);
        intent.putExtra(DisplayActivity.SPREADSHEET, spreadSheet);
        startActivity(intent);
        overridePendingTransition(R.anim.enter_from_right, R.anim.exit_to_left);
    }
}
