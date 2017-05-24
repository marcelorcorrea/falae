package com.marcelorcorrea.falae.fragment;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.google.gson.Gson;
import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.User;

import org.apache.commons.io.IOUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddUserFragment extends Fragment {

    private static final Pattern VALID_EMAIL_REGEX = Pattern.compile("\\A[\\w+\\-.]+@[a-z\\d\\-.]+\\.[a-z]+\\z", Pattern.CASE_INSENSITIVE);
    private static final String[] DUMMY_CREDENTIALS = new String[]{
            "foo@example.com:hello", "mlongaray@hp.com:123456", "marcelorcorrea@hp.com:123456"
    };

    private UserLoginTask mAuthTask = null;
    private OnFragmentInteractionListener mListener;

    private EditText mEmailView;
    private EditText mPasswordView;
    private View mLoginFormView;

    public AddUserFragment() {
    }

    public static AddUserFragment newInstance() {
        return new AddUserFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_add_user, container, false);
        mEmailView = (EditText) view.findViewById(R.id.email);
        mPasswordView = (EditText) view.findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == R.id.login || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        mEmailView.setText("marcelorcorrea@hp.com");
        mPasswordView.setText("123456");

        Button mEmailSignInButton = (Button) view.findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });

        mLoginFormView = view.findViewById(R.id.login_form);
        return view;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    private void attemptLogin() {
        if (mAuthTask != null) {
            return;
        }

        // Reset errors.
        mEmailView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String email = mEmailView.getText().toString();
        String password = mPasswordView.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_invalid_password));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.setError(getString(R.string.error_field_required));
            focusView = mEmailView;
            cancel = true;
        } else if (!isEmailValid(email)) {
            mEmailView.setError(getString(R.string.error_invalid_email));
            focusView = mEmailView;
            cancel = true;
        }

        if (cancel) {
            focusView.requestFocus();
        } else {
            mAuthTask = new UserLoginTask(email, password);
            mAuthTask.execute();
        }
    }

    private boolean isEmailValid(String email) {
        Matcher m = VALID_EMAIL_REGEX.matcher(email);
        return m.matches();
    }

    private boolean isPasswordValid(String password) {
        return password.length() > 4;
    }


    public class UserLoginTask extends AsyncTask<Void, Void, User> {

        private final String mEmail;
        private final String mPassword;
        private ProgressDialog pDialog;

        UserLoginTask(String email, String password) {
            mEmail = email;
            mPassword = password;
        }

        @Override
        protected void onPreExecute() {
            try {
                if (pDialog != null) {
                    pDialog = null;
                }
                pDialog = new ProgressDialog(getContext());
                pDialog.setMessage(getContext().getString(R.string.authenticate_message));
                pDialog.setIndeterminate(false);
                pDialog.setCancelable(false);
                pDialog.show();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        protected User doInBackground(Void... params) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {

            }
            for (String credential : DUMMY_CREDENTIALS) {
                String[] pieces = credential.split(":");
                if (pieces[0].equals(mEmail)) {
                    if (pieces[1].equals(mPassword)) {
                        if (mEmail.equals("mlongaray@hp.com")) {
                            return createMockSpreadsheets(R.raw.mockspreadsheet2);
                        }
                        return createMockSpreadsheets(R.raw.mockspreadsheet);
                    }
                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(final User user) {
            mAuthTask = null;
            if (pDialog != null && pDialog.isShowing()) {
                pDialog.dismiss();
            }
            if (user != null) {
                mListener.onFragmentInteraction(user);
            } else {
                mPasswordView.setError(getString(R.string.error_incorrect_password));
                mPasswordView.requestFocus();
            }
        }

        @Override
        protected void onCancelled() {
            mAuthTask = null;
        }
    }

    public interface OnFragmentInteractionListener {
        void onFragmentInteraction(User user);
    }

    private User createMockSpreadsheets(int id) {
        try {
            InputStream raw = getContext().getResources().openRawResource(id);
            Reader is = new BufferedReader(new InputStreamReader(raw, "UTF8"));
            String json = IOUtils.toString(is);
            return new Gson().fromJson(json, User.class);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
