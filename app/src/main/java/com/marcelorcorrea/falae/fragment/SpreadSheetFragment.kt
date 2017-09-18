package com.marcelorcorrea.falae.fragment

import android.content.DialogInterface
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v7.app.AlertDialog
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.*
import com.marcelorcorrea.falae.R
import com.marcelorcorrea.falae.adapter.SpreadSheetAdapter
import com.marcelorcorrea.falae.model.SpreadSheet
import com.marcelorcorrea.falae.model.User


class SpreadSheetFragment : Fragment() {

    private lateinit var mListener: OnFragmentInteractionListener
    private lateinit var spreadSheetAdapter: SpreadSheetAdapter
    private var user: User? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (arguments != null) {
            user = arguments.getParcelable(USER_PARAM)
        }
        onAttachFragment(parentFragment)
        setHasOptionsMenu(true)
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val view = inflater.inflate(R.layout.fragment_spread_sheet, container, false)
        val recyclerView = view.findViewById(R.id.spreadsheet_recycler) as RecyclerView
        spreadSheetAdapter = SpreadSheetAdapter(context, user!!.spreadsheets, { spreadSheet -> mListener.displayActivity(spreadSheet) })
        recyclerView.adapter = spreadSheetAdapter
        val layoutManager = LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false)
        recyclerView.layoutManager = layoutManager
        return view
    }

    override fun onAttachFragment(fragment: Fragment?) {
        if (fragment is OnFragmentInteractionListener) {
            mListener = fragment
        } else {
            throw RuntimeException(fragment!!.toString() + " must implement OnFragmentInteractionListener")
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?, inflater: MenuInflater?) {
        inflater?.inflate(R.menu.board_menu, menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.remove_item -> {
                val confirmBuilder = AlertDialog.Builder(activity)
                val confirmDialog = confirmBuilder.setTitle(getString(R.string.removeUser))
                        .setMessage(getString(R.string.questionRemoveUser))
                        .setPositiveButton(getString(R.string.yes_option), { _, id ->
                            mListener.removeUser(user!!)
                        })
                        .setNegativeButton(getString(R.string.no_option), { _, _ -> })
                        .create()
                confirmDialog.setOnShowListener {
                    val buttonPositive = confirmDialog.getButton(AlertDialog.BUTTON_POSITIVE)
                    val buttonNegative = confirmDialog.getButton(AlertDialog.BUTTON_NEGATIVE)
                    buttonPositive.setTextColor(resources.getColor(R.color.colorAccent))
                    buttonNegative.setTextColor(resources.getColor(R.color.colorAccent))
                }
                confirmDialog.show()
                return true
            }
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onDetach() {
        super.onDetach()
    }

    interface OnFragmentInteractionListener {
        fun displayActivity(spreadSheet: SpreadSheet)
        fun removeUser(user: User)
    }

    companion object {

        private val USER_PARAM = "userParam"

        fun newInstance(user: User): SpreadSheetFragment {
            val fragment = SpreadSheetFragment()
            val args = Bundle()
            args.putParcelable(USER_PARAM, user)
            fragment.arguments = args
            return fragment
        }
    }
}
