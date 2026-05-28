package com.rayhan.erp.service;

import com.rayhan.erp.model.*;
import com.rayhan.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class SalesOrderService {

    @Autowired private SalesOrderRepository salesOrderRepository;
    @Autowired private DeliveryNoteRepository deliveryNoteRepository;
    @Autowired private ArticleRepository articleRepository;
    @Autowired private StockService stockService;
    @Autowired private SequenceService sequenceService;

    @Transactional
    public SalesOrder createSalesOrder(SalesOrder order) {
        // Vérification du stock disponible avant validation
        for (SalesOrderLine ligne : order.getLignes()) {
            Article article = articleRepository.findById(ligne.getArticle().getId())
                .orElseThrow(() -> new RuntimeException("Article introuvable"));
            if (article.getStockActuel().compareTo(ligne.getQuantiteCommandee()) < 0) {
                throw new IllegalStateException(
                    "Stock insuffisant pour " + article.getDesignation());
            }
        }

        order.setReference(sequenceService.generateRef("CC"));
        order.setStatut(SalesOrder.StatutCommande.CONFIRMEE);

        BigDecimal totalHT = BigDecimal.ZERO;
        for (SalesOrderLine ligne : order.getLignes()) {
            ligne.setSalesOrder(order);
            BigDecimal montantHT = ligne.getPrixUnitaireHT().multiply(ligne.getQuantiteCommandee());
            ligne.setMontantHT(montantHT);
            BigDecimal tva = montantHT.multiply(ligne.getTauxTVA().divide(new BigDecimal("100")));
            ligne.setMontantTTC(montantHT.add(tva));
            totalHT = totalHT.add(montantHT);
        }

        order.setTotalHT(totalHT);
        BigDecimal tvaGlobal = totalHT.multiply(new BigDecimal("0.19"));
        order.setTotalTVA(tvaGlobal);
        order.setTotalTTC(totalHT.add(tvaGlobal));

        return salesOrderRepository.save(order);
    }

    @Transactional
    public DeliveryNote createDeliveryNote(Long salesOrderId, DeliveryNote bonLivraison, User user) {
        SalesOrder order = salesOrderRepository.findById(salesOrderId)
            .orElseThrow(() -> new RuntimeException("Commande introuvable : " + salesOrderId));

        bonLivraison.setReference(sequenceService.generateRef("BL"));
        bonLivraison.setSalesOrder(order);
        bonLivraison.setCreePar(user);

        for (DeliveryNoteLine ligne : bonLivraison.getLignes()) {
            ligne.setDeliveryNote(bonLivraison);
            Article article = articleRepository.findById(ligne.getArticle().getId())
                .orElseThrow(() -> new RuntimeException("Article introuvable"));
            ligne.setArticle(article);

            stockService.sortieStock(article, ligne.getQuantiteLivree(),
                "BON_LIVRAISON", bonLivraison.getReference(),
                "Livraison commande " + order.getReference(), user);

            ligne.getSalesOrderLine().setQuantiteLivree(
                ligne.getSalesOrderLine().getQuantiteLivree().add(ligne.getQuantiteLivree()));
        }

        order.setStatut(SalesOrder.StatutCommande.COMPLETEMENT_LIVREE);
        salesOrderRepository.save(order);

        return deliveryNoteRepository.save(bonLivraison);
    }

    public List<SalesOrder> getAllSalesOrders() {
        return salesOrderRepository.findAll();
    }
}
