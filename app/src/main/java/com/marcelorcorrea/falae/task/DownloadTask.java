package com.marcelorcorrea.falae.task;

import android.app.ProgressDialog;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;
import android.webkit.MimeTypeMap;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;

import org.apache.commons.io.IOUtils;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.lang.reflect.Type;
import java.net.URL;
import java.net.URLConnection;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;


/**
 * Created by corream on 15/05/2017.
 */

public class DownloadTask extends AsyncTask<User, Void, User> {

    private final Callback callback;
    private final ThreadPoolExecutor executor;
    private final int numberOfCores;
    private Context context;
    private ProgressDialog pDialog;

    public DownloadTask(Context context, DownloadTask.Callback callback) {
        this.context = context;
        this.callback = callback;
        numberOfCores = Runtime.getRuntime().availableProcessors();
        executor = new ThreadPoolExecutor(
                numberOfCores * 2,
                numberOfCores * 2,
                60L,
                TimeUnit.SECONDS,
                new LinkedBlockingQueue<Runnable>()
        );
    }

    public interface Callback {
        void onSyncComplete(User user);
    }

    @Override
    protected void onPreExecute() {
        try {
            if (pDialog != null) {
                pDialog = null;
            }
            pDialog = new ProgressDialog(context);
            pDialog.setMessage("Sincronizando ...");
            pDialog.setIndeterminate(false);
            pDialog.setCancelable(false);
            pDialog.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected User doInBackground(User... params) {
        User user = params[0];

        for (SpreadSheet spreadSheet : user.getSpreadSheets()) {
            for (Page page : spreadSheet.getPages()) {
                for (final Item item : page.getItems()) {
                    executor.execute(new Runnable() {
                        @Override
                        public void run() {
                            Log.d("DEBUG", "Downloading item: " + item.getName());
                            String uri = download(item.getName(), item.getImgSrc());
                            item.setImgSrc(uri);
                        }
                    });
                }
            }
        }
        executor.shutdown();
        try {
            executor.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return user;
    }

    private String download(String name, String imgSrc) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(imgSrc);
        File filename = new File(context.getFilesDir(), name + "." + extension);
        try {
            int read;
            URL url = new URL(imgSrc);
            URLConnection connection = url.openConnection();
            connection.connect();
            InputStream input = new BufferedInputStream(url.openStream(), 8192);
            OutputStream output = new FileOutputStream(filename);
            byte data[] = new byte[1024];
            while ((read = input.read(data)) != -1) {
                output.write(data, 0, read);
            }
            output.flush();
            output.close();
            input.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        Uri uri = Uri.fromFile(filename);
        return uri.toString();
    }

    @Override
    protected void onPostExecute(User user) {
        if (callback != null) {
            callback.onSyncComplete(user);
        }
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
    }

    private List<SpreadSheet> createMockSpreadsheets() {
        try {
            InputStream raw = context.getResources().openRawResource(R.raw.mockspreadsheet);
            Reader is = new BufferedReader(new InputStreamReader(raw, "UTF8"));
            String json = IOUtils.toString(is);

            Type listType = new TypeToken<List<SpreadSheet>>() {
            }.getType();
            return new Gson().fromJson(json, listType);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return Collections.emptyList();
    }
}
