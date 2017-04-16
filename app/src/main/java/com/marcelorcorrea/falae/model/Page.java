package com.marcelorcorrea.falae.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by marcelo on 4/11/17.
 */

public class Page {
    private List<Item> items = new ArrayList<>();

    public List<Item> getItems() {
        return items;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }
}
