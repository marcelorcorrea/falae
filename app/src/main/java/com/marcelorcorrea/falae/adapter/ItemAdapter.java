package com.marcelorcorrea.falae.adapter;

import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Item;
import com.squareup.picasso.Picasso;

import java.util.List;

public class ItemAdapter extends RecyclerView.Adapter {

    private List<Item> items;
    private Context context;

    public ItemAdapter(Context context, List<Item> items) {
        this.items = items;
        this.context = context;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item, parent, false);
        return new ItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        ItemViewHolder itemViewHolder = (ItemViewHolder) holder;

        Item item = items.get(position);
        System.out.println(item.getImgSrc());
        itemViewHolder.name.setText(item.getName());
        itemViewHolder.layout.setBackgroundColor(item.getCategory().color());
        Picasso.with(context)
                .load(item.getImgSrc())
                .placeholder(R.drawable.ic_image_black_48dp)
                .error(R.drawable.ic_broken_image_black_48dp)
                .into(itemViewHolder.imageView);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static class ItemViewHolder extends RecyclerView.ViewHolder {
        final LinearLayout layout;
        final TextView name;
        final ImageView imageView;

        ItemViewHolder(View view) {
            super(view);
            name = (TextView) view.findViewById(R.id.spreadsheet_item_name);
            imageView = (ImageView) view.findViewById(R.id.spreadsheet_item_image_view);
            layout = (LinearLayout) view.findViewById(R.id.item_layout);
        }
    }
}