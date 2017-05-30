package com.marcelorcorrea.falae.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by corream on 17/05/2017.
 */

public class User implements Parcelable {

    private String name;
    private String email;
    private List<SpreadSheet> spreadSheets;
    private String info;
    private String photoSrc;

    public User(String name, String email) {
        this.name = name;
        this.email = email;
    }

    public User(String name, String email, List<SpreadSheet> spreadSheets, String info, String photoSrc) {
        this.name = name;
        this.email = email;
        this.spreadSheets = spreadSheets;
        this.info = info;
        this.photoSrc = photoSrc;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public List<SpreadSheet> getSpreadSheets() {
        return spreadSheets;
    }

    public void setSpreadSheets(List<SpreadSheet> spreadSheets) {
        this.spreadSheets = spreadSheets;
    }

    public String getInfo() {
        return info;
    }

    public void setInfo(String info) {
        this.info = info;
    }

    public String getPhotoSrc() {
        return photoSrc;
    }

    public void setPhotoSrc(String photoSrc) {
        this.photoSrc = photoSrc;
    }

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", spreadSheets=" + spreadSheets +
                ", info=" + info +
                ", photoSrc=" + photoSrc +
                '}';
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.name);
        dest.writeString(this.email);
        dest.writeTypedList(this.spreadSheets);
        dest.writeString(this.info);
        dest.writeString(this.photoSrc);
    }

    public User() {
    }

    protected User(Parcel in) {
        this.name = in.readString();
        this.email = in.readString();
        this.spreadSheets = in.createTypedArrayList(SpreadSheet.CREATOR);
        this.info = in.readString();
        this.photoSrc = in.readString();
    }

    public static final Parcelable.Creator<User> CREATOR = new Parcelable.Creator<User>() {
        @Override
        public User createFromParcel(Parcel source) {
            return new User(source);
        }

        @Override
        public User[] newArray(int size) {
            return new User[size];
        }
    };
}
