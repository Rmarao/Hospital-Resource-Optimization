package com.hospital.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "equipment_logs")
public class EquipmentLog {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "equipment_type")
    private String equipmentType;

    @Column(name = "equipment_id")
    private Integer equipmentId;

    @Column(name = "room_temperature")
    private Float roomTemperature;

    @Column(name = "internal_temperature")
    private Float internalTemperature;

    @Column(name = "usage_intensity")
    private Float usageIntensity;

    @Column(name = "mechanical_load")
    private Float mechanicalLoad;

    @Column(name = "operating_hours")
    private Float operatingHours;

    @Column(name = "error_count")
    private Integer errorCount;

    @Column(name = "power_fluctuation")
    private Float powerFluctuation;

    @Column(name = "days_since_maintenance")
    private Integer daysSinceMaintenance;

    @Column(name = "predicted_risk")
    private String predictedRisk;

    @Column(name = "risk_probability")
    private Float riskProbability;

    @Column(name = "log_time")
    private LocalDateTime logTime;

    @PrePersist
    protected void onCreate() {
        logTime = LocalDateTime.now();
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getEquipmentType() { return equipmentType; }
    public void setEquipmentType(String equipmentType) { this.equipmentType = equipmentType; }

    public Integer getEquipmentId() { return equipmentId; }
    public void setEquipmentId(Integer equipmentId) { this.equipmentId = equipmentId; }

    public Float getRoomTemperature() { return roomTemperature; }
    public void setRoomTemperature(Float roomTemperature) { this.roomTemperature = roomTemperature; }

    public Float getInternalTemperature() { return internalTemperature; }
    public void setInternalTemperature(Float internalTemperature) { this.internalTemperature = internalTemperature; }

    public Float getUsageIntensity() { return usageIntensity; }
    public void setUsageIntensity(Float usageIntensity) { this.usageIntensity = usageIntensity; }

    public Float getMechanicalLoad() { return mechanicalLoad; }
    public void setMechanicalLoad(Float mechanicalLoad) { this.mechanicalLoad = mechanicalLoad; }

    public Float getOperatingHours() { return operatingHours; }
    public void setOperatingHours(Float operatingHours) { this.operatingHours = operatingHours; }

    public Integer getErrorCount() { return errorCount; }
    public void setErrorCount(Integer errorCount) { this.errorCount = errorCount; }

    public Float getPowerFluctuation() { return powerFluctuation; }
    public void setPowerFluctuation(Float powerFluctuation) { this.powerFluctuation = powerFluctuation; }

    public Integer getDaysSinceMaintenance() { return daysSinceMaintenance; }
    public void setDaysSinceMaintenance(Integer daysSinceMaintenance) { this.daysSinceMaintenance = daysSinceMaintenance; }

    public String getPredictedRisk() { return predictedRisk; }
    public void setPredictedRisk(String predictedRisk) { this.predictedRisk = predictedRisk; }

    public Float getRiskProbability() { return riskProbability; }
    public void setRiskProbability(Float riskProbability) { this.riskProbability = riskProbability; }

    public LocalDateTime getLogTime() { return logTime; }
    public void setLogTime(LocalDateTime logTime) { this.logTime = logTime; }
}
