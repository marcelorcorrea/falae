package com.marcelorcorrea.falae.model;

/**
 * Created by marcelo on 4/11/17.
 */

public class Item {

    private String name;
    private String imgSrc;
    private String nameToPronounce;
    private Category category;

    public Item(String name, String imgSrc, String nameToPronounce, Category category) {
        this.name = name;
        this.imgSrc = imgSrc;
        this.nameToPronounce = nameToPronounce;
        this.category = category;
    }

    public String getName() {
        return name;
    }

    public String getImgSrc() {
        return imgSrc;
    }

    public String getNameToPronounce() {
        return nameToPronounce;
    }

    public Category getCategory() {
        return category;
    }

    public static Item of(String name, String imgSrc, String nameToPronounce, Category type) {
        return new Item(name, imgSrc, nameToPronounce, type);
    }
}
