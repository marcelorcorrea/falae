package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

import java.util.ArrayList;
import java.util.List;


public class PageFragment extends Fragment implements ItemFragment.OnFragmentInteractionListener {
    private static final String SPREADSHEET_PARAM = "spreadsheetParam";
    private static final String PAGE_PARAM = "pageParam";

    private Page page;
    private SpreadSheet spreadSheet;
    private OnFragmentInteractionListener mListener;
    private ViewPager mPager;
    private ItemPagerAdapter mPagerAdapter;

    public PageFragment() {
    }

    public static PageFragment newInstance(SpreadSheet spreadSheet, Page page) {
        PageFragment fragment = new PageFragment();
        Bundle args = new Bundle();
        args.putParcelable(PAGE_PARAM, page);
        args.putParcelable(SPREADSHEET_PARAM, spreadSheet);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            page = getArguments().getParcelable(PAGE_PARAM);
            spreadSheet = getArguments().getParcelable(SPREADSHEET_PARAM);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        ((AppCompatActivity) getActivity()).getSupportActionBar().hide();
        View view = inflater.inflate(R.layout.fragment_page, container, false);
        mPager = (ViewPager) view.findViewById(R.id.pager);
        mPagerAdapter = new ItemPagerAdapter(getChildFragmentManager(), page);
        mPager.setAdapter(mPagerAdapter);
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
    public void onStop() {
        super.onStop();
        ((AppCompatActivity) getActivity()).getSupportActionBar().show();
    }

    @Override
    public void openPageFragment(String linkTo) {
        mListener.openPageFragment(spreadSheet, linkTo);
    }

    public interface OnFragmentInteractionListener {
        void openPageFragment(SpreadSheet spreadSheet, String linkTo);
    }

    private class ItemPagerAdapter extends FragmentStatePagerAdapter {

        private Page page;

        public ItemPagerAdapter(FragmentManager fm, Page page) {
            super(fm);
            this.page = page;
        }

        @Override
        public Fragment getItem(int position) {
            List<Item> items = page.getItems();
            int itemsPerPage = page.getColumns() * page.getRows();
            int fromIndex = position * itemsPerPage;
            List<Item> subList = items.subList(fromIndex, Math.min(fromIndex + itemsPerPage, items.size()));
            return ItemFragment.newInstance(new ArrayList<>(subList), page.getColumns(), page.getRows());
        }

        @Override
        public int getCount() {
            double numberOfPages = (double) page.getItems().size() / (page.getColumns() * page.getRows());
            if (numberOfPages % 2 == 0) {
                return (int) numberOfPages;
            }
            return (int) Math.round(numberOfPages + 0.5d);
        }
    }
}
