package com.marcelorcorrea.falae.fragment

import android.app.ProgressDialog
import android.content.Context
import android.os.Bundle
import android.support.v4.app.Fragment
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import com.android.volley.AuthFailureError
import com.android.volley.Response
import com.android.volley.VolleyError
import com.android.volley.toolbox.Volley
import com.google.gson.Gson
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.model.User
import com.marcelorcorrea.falae.task.GsonRequest
import org.apache.commons.io.IOUtils
import org.json.JSONException
import org.json.JSONObject
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.util.regex.Pattern

class SyncUserFragment : Fragment(), Response.Listener<User>, Response.ErrorListener {
    private lateinit var mListener: OnFragmentInteractionListener

    private lateinit var mEmailView: EditText
    private lateinit var mPasswordView: EditText
    private lateinit var pDialog: ProgressDialog

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        val view = inflater.inflate(R.layout.fragment_sync_user, container, false)
        mEmailView = view.findViewById(R.id.email) as EditText
        mPasswordView = view.findViewById(R.id.password) as EditText
        mPasswordView.setOnEditorActionListener(TextView.OnEditorActionListener { _, id, _ ->
            if (id == R.id.login || id == EditorInfo.IME_ACTION_DONE) {
                val imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                imm.hideSoftInputFromWindow(mPasswordView.windowToken, 0)
                attemptLogin()
                return@OnEditorActionListener true
            }
            false
        })

        pDialog = ProgressDialog(context)
        pDialog.setMessage(context.getString(R.string.authenticate_message))
        pDialog.isIndeterminate = false
        pDialog.setCancelable(false)
        val mEmailSignInButton = view.findViewById(R.id.email_sign_in_button) as Button
        mEmailSignInButton.setOnClickListener { attemptLogin() }
        return view
    }

    override fun onAttach(context: Context?) {
        super.onAttach(context)
        if (context is OnFragmentInteractionListener) {
            mListener = context
        } else {
            throw RuntimeException(context!!.toString() + " must implement OnFragmentInteractionListener")
        }
    }

    override fun onDetach() {
        super.onDetach()
    }

    private fun attemptLogin() {
        // Reset errors.
        mEmailView.error = null
        mPasswordView.error = null

        // Store values at the time of the login attempt.
        val email = mEmailView.text.toString()
        val password = mPasswordView.text.toString()

        var cancel = false
        var focusView: View? = null

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.error = getString(R.string.error_invalid_password)
            focusView = mPasswordView
            cancel = true
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.error = getString(R.string.error_field_required)
            focusView = mEmailView
            cancel = true
        } else if (!isEmailValid(email)) {
            mEmailView.error = getString(R.string.error_invalid_email)
            focusView = mEmailView
            cancel = true
        }

        if (cancel) {
            focusView?.requestFocus()
        } else {
            if (loginMock(email, password) == null) { //remove this if when mock method is removed.
                loginIn(email, password)
            }
        }
    }

    private fun isEmailValid(email: String): Boolean {
        val m = VALID_EMAIL_REGEX.matcher(email)
        return m.matches()
    }

    private fun isPasswordValid(password: String): Boolean = password.length > 4

    private fun loginIn(email: String, password: String) {
        val queue = Volley.newRequestQueue(context)
        try {
            val credentials = JSONObject()
            credentials.put(EMAIL_CREDENTIAL_FIELD, email)
            credentials.put(PASSWORD_CREDENTIAL_FIELD, password)

            val jsonRequest = JSONObject()
            jsonRequest.put(USER_CREDENTIAL_FIELD, credentials)

            val jsObjRequest = GsonRequest(URL, User::class.java, null, jsonRequest, this, this)
            queue.add(jsObjRequest)
            pDialog.show()
        } catch (e: JSONException) {
            e.printStackTrace()
        }

    }

    private fun loginMock(email: String, password: String): User? {
        var user: User? = null
        DUMMY_CREDENTIALS.forEach { credential ->
            val pieces = credential.split(":".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            if (email == "amostra@falae.com") {
                user = createMockSpreadsheets(R.raw.sampleboard)
            } else if (pieces[0] == email) {
                if (pieces[1] == password) {
                    user = createMockSpreadsheets(R.raw.mockspreadsheet)
                    if (email == "mlongaray@hp.com") {
                        user = createMockSpreadsheets(R.raw.mockspreadsheet2)
                    }
                }
            }
        }
        if (pDialog.isShowing) {
            pDialog.dismiss()
        }
        if (user != null) {
            mListener.onFragmentInteraction(user)
        }
        return user
    }

    override fun onResponse(response: User) {
        mListener.onFragmentInteraction(response)
        if (pDialog.isShowing) {
            pDialog.dismiss()
        }
    }

    override fun onErrorResponse(error: VolleyError) {
        if (pDialog.isShowing) {
            pDialog.dismiss()
        }
        if (error is AuthFailureError) {
            mPasswordView.error = getString(R.string.error_incorrect_password)
            mPasswordView.requestFocus()
        } else {
            Toast.makeText(context, getString(R.string.error_internet_access), Toast.LENGTH_LONG).show()
            error.printStackTrace()
        }
    }


    interface OnFragmentInteractionListener {
        fun onFragmentInteraction(user: User?)
    }

    private fun createMockSpreadsheets(id: Int): User? {
        try {
            val raw = context.resources.openRawResource(id)
            val `is` = BufferedReader(InputStreamReader(raw, "UTF8"))
            val json = IOUtils.toString(`is`)
            return Gson().fromJson(json, User::class.java)
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return null
    }

    companion object {

        private val URL = "http://10.28.0.64:3000/login.json"
        private val EMAIL_CREDENTIAL_FIELD = "email"
        private val PASSWORD_CREDENTIAL_FIELD = "password"
        private val USER_CREDENTIAL_FIELD = "user"
        private val VALID_EMAIL_REGEX = Pattern.compile("\\A[\\w+\\-.]+@[a-z\\d\\-.]+\\.[a-z]+\\z", Pattern.CASE_INSENSITIVE)

        private val DUMMY_CREDENTIALS = arrayOf("mlongaray@hp.com:123456", "marcelorcorrea@hp.com:123456", "amostra@falae.com:")

        fun newInstance(): SyncUserFragment = SyncUserFragment()
    }
}
