package com.marcelorcorrea.falae.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.List;

/**
 * Created by corream on 17/05/2017.
 */

public class User implements Parcelable {

    private int id;
    private String name;
    private String email;
    private List<SpreadSheet> spreadsheets;
    private String info;
    private String photoSrc;

    public User(int id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    public User(int id, String name, String email, List<SpreadSheet> spreadsheets, String info, String photoSrc) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.spreadsheets = spreadsheets;
        this.info = info;
        this.photoSrc = photoSrc;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public List<SpreadSheet> getSpreadsheets() {
        return spreadsheets;
    }

    public void setSpreadsheets(List<SpreadSheet> spreadsheets) {
        this.spreadsheets = spreadsheets;
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
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", spreadsheets=" + spreadsheets +
                ", info='" + info + '\'' +
                ", photoSrc='" + photoSrc + '\'' +
                '}';
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(this.id);
        dest.writeString(this.name);
        dest.writeString(this.email);
        dest.writeTypedList(this.spreadsheets);
        dest.writeString(this.info);
        dest.writeString(this.photoSrc);
    }

    protected User(Parcel in) {
        this.id = in.readInt();
        this.name = in.readString();
        this.email = in.readString();
        this.spreadsheets = in.createTypedArrayList(SpreadSheet.CREATOR);
        this.info = in.readString();
        this.photoSrc = in.readString();
    }

    public static final Creator<User> CREATOR = new Creator<User>() {
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
