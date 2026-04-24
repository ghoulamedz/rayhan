package com.rayhan.erp.controller;

import com.rayhan.erp.model.Fournisseur;
import com.rayhan.erp.repository.FournisseurRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fournisseurs")
public class FournisseurController {

    @Autowired
    FournisseurRepository fournisseurRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_ACHAT')")
    public List<Fournisseur> getAllFournisseurs() {
        return fournisseurRepository.findByActifTrue();
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_ACHAT')")
    public List<Fournisseur> searchFournisseurs(@RequestParam String q) {
        return fournisseurRepository.findByRaisonSocialeContainingIgnoreCase(q);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_ACHAT')")
    public ResponseEntity<Fournisseur> getFournisseurById(@PathVariable Long id) {
        return fournisseurRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_ACHAT')")
    public Fournisseur createFournisseur(@Valid @RequestBody Fournisseur fournisseur) {
        return fournisseurRepository.save(fournisseur);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_ACHAT')")
    public ResponseEntity<Fournisseur> updateFournisseur(@PathVariable Long id,
                                                          @Valid @RequestBody Fournisseur details) {
        return fournisseurRepository.findById(id)
            .map(f -> {
                f.setRaisonSociale(details.getRaisonSociale());
                f.setMatriculeFiscal(details.getMatriculeFiscal());
                f.setAdresse(details.getAdresse());
                f.setTelephone(details.getTelephone());
                f.setEmail(details.getEmail());
                f.setVille(details.getVille());
                f.setPays(details.getPays());
                f.setCategorieProduit(details.getCategorieProduit());
                f.setDelaiLivraison(details.getDelaiLivraison());
                f.setModePaiement(details.getModePaiement());
                return ResponseEntity.ok(fournisseurRepository.save(f));
            })
            .orElse(ResponseEntity.notFound().build());
    }
}
