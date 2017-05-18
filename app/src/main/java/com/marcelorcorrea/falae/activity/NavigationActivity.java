package com.marcelorcorrea.falae.activity;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.RequiresApi;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
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
import com.marcelorcorrea.falae.fragment.PageFragment;
import com.marcelorcorrea.falae.fragment.SpreadSheetFragment;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;
import com.marcelorcorrea.falae.task.DownloadTask;

import java.util.List;

public class NavigationActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener, SpreadSheetFragment.OnFragmentInteractionListener, PageFragment.OnFragmentInteractionListener, AddUserFragment.OnFragmentInteractionListener {

    private DrawerLayout drawer;
    private NavigationView navigationView;
    private User mUser;
    private UserDbHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M && !hasReadPermission()) {
            requestReadPermission();
        } else {
            setContentView(R.layout.activity_navigation);

            Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
            setSupportActionBar(toolbar);

            drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
            ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                    this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
            drawer.addDrawerListener(toggle);
            toggle.syncState();

            navigationView = (NavigationView) findViewById(R.id.nav_view);
            navigationView.setNavigationItemSelectedListener(this);

            dbHelper = new UserDbHelper(this);
            if (dbHelper.isThereData()) {
                List<User> users = dbHelper.read();
                for (final User u : users) {
                    MenuItem userItem = navigationView.getMenu().add(R.id.users_group, Menu.NONE, 0, u.getName());
                    userItem.setIcon(R.drawable.ic_person_black_24dp);
                    userItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                        @Override
                        public boolean onMenuItemClick(MenuItem item) {
                            mUser = u;
                            onNavigationItemSelected(item);
                            return true;
                        }
                    });
                }
            }
//            if (savedInstanceState == null) {
//                MenuItem item = navigationView.getMenu().getItem(0);
//                onNavigationItemSelected(item);
//            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.M)
    public boolean hasReadPermission() {
        return ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }

    @RequiresApi(Build.VERSION_CODES.M)
    public void requestReadPermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 112);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == 112) {
            if ((grantResults.length > 0) && (grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                recreate();
            } else {
                Toast.makeText(this, "É necessário permissão de leitura e escrita.", Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
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
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    @Override
    protected void onDestroy() {
        dbHelper.close();
        super.onDestroy();
    }

    @Override
    public void openPageFragment(SpreadSheet spreadSheet, String name) {
        Fragment spreadSheetFragment = getSupportFragmentManager().findFragmentByTag(SpreadSheetFragment.class.getSimpleName());
        if (spreadSheetFragment != null) {
            Page page = ((SpreadSheetFragment) spreadSheetFragment).getPage(spreadSheet, name);
            Fragment fragment = PageFragment.newInstance(spreadSheet, page);
            getSupportFragmentManager()
                    .beginTransaction()
                    .setCustomAnimations(R.anim.enter_from_right, R.anim.exit_to_left,
                            R.anim.enter_from_left, R.anim.exit_to_right)
                    .replace(R.id.container, fragment)
                    .addToBackStack(null)
                    .commit();
        }
    }

    @Override
    public void onFragmentInteraction(final User user) {
        new DownloadTask(this, new DownloadTask.Callback() {
            @Override
            public void onSyncComplete(User u) {
                if (!dbHelper.doesUserExists(u)) {
                    MenuItem add = navigationView.getMenu().add(Menu.NONE, Menu.NONE, 0, user.getName());
                    add.setIcon(R.drawable.ic_person_black_24dp);
                }
                dbHelper.insertOrUpdate(user);
                mUser = u;
            }
        }).execute(user);
    }
}
