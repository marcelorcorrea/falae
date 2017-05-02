package com.marcelorcorrea.falae.fragment;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutCompat;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class ItemFragment extends Fragment {
    private static final String ITEMS_PARAM = "items";
    private static final String COLUMNS_PARAM = "columns";
    private static final String ROWS_PARAM = "rows";

    private List<Item> mItems;

    private TextToSpeech textToSpeech;
    private OnFragmentInteractionListener mListener;
    private int mColumns;
    private int mRows;

    public ItemFragment() {
    }

    public static ItemFragment newInstance(ArrayList<Item> items, int columns, int rows) {
        ItemFragment fragment = new ItemFragment();
        Bundle args = new Bundle();
        args.putParcelableArrayList(ITEMS_PARAM, items);
        args.putInt(COLUMNS_PARAM, columns);
        args.putInt(ROWS_PARAM, rows);
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
        }
        onAttachFragment(getParentFragment());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_item, container, false);
        GridLayout gridLayout = (GridLayout) view.findViewById(R.id.grid_layout);

        textToSpeech = new TextToSpeech(getContext(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status != TextToSpeech.ERROR) {
                    textToSpeech.setLanguage(new Locale("pt", "BR"));
                }
            }
        });

        gridLayout.setAlignmentMode(GridLayout.ALIGN_BOUNDS);
        gridLayout.setColumnCount(mColumns);
        gridLayout.setRowCount(mRows);

        for (final Item item : mItems) {
            LinearLayout layout = (LinearLayout) inflater.inflate(R.layout.item, null, false);
            layout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Toast.makeText(getContext(), item.getName(), Toast.LENGTH_SHORT).show();
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        textToSpeech.speak(item.getNameToPronounce(), TextToSpeech.QUEUE_FLUSH, null, null);
                    } else {
                        textToSpeech.speak(item.getNameToPronounce(), TextToSpeech.QUEUE_FLUSH, null);
                    }
                    if (item.getLinkTo() != null) {
                        mListener.openPageFragment(item.getLinkTo());
                    }
                }
            });

            TextView name = (TextView) layout.findViewById(R.id.item_name);
            ImageView imageView = (ImageView) layout.findViewById(R.id.item_image_view);
            name.setText(item.getName());
            if (item.getCategory() == Category.SUBJECT) {
                name.setTextColor(Color.BLACK);
            }

            Drawable drawable = createGradientDrawable(item);
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                layout.setBackgroundDrawable(drawable);
            } else {
                layout.setBackground(drawable);
            }

            //TODO remove this logic from here
            DisplayMetrics metrics = new DisplayMetrics();
            getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);
            int widthDimension = Math.round(metrics.widthPixels / mColumns);
            int heightDimension = Math.round(metrics.heightPixels / mRows);
            int size = Math.min(widthDimension, heightDimension);
            size = (int) ((double) size - size * 25 / 100);
            layout.setLayoutParams(new LinearLayoutCompat.LayoutParams(widthDimension, heightDimension));
            Picasso.with(getContext())
                    .load(item.getImgSrc())
                    .placeholder(R.drawable.ic_image_black_48dp)
                    .error(R.drawable.ic_broken_image_black_48dp)
                    .resize(size, size)
                    .centerCrop()
                    .into(imageView);

            gridLayout.addView(layout);
        }
        return view;
    }

    private Drawable createGradientDrawable(Item item) {
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
    }
}
