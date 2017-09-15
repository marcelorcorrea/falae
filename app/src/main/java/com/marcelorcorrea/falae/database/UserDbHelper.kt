package com.marcelorcorrea.falae.database

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.marcelorcorrea.falae.model.SpreadSheet
import com.marcelorcorrea.falae.model.User
import java.util.*

/**
 * Created by corream on 11/05/2017.
 */

class UserDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    class UserEntry {
        companion object {

            val TABLE_NAME = "user"
            val COLUMN_SPREADSHEETS = "spreadsheets"
            val _ID = "_id"
            val COLUMN_NAME = "name"
            val COLUMN_EMAIL = "email"
            val COLUMN_INFO = "info"
            val COLUMN_PHOTO = "photoSrc"
            val _COUNT = "_count"
        }
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL(SQL_DELETE_ENTRIES)
        onCreate(db)
    }

    private fun createUserContentValues(user: User): ContentValues {
        val contentValues = ContentValues()
        contentValues.put(UserEntry.COLUMN_NAME, user.name)
        contentValues.put(UserEntry.COLUMN_EMAIL, user.email)
        contentValues.put(UserEntry.COLUMN_INFO, user.info)
        contentValues.put(UserEntry.COLUMN_PHOTO, user.photoSrc)
        contentValues.put(UserEntry.COLUMN_SPREADSHEETS, Gson().toJson(user.spreadsheets))
        return contentValues
    }

    fun insert(user: User): Long {
        val userContentValues = createUserContentValues(user)
        val db = writableDatabase
        Log.d("FALAE", "Inserting entry...")
        return db.insert(UserEntry.TABLE_NAME, null, userContentValues)
    }

    fun update(user: User) {
        val userContentValues = createUserContentValues(user)
        val db = writableDatabase
        Log.d("FALAE", "Updating entry...")
        db.update(UserEntry.TABLE_NAME, userContentValues, UserEntry.COLUMN_EMAIL + "= ? ", arrayOf(user.email))
    }

    fun doesUserExist(user: User): Boolean {
        var cursor: Cursor? = null
        try {
            val db = readableDatabase
            val projection = arrayOf(UserEntry.COLUMN_NAME)
            val selection = UserEntry.COLUMN_EMAIL + " = ?"
            val selectionArgs = arrayOf(user.email)
            cursor = db.query(UserEntry.TABLE_NAME, projection, selection, selectionArgs, null, null, null)
            return cursor!!.moveToFirst()
        } finally {
            if (cursor != null && !cursor.isClosed) {
                cursor.close()
            }
        }
    }

    fun findByEmail(email: String): User? {
        var cursor: Cursor? = null
        try {
            val db = readableDatabase
            val projection = arrayOf(UserEntry._ID, UserEntry.COLUMN_NAME, UserEntry.COLUMN_EMAIL, UserEntry.COLUMN_INFO, UserEntry.COLUMN_PHOTO, UserEntry.COLUMN_SPREADSHEETS)
            val selection = UserEntry.COLUMN_EMAIL + " = ?"
            val selectionArgs = arrayOf(email)
            cursor = db.query(UserEntry.TABLE_NAME, projection, selection, selectionArgs, null, null, null)
            val listType = object : TypeToken<List<SpreadSheet>>() {

            }.type
            val gson = Gson()
            if (cursor!!.moveToFirst()) {
                val id = cursor.getLong(cursor.getColumnIndex(UserEntry._ID))
                val name = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_NAME))
                val e = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_EMAIL))
                val spreadSheetsJson = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_SPREADSHEETS))
                val info = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_INFO))
                val photoSrc = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_PHOTO))
                val spreadSheets = gson.fromJson<List<SpreadSheet>>(spreadSheetsJson, listType)

                return User(id.toInt(), name, e, spreadSheets, info, photoSrc)
            }
            if (!cursor.isClosed) {
                cursor.close()
            }
            return null
        } finally {
            if (cursor != null && !cursor.isClosed) {
                cursor.close()
            }
        }
    }

    fun read(): List<User> {
        val db = readableDatabase

        val projection = arrayOf(UserEntry._ID, UserEntry.COLUMN_NAME, UserEntry.COLUMN_EMAIL)

        val cursor = db.query(UserEntry.TABLE_NAME, projection, null, null, null, null, null)

        val users = ArrayList<User>()
        while (cursor.moveToNext()) {
            val id = cursor.getLong(cursor.getColumnIndex(UserEntry._ID))
            val name = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_NAME))
            val email = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_EMAIL))
            val user = User(id.toInt(), name, email)
            users.add(user)
        }
        if (!cursor.isClosed) {
            cursor.close()
        }
        return users
    }

    companion object {
        val DATABASE_VERSION = 1
        val DATABASE_NAME = "Falae.db"

        private val SQL_CREATE_ENTRIES =
                "CREATE TABLE " + UserEntry.TABLE_NAME + " (" +
                        UserEntry._ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                        UserEntry.COLUMN_NAME + " TEXT NOT NULL," +
                        UserEntry.COLUMN_EMAIL + " TEXT NOT NULL UNIQUE," +
                        UserEntry.COLUMN_INFO + " TEXT," +
                        UserEntry.COLUMN_PHOTO + " TEXT," +
                        UserEntry.COLUMN_SPREADSHEETS + " TEXT)"

        private val SQL_DELETE_ENTRIES = "DROP TABLE IF EXISTS " + UserEntry.TABLE_NAME
    }
}
