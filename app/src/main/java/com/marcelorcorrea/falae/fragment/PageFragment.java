package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.adapter.ItemPagerAdapter;
import com.marcelorcorrea.falae.model.Page;

import static com.marcelorcorrea.falae.R.id.pager;


public class PageFragment extends Fragment {
    private static final String PAGE_PARAM = "pageParam";

    private Page page;
    private OnFragmentInteractionListener mListener;
    private ViewPager mPager;
    private ItemPagerAdapter mPagerAdapter;
    private ImageView leftNav;
    private ImageView rightNav;
    private FrameLayout leftNavHolder;
    private FrameLayout rightNavHolder;

    public PageFragment() {
    }

    public static PageFragment newInstance(Page page) {
        PageFragment fragment = new PageFragment();
        Bundle args = new Bundle();
        args.putParcelable(PAGE_PARAM, page);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            page = getArguments().getParcelable(PAGE_PARAM);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.fragment_page, container, false);
        leftNav = (ImageView) view.findViewById(R.id.left_nav);
        rightNav = (ImageView) view.findViewById(R.id.right_nav);

        leftNavHolder = (FrameLayout) view.findViewById(R.id.left_nav_holder);
        rightNavHolder = (FrameLayout) view.findViewById(R.id.right_nav_holder);

        ViewTreeObserver vto = view.getViewTreeObserver();
        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                    view.getViewTreeObserver().removeGlobalOnLayoutListener(this);
                } else {
                    view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                }
                int leftNavMeasuredWidth = leftNavHolder.getMeasuredWidth();
                int rightNavMeasureWidth = rightNavHolder.getMeasuredWidth();

                mPager = (ViewPager) view.findViewById(pager);
                mPagerAdapter = new ItemPagerAdapter(getChildFragmentManager(), page, leftNavMeasuredWidth + rightNavMeasureWidth);
                mPager.setAdapter(mPagerAdapter);

                ViewGroup.MarginLayoutParams pagerLayoutParams = (ViewGroup.MarginLayoutParams) mPager.getLayoutParams();
                pagerLayoutParams.leftMargin += leftNavMeasuredWidth;
                pagerLayoutParams.rightMargin += rightNavMeasureWidth;

                mPager.addOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
                    @Override
                    public void onPageSelected(int position) {
                        handleNavButtons();
                    }
                });

                if (shouldEnableNavButtons()) {
                    handleNavButtons();
                }
                leftNavHolder.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int tab = mPager.getCurrentItem();
                        if (tab > 0) {
                            tab--;
                            speak(getString(R.string.previous));
                            mPager.setCurrentItem(tab);
                        } else if (tab == 0) {
                            mPager.setCurrentItem(tab);
                        }
                    }
                });
                rightNavHolder.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int tab = mPager.getCurrentItem();
                        if (mPagerAdapter.getCount() > 1 && tab != mPagerAdapter.getCount() - 1) {
                            speak(getString(R.string.next));
                        }
                        tab++;
                        mPager.setCurrentItem(tab);
                    }
                });
            }
        });

        return view;
    }

    private void handleNavButtons() {
        enableNavButtons();
        if (shouldDisableLeftNavButton()) {
            leftNav.setVisibility(View.INVISIBLE);
        }
        if (shouldDisableRightButton()) {
            rightNav.setVisibility(View.INVISIBLE);
        }
    }

    private void enableNavButtons() {
        leftNav.setVisibility(View.VISIBLE);
        rightNav.setVisibility(View.VISIBLE);
    }

    private boolean shouldEnableNavButtons() {
        return mPagerAdapter.getCount() > 1;
    }

    private boolean shouldDisableLeftNavButton() {
        return mPager.getCurrentItem() == 0;
    }

    private boolean shouldDisableRightButton() {
        return mPager.getCurrentItem() >= mPagerAdapter.getCount() - 1;
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

    public void speak(String msg) {
        mListener.speak(msg);
    }

    public interface OnFragmentInteractionListener {
        void speak(String msg);
    }
}
