package com.marcelorcorrea.falae;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridLayout;
import android.widget.GridView;
import android.widget.LinearLayout;

import com.marcelorcorrea.falae.adapter.ItemAdapter;
import com.marcelorcorrea.falae.decoration.SpacesItemDecoration;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link SpreadSheetFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link SpreadSheetFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class SpreadSheetFragment extends Fragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    public SpreadSheetFragment() {
        // Required empty public constructor
    }

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment SpreadSheetFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static SpreadSheetFragment newInstance(String param1, String param2) {
        SpreadSheetFragment fragment = new SpreadSheetFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_spread_sheet, container, false);
        RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler);
//        GridView gridView = (GridView) view.findViewById(R.id.gridView);


        List<Item> items = Arrays.asList(Item.of("Comer", "http://static.tudointeressante.com.br/uploads/2016/02/comidas-desenhos-2-.jpg", "Comer", Category.VERB),
                Item.of("Homer", "http://entretenimento.r7.com/blogs/keila-jimenez/files/2016/05/homer.jpg", "Homer", Category.SUBJECT),
                Item.of("Olá", "http://2.bp.blogspot.com/-y2u_dCguCFY/Tjsi_14bDyI/AAAAAAAAAAs/MEO88PVvqQE/s1600/6536homer2.jpg", "Olá", Category.GREETINGS_SOCIAL_EXPRESSIONS),
                Item.of("Gordo", "http://38.media.tumblr.com/23e8c8f2fd524f82076f050415b4e5e9/tumblr_n26z0jKDer1qh59n0o2_500.png", "Gordo", Category.ADJECTIVE),
                Item.of("Cerveja", "http://www.plzdontletbuddie.com/uploads/1/2/1/5/12155558/2062398_orig.jpg", "Cerveja", Category.NOUN),
                Item.of("Donut", "https://s-media-cache-ak0.pinimg.com/originals/a9/a0/75/a9a075788700ecec89413dce43408d26.jpg", "Donut", Category.NOUN));

        List<Item> selectedItems = new ArrayList<>();
        int numberOfItems = 16;
        Random random = new Random();
        for (int i = 0; i < numberOfItems; i++) {
            int i1 = random.nextInt(items.size());
            selectedItems.add(items.get(i1));
        }

        recyclerView.setAdapter(new ItemAdapter(getContext(), selectedItems));
        RecyclerView.LayoutManager layout = new GridLayoutManager(getContext(), 3, GridLayoutManager.VERTICAL, false);
        recyclerView.addItemDecoration(new SpacesItemDecoration(5));
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(layout);
        return view;
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
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

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        void onFragmentInteraction(Uri uri);
    }
}
