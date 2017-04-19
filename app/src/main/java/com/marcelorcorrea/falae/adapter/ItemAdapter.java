package com.marcelorcorrea.falae.adapter;

import android.content.Context;
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

public class ItemAdapter extends RecyclerView.Adapter<ItemAdapter.ItemViewHolder> {
    public interface OnItemClickListener {
        void onItemClick(Item item);
    }

    private final OnItemClickListener listener;
    private List<Item> items;
    private Context context;

    public ItemAdapter(Context context, List<Item> items, OnItemClickListener listener) {
        this.items = items;
        this.context = context;
        this.listener = listener;
    }

    @Override
    public ItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item, parent, false);
        return new ItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ItemViewHolder holder, int position) {
        holder.bind(items.get(position), listener);
    }


    @Override
    public int getItemCount() {
        return items.size();
    }

    class ItemViewHolder extends RecyclerView.ViewHolder {
        final LinearLayout layout;
        final TextView name;
        final ImageView imageView;

        ItemViewHolder(View view) {
            super(view);
            name = (TextView) view.findViewById(R.id.item_name);
            imageView = (ImageView) view.findViewById(R.id.item_image_view);
            layout = (LinearLayout) view.findViewById(R.id.item_layout);
        }

        void bind(final Item item, final OnItemClickListener onItemClickListener) {
            name.setText(item.getName());
            layout.setBackgroundColor(item.getCategory().color());
            Picasso.with(context)
                    .load(item.getImgSrc())
                    .placeholder(R.drawable.ic_image_black_48dp)
                    .error(R.drawable.ic_broken_image_black_48dp)
                    .into(imageView);
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onItemClickListener.onItemClick(item);
                }
            });

        }
    }
}