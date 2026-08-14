package com.hospital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "ot")
public class Ot {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String status = "AVAILABLE";

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

}
