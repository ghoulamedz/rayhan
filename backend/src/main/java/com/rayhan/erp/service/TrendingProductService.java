package com.rayhan.erp.service;

import com.rayhan.erp.dto.TrendingProduct;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TrendingProductService {

    public List<TrendingProduct> fetchTrending() {
        // Placeholder — returns hardcoded trending products in plastic bags
        // industry. Replace with real web scraping / API calls later.
        return List.of(
            new TrendingProduct(
                "Sacs poubelles biodégradables en amidon de maïs",
                "Demande croissante pour les sacs compostables certifiés EN 13432. Les grandes surfaces multiplient les références.",
                "https://images.unsplash.com/photo-1605600659873-2ef7cf0b7e5b?w=200",
                "https://www.google.com/search?q=sacs+poubelles+biodégradables+amidon+maïs",
                "Google Trends"
            ),
            new TrendingProduct(
                "Films agricoles phot sélectifs",
                "Innovation dans les films de paillage agricole qui filtrent des longueurs d'onde spécifiques pour améliorer les rendements.",
                "https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=200",
                "https://www.google.com/search?q=films+agricoles+photosélectifs",
                "Industry Reports"
            ),
            new TrendingProduct(
                "Sacs réutilisables en PP tissé",
                "Les interdictions des sacs plastique à usage unique boostent la demande de sacs réutilisables en polypropylène tissé.",
                "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200",
                "https://www.google.com/search?q=sacs+réutilisables+PP+tissé",
                "Market Analysis"
            ),
            new TrendingProduct(
                "Emballages souples mono-matériaux",
                "Tendance vers les films PE/PP mono-matériaux pour faciliter le recyclage, poussée par la réglementation PPWR européenne.",
                "https://images.unsplash.com/photo-1605600659873-2ef7cf0b7e5b?w=200",
                "https://www.google.com/search?q=emballages+souples+mono-matériaux+recyclage",
                "Plastics Today"
            ),
            new TrendingProduct(
                "Sacs à déchets alimentaires en PLA",
                "Avec le tri à la source des biodéchets obligatoire depuis 2024, les sacs en PLA pour déchets alimentaires explosent.",
                "https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=200",
                "https://www.google.com/search?q=sacs+déchets+alimentaires+PLA",
                "Packaging Europe"
            ),
            new TrendingProduct(
                "Films rétractables à base de résine recyclée PCR",
                "Les grandes marques exigent un minimum de 30% de contenu recyclé dans les films d'emballage secondaire.",
                "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200",
                "https://www.google.com/search?q=films+rétractables+PCR+résine+recyclée",
                "Plastic News"
            )
        );
    }
}
