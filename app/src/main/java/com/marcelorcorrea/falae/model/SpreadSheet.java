package com.marcelorcorrea.falae.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by marcelo on 4/11/17.
 */

public class SpreadSheet {

    private List<Page> pages = new ArrayList<>();

    public List<Page> getPages() {
        return pages;
    }

    public void setPages(List<Page> pages) {
        this.pages = pages;
    }
}
