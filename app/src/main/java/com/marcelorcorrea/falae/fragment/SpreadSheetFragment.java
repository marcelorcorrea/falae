package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.adapter.SpreadSheetAdapter;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

import org.apache.commons.io.IOUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;


public class SpreadSheetFragment extends Fragment {
    private TextToSpeech textToSpeech;

    private OnFragmentInteractionListener mListener;

    public SpreadSheetFragment() {
    }

    public static SpreadSheetFragment newInstance() {
        return new SpreadSheetFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        createMockSpreadsheets();
        List<SpreadSheet> spreadsheets = createMockSpreadsheets2();
        View view = inflater.inflate(R.layout.fragment_spread_sheet, container, false);
        RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.spreadsheet_recycler);
        recyclerView.setAdapter(new SpreadSheetAdapter(getContext(), spreadsheets, new SpreadSheetAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(SpreadSheet spreadSheet) {
                mListener.openPageFragment(spreadSheet, spreadSheet.getInitialPage());
            }
        }));
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(layoutManager);
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

    public Page getPage(SpreadSheet spreadSheet, String name) {
        for (Page page : spreadSheet.getPages()) {
            if (page.getName().equals(name)) {
                return page;
            }
        }
        return null;
    }

    public interface OnFragmentInteractionListener {
        void openPageFragment(SpreadSheet spreadSheet, String linkTo);
    }

    private List<SpreadSheet> createMockSpreadsheets2() {
        List<SpreadSheet> spreadSheets = null;
        try {
            InputStream raw = getResources().openRawResource(R.raw.mockspreadsheet);
            Reader is = new BufferedReader(new InputStreamReader(raw, "UTF8"));
            String string = IOUtils.toString(is);
            Type listType = new TypeToken<List<SpreadSheet>>() {
            }.getType();
            spreadSheets = new Gson().fromJson(string, listType);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return spreadSheets;
    }

    private List<SpreadSheet> createMockSpreadsheets() {
        Page mainPage = new Page();
        mainPage.setName("Main");

        Page foodPage = new Page();
        foodPage.setName("FoodPage");
        foodPage.addItem(Item.of("Donut", "https://s-media-cache-ak0.pinimg.com/originals/a9/a0/75/a9a075788700ecec89413dce43408d26.jpg", "Donut", Category.NOUN));
        foodPage.addItem(Item.of("Sanduíche", "https://rchaybok.files.wordpress.com/2009/02/homereatingsub.jpg", "Sanduíche", Category.NOUN));
        foodPage.addItem(Item.of("Bolo", "http://www.taurusarmed.net/forums/attachments/diner/68891d1385221291-pie-homer_drool.jpg", "Bolo", Category.NOUN));

        Page drinkPage = new Page();
        drinkPage.setName("DrinkPage");
        drinkPage.addItem(Item.of("Cerveja", "http://www.plzdontletbuddie.com/uploads/1/2/1/5/12155558/2062398_orig.jpg", "Cerveja", Category.NOUN));
        drinkPage.addItem(Item.of("Água", "https://i.ytimg.com/vi/mM5q1Pzod1I/hqdefault.jpg", "Água", Category.NOUN));

        mainPage.addItem(Item.of("Comer", "http://static.tudointeressante.com.br/uploads/2016/02/comidas-desenhos-2-.jpg", "Comer", Category.VERB, "FoodPage"));
        mainPage.addItem(Item.of("Beber", "https://www.kegworks.com/wp/wp-content/uploads/2013/05/HomerSimpson22.gif", "Beber", Category.VERB, "DrinkPage"));
        mainPage.addItem(Item.of("Homer", "http://entretenimento.r7.com/blogs/keila-jimenez/files/2016/05/homer.jpg", "Homer", Category.SUBJECT));
        mainPage.addItem(Item.of("Olá", "http://2.bp.blogspot.com/-y2u_dCguCFY/Tjsi_14bDyI/AAAAAAAAAAs/MEO88PVvqQE/s1600/6536homer2.jpg", "Olá", Category.GREETINGS_SOCIAL_EXPRESSIONS));
        mainPage.addItem(Item.of("Gordo", "http://38.media.tumblr.com/23e8c8f2fd524f82076f050415b4e5e9/tumblr_n26z0jKDer1qh59n0o2_500.png", "Gordo", Category.ADJECTIVE));


        SpreadSheet ss = new SpreadSheet();
        ss.setName("Prancha 1");
        ss.setInitialPage("Main");
        ss.addPages(mainPage, foodPage, drinkPage);
        List<SpreadSheet> spreadSheets = new ArrayList<>();
        spreadSheets.add(ss);

        String s = new Gson().toJson(spreadSheets);
        System.out.println(s);
        return spreadSheets;
    }
}
