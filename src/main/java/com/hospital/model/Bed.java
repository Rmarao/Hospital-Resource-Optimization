package com.hospital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "beds")
public class Bed {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "bed_number")
    private String bedNumber;

    private String ward;
    private Integer floor;
    private String status = "AVAILABLE";

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getBedNumber() { return bedNumber; }
    public void setBedNumber(String bedNumber) { this.bedNumber = bedNumber; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public Integer getFloor() { return floor; }
    public void setFloor(Integer floor) { this.floor = floor; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
