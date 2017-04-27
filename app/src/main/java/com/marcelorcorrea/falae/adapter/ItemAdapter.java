package com.marcelorcorrea.falae.adapter;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Category;
import com.marcelorcorrea.falae.model.Item;
import com.squareup.picasso.Picasso;

import java.util.List;

public class ItemAdapter extends RecyclerView.Adapter<ItemAdapter.ItemViewHolder> {

    public interface OnItemClickListener {
        void onItemClick(Item item);
    }

    private final OnItemClickListener mListener;
    private final List<Item> mItems;
    private final Context mContext;
    private final int mSpanCount;

    public ItemAdapter(Context context, int spanCount, List<Item> items, OnItemClickListener listener) {
        this.mItems = items;
        this.mSpanCount = spanCount;
        this.mContext = context;
        this.mListener = listener;
    }

    @Override
    public ItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item, parent, false);
        return new ItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ItemViewHolder holder, int position) {
        holder.bind(mItems.get(position), mListener);
    }


    @Override
    public int getItemCount() {
        return mItems.size();
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
            if (item.getCategory() == Category.SUBJECT) {
                name.setTextColor(Color.BLACK);
            }

            //TODO remove this logic from here
            DisplayMetrics metrics = new DisplayMetrics();
            ((Activity) mContext).getWindowManager().getDefaultDisplay().getMetrics(metrics);
            int widthPixels = metrics.widthPixels;
            int totalItemDimension = (widthPixels / mSpanCount) - 3; // 3px is the space for border
            int imageDimension = (int) (totalItemDimension - Math.round(totalItemDimension * 0.3)); // image dimension is the totalDimension minus 30%

            layout.getLayoutParams().height = totalItemDimension;
            layout.getLayoutParams().width = totalItemDimension;
            Picasso.with(mContext)
                    .load(item.getImgSrc())
                    .placeholder(R.drawable.ic_image_black_48dp)
                    .error(R.drawable.ic_broken_image_black_48dp)
                    .resize(imageDimension, imageDimension)
                    .centerCrop()
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