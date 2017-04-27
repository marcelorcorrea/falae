package com.marcelorcorrea.falae.decoration;

import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;

public class SpacesItemDecoration extends RecyclerView.ItemDecoration {
    private final int spanCount;
    private int space;

    public SpacesItemDecoration(int space, int spanCount) {
        this.space = space;
        this.spanCount = spanCount;
    }

    @Override
    public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
        outRect.left = space;
        outRect.right = space;
//        outRect.bottom = space;

        if (parent.getChildLayoutPosition(view) >= spanCount) {
            outRect.top = space;
        } else {
            outRect.top = 0;
        }
    }
}