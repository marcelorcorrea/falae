package com.marcelorcorrea.falae.model;

import android.graphics.Color;

/**
 * Created by marcelo on 4/12/17.
 */

public enum Category {
    GREETINGS_SOCIAL_EXPRESSIONS(Color.parseColor("#CC6699")),
    SUBJECT(Color.parseColor("#E6E600")),
    VERB(Color.parseColor("#009900")),
    NOUN(Color.parseColor("#FFA500")),
    ADJECTIVE(Color.BLUE),
    OTHER(Color.WHITE);

    private int color;

    Category(int color) {
        this.color = color;
    }

    public int color() {
        return color;
    }
}
