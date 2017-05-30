package com.marcelorcorrea.falae.fragment;

import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.User;
import com.squareup.picasso.Picasso;

import org.w3c.dom.Text;

import static android.R.attr.name;
import static com.marcelorcorrea.falae.R.layout.item;

public class UserInfoFragment extends Fragment {

    private static final String USER_PARAM = "userParam";

    private OnFragmentInteractionListener mListener;
    private User user;

    public UserInfoFragment() {
        // Required empty public constructor
    }

    public static UserInfoFragment newInstance(User user) {
        UserInfoFragment fragment = new UserInfoFragment();
        Bundle args = new Bundle();
        args.putParcelable(USER_PARAM, user);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            user = getArguments().getParcelable(USER_PARAM);
        }
        onAttachFragment(getParentFragment());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_user_info, container, false);
        ImageView imageView = (ImageView) view.findViewById(R.id.user_photo);
        TextView userName = (TextView) view.findViewById(R.id.user_name);
        TextView userInfo = (TextView) view.findViewById(R.id.user_information);

        Drawable brokenImage;
        Drawable placeHolderImage;

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            brokenImage = getContext().getResources().getDrawable(R.drawable.ic_broken_image_black_48dp);
            placeHolderImage = getContext().getResources().getDrawable(R.drawable.ic_person_black_24dp);
        } else {
            brokenImage = getContext().getDrawable(R.drawable.ic_broken_image_black_48dp);
            placeHolderImage = getContext().getDrawable(R.drawable.ic_person_black_24dp);
        }

        System.out.println(user.getPhotoSrc());
        System.out.println(user.getName());

        Picasso.with(getContext())
                .load(user.getPhotoSrc())
                .placeholder(placeHolderImage)
                .error(brokenImage)
                .into(imageView);

        userName.setText(user.getName());
        userInfo.setText(user.getInfo());

        return view;
    }

    public void onAttachFragment(Fragment fragment) {
        if (fragment instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) fragment;
        } else {
            throw new RuntimeException(fragment.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }
}
