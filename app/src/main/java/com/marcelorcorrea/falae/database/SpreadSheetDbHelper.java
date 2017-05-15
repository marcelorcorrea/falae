package com.marcelorcorrea.falae.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcelorcorrea.falae.model.SpreadSheet;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by corream on 11/05/2017.
 */

public class SpreadSheetDbHelper extends SQLiteOpenHelper {
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "Falae.db";

    public static class SpreadSheetEntry implements BaseColumns {
        public static final String TABLE_NAME = "spreadsheet";
        public static final String COLUMN_VALUE = "value";

    }

    private static final String SQL_CREATE_ENTRIES =
            "CREATE TABLE " + SpreadSheetEntry.TABLE_NAME + " (" +
                    SpreadSheetEntry._ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                    SpreadSheetEntry.COLUMN_VALUE + " TEXT)";

    private static final String SQL_DELETE_ENTRIES =
            "DROP TABLE IF EXISTS " + SpreadSheetEntry.TABLE_NAME;


    public SpreadSheetDbHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(SQL_CREATE_ENTRIES);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL(SQL_DELETE_ENTRIES);
        onCreate(db);
    }

    public void insert(List<SpreadSheet> spreadSheet) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(SpreadSheetEntry.COLUMN_VALUE, new Gson().toJson(spreadSheet));
        db.insert(SpreadSheetEntry.TABLE_NAME, null, contentValues);
    }

    public boolean isThereData() {
        SQLiteDatabase db = getReadableDatabase();
        long count = DatabaseUtils.queryNumEntries(db, SpreadSheetEntry.TABLE_NAME);
        return count > 0;
    }

    public List<SpreadSheet> read() {
        SQLiteDatabase db = getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT " + SpreadSheetEntry.COLUMN_VALUE + " from " + SpreadSheetEntry.TABLE_NAME, null);

        Gson gson = new Gson();
        Type listType = new TypeToken<List<SpreadSheet>>() {
        }.getType();
        List<SpreadSheet> spreadSheets = new ArrayList<>();
        if (cursor.moveToFirst()) {
            String jsonSpreadsheet = cursor.getString(cursor.getColumnIndex(SpreadSheetEntry.COLUMN_VALUE));
            spreadSheets = gson.fromJson(jsonSpreadsheet, listType);
        }
        if (!cursor.isClosed()) {
            cursor.close();
        }
        return spreadSheets;
    }
}
