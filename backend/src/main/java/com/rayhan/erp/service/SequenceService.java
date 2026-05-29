package com.rayhan.erp.service;

import com.rayhan.erp.model.ReferenceSequence;
import com.rayhan.erp.repository.ReferenceSequenceRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class SequenceService {

    @Autowired
    private ReferenceSequenceRepository repository;

    @PostConstruct
    public void init() {
        List.of("CC", "BL", "BC", "BR", "OF").forEach(type -> {
            if (!repository.existsById(type)) {
                repository.save(new ReferenceSequence(type, 0));
            }
        });
    }

    @Transactional
    public long getNextValue(String type) {
        repository.incrementByType(type);
        return repository.findById(type)
            .orElseThrow(() -> new RuntimeException("Sequence not found: " + type))
            .getLastValue();
    }

    public synchronized String generateRef(String prefix) {
        long num = getNextValue(prefix);
        return prefix + "-" + LocalDate.now().getYear() + "-" + String.format("%03d", num);
    }
}
