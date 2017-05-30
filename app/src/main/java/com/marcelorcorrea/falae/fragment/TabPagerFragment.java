package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;

public class TabPagerFragment extends Fragment implements SpreadSheetFragment.OnFragmentInteractionListener, UserInfoFragment.OnFragmentInteractionListener {

    private static final String USER_PARAM = "userParam";
    private User user;

    private OnFragmentInteractionListener mListener;
    private ViewPager viewPager;

    public TabPagerFragment() {
    }

    public static TabPagerFragment newInstance(User user) {
        TabPagerFragment fragment = new TabPagerFragment();
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
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_tab_pager, container, false);
        viewPager = (ViewPager) view.findViewById(R.id.viewpager);
        viewPager.setAdapter(new CustomFragmentPagerAdapter(getChildFragmentManager(), getActivity()));
        viewPager.setOffscreenPageLimit(2);

        // Give the TabLayout the ViewPager
        TabLayout tabLayout = (TabLayout) view.findViewById(R.id.layout_tabs);
        tabLayout.setupWithViewPager(viewPager);
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

    @Override
    public void displayActivity(SpreadSheet spreadSheet) {
        mListener.displayActivity(spreadSheet);

    }

    @Override
    public void onFragmentInteraction(Uri uri) {

    }

    public interface OnFragmentInteractionListener {
        void displayActivity(SpreadSheet spreadSheet);
    }

    public class CustomFragmentPagerAdapter extends FragmentStatePagerAdapter {
        final int TAB_COUNT = 2;
        private String tabTitles[] = new String[]{getResources().getString(R.string.spreadsheets), getResources().getString(R.string.user_info)};
        private Context context;

        public CustomFragmentPagerAdapter(FragmentManager fm, Context context) {
            super(fm);
            this.context = context;
        }

        public Fragment getItem(int position) {
            Fragment fragment;
            if (position == 0) {
                fragment = SpreadSheetFragment.newInstance(user);
            } else {
                fragment = UserInfoFragment.newInstance(user);
            }
            return fragment;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return tabTitles[position];
        }

        @Override
        public int getCount() {
            return TAB_COUNT;
        }
    }
}
