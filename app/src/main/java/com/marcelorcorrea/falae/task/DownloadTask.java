package com.marcelorcorrea.falae.task;

import android.app.ProgressDialog;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;
import android.webkit.MimeTypeMap;
import android.widget.Toast;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.model.Item;
import com.marcelorcorrea.falae.model.Page;
import com.marcelorcorrea.falae.model.SpreadSheet;
import com.marcelorcorrea.falae.model.User;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;


/**
 * Created by corream on 15/05/2017.
 */

public class DownloadTask extends AsyncTask<User, Void, User> {

    private static final int TIME_OUT = 6000;
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
            pDialog.setMessage(context.getString(R.string.synchronize_message));
            pDialog.setIndeterminate(false);
            pDialog.setCancelable(false);
            pDialog.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected User doInBackground(User... params) {
        if (!haveNetworkConnection()) {
            return null;
        }

        final User user = params[0];

        final File folder = new File(context.getFilesDir(), user.getEmail());
        if (!folder.exists()) {
            folder.mkdirs();
        }
        for (SpreadSheet spreadSheet : user.getSpreadSheets()) {
            for (Page page : spreadSheet.getPages()) {
                for (final Item item : page.getItems()) {
                    executor.execute(new Runnable() {
                        @Override
                        public void run() {
                            Log.d("DEBUG", "Downloading item: " + item.getName());
                            String uri = download(folder, item.getName(), item.getImgSrc());
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

    private String download(File folder, String name, String imgSrc) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(imgSrc);
        File filename = new File(folder, name + "." + extension);
        try {
            int read;
            URL url = new URL(imgSrc);
            URLConnection connection = url.openConnection();
            connection.setConnectTimeout(TIME_OUT);
            connection.setReadTimeout(TIME_OUT);
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
        if (callback != null && user != null) {
            callback.onSyncComplete(user);
        } else {
            Toast.makeText(context, context.getString(R.string.download_failed), Toast.LENGTH_LONG).show();
        }
        if (pDialog != null && pDialog.isShowing()) {
            pDialog.dismiss();
        }
    }

    private boolean haveNetworkConnection() {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Network[] allNetworks = cm.getAllNetworks();
            for (Network network : allNetworks) {
                NetworkInfo networkInfo = cm.getNetworkInfo(network);
                if (isConnected(networkInfo)) {
                    return true;
                }
            }
        } else {
            NetworkInfo[] netInfo = cm.getAllNetworkInfo();
            for (NetworkInfo networkInfo : netInfo) {
                if (isConnected(networkInfo)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean isConnected(NetworkInfo networkInfo) {
        return (networkInfo.getType() == ConnectivityManager.TYPE_WIFI ||
                networkInfo.getType() == ConnectivityManager.TYPE_MOBILE) &&
                networkInfo.isConnected();
    }
}
