package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.adapter.ItemAdapter;
import com.marcelorcorrea.falae.decoration.SpacesItemDecoration;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

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
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_page, container, false);
        RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler);

        textToSpeech = new TextToSpeech(getContext(), new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (status != TextToSpeech.ERROR) {
                    textToSpeech.setLanguage(new Locale("pt", "BR"));
                }
            }
        });
        int spanCount = 6;
        RecyclerView.LayoutManager layout = new GridLayoutManager(getContext(), spanCount, GridLayoutManager.VERTICAL, false);
        recyclerView.setAdapter(new ItemAdapter(getContext(), spanCount, page.getItems(), new ItemAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(Item item) {
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
        }));
        recyclerView.addItemDecoration(new SpacesItemDecoration(3, spanCount));
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(layout);
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

    public interface OnFragmentInteractionListener {
        void openPageFragment(SpreadSheet spreadSheet, String linkTo);
    }
}
