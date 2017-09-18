package com.marcelorcorrea.falae.adapter

import android.content.Context
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView

import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.model.SpreadSheet

/**
 * Created by marcelo on 4/18/17.
 */

class SpreadSheetAdapter(private val context: Context, private val spreadSheets: List<SpreadSheet>, private val onItemClick: (spreadSheet: SpreadSheet) -> Unit) : RecyclerView.Adapter<SpreadSheetAdapter.SpreadSheetViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SpreadSheetViewHolder {
        val view = LayoutInflater.from(context).inflate(R.layout.spreadsheet_item, parent, false)
        return SpreadSheetViewHolder(view)
    }

    override fun onBindViewHolder(holder: SpreadSheetViewHolder, position: Int) {
        holder.bind(spreadSheets[position], onItemClick)
    }

    override fun getItemCount(): Int = spreadSheets.size

    inner class SpreadSheetViewHolder internal constructor(view: View) : RecyclerView.ViewHolder(view) {
        internal val name: TextView = view.findViewById(R.id.spreadsheet_name) as TextView

        internal fun bind(spreadSheet: SpreadSheet, onItemClickListener: (spreadSheet: SpreadSheet) -> Unit) {
            name.text = spreadSheet.name
            itemView.setOnClickListener { onItemClickListener(spreadSheet) }

        }
    }
}
