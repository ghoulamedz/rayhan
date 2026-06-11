package com.rayhan.erp.dto;

public class TrendingProduct {
    private String title;
    private String description;
    private String imageUrl;
    private String linkUrl;
    private String source;

    public TrendingProduct() {}

    public TrendingProduct(String title, String description, String imageUrl, String linkUrl, String source) {
        this.title = title;
        this.description = description;
        this.imageUrl = imageUrl;
        this.linkUrl = linkUrl;
        this.source = source;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getLinkUrl() { return linkUrl; }
    public void setLinkUrl(String linkUrl) { this.linkUrl = linkUrl; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
}
