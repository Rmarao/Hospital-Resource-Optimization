package com.hospital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "doctor_availability", uniqueConstraints =
    @UniqueConstraint(name = "uk_doctor_day", columnNames = {"doctor_id", "day_of_week"}))
public class DoctorAvailability {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "doctor_id", nullable = false)
    private Long doctorId;

    @Column(name = "day_of_week", nullable = false, length = 9)
    private String dayOfWeek; // MONDAY .. SUNDAY

    @Column(nullable = false)
    private boolean available = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }

    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
}
