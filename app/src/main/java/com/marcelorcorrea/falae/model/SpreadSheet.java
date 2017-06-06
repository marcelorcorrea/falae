package com.marcelorcorrea.falae.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by marcelo on 4/11/17.
 */

public class SpreadSheet implements Parcelable {

    private String name;
    private String initialPage;
    private List<Page> pages = new ArrayList<>();

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Page> getPages() {
        return pages;
    }

    public void setPages(List<Page> pages) {
        this.pages = pages;
    }

    public String getInitialPage() {
        return initialPage;
    }

    public void setInitialPage(String initialPage) {
        this.initialPage = initialPage;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.name);
        dest.writeString(this.initialPage);
        dest.writeTypedList(this.pages);
    }

    public SpreadSheet() {
    }

    protected SpreadSheet(Parcel in) {
        this.name = in.readString();
        this.initialPage = in.readString();
        this.pages = in.createTypedArrayList(Page.CREATOR);
    }

    public static final Creator<SpreadSheet> CREATOR = new Creator<SpreadSheet>() {
        @Override
        public SpreadSheet createFromParcel(Parcel source) {
            return new SpreadSheet(source);
        }

        @Override
        public SpreadSheet[] newArray(int size) {
            return new SpreadSheet[size];
        }
    };
}
