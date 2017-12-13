package com.marcelorcorrea.falae.fragment

import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.support.v4.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView

import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.model.User
import com.squareup.picasso.Picasso

import jp.wasabeef.picasso.transformations.CropCircleTransformation

class UserInfoFragment : Fragment() {

    private lateinit var mListener: OnFragmentInteractionListener
    private var user: User? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (arguments != null) {
            user = arguments.getParcelable(USER_PARAM)
        }
        onAttachFragment(parentFragment)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        // Inflate the layout for this fragment
        val view = inflater.inflate(R.layout.fragment_user_info, container, false)
        val imageView = view.findViewById(R.id.user_photo) as ImageView
        val userName = view.findViewById(R.id.user_name) as TextView
        val userInfo = view.findViewById(R.id.user_information) as TextView

        val brokenImage: Drawable?
        val placeHolderImage: Drawable?

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            brokenImage = context.resources.getDrawable(R.drawable.ic_broken_image_black_48dp)
            placeHolderImage = context.resources.getDrawable(R.drawable.ic_person_black_24dp)
        } else {
            brokenImage = context.getDrawable(R.drawable.ic_broken_image_black_48dp)
            placeHolderImage = context.getDrawable(R.drawable.ic_person_black_24dp)
        }

        Picasso.with(context)
                .load(user!!.photo)
                .placeholder(placeHolderImage)
                .error(brokenImage!!)
                .transform(CropCircleTransformation())
                .into(imageView)

        userName.text = user?.name
        userInfo.text = user?.profile

        return view
    }

    override fun onAttachFragment(fragment: Fragment?) {
        if (fragment is OnFragmentInteractionListener) {
            mListener = fragment
        } else {
            throw RuntimeException(fragment!!.toString() + " must implement OnFragmentInteractionListener")
        }
    }

    override fun onDetach() {
        super.onDetach()
    }

    interface OnFragmentInteractionListener {
        fun onFragmentInteraction(uri: Uri)
    }

    companion object {

        private val USER_PARAM = "userParam"

        fun newInstance(user: User): UserInfoFragment {
            val fragment = UserInfoFragment()
            val args = Bundle()
            args.putParcelable(USER_PARAM, user)
            fragment.arguments = args
            return fragment
        }
    }
}
