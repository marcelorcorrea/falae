package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayout;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

public class ViewPagerItemFragment extends Fragment {
    private static final String ITEMS_PARAM = "items";
    private static final String COLUMNS_PARAM = "columns";
    private static final String ROWS_PARAM = "rows";
    private static final String MARGIN_WIDTH = "marginWidth";

    private List<Item> mItems;
    private List<FrameLayout> mItemsLayout;
    private OnFragmentInteractionListener mListener;
    private int mColumns;
    private int mRows;
    private int mMarginWidth;
    private boolean isScanMode = false;
    private int currentItemSelectedFromScan = -1;
    private GridLayout mGridLayout = null;
    private Timer mTimer;

    public ViewPagerItemFragment() {
    }

    public static ViewPagerItemFragment newInstance(ArrayList<Item> items, int columns, int rows, int width) {
        ViewPagerItemFragment fragment = new ViewPagerItemFragment();
        Bundle args = new Bundle();
        args.putParcelableArrayList(ITEMS_PARAM, items);
        args.putInt(COLUMNS_PARAM, columns);
        args.putInt(ROWS_PARAM, rows);
        args.putInt(MARGIN_WIDTH, width);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mItems = getArguments().getParcelableArrayList(ITEMS_PARAM);
            mColumns = getArguments().getInt(COLUMNS_PARAM);
            mRows = getArguments().getInt(ROWS_PARAM);
            mMarginWidth = getArguments().getInt(MARGIN_WIDTH);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_view_pager_item, container, false);
        mGridLayout = (GridLayout) view.findViewById(R.id.grid_layout);
        mGridLayout.setAlignmentMode(GridLayout.ALIGN_BOUNDS);
        mGridLayout.setColumnCount(mColumns);
        mGridLayout.setRowCount(mRows);

        Point layoutDimensions = calculateLayoutDimensions();

        mItemsLayout = new ArrayList<>();

        for (final Item item : mItems) {
            FrameLayout layout = generateLayout(inflater, item, layoutDimensions);
            mItemsLayout.add(layout);
            mGridLayout.addView(layout);
        }

