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
    private int columns;
    private int rows;

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

    public int getColumns() {
        return columns;
    }

    public void setColumns(int columns) {
        this.columns = columns;
    }

    public int getRows() {
        return rows;
    }

    public void setRows(int rows) {
        this.rows = rows;
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
        dest.writeInt(this.columns);
        dest.writeInt(this.rows);
    }

    public Page() {
    }

    protected Page(Parcel in) {
        this.name = in.readString();
        this.items = in.createTypedArrayList(Item.CREATOR);
        this.columns = in.readInt();
        this.rows = in.readInt();
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
