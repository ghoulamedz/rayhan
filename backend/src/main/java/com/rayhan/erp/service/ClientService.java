package com.rayhan.erp.service;

import com.rayhan.erp.model.Client;
import com.rayhan.erp.repository.ClientRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ClientService {

    @Autowired
    private ClientRepository clientRepository;

    public List<Client> getAllClients() {
        return clientRepository.findByActifTrue();
    }

    public List<Client> searchClients(String q) {
        return clientRepository.findByRaisonSocialeContainingIgnoreCase(q);
    }

    public Client getClientById(Long id) {
        return clientRepository.findById(id).orElse(null);
    }

    public Client createClient(@Valid Client client) {
        return clientRepository.save(client);
    }

    public Client updateClient(Long id, Client details) {
        return clientRepository.findById(id).map(client -> {
            client.setRaisonSociale(details.getRaisonSociale());
            client.setMatriculeFiscal(details.getMatriculeFiscal());
            client.setAdresse(details.getAdresse());
            client.setTelephone(details.getTelephone());
            client.setEmail(details.getEmail());
            client.setVille(details.getVille());
            client.setTypeClient(details.getTypeClient());
            client.setPlafondCredit(details.getPlafondCredit());
            client.setDelaiPaiement(details.getDelaiPaiement());
            return clientRepository.save(client);
        }).orElse(null);
    }
}
