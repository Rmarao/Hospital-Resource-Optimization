package com.hospital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "oxygen_tanks")
public class OxygenTank {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "tank_no", unique = true)
    private Integer tankNo;

    private Integer capacity;

    @Column(name = "current_level")
    private Float currentLevel;

    private String status = "AVAILABLE";

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getTankNo() { return tankNo; }
    public void setTankNo(Integer tankNo) { this.tankNo = tankNo; }

    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }

    public Float getCurrentLevel() { return currentLevel; }
    public void setCurrentLevel(Float currentLevel) { this.currentLevel = currentLevel; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
