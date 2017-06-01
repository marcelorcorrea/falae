package com.marcelorcorrea.falae.fragment;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;

import com.marcelorcorrea.falae.R;
import com.marcelorcorrea.falae.storage.SharedPreferencesUtils;

public class SettingsFragment extends Fragment {

    public static final String SCAN_MODE = "scanMode";
    public static final String SEEK_BAR_PROGRESS = "seekBarProgress";
    public static final String SCAN_MODE_DURATION = "scanModeDuration";

    private SeekBar seekBar;
    private TextView seekBarValue;

    public SettingsFragment() {
    }

    public static SettingsFragment newInstance() {
        return new SettingsFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_settings, container, false);
        Switch scanMode = (Switch) view.findViewById(R.id.scan_mode);
        scanMode.setChecked(SharedPreferencesUtils.getBooleanPreferences(SCAN_MODE, getContext()));

        scanMode.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                SharedPreferencesUtils.storeBooleanPreferences(SCAN_MODE, isChecked, getContext());
            }
        });

        seekBarValue = (TextView) view.findViewById(R.id.seekbar_value);
        seekBar = (SeekBar) view.findViewById(R.id.seekBar);

        final int seekBarProgress = SharedPreferencesUtils.getIntPreferences(SEEK_BAR_PROGRESS, getContext());
        seekBar.post(new Runnable() {
            @Override
            public void run() {
                setSeekBarText(seekBarProgress);
                seekBar.setProgress(seekBarProgress);
            }
        });

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                setSeekBarText(progress);
                SharedPreferencesUtils.storeIntPreferences(SEEK_BAR_PROGRESS, progress, getContext());
                int timeMillis = progress * 500;
                SharedPreferencesUtils.storeIntPreferences(SCAN_MODE_DURATION, timeMillis, getContext());
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        return view;
    }

    private float calculateSeekBarPosition(int progress) {
        int seekBarPosition = (progress * ((seekBar.getWidth()) - 3 * seekBar.getThumbOffset())) / seekBar.getMax();
        return seekBar.getX() + seekBarPosition + seekBar.getThumbOffset() / 2;
    }

    public void setSeekBarText(int progress) {
        seekBarValue.setX(calculateSeekBarPosition(progress));
        seekBarValue.setText("" + progress * 0.5f);
    }
}
