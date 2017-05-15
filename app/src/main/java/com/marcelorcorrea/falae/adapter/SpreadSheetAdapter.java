package com.marcelorcorrea.falae.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.SpreadSheet;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by marcelo on 4/18/17.
 */

public class SpreadSheetAdapter extends RecyclerView.Adapter<SpreadSheetAdapter.SpreadSheetViewHolder> {
    public interface OnItemClickListener {
        void onItemClick(SpreadSheet spreadSheet);
    }

    private final SpreadSheetAdapter.OnItemClickListener listener;
    private List<SpreadSheet> spreadSheets;
    private Context context;

    public SpreadSheetAdapter(Context context, List<SpreadSheet> spreadSheets, SpreadSheetAdapter.OnItemClickListener listener) {
        this.spreadSheets = spreadSheets;
        this.context = context;
        this.listener = listener;
    }

    public void update(List<SpreadSheet> spreadSheets) {
        this.spreadSheets = spreadSheets;
        notifyDataSetChanged();
    }

    @Override
    public SpreadSheetViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.spreadsheet_item, parent, false);
        return new SpreadSheetViewHolder(view);
    }

    @Override
    public void onBindViewHolder(SpreadSheetViewHolder holder, int position) {
        holder.bind(spreadSheets.get(position), listener);
    }

    @Override
    public int getItemCount() {
        return spreadSheets.size();
    }

    public class SpreadSheetViewHolder extends RecyclerView.ViewHolder {
        final TextView name;

        SpreadSheetViewHolder(View view) {
            super(view);
            name = (TextView) view.findViewById(R.id.spreadsheet_name);
        }

        void bind(final SpreadSheet spreadSheet, final SpreadSheetAdapter.OnItemClickListener onItemClickListener) {
            name.setText(spreadSheet.getName());
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onItemClick(spreadSheet);
                }
            });

        }
    }
}
