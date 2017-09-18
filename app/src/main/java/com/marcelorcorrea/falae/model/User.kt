package com.marcelorcorrea.falae.model

import android.os.Parcel
import android.os.Parcelable

/**
 * Created by corream on 17/05/2017.
 */

class User(val id: Int, val name: String, val email: String, val spreadsheets: List<SpreadSheet> = emptyList(), val info: String = "", val photoSrc: String = "") : Parcelable {

    constructor(`in`: Parcel) : this(
            `in`.readInt(),
            `in`.readString(),
            `in`.readString(),
            `in`.createTypedArrayList(SpreadSheet.CREATOR),
            `in`.readString(),
            `in`.readString()
    )

    fun copy(id: Int = this.id,
             name: String = this.name,
             email: String = this.email,
             spreadsheets: List<SpreadSheet> = this.spreadsheets,
             info: String = this.info,
             photoSrc: String = this.photoSrc) = User(id, name, email, spreadsheets, info, photoSrc)


    override fun describeContents(): Int = 0

    override fun writeToParcel(dest: Parcel, flags: Int) {
        dest.writeLong(this.id.toLong())
        dest.writeString(this.name)
        dest.writeString(this.email)
        dest.writeTypedList(this.spreadsheets)
        dest.writeString(this.info)
        dest.writeString(this.photoSrc)
    }

    override fun toString(): String {
        return "User(id=$id, name='$name', email='$email', spreadsheets=$spreadsheets, info='$info', photoSrc='$photoSrc')"
    }

    companion object {

        val CREATOR: Parcelable.Creator<User> = object : Parcelable.Creator<User> {
            override fun createFromParcel(source: Parcel): User = User(source)

            override fun newArray(size: Int): Array<User?> = arrayOfNulls(size)
        }
    }


}
