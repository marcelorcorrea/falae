package com.marcelorcorrea.falae.activity

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.speech.tts.TextToSpeech
import android.support.design.widget.NavigationView
import android.support.v4.app.Fragment
import android.support.v4.view.GravityCompat
import android.support.v4.widget.DrawerLayout
import android.support.v7.app.ActionBarDrawerToggle
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.Toolbar
import android.view.MenuItem
import android.view.Window
import android.view.WindowManager
import android.widget.Toast
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.database.UserDbHelper
import com.marcelorcorrea.falae.fragment.SettingsFragment
import com.marcelorcorrea.falae.fragment.SyncUserFragment
import com.marcelorcorrea.falae.fragment.TabPagerFragment
import com.marcelorcorrea.falae.loadUser
import com.marcelorcorrea.falae.model.SpreadSheet
import com.marcelorcorrea.falae.model.User
import com.marcelorcorrea.falae.storage.FileHandler
import com.marcelorcorrea.falae.storage.SharedPreferencesUtils
import com.marcelorcorrea.falae.task.DownloadTask

class MainActivity : AppCompatActivity(), NavigationView.OnNavigationItemSelectedListener, TabPagerFragment.OnFragmentInteractionListener, SyncUserFragment.OnFragmentInteractionListener {

    private lateinit var mDrawer: DrawerLayout
    private lateinit var mNavigationView: NavigationView
    private lateinit var dbHelper: UserDbHelper
    private var mCurrentUser: User? = null
    private var doubleBackToExitPressedOnce: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        requestWindowFeature(Window.FEATURE_ACTION_BAR_OVERLAY)
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN)
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        val toolbar = findViewById(R.id.toolbar) as Toolbar
        setSupportActionBar(toolbar)

        mDrawer = findViewById(R.id.drawer_layout) as DrawerLayout
        val toggle = ActionBarDrawerToggle(
                this, mDrawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close)
        mDrawer.addDrawerListener(toggle)
        toggle.syncState()
        mDrawer.openDrawer(GravityCompat.START)
        mNavigationView = findViewById(R.id.nav_view) as NavigationView
        mNavigationView.setNavigationItemSelectedListener(this)
        dbHelper = UserDbHelper(this)
        val users = dbHelper.read()
        for (user in users) {
            addUserToMenu(user)
        }
        loadDemoUser()
        getLastConnectedUser()
    }

    private fun getLastConnectedUser() {
        val email = SharedPreferencesUtils.getString(USER_EMAIL, this)
        if (email.isNotEmpty()) {
            openUserMenuItem(email)
        } else {
            onNavigationItemSelected(mNavigationView.menu.findItem(R.id.add_user))
            mDrawer.openDrawer(GravityCompat.START)
        }
    }

    private fun openUserMenuItem(email: String) {
        mCurrentUser = dbHelper.findByEmail(email)
        val item = mCurrentUser?.id?.let { mNavigationView.menu.findItem(it) }
        if (item != null) {
            onNavigationItemSelected(item)
        }
    }

    private fun loadDemoUser() {
        val demoUser = resources.loadUser(getString(R.string.sampleboard))
        addUserToMenu(demoUser, R.id.settings_group, 1) { null }
    }

    private fun addUserToMenu(user: User, groupId: Int = R.id.users_group, order: Int = 0, findUser: (User) -> User? = this::findUser) {
        val userItem = mNavigationView.menu.add(groupId, user.id, order, user.name)
        userItem.setIcon(R.drawable.ic_person_black_24dp)
        userItem.setOnMenuItemClickListener { item ->
            mCurrentUser = findUser(user) ?: user
            onNavigationItemSelected(item)
            true
        }
    }

    private fun findUser(user: User) = dbHelper.findByEmail(user.email)

    override fun onBackPressed() {
        if (mDrawer.isDrawerOpen(GravityCompat.START)) {
            mDrawer.closeDrawer(GravityCompat.START)
        } else {
            if (doubleBackToExitPressedOnce) {
                super.onBackPressed()
            } else {
                this.doubleBackToExitPressedOnce = true
                Toast.makeText(this, R.string.exit_app_msg, Toast.LENGTH_SHORT).show()
                Handler().postDelayed({ doubleBackToExitPressedOnce = false }, 2000)
            }
        }
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        val fragment: Fragment
        val tag: String
        val id = item.itemId
        when (id) {
            R.id.add_user -> {
                fragment = SyncUserFragment.newInstance()
                tag = SyncUserFragment::class.java.simpleName
            }
            R.id.voice_item -> {
                openTTSLanguageSettings()
                return false
            }
            R.id.settings -> {
                fragment = SettingsFragment.newInstance()
                tag = SettingsFragment::class.java.simpleName
            }
            else -> {
                fragment = TabPagerFragment.newInstance(mCurrentUser)
                tag = TabPagerFragment::class.java.simpleName
            }
        }
        supportFragmentManager.beginTransaction()
                .setCustomAnimations(R.anim.enter_from_right, R.anim.exit_to_left,
                        R.anim.enter_from_left, R.anim.exit_to_right)
                .replace(R.id.container, fragment, tag)
                .commit()

        item.isChecked = true
        title = item.title
        mDrawer.closeDrawer(GravityCompat.START)
        return true
    }

    override fun onDestroy() {
        dbHelper.close()
        if (mCurrentUser != null) {
            SharedPreferencesUtils.storeString(USER_EMAIL, mCurrentUser!!.email, this)
        }
        super.onDestroy()
    }

    override fun onFragmentInteraction(user: User?) {
        DownloadTask(this, { u ->
            if (!dbHelper.doesUserExist(u)) {
                val id = dbHelper.insert(u)
                addUserToMenu(u.copy(id = id.toInt()))
            } else {
                dbHelper.update(u)
            }
            Toast.makeText(this@MainActivity, R.string.success_user_added, Toast.LENGTH_SHORT).show()
            openUserMenuItem(u.email)
        }).execute(user)
    }

    private fun openTTSLanguageSettings() {
        val installTts = Intent()
        installTts.action = TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA
        startActivity(installTts)
    }

    override fun displayActivity(spreadSheet: SpreadSheet) {
        val intent = Intent(this, DisplayActivity::class.java)
        intent.putExtra(DisplayActivity.SPREADSHEET, spreadSheet)
        startActivity(intent)
        overridePendingTransition(R.anim.enter_from_right, R.anim.exit_to_left)
    }

    override fun removeUser(user: User) {
        dbHelper.remove(user.id)
        SharedPreferencesUtils.remove(USER_EMAIL, this)
        FileHandler.deleteUserFolder(this, user.email)
        mCurrentUser = null
        recreate()
    }

    companion object {

        private val USER_EMAIL = "email"
    }
}
