package com.marcelorcorrea.falae.activity

import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.widget.Toast
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.fragment.PageFragment
import com.marcelorcorrea.falae.fragment.ViewPagerItemFragment
import com.marcelorcorrea.falae.model.Page
import com.marcelorcorrea.falae.model.SpreadSheet
import com.marcelorcorrea.falae.service.TextToSpeechService

class DisplayActivity : AppCompatActivity(), PageFragment.OnFragmentInteractionListener, ViewPagerItemFragment.OnFragmentInteractionListener {

    private var currentSpreadSheet: SpreadSheet? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_display)

        currentSpreadSheet = intent.getParcelableExtra(SPREADSHEET)
        if (currentSpreadSheet != null) {
            openPage(currentSpreadSheet!!.initialPage)
        }
    }

    override fun openPage(linkTo: String) {
        val page = getPage(linkTo)
        if (page != null) {
            val fragment = PageFragment.newInstance(page)
            val fragmentManager = supportFragmentManager
            val fragmentTransaction = fragmentManager
                    .beginTransaction()
                    .setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out,
                            android.R.anim.fade_in, android.R.anim.fade_out)
                    .replace(R.id.page_container, fragment)
            if (currentSpreadSheet!!.initialPage != linkTo) {
                fragmentTransaction.addToBackStack(null)
            } else if (fragmentManager.backStackEntryCount > 0) {
                fragmentManager.popBackStackImmediate()
            }
            fragmentTransaction.commit()
            fragmentManager.executePendingTransactions()
        } else {
            Toast.makeText(this, getString(R.string.page_not_found), Toast.LENGTH_SHORT).show()
        }
    }

    private fun getPage(name: String): Page? = currentSpreadSheet!!.pages.firstOrNull { it.name == name }

    override fun speak(msg: String) {
        val intent = Intent(this, TextToSpeechService::class.java)
        intent.putExtra(TextToSpeechService.TEXT_TO_SPEECH_MESSAGE, msg)
        startService(intent)
    }

    override fun onBackPressed() {
        super.onBackPressed()
        overridePendingTransition(R.anim.enter_from_left, R.anim.exit_to_right)
    }

    companion object {

        val SPREADSHEET = "SpreadSheet"
    }
}
