package com.rayhan.erp.controller;

import com.rayhan.erp.model.Client;
import com.rayhan.erp.repository.ClientRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

    @Autowired
    ClientRepository clientRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public List<Client> getAllClients() {
        return clientRepository.findByActifTrue();
    }

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public List<Client> searchClients(@RequestParam String q) {
        return clientRepository.findByRaisonSocialeContainingIgnoreCase(q);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public ResponseEntity<Client> getClientById(@PathVariable Long id) {
        return clientRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public Client createClient(@Valid @RequestBody Client client) {
        return clientRepository.save(client);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ROLE_PDG', 'ROLE_RESPONSABLE_VENTE')")
    public ResponseEntity<Client> updateClient(@PathVariable Long id, @Valid @RequestBody Client details) {
        return clientRepository.findById(id)
            .map(client -> {
                client.setRaisonSociale(details.getRaisonSociale());
                client.setMatriculeFiscal(details.getMatriculeFiscal());
                client.setAdresse(details.getAdresse());
                client.setTelephone(details.getTelephone());
                client.setEmail(details.getEmail());
                client.setVille(details.getVille());
                client.setTypeClient(details.getTypeClient());
                client.setPlafondCredit(details.getPlafondCredit());
                client.setDelaiPaiement(details.getDelaiPaiement());
                return ResponseEntity.ok(clientRepository.save(client));
            })
            .orElse(ResponseEntity.notFound().build());
    }
}
