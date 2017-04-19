package com.marcelorcorrea.falae.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by marcelo on 4/11/17.
 */

public class Page implements Parcelable {

    private String name;
    private List<Item> items = new ArrayList<>();

    public List<Item> getItems() {
        return items;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void addItem(Item item) {
        items.add(item);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.name);
        dest.writeTypedList(this.items);
    }

    public Page() {
    }

    protected Page(Parcel in) {
        this.name = in.readString();
        this.items = in.createTypedArrayList(Item.CREATOR);
    }

    public static final Creator<Page> CREATOR = new Creator<Page>() {
        @Override
        public Page createFromParcel(Parcel source) {
            return new Page(source);
        }

        @Override
        public Page[] newArray(int size) {
            return new Page[size];
        }
    };
}
