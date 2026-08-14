package com.hospital.model;

import com.hospital.crypto.AesGcmStringConverter;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;

@Entity
@Table(name = "patients")
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String password;
    private String phone;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private String gender;

    @Column(name = "blood_group")
    private String bloodGroup;

    private String address;

    @Column(name = "emergency_contact")
    private String emergencyContact;

    @Convert(converter = AesGcmStringConverter.class)
    @Column(name = "medical_history", columnDefinition = "TEXT")
    private String medicalHistory;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Convert(converter = AesGcmStringConverter.class)
    @Column(name = "google_fit_token", columnDefinition = "TEXT")
    private String googleFitAccessToken;

    @Convert(converter = AesGcmStringConverter.class)
    @Column(name = "google_fit_refresh_token", columnDefinition = "TEXT")
    private String googleFitRefreshToken;

    // Getters and Setters
    public String getGoogleFitAccessToken() { return googleFitAccessToken; }
    public void setGoogleFitAccessToken(String token) { this.googleFitAccessToken = token; }

    public String getGoogleFitRefreshToken() { return googleFitRefreshToken; }
    public void setGoogleFitRefreshToken(String token) { this.googleFitRefreshToken = token; }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Calculated field - not stored in DB
    @Transient
    public int getAge() {
        if (dateOfBirth == null) return 0;
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }

    public String getMedicalHistory() { return medicalHistory; }
    public void setMedicalHistory(String medicalHistory) { this.medicalHistory = medicalHistory; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}