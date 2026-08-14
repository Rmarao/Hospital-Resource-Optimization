package com.hospital.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "patient_recommendations")
public class PatientRecommendation {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "patient_id")
    private Long patientId;

    private String department;

    @Column(name = "severity_score")
    private Integer severityScore;

    @Column(name = "severity_level")
    private String severityLevel;

    @Column(name = "recommended_resources")
    private String recommendedResources;

    @Column(name = "doctor_specialization")
    private String doctorSpecialization;

    @Column(columnDefinition = "TEXT")
    private String reasoning;

    private String urgency;
    private String status = "PENDING";

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public Integer getSeverityScore() { return severityScore; }
    public void setSeverityScore(Integer severityScore) { this.severityScore = severityScore; }

    public String getSeverityLevel() { return severityLevel; }
    public void setSeverityLevel(String severityLevel) { this.severityLevel = severityLevel; }

    public String getRecommendedResources() { return recommendedResources; }
    public void setRecommendedResources(String recommendedResources) { this.recommendedResources = recommendedResources; }

    public String getDoctorSpecialization() { return doctorSpecialization; }
    public void setDoctorSpecialization(String doctorSpecialization) { this.doctorSpecialization = doctorSpecialization; }

    public String getReasoning() { return reasoning; }
    public void setReasoning(String reasoning) { this.reasoning = reasoning; }

    public String getUrgency() { return urgency; }
    public void setUrgency(String urgency) { this.urgency = urgency; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
