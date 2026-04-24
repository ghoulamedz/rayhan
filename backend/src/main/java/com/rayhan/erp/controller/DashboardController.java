package com.rayhan.erp.controller;

import com.rayhan.erp.model.Article;
import com.rayhan.erp.model.ProductionOrder;
import com.rayhan.erp.model.PurchaseOrder;
import com.rayhan.erp.model.SalesOrder;
import com.rayhan.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired private SalesOrderRepository salesOrderRepository;
    @Autowired private PurchaseOrderRepository purchaseOrderRepository;
    @Autowired private ProductionOrderRepository productionOrderRepository;
    @Autowired private ArticleRepository articleRepository;

    /**
     * GET /api/dashboard
     * KPIs principaux pour le tableau de bord du PDG
     */
    @GetMapping
    @PreAuthorize("hasRole('ROLE_PDG')")
    public Map<String, Object> getDashboard() {
        Map<String, Object> dashboard = new HashMap<>();

        LocalDate debutMois = LocalDate.now().withDayOfMonth(1);
        LocalDate finMois = LocalDate.now();

        // KPIs Ventes
        BigDecimal caMois = salesOrderRepository
            .sumTotalTTCByDateCommandeBetween(debutMois, finMois);
        long nbCommandesMois = salesOrderRepository
            .countByDateCommandeBetween(debutMois, finMois);

        Map<String, Object> ventes = new HashMap<>();
        ventes.put("chiffreAffairesMois", caMois != null ? caMois : BigDecimal.ZERO);
        ventes.put("nbCommandesMois", nbCommandesMois);
        ventes.put("commandesEnCours",
            salesOrderRepository.findByStatutOrderByDateCommandeDesc(SalesOrder.StatutCommande.CONFIRMEE).size());
        dashboard.put("ventes", ventes);

        // KPIs Achats
        Map<String, Object> achats = new HashMap<>();
        achats.put("commandesEnAttente",
            purchaseOrderRepository.countByStatutIn(
                List.of(PurchaseOrder.StatutCommande.CONFIRMEE,
                        PurchaseOrder.StatutCommande.PARTIELLEMENT_RECUE)));
        dashboard.put("achats", achats);

        // KPIs Production
        Map<String, Object> production = new HashMap<>();
        production.put("ofPlanifies",
            productionOrderRepository.countByStatut(ProductionOrder.StatutOF.PLANIFIE));
        production.put("ofEnCours",
            productionOrderRepository.countByStatut(ProductionOrder.StatutOF.LANCE));
        dashboard.put("production", production);

        // KPIs Stock
        List<Article> alertesStock = articleRepository.findAll().stream()
            .filter(a -> a.isActif() && a.getStockActuel().compareTo(a.getStockMinimum()) <= 0)
            .toList();
        Map<String, Object> stock = new HashMap<>();
        stock.put("articlesEnAlerte", alertesStock.size());
        stock.put("articlesEnAlerteDetails", alertesStock.stream()
            .map(a -> Map.of("reference", a.getReference(),
                             "designation", a.getDesignation(),
                             "stockActuel", a.getStockActuel(),
                             "stockMinimum", a.getStockMinimum()))
            .toList());
        dashboard.put("stock", stock);

        return dashboard;
    }
}
