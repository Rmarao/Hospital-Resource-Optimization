package com.hospital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "icu")
public class Icu {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Boolean ventilator = false;
    private String status = "AVAILABLE";

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Boolean getVentilator() { return ventilator; }
    public void setVentilator(Boolean ventilator) { this.ventilator = ventilator; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
