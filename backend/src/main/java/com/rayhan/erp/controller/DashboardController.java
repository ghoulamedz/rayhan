package com.rayhan.erp.controller;

import com.rayhan.erp.dto.TrendingProduct;
import com.rayhan.erp.service.DashboardService;
import com.rayhan.erp.service.TrendingProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    @Autowired
    private TrendingProductService trendingProductService;

    @GetMapping
    @PreAuthorize("hasRole('ROLE_PDG')")
    public Map<String, Object> getDashboard() {
        return dashboardService.getDashboard();
    }

    @GetMapping("/trending-products")
    @PreAuthorize("hasRole('ROLE_PDG')")
    public List<TrendingProduct> getTrendingProducts() {
        return trendingProductService.fetchTrending();
    }
}
