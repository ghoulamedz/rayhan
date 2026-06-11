package com.rayhan.erp.dto.request;

import com.rayhan.erp.model.Article;
import jakarta.validation.Valid;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class ArticleRequest {
    @Valid
    private Article article;

    private List<BomLineEntry> bomLines;

    @Data
    public static class BomLineEntry {
        private Long composantId;
        private BigDecimal quantiteParUnite;
        private String uniteMesure;
    }
}
