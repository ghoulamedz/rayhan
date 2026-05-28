package com.rayhan.erp.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "reference_sequences")
@Getter
@Setter
@NoArgsConstructor
public class ReferenceSequence {

    @Id
    @Column(length = 10)
    private String type;

    @Column(nullable = false)
    private long lastValue = 0;

    public ReferenceSequence(String type, long lastValue) {
        this.type = type;
        this.lastValue = lastValue;
    }
}
