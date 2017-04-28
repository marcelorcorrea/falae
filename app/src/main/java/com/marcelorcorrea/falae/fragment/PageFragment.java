package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
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
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.squareup.picasso.Picasso;

import java.util.List;
import java.util.Locale;


public class PageFragment extends Fragment {
    private static final String SPREADSHEET_PARAM = "spreadsheetParam";
    private static final String PAGE_PARAM = "pageParam";

    private TextToSpeech textToSpeech;
    private Page page;
    private SpreadSheet spreadSheet;
    private OnFragmentInteractionListener mListener;

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
        int columns = 1;
        int rows = 3;
        gridLayout.setColumnCount(columns);
        gridLayout.setRowCount(rows);
        List<Item> items = page.getItems();
        for (final Item item : items) {
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
                        mListener.openPageFragment(spreadSheet, item.getLinkTo());
                    }
                }
            });

            TextView name = (TextView) layout.findViewById(R.id.item_name);
            ImageView imageView = (ImageView) layout.findViewById(R.id.item_image_view);
            name.setText(item.getName());
            if (item.getCategory() == Category.SUBJECT) {
                name.setTextColor(Color.BLACK);
            }
            GradientDrawable drawable = new GradientDrawable();
            drawable.setShape(GradientDrawable.RECTANGLE);
            drawable.setStroke(1, Color.BLACK);
            drawable.setCornerRadius(8);
            drawable.setColor(item.getCategory().color());
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                layout.setBackgroundDrawable(drawable);
            } else {
                layout.setBackground(drawable);
            }

            //TODO remove this logic from here
            DisplayMetrics metrics = new DisplayMetrics();
            getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);
            int widthPixels = metrics.widthPixels;
            int heightPixels = metrics.heightPixels;
            int widthDimension = Math.round(widthPixels / columns);
            int heightDimension = Math.round(heightPixels / rows);

            int size = widthDimension > heightDimension ? widthDimension : heightDimension;
            size = (size - (size * (columns * rows)));
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

    public interface OnFragmentInteractionListener {
        void openPageFragment(SpreadSheet spreadSheet, String linkTo);
    }
}
