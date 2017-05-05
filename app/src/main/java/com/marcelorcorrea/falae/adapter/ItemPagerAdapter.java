package com.marcelorcorrea.falae.adapter;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.marcelorcorrea.falae.fragment.ItemFragment;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;

import java.util.ArrayList;
import java.util.List;

public class ItemPagerAdapter extends FragmentStatePagerAdapter {

        private Page page;
        private int pageCount;

        public ItemPagerAdapter(FragmentManager fm, Page page) {
            super(fm);
            this.page = page;
            pageCount = calculatePageCount();
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
            return pageCount;
        }

        private int calculatePageCount() {
            double numberOfPages = (double) page.getItems().size() / (page.getColumns() * page.getRows());
            if (numberOfPages % 2 == 0) {
                return (int) numberOfPages;
            }
            return (int) Math.round(numberOfPages + 0.5d);
        }
    }