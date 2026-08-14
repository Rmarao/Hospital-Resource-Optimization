package com.hospital.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "icu_admissions")
public class IcuAdmission {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "icu_id")
    private Integer icuId;

    @Column(name = "patient_id")
    private Long patientId;

    @Column(name = "doctor_id")
    private Long doctorId;

    @Column(name = "admitted_date")
    private LocalDate admittedDate;

    @Column(name = "discharge_date")
    private LocalDate dischargeDate;

    private String status = "ACTIVE";

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getIcuId() { return icuId; }
    public void setIcuId(Integer icuId) { this.icuId = icuId; }

    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }

    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }

    public LocalDate getAdmittedDate() { return admittedDate; }
    public void setAdmittedDate(LocalDate admittedDate) { this.admittedDate = admittedDate; }

    public LocalDate getDischargeDate() { return dischargeDate; }
    public void setDischargeDate(LocalDate dischargeDate) { this.dischargeDate = dischargeDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
