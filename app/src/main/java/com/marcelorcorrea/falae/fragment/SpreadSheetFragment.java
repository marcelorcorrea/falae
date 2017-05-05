package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Bundle;
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
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

import org.apache.commons.io.IOUtils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Type;
import java.util.List;


public class SpreadSheetFragment extends Fragment {
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
        List<SpreadSheet> spreadsheets = createMockSpreadsheets();
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

    private List<SpreadSheet> createMockSpreadsheets() {
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
}
