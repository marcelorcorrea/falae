package com.marcelorcorrea.falae.fragment

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Point
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.support.constraint.ConstraintLayout
import android.support.v4.app.Fragment
import android.support.v7.widget.GridLayout
import android.util.DisplayMetrics
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.model.Category
import com.marcelorcorrea.falae.model.Item
import com.marcelorcorrea.falae.storage.SharedPreferencesUtils
import com.squareup.picasso.Picasso
import java.util.*

class ViewPagerItemFragment : Fragment() {

    private var mItems: List<Item>? = null
    private var mItemsLayout: MutableList<FrameLayout>? = null
    private lateinit var mListener: OnFragmentInteractionListener
    private var mColumns: Int = 0
    private var mRows: Int = 0
    private var mMarginWidth: Int = 0
    private var currentItemSelectedFromScan = -1
    private lateinit var mGridLayout: GridLayout
    private var mTimer: Timer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (arguments != null) {
            mItems = arguments.getParcelableArrayList(ITEMS_PARAM)
            mColumns = arguments.getInt(COLUMNS_PARAM)
            mRows = arguments.getInt(ROWS_PARAM)
            mMarginWidth = arguments.getInt(MARGIN_WIDTH)
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_view_pager_item, container, false)
        mGridLayout = view.findViewById(R.id.grid_layout) as GridLayout
        mGridLayout.alignmentMode = GridLayout.ALIGN_BOUNDS
        mGridLayout.columnCount = mColumns
        mGridLayout.rowCount = mRows

        val layoutDimensions = calculateLayoutDimensions()

        mItemsLayout = ArrayList()

