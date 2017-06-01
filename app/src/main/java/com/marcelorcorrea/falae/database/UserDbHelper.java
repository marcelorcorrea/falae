package com.marcelorcorrea.falae.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by corream on 11/05/2017.
 */

public class UserDbHelper extends SQLiteOpenHelper {
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "Falae.db";

    public static class UserEntry implements BaseColumns {
        public static final String TABLE_NAME = "user";
        public static final String COLUMN_SPREADSHEETS = "spreadsheets";
        public static final String COLUMN_NAME = "name";
        public static final String COLUMN_EMAIL = "email";
        public static final String COLUMN_INFO = "info";
        public static final String COLUMN_PHOTO = "photoSrc";
    }

    private static final String SQL_CREATE_ENTRIES =
            "CREATE TABLE " + UserEntry.TABLE_NAME + " (" +
                    UserEntry._ID + " INTEGER PRIMARY KEY AUTOINCREMENT," +
                    UserEntry.COLUMN_NAME + " TEXT NOT NULL," +
                    UserEntry.COLUMN_EMAIL + " TEXT NOT NULL UNIQUE," +
                    UserEntry.COLUMN_INFO + " TEXT," +
                    UserEntry.COLUMN_PHOTO + " TEXT," +
                    UserEntry.COLUMN_SPREADSHEETS + " TEXT)";

    private static final String SQL_DELETE_ENTRIES =
            "DROP TABLE IF EXISTS " + UserEntry.TABLE_NAME;


    public UserDbHelper(Context context) {
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

    private ContentValues createUserContentValues(User user) {
        ContentValues contentValues = new ContentValues();
        contentValues.put(UserEntry.COLUMN_NAME, user.getName());
        contentValues.put(UserEntry.COLUMN_EMAIL, user.getEmail());
        contentValues.put(UserEntry.COLUMN_INFO, user.getInfo());
        contentValues.put(UserEntry.COLUMN_PHOTO, user.getPhotoSrc());
        contentValues.put(UserEntry.COLUMN_SPREADSHEETS, new Gson().toJson(user.getSpreadSheets()));
        return contentValues;
    }

    public long insert(User user) {
        ContentValues userContentValues = createUserContentValues(user);
        SQLiteDatabase db = getWritableDatabase();
        Log.d("FALAE", "Inserting entry...");
        return db.insert(UserEntry.TABLE_NAME, null, userContentValues);
    }

    public void update(User user) {
        ContentValues userContentValues = createUserContentValues(user);
        SQLiteDatabase db = getWritableDatabase();
        Log.d("FALAE", "Updating entry...");
        db.update(UserEntry.TABLE_NAME, userContentValues, UserEntry.COLUMN_EMAIL + "= ? ", new String[]{user.getEmail()});
    }

    public boolean doesUserExist(User user) {
        Cursor cursor = null;
        try {
            SQLiteDatabase db = getReadableDatabase();
            String[] projection = {
                    UserEntry.COLUMN_NAME,
            };
            String selection = UserEntry.COLUMN_EMAIL + " = ?";
            String[] selectionArgs = {user.getEmail()};
            cursor = db.query(UserEntry.TABLE_NAME, projection, selection, selectionArgs, null, null, null);
            return cursor.moveToFirst();
        } finally {
            if (cursor != null && !cursor.isClosed()) {
                cursor.close();
            }
        }
    }

    public User findByEmail(String email) {
        Cursor cursor = null;
        try {
            SQLiteDatabase db = getReadableDatabase();
            String[] projection = {
                    UserEntry._ID,
                    UserEntry.COLUMN_NAME,
                    UserEntry.COLUMN_EMAIL,
                    UserEntry.COLUMN_INFO,
                    UserEntry.COLUMN_PHOTO,
                    UserEntry.COLUMN_SPREADSHEETS
            };
            String selection = UserEntry.COLUMN_EMAIL + " = ?";
            String[] selectionArgs = {email};
            cursor = db.query(UserEntry.TABLE_NAME, projection, selection, selectionArgs, null, null, null);
            Type listType = new TypeToken<List<SpreadSheet>>() {
            }.getType();
            Gson gson = new Gson();
            if (cursor.moveToFirst()) {
                Long id = cursor.getLong(cursor.getColumnIndex(UserEntry._ID));
                String name = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_NAME));
                String e = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_EMAIL));
                String spreadSheetsJson = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_SPREADSHEETS));
                String info = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_INFO));
                String photoSrc = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_PHOTO));
                List<SpreadSheet> spreadSheets = gson.fromJson(spreadSheetsJson, listType);

                return new User(id.intValue(), name, e, spreadSheets, info, photoSrc);
            }
            if (!cursor.isClosed()) {
                cursor.close();
            }
            return null;
        } finally {
            if (cursor != null && !cursor.isClosed()) {
                cursor.close();
            }
        }
    }

    public List<User> read() {
        SQLiteDatabase db = getReadableDatabase();

        String[] projection = {
                UserEntry._ID,
                UserEntry.COLUMN_NAME,
                UserEntry.COLUMN_EMAIL,
        };

        Cursor cursor = db.query(UserEntry.TABLE_NAME, projection, null, null, null, null, null);

        List<User> users = new ArrayList<>();
        while (cursor.moveToNext()) {
            Long id = cursor.getLong(cursor.getColumnIndex(UserEntry._ID));
            String name = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_NAME));
            String email = cursor.getString(cursor.getColumnIndex(UserEntry.COLUMN_EMAIL));
            User user = new User(id.intValue(),name, email);
            users.add(user);
        }
        if (!cursor.isClosed()) {
            cursor.close();
        }
        return users;
    }
}
