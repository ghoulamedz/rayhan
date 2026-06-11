package com.rayhan.erp.service;

import com.rayhan.erp.dto.request.ArticleRequest;
import com.rayhan.erp.model.Article;
import com.rayhan.erp.model.BomLine;
import com.rayhan.erp.repository.ArticleRepository;
import com.rayhan.erp.repository.BomLineRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ArticleService {

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private BomLineRepository bomLineRepository;

    public List<Article> getAllArticles() {
        return articleRepository.findByActifTrue();
    }

    public List<Article> getPublicCatalog() {
        return articleRepository.findByTypeAndActifTrue(Article.TypeArticle.PF);
    }

    public List<Article> getArticlesByType(Article.TypeArticle type) {
        return articleRepository.findByType(type);
    }

    public List<Article> getArticlesEnAlerte() {
        return articleRepository.findByStockActuelLessThanEqualAndActifTrue(java.math.BigDecimal.ZERO);
    }

    public Article getArticleById(Long id) {
        return articleRepository.findById(id).orElse(null);
    }

    @Transactional
    public Article createArticle(ArticleRequest request) {
        Article article = request.getArticle();
        validateBom(article, request.getBomLines());

        article = articleRepository.save(article);
        saveBomLines(article, request.getBomLines());
        return article;
    }

    @Transactional
    public Article updateArticle(Long id, ArticleRequest request) {
        return articleRepository.findById(id).map(article -> {
            Article details = request.getArticle();
            article.setDesignation(details.getDesignation());
            article.setType(details.getType());
            article.setUniteMesure(details.getUniteMesure());
            article.setPrixUnitaire(details.getPrixUnitaire());
            article.setStockMinimum(details.getStockMinimum());
            article.setAssetImage(details.getAssetImage());
            article = articleRepository.save(article);

            bomLineRepository.deleteByProduitFiniId(id);
            saveBomLines(article, request.getBomLines());
            return article;
        }).orElse(null);
    }

    public boolean deleteArticle(Long id) {
        return articleRepository.findById(id).map(article -> {
            article.setActif(false);
            articleRepository.save(article);
            return true;
        }).orElse(false);
    }

    public boolean existsById(Long id) {
        return articleRepository.existsById(id);
    }

    private void validateBom(Article article, List<ArticleRequest.BomLineEntry> bomLines) {
        if (article.getType() == Article.TypeArticle.PF || article.getType() == Article.TypeArticle.PSF) {
            if (bomLines == null || bomLines.isEmpty()) {
                throw new RuntimeException(
                    "Un produit fini ou semi-fini doit avoir une nomenclature (BOM)");
            }
        }
    }

    private void saveBomLines(Article produitFini, List<ArticleRequest.BomLineEntry> bomLines) {
        if (bomLines == null) return;
        for (ArticleRequest.BomLineEntry entry : bomLines) {
            BomLine line = new BomLine();
            line.setProduitFini(produitFini);
            Article composant = articleRepository.findById(entry.getComposantId())
                .orElseThrow(() -> new RuntimeException(
                    "Composant introuvable: " + entry.getComposantId()));
            line.setComposant(composant);
            line.setQuantiteParUnite(entry.getQuantiteParUnite());
            line.setUniteMesure(entry.getUniteMesure());
            bomLineRepository.save(line);
        }
    }
}
