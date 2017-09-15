package com.marcelorcorrea.falae.model

import android.graphics.Color

/**
 * Created by marcelo on 4/12/17.
 */

enum class Category(private val color: Int) {
    GREETINGS_SOCIAL_EXPRESSIONS(Color.parseColor("#CC6699")),
    SUBJECT(Color.parseColor("#E6E600")),
    VERB(Color.parseColor("#009900")),
    NOUN(Color.parseColor("#FFA500")),
    ADJECTIVE(Color.BLUE),
    OTHER(Color.WHITE);

    fun color(): Int = color
}