        return view;
    }

    @Override
    public void onResume(){
        super.onResume();

        if(isScanMode){
            currentItemSelectedFromScan = -1;
            doSpreadsheetScan(1000);
        }
    }

    @Override
    public void onPause() {
        super.onPause();

        if(mTimer != null) {
            mTimer.purge();
            mTimer.cancel();
            mTimer = null;
        }
    }

    private FrameLayout generateLayout(LayoutInflater inflater, final Item item, final Point layoutDimensions) {
        final FrameLayout frameLayout = (FrameLayout) inflater.inflate(R.layout.item, null, false);
        final TextView name = (TextView) frameLayout.findViewById(R.id.item_name);
        final ImageView imageView = (ImageView) frameLayout.findViewById(R.id.item_image_view);
        final ImageView linkPage = (ImageView) frameLayout.findViewById(R.id.link_page);

        frameLayout.setLayoutParams(new FrameLayout.LayoutParams(layoutDimensions.x, layoutDimensions.y));
        Drawable drawable = createBackgroundDrawable(item);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
            frameLayout.setBackgroundDrawable(drawable);
        } else {
            frameLayout.setBackground(drawable);
        }
        frameLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Item itemSelected = item;

                if(isScanMode) {
                    itemSelected = mItems.get(currentItemSelectedFromScan);
                }

                onItemClicked(itemSelected);
            }
        });
        name.setText(item.getName());
        name.post(new Runnable() {
            @Override
            public void run() {
                int imageSize = calculateImageSize(layoutDimensions.x, layoutDimensions.y, name, imageView);

                if (item.getCategory() == Category.SUBJECT) {
                    name.setTextColor(Color.BLACK);
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                        linkPage.setImageDrawable(getContext().getResources().getDrawable(R.drawable.ic_launch_black_48dp));
                    } else {
                        linkPage.setImageDrawable(getContext().getDrawable(R.drawable.ic_launch_black_48dp));
                    }
                }
                Drawable brokenImage = getResizedDrawable(R.drawable.ic_broken_image_black_48dp, imageSize);
                Drawable placeHolderImage = getResizedDrawable(R.drawable.ic_image_black_48dp, imageSize);

                Picasso.with(getContext())
                        .load(item.getImgSrc())
                        .placeholder(placeHolderImage)
                        .error(brokenImage)
                        .resize(imageSize, imageSize)
                        .centerCrop()
                        .into(imageView);

                if (item.getLinkTo() != null) {
                    linkPage.setVisibility(View.VISIBLE);
                }
            }
        });
        return frameLayout;
    }

    private void onItemClicked(Item item){

        mListener.speak(item.getNameToPronounce());
        if (item.getLinkTo() != null) {
            mListener.openPage(item.getLinkTo());
        }
    }

    private Point calculateLayoutDimensions() {
        DisplayMetrics metrics = new DisplayMetrics();
        getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);
        int widthDimension = Math.round((metrics.widthPixels - mMarginWidth) / mColumns);
        int heightDimension = Math.round(metrics.heightPixels / mRows);
        return new Point(widthDimension, heightDimension);
    }

    private int calculateImageSize(int layoutWidth, int layoutHeight, TextView name, ImageView imageView) {
        int nameTopMargin = ((ConstraintLayout.LayoutParams) name.getLayoutParams()).topMargin;
        int nameBoxHeight = nameTopMargin + (name.getLineHeight() * name.getLineCount());
        int availableHeight = layoutHeight - nameBoxHeight;
        if (availableHeight > layoutWidth) {
            int imageLeftMargin = ((ConstraintLayout.LayoutParams) imageView.getLayoutParams()).leftMargin;
            int imageRightMargin = ((ConstraintLayout.LayoutParams) imageView.getLayoutParams()).rightMargin;
            return layoutWidth - (imageLeftMargin + imageRightMargin);
        } else {
            int imageTopMargin = ((ConstraintLayout.LayoutParams) imageView.getLayoutParams()).topMargin;
            int imageBottomMargin = ((ConstraintLayout.LayoutParams) imageView.getLayoutParams()).bottomMargin;
            return availableHeight - (imageTopMargin + imageBottomMargin);
        }
    }

    private Drawable createBackgroundDrawable(Item item) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setStroke(2, Color.BLACK);
        drawable.setCornerRadius(8);
        drawable.setColor(item.getCategory().color());
        return drawable;
    }

    private Drawable getResizedDrawable(int drawableId, int size) {
        Drawable drawable;
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            drawable = getContext().getResources().getDrawable(drawableId);
        } else {
            drawable = getContext().getDrawable(drawableId);
        }

        Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
        return new BitmapDrawable(getResources(),
                Bitmap.createScaledBitmap(bitmap, size, size, true));
    }


    private void doSpreadsheetScan(final int delay) {

        mTimer = new Timer();
        mTimer.schedule(new TimerTask() {
             @Override
             public void run() {

                 try {
                     currentItemSelectedFromScan++;

                     if (currentItemSelectedFromScan > mItemsLayout.size() - 1) {
                         currentItemSelectedFromScan = 0;
                     }

                     getActivity().runOnUiThread(new Runnable() {
                         @Override
                         public void run() {
                             //Highlight current selected item
                             if (getContext() != null && mItemsLayout != null && currentItemSelectedFromScan < mItemsLayout.size()) {
                                 Log.d("Test", "hightlight current item: " + currentItemSelectedFromScan);
                                 mItemsLayout.get(currentItemSelectedFromScan).setForeground(getContext().getResources().getDrawable(R.drawable.pressed_color));
                             }

                             int previousItem = currentItemSelectedFromScan - 1;

                             if (previousItem < 0) {
                                 previousItem = mItemsLayout.size() - 1;
                             }

                             //remove highlight from previus item
                             if (getContext() != null && mItemsLayout != null && previousItem < mItemsLayout.size()) {
                                 Log.d("Test", "remove hightlight current item: " + previousItem);
                                 mItemsLayout.get(previousItem).setForeground(getContext().getResources().getDrawable(R.drawable.normal_color));
                             }
                         }
                     });
                 } catch (Exception e) {
                     Log.e("Error", "ViewPagerItemFragment:run:256 ");
                 }
             }
         },0, delay);
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

    public interface OnFragmentInteractionListener {
        void openPage(String linkTo);

        void speak(String msg);
    }
}
