package com.marcelorcorrea.falae.model

import android.os.Parcel
import android.os.Parcelable

/**
 * Created by corream on 17/05/2017.
 */

data class User(val id: Int, val name: String, val authToken: String = "", val email: String, val spreadsheets: List<SpreadSheet> = emptyList(), val info: String? = "", val photoSrc: String? = "") : Parcelable {

    constructor(`in`: Parcel) : this(
            `in`.readInt(),
            `in`.readString(),
            `in`.readString(),
            `in`.readString(),
            `in`.createTypedArrayList(SpreadSheet.CREATOR),
            `in`.readString(),
            `in`.readString()
    )

    override fun describeContents(): Int = 0

    override fun writeToParcel(dest: Parcel, flags: Int) {
        dest.writeLong(this.id.toLong())
        dest.writeString(this.name)
        dest.writeString(this.authToken)
        dest.writeString(this.email)
        dest.writeTypedList(this.spreadsheets)
        dest.writeString(this.info)
        dest.writeString(this.photoSrc)
    }

    companion object {

        val CREATOR: Parcelable.Creator<User> = object : Parcelable.Creator<User> {
            override fun createFromParcel(source: Parcel): User = User(source)

            override fun newArray(size: Int): Array<User?> = arrayOfNulls(size)
        }
    }


}
