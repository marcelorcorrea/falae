package com.marcelorcorrea.falae.fragment;

import android.graphics.Color;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutCompat;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

public class ItemFragment extends Fragment {
    private static final String ITEMS_PARAM = "items";
    private static final String COLUMNS_PARAM = "columns";
    private static final String ROWS_PARAM = "rows";
    private static final String MARGIN_WIDTH = "marginWidth";

    private List<Item> mItems;

    private OnFragmentInteractionListener mListener;
    private int mColumns;
    private int mRows;
    private int mImageSize;
    private int mMarginWidth;

    public ItemFragment() {
    }

    public static ItemFragment newInstance(ArrayList<Item> items, int columns, int rows, int width) {
        ItemFragment fragment = new ItemFragment();
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
        onAttachFragment(getParentFragment());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_item, container, false);
        GridLayout gridLayout = (GridLayout) view.findViewById(R.id.grid_layout);
        gridLayout.setAlignmentMode(GridLayout.ALIGN_BOUNDS);
        gridLayout.setColumnCount(mColumns);
        gridLayout.setRowCount(mRows);

        Point layoutDimensions = calculateLayoutDimensions();

        for (final Item item : mItems) {
            ConstraintLayout layout = generateLayout(inflater, item, layoutDimensions);
            gridLayout.addView(layout);
        }
        return view;
    }

    private ConstraintLayout generateLayout(LayoutInflater inflater, final Item item, Point layoutDimensions) {
        final ConstraintLayout layout = (ConstraintLayout) inflater.inflate(R.layout.item, null, false);
        final TextView name = (TextView) layout.findViewById(R.id.item_name);
        final ImageView imageView = (ImageView) layout.findViewById(R.id.item_image_view);

        layout.setLayoutParams(new LinearLayoutCompat.LayoutParams(layoutDimensions.x, layoutDimensions.y));
        Drawable drawable = createBackgroundDrawable(item);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
            layout.setBackgroundDrawable(drawable);
        } else {
            layout.setBackground(drawable);
        }
        layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mListener.speak(item.getNameToPronounce());
                if (item.getLinkTo() != null) {
                    mListener.openPageFragment(item.getLinkTo());
                }
            }
        });

        name.setText(item.getName());
        if (item.getCategory() == Category.SUBJECT) {
            name.setTextColor(Color.BLACK);
        }

        if (mImageSize == 0) {
            mImageSize = calculateImageSize(layoutDimensions.x, layoutDimensions.y, name, imageView);
        }
        Picasso.with(getContext())
                .load(item.getImgSrc())
                .placeholder(R.drawable.ic_image_black_48dp)
                .error(R.drawable.ic_broken_image_black_48dp)
                .resize(mImageSize, mImageSize)
                .centerCrop()
                .into(imageView);

        return layout;
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
        int nameBoxHeight = nameTopMargin + name.getLineHeight();
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
        void openPageFragment(String linkTo);

        void speak(String msg);
    }
}
