package com.hospital.repository;

import com.hospital.model.PatientRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface PatientRecommendationRepository
    extends JpaRepository<PatientRecommendation, Integer> {

    Optional<PatientRecommendation> findTopByPatientIdOrderByCreatedAtDesc(
        Long patientId);
    List<PatientRecommendation> findByPatientId(Long patientId);
    List<PatientRecommendation> findBySeverityLevel(String severityLevel);
}