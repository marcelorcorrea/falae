package com.marcelorcorrea.falae.adapter

import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentStatePagerAdapter
import com.marcelorcorrea.falae.fragment.ViewPagerItemFragment
import com.marcelorcorrea.falae.model.Page
import java.util.*

class ItemPagerAdapter(fm: FragmentManager, private val page: Page, private val marginWidth: Int) : FragmentStatePagerAdapter(fm) {
    private val pageCount: Int

    init {
        pageCount = calculatePageCount()
    }

    override fun getItem(position: Int): Fragment {
        val items = page.items
        val itemsPerPage = page.columns * page.rows
        val fromIndex = position * itemsPerPage
        val subList = items.subList(fromIndex, Math.min(fromIndex + itemsPerPage, items.size))
        return ViewPagerItemFragment.newInstance(ArrayList(subList), page.columns, page.rows, marginWidth)
    }

    override fun getCount(): Int = pageCount

    private fun calculatePageCount(): Int {
        val numberOfPages = page.items.size.toDouble() / (page.columns * page.rows)
        return if (numberOfPages == Math.round(numberOfPages).toDouble()) {
            numberOfPages.toInt()
        } else Math.round(numberOfPages + 0.5).toInt()
    }
}