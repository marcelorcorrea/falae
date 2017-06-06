package com.marcelorcorrea.falae.model;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by marcelo on 4/11/17.
 */

public class Item implements Parcelable {

    private String name;
    private String imgSrc;
    private String speech;
    private Category category;
    private String linkTo;

    public String getName() {
        return name;
    }

    public String getImgSrc() {
        return imgSrc;
    }

    public String getSpeech() {
        return speech;
    }

    public Category getCategory() {
        return category;
    }

    public String getLinkTo() {
        return linkTo;
    }

    public void setImgSrc(String imgSrc) {
        this.imgSrc = imgSrc;
    }

    public void setLinkTo(String linkTo) {
        this.linkTo = linkTo;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.name);
        dest.writeString(this.imgSrc);
        dest.writeString(this.speech);
        dest.writeInt(this.category == null ? -1 : this.category.ordinal());
        dest.writeString(this.linkTo);
    }

    protected Item(Parcel in) {
        this.name = in.readString();
        this.imgSrc = in.readString();
        this.speech = in.readString();
        int tmpCategory = in.readInt();
        this.category = tmpCategory == -1 ? null : Category.values()[tmpCategory];
        this.linkTo = in.readString();
    }

    public static final Creator<Item> CREATOR = new Creator<Item>() {
        @Override
        public Item createFromParcel(Parcel source) {
            return new Item(source);
        }

        @Override
        public Item[] newArray(int size) {
            return new Item[size];
        }
    };
}
