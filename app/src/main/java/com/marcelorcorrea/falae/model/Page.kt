package com.marcelorcorrea.falae.model

import android.os.Parcel
import android.os.Parcelable

/**
 * Created by marcelo on 4/11/17.
 */

class Page(val name: String, val items: MutableList<Item>, val columns: Int, val rows: Int) : Parcelable {

    override fun describeContents(): Int = 0

    override fun writeToParcel(dest: Parcel, flags: Int) {
        dest.writeString(this.name)
        dest.writeTypedList(this.items)
        dest.writeInt(this.columns)
        dest.writeInt(this.rows)
    }

    constructor(`in`: Parcel) : this(
            `in`.readString(),
            `in`.createTypedArrayList(Item.CREATOR),
            `in`.readInt(),
            `in`.readInt())

    companion object {

        val CREATOR: Parcelable.Creator<Page> = object : Parcelable.Creator<Page> {
            override fun createFromParcel(source: Parcel): Page = Page(source)

            override fun newArray(size: Int): Array<Page?> = arrayOfNulls(size)
        }
    }
}
