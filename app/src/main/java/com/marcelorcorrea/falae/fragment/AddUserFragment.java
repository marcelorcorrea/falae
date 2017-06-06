package com.marcelorcorrea.falae.fragment;

import android.app.ProgressDialog;
import android.content.Context;
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
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;
import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.User;
import com.marcelorcorrea.falae.task.GsonRequest;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddUserFragment extends Fragment implements Response.Listener<User>, Response.ErrorListener {

    private static final String URL = "http://10.28.0.64:3000/login.json";
    private static final String EMAIL_CREDENTIAL_FIELD = "email";
    private static final String PASSWORD_CREDENTIAL_FIELD = "password";
    private static final String USER_CREDENTIAL_FIELD = "user";
    private static final Pattern VALID_EMAIL_REGEX = Pattern.compile("\\A[\\w+\\-.]+@[a-z\\d\\-.]+\\.[a-z]+\\z", Pattern.CASE_INSENSITIVE);

    private static final String[] DUMMY_CREDENTIALS = new String[]{
            "mlongaray@hp.com:123456", "marcelorcorrea@hp.com:123456", "amostra@falae.com:"
    };
    private OnFragmentInteractionListener mListener;

    private EditText mEmailView;
    private EditText mPasswordView;
    private ProgressDialog pDialog;

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

        Button mEmailSignInButton = (Button) view.findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });
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
            if (loginMock(email, password) == null) { //remove this if when mock method is removed.
                loginIn(email, password);
            }
        }
    }

    private boolean isEmailValid(String email) {
        Matcher m = VALID_EMAIL_REGEX.matcher(email);
        return m.matches();
    }

    private boolean isPasswordValid(String password) {
        return password.length() > 4;
    }

    private void loginIn(String email, String password) {
        RequestQueue queue = Volley.newRequestQueue(getContext());
        try {
            JSONObject credentials = new JSONObject();
            credentials.put(EMAIL_CREDENTIAL_FIELD, email);
            credentials.put(PASSWORD_CREDENTIAL_FIELD, password);

            JSONObject jsonRequest = new JSONObject();
            jsonRequest.put(USER_CREDENTIAL_FIELD, credentials);

            GsonRequest<User> jsObjRequest = new GsonRequest<>(URL, User.class, null, jsonRequest, this, this);
            queue.add(jsObjRequest);
            pDialog = new ProgressDialog(getContext());
            pDialog.setMessage(getContext().getString(R.string.authenticate_message));
            pDialog.setIndeterminate(false);
            pDialog.setCancelable(false);
            pDialog.show();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private User loginMock(String email, String password) {
        User user = null;
        for (String credential : DUMMY_CREDENTIALS) {
            String[] pieces = credential.split(":");
            if (email.equals("amostra@falae.com")) {
                user = createMockSpreadsheets(R.raw.sampleboard);
            }
            if (pieces[0].equals(email)) {
                if (pieces[1].equals(password)) {
                    user = createMockSpreadsheets(R.raw.mockspreadsheet);
                    if (email.equals("mlongaray@hp.com")) {
                        user = createMockSpreadsheets(R.raw.mockspreadsheet2);
                    }
                }
            }
        }
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
        if (user != null) {
            mListener.onFragmentInteraction(user);
        }
        return user;
    }

    @Override
    public void onResponse(User response) {
        mListener.onFragmentInteraction(response);
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
    }

    @Override
    public void onErrorResponse(VolleyError error) {
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
        if (error instanceof AuthFailureError) {
            mPasswordView.setError(getString(R.string.error_incorrect_password));
            mPasswordView.requestFocus();
        } else {
            Toast.makeText(getContext(), getString(R.string.error_internet_access), Toast.LENGTH_LONG).show();
            error.printStackTrace();
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
