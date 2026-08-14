package com.hospital.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "blood_bank")
public class BloodBank {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String component;

    @Column(name = "blood_group")
    private String bloodGroup;

    @Column(name = "quantity_units")
    private Integer quantityUnits = 0;

    @Column(name = "collection_date")
    private LocalDate collectionDate;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    private String status = "AVAILABLE";

    // Check if expired
    @Transient
    public boolean isExpired() {
        return expiryDate != null && expiryDate.isBefore(LocalDate.now());
    }

    // Days until expiry
    @Transient
    public long getDaysUntilExpiry() {
        if (expiryDate == null) return 0;
        return java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), expiryDate);
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getComponent() { return component; }
    public void setComponent(String component) { this.component = component; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public Integer getQuantityUnits() { return quantityUnits; }
    public void setQuantityUnits(Integer quantityUnits) { this.quantityUnits = quantityUnits; }

    public LocalDate getCollectionDate() { return collectionDate; }
    public void setCollectionDate(LocalDate collectionDate) { this.collectionDate = collectionDate; }

    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
