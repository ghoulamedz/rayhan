package com.rayhan.erp.controller;

import com.rayhan.erp.model.DeliveryNote;
import com.rayhan.erp.model.SalesOrder;
import com.rayhan.erp.model.User;
import com.rayhan.erp.repository.UserRepository;
import com.rayhan.erp.security.services.UserDetailsImpl;
import com.rayhan.erp.service.SalesOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sales-orders")
public class SalesOrderController {

    @Autowired private SalesOrderService salesOrderService;
    @Autowired private UserRepository userRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public List<SalesOrder> getAllOrders() {
        return salesOrderService.getAllSalesOrders();
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public ResponseEntity<SalesOrder> createOrder(@RequestBody SalesOrder order,
                                                   @AuthenticationPrincipal UserDetailsImpl userDetails) {
        User user = userRepository.findById(userDetails.getId()).orElse(null);
        order.setCreePar(user);
        return ResponseEntity.ok(salesOrderService.createSalesOrder(order));
    }

    @PostMapping("/{id}/deliver")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE', 'ROLE_MAGASINIER')")
    public ResponseEntity<DeliveryNote> createDelivery(@PathVariable Long id,
                                                        @RequestBody DeliveryNote bonLivraison,
                                                        @AuthenticationPrincipal UserDetailsImpl userDetails) {
        User user = userRepository.findById(userDetails.getId()).orElse(null);
        return ResponseEntity.ok(salesOrderService.createDeliveryNote(id, bonLivraison, user));
    }
}
