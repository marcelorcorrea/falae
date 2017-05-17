package com.marcelorcorrea.falae.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.adapter.SpreadSheetAdapter;
import com.marcelorcorrea.falae.database.UserDbHelper;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;
import com.marcelorcorrea.falae.task.DownloadTask;


public class SpreadSheetFragment extends Fragment {

    private static final String USER_PARAM = "userParam";

    private OnFragmentInteractionListener mListener;
    private UserDbHelper dbHelper;
    private SpreadSheetAdapter spreadSheetAdapter;
    private User user;

    public SpreadSheetFragment() {
    }

    public static SpreadSheetFragment newInstance(User user) {
        SpreadSheetFragment fragment = new SpreadSheetFragment();
        Bundle args = new Bundle();
        args.putParcelable(USER_PARAM, user);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            user = getArguments().getParcelable(USER_PARAM);
        }
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_spread_sheet, container, false);
        RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.spreadsheet_recycler);
        spreadSheetAdapter = new SpreadSheetAdapter(getContext(), user.getSpreadSheets(), new SpreadSheetAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(SpreadSheet spreadSheet) {
                mListener.openPageFragment(spreadSheet, spreadSheet.getInitialPage());
            }
        });
        recyclerView.setAdapter(spreadSheetAdapter);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(layoutManager);
        setHasOptionsMenu(true);
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
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.navigation, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.synchronize) {
            synchronize();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void synchronize() {
        new DownloadTask(getContext(), new DownloadTask.Callback() {
            @Override
            public void onSyncComplete(User user) {
//                mSpreadSheets = spreadSheets;
//                dbHelper.insertOrUpdate(spreadSheets);
//                spreadSheetAdapter.update(mSpreadSheets);
            }
        }).execute();
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
}
