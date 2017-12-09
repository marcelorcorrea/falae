package com.marcelorcorrea.falae.model

import android.os.Parcel
import android.os.Parcelable

/**
 * Created by marcelo on 4/11/17.
 */

data class SpreadSheet(val name: String, val initialPage: String, val pages: List<Page>) : Parcelable {

    constructor(parcel: Parcel) : this(
            parcel.readString(),
            parcel.readString(),
            parcel.createTypedArrayList(Page.CREATOR))

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(name)
        parcel.writeString(initialPage)
        parcel.writeTypedList(pages)
    }

    override fun describeContents(): Int = 0

    companion object CREATOR : Parcelable.Creator<SpreadSheet> {
        override fun createFromParcel(parcel: Parcel): SpreadSheet = SpreadSheet(parcel)

        override fun newArray(size: Int): Array<SpreadSheet?> = arrayOfNulls(size)
    }

}