        mItems?.forEach { item ->
            val layout = generateLayout(inflater, item, layoutDimensions)
            mItemsLayout!!.add(layout)
            mGridLayout.addView(layout)
        }
        return view
    }

    override fun onResume() {
        super.onResume()
        if (SharedPreferencesUtils.getBoolean(SettingsFragment.SCAN_MODE, context)) {
            currentItemSelectedFromScan = -1
            val scanModeDuration = SharedPreferencesUtils.getInt(SettingsFragment.SCAN_MODE_DURATION, context)
            doSpreadsheetScan(scanModeDuration)
        }
    }

    override fun onPause() {
        super.onPause()
        if (mTimer != null) {
            mTimer!!.purge()
            mTimer!!.cancel()
            mTimer = null
        }
    }

    private fun generateLayout(inflater: LayoutInflater, item: Item, layoutDimensions: Point): FrameLayout {
        val frameLayout = inflater.inflate(R.layout.item, null, false) as FrameLayout
        val name = frameLayout.findViewById(R.id.item_name) as TextView
        val imageView = frameLayout.findViewById(R.id.item_image_view) as ImageView
        val linkPage = frameLayout.findViewById(R.id.link_page) as ImageView

        frameLayout.layoutParams = FrameLayout.LayoutParams(layoutDimensions.x, layoutDimensions.y)
        val drawable = createBackgroundDrawable(item)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
            frameLayout.setBackgroundDrawable(drawable)
        } else {
            frameLayout.background = drawable
        }
        frameLayout.setOnClickListener {
            var itemSelected = item
            if (SharedPreferencesUtils.getBoolean(SettingsFragment.SCAN_MODE, context)) {
                itemSelected = mItems!![currentItemSelectedFromScan]
            }
            onItemClicked(itemSelected)
        }
        name.text = item.name
        name.post {
            val imageSize = calculateImageSize(layoutDimensions.x, layoutDimensions.y, name, imageView)

            if (item.category == Category.SUBJECT) {
                name.setTextColor(Color.BLACK)
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                    linkPage.setImageDrawable(context.resources.getDrawable(R.drawable.ic_launch_black_48dp))
                } else {
                    linkPage.setImageDrawable(context.getDrawable(R.drawable.ic_launch_black_48dp))
                }
            }
            val brokenImage = getResizedDrawable(R.drawable.ic_broken_image_black_48dp, imageSize)
            val placeHolderImage = getResizedDrawable(R.drawable.ic_image_black_48dp, imageSize)

            Picasso.with(context)
                    .load(item.imgSrc)
                    .placeholder(placeHolderImage)
                    .error(brokenImage)
                    .resize(imageSize, imageSize)
                    .centerCrop()
                    .into(imageView)

            if (item.linkTo != null && item.linkTo.isNotEmpty()) {
                linkPage.visibility = View.VISIBLE
            }
        }
        return frameLayout
    }

    private fun onItemClicked(item: Item) {
        mListener.speak(item.speech)
        if (item.linkTo != null && item.linkTo.isNotEmpty()) {
            mListener.openPage(item.linkTo)
        }
    }

    private fun calculateLayoutDimensions(): Point {
        val metrics = DisplayMetrics()
        activity.windowManager.defaultDisplay.getMetrics(metrics)
        val widthDimension = Math.round(((metrics.widthPixels - mMarginWidth) / mColumns).toFloat())
        val heightDimension = Math.round((metrics.heightPixels / mRows).toFloat())
        return Point(widthDimension, heightDimension)
    }

    private fun calculateImageSize(layoutWidth: Int, layoutHeight: Int, name: TextView, imageView: ImageView): Int {
        val nameTopMargin = (name.layoutParams as ConstraintLayout.LayoutParams).topMargin
        val nameBoxHeight = nameTopMargin + name.lineHeight * name.lineCount
        val availableHeight = layoutHeight - nameBoxHeight
        if (availableHeight > layoutWidth) {
            val imageLeftMargin = (imageView.layoutParams as ConstraintLayout.LayoutParams).leftMargin
            val imageRightMargin = (imageView.layoutParams as ConstraintLayout.LayoutParams).rightMargin
            return layoutWidth - (imageLeftMargin + imageRightMargin)
        } else {
            val imageTopMargin = (imageView.layoutParams as ConstraintLayout.LayoutParams).topMargin
            val imageBottomMargin = (imageView.layoutParams as ConstraintLayout.LayoutParams).bottomMargin
            return availableHeight - (imageTopMargin + imageBottomMargin)
        }
    }

    private fun createBackgroundDrawable(item: Item): Drawable {
        val drawable = GradientDrawable()
        drawable.shape = GradientDrawable.RECTANGLE
        drawable.setStroke(2, Color.BLACK)
        drawable.cornerRadius = 8f
        drawable.setColor(item.category.color())
        return drawable
    }

    private fun getResizedDrawable(drawableId: Int, size: Int): Drawable {
        val drawable: Drawable?
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            drawable = context.resources.getDrawable(drawableId)
        } else {
            drawable = context.getDrawable(drawableId)
        }

        val bitmap = (drawable as BitmapDrawable).bitmap
        return BitmapDrawable(resources,
                Bitmap.createScaledBitmap(bitmap, size, size, true))
    }


    private fun doSpreadsheetScan(delay: Int) {
        mTimer = Timer()
        mTimer!!.schedule(object : TimerTask() {
            override fun run() {
                try {
                    currentItemSelectedFromScan++
                    if (currentItemSelectedFromScan > mItemsLayout!!.size - 1) {
                        currentItemSelectedFromScan = 0
                    }
                    activity.runOnUiThread {
                        //Highlight current selected item
                        if (context != null && mItemsLayout != null && currentItemSelectedFromScan < mItemsLayout!!.size) {
                            Log.d("Test", "hightlight current item: " + currentItemSelectedFromScan)
                            mItemsLayout!![currentItemSelectedFromScan].foreground = context.resources.getDrawable(R.drawable.pressed_color)
                        }
                        var previousItem = currentItemSelectedFromScan - 1
                        if (previousItem < 0) {
                            previousItem = mItemsLayout!!.size - 1
                        }
                        //remove highlight from previus item
                        if (context != null && mItemsLayout != null && previousItem < mItemsLayout!!.size) {
                            Log.d("Test", "remove hightlight current item: " + previousItem)
                            mItemsLayout!![previousItem].foreground = context.resources.getDrawable(R.drawable.normal_color)
                        }
                    }
                } catch (e: Exception) {
                    Log.e("Error", "ViewPagerItemFragment:run:256 ")
                }

            }
        }, 0, delay.toLong())
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

    interface OnFragmentInteractionListener {
        fun openPage(linkTo: String)

        fun speak(msg: String)
    }

    companion object {
        private val ITEMS_PARAM = "items"
        private val COLUMNS_PARAM = "columns"
        private val ROWS_PARAM = "rows"
        private val MARGIN_WIDTH = "marginWidth"

        fun newInstance(items: ArrayList<Item>, columns: Int, rows: Int, width: Int): ViewPagerItemFragment {
            val fragment = ViewPagerItemFragment()
            val args = Bundle()
            args.putParcelableArrayList(ITEMS_PARAM, items)
            args.putInt(COLUMNS_PARAM, columns)
            args.putInt(ROWS_PARAM, rows)
            args.putInt(MARGIN_WIDTH, width)
            fragment.arguments = args
            return fragment
        }
    }
}
