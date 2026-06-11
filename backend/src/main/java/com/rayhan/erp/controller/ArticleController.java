package com.rayhan.erp.controller;

import com.rayhan.erp.dto.request.ArticleRequest;
import com.rayhan.erp.model.Article;
import com.rayhan.erp.service.ArticleService;
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
    private ArticleService articleService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION', 'ROLE_RESPONSABLE_VENTE', 'ROLE_RESPONSABLE_ACHAT', 'ROLE_MAGASINIER')")
    public List<Article> getAllArticles() {
        return articleService.getAllArticles();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION', 'ROLE_RESPONSABLE_VENTE', 'ROLE_RESPONSABLE_ACHAT', 'ROLE_MAGASINIER')")
    public ResponseEntity<Article> getArticleById(@PathVariable Long id) {
        Article article = articleService.getArticleById(id);
        return article != null ? ResponseEntity.ok(article) : ResponseEntity.notFound().build();
    }

    @GetMapping("/type/{type}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION', 'ROLE_RESPONSABLE_VENTE', 'ROLE_RESPONSABLE_ACHAT', 'ROLE_MAGASINIER')")
    public List<Article> getArticlesByType(@PathVariable Article.TypeArticle type) {
        return articleService.getArticlesByType(type);
    }

    @GetMapping("/alertes-stock")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION', 'ROLE_RESPONSABLE_VENTE', 'ROLE_RESPONSABLE_ACHAT', 'ROLE_MAGASINIER')")
    public List<Article> getArticlesEnAlerte() {
        return articleService.getArticlesEnAlerte();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION')")
    public Article createArticle(@Valid @RequestBody ArticleRequest request) {
        return articleService.createArticle(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_PRODUCTION')")
    public ResponseEntity<Article> updateArticle(@PathVariable Long id, @Valid @RequestBody ArticleRequest request) {
        Article updated = articleService.updateArticle(id, request);
        return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_PDG')")
    public ResponseEntity<?> deleteArticle(@PathVariable Long id) {
        boolean deleted = articleService.deleteArticle(id);
        return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
}
