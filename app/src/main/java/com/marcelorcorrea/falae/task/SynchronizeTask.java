package com.marcelorcorrea.falae.task;

import android.app.ProgressDialog;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.webkit.MimeTypeMap;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;

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
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;


/**
 * Created by corream on 15/05/2017.
 */

public class SynchronizeTask extends AsyncTask<String, Void, List<SpreadSheet>> {

    private final Callback callback;
    private Context context;
    private ProgressDialog pDialog;
    private ExecutorService executorService;

    public SynchronizeTask(Context context, SynchronizeTask.Callback callback) {
        this.context = context;
        this.callback = callback;
        executorService = Executors.newCachedThreadPool();
    }

    public interface Callback {
        void onSyncComplete(List<SpreadSheet> spreadSheets);
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
    protected List<SpreadSheet> doInBackground(String... params) {
        List<SpreadSheet> spreadSheets = createMockSpreadsheets(); //request web service.

        for (SpreadSheet spreadSheet : spreadSheets) {
            for (Page page : spreadSheet.getPages()) {
                for (final Item item : page.getItems()) {
                    try {
                        Future<String> stringFuture = executorService.submit(new Callable<String>() {
                            @Override
                            public String call() throws Exception {
                                System.out.println("Downloading item: " + item.getName());
                                return download(item.getName(), item.getImgSrc());
                            }
                        });
                        item.setImgSrc(stringFuture.get());
                        System.out.println(item.getImgSrc());
                    } catch (InterruptedException | ExecutionException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return spreadSheets;
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
    protected void onPostExecute(List<SpreadSheet> spreadSheets) {
        if (callback != null) {
            callback.onSyncComplete(spreadSheets);
        }
        executorService.shutdown();
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
