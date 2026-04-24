package com.rayhan.erp.controller;

import com.rayhan.erp.model.Article;
import com.rayhan.erp.repository.ArticleRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/articles")
public class ArticleController {

    @Autowired
    ArticleRepository articleRepository;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public List<Article> getAllArticles() {
        return articleRepository.findByActifTrue();
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Article> getArticleById(@PathVariable Long id) {
        return articleRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("isAuthenticated()")
    public List<Article> getArticlesByType(@PathVariable Article.TypeArticle type) {
        return articleRepository.findByType(type);
    }

    @GetMapping("/alertes-stock")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_MAGASINIER', 'ROLE_RESPONSABLE_PRODUCTION')")
    public List<Article> getArticlesEnAlerte() {
        return articleRepository.findAll().stream()
            .filter(a -> a.isActif() && a.getStockActuel().compareTo(a.getStockMinimum()) <= 0)
            .toList();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION', 'ROLE_MAGASINIER')")
    public Article createArticle(@Valid @RequestBody Article article) {
        return articleRepository.save(article);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION')")
    public ResponseEntity<Article> updateArticle(@PathVariable Long id, @Valid @RequestBody Article details) {
        return articleRepository.findById(id)
            .map(article -> {
                article.setDesignation(details.getDesignation());
                article.setType(details.getType());
                article.setUniteMesure(details.getUniteMesure());
                article.setPrixUnitaire(details.getPrixUnitaire());
                article.setStockMinimum(details.getStockMinimum());
                return ResponseEntity.ok(articleRepository.save(article));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_PDG')")
    public ResponseEntity<?> deleteArticle(@PathVariable Long id) {
        return articleRepository.findById(id)
            .map(article -> {
                article.setActif(false);
                articleRepository.save(article);
                return ResponseEntity.ok().build();
            })
            .orElse(ResponseEntity.notFound().build());
    }
}
