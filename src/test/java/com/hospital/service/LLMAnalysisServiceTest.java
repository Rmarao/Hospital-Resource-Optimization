package com.hospital.service;

import com.hospital.model.Patient;
import com.hospital.model.PatientRecommendation;
import com.hospital.repository.DoctorPatientRepository;
import com.hospital.repository.DoctorRepository;
import com.hospital.repository.PatientRecommendationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

/**
 * Covers the rule-based fallback path only (empty medical history) — no
 * Spring context, so @Value-injected Groq config fields stay null, which is
 * fine since that path never calls the Groq API.
 */
@ExtendWith(MockitoExtension.class)
class LLMAnalysisServiceTest {

    @Mock private PatientRecommendationRepository recommendationRepository;
    @Mock private DoctorRepository doctorRepository;
    @Mock private DoctorPatientRepository doctorPatientRepository;

    @InjectMocks
    private LLMAnalysisService llmAnalysisService;

    @Test
    void patientWithNoMedicalHistoryGetsDefaultLowSeverityRecommendation() {
        Patient patient = new Patient();
        patient.setId(42L);
        patient.setMedicalHistory(null);

        when(recommendationRepository.save(any(PatientRecommendation.class)))
            .thenAnswer(invocation -> invocation.getArgument(0));

        PatientRecommendation rec = llmAnalysisService.analysePatient(patient);

        assertEquals(42L, rec.getPatientId());
        assertEquals("GENERAL_MEDICINE", rec.getDepartment());
        assertEquals("LOW", rec.getSeverityLevel());
        assertEquals("ROUTINE", rec.getUrgency());
        assertEquals("PENDING", rec.getStatus());
    }

    @Test
    void resourceRecommendationEscalatesWithSeverity() {
        PatientRecommendation rec = new PatientRecommendation();
        rec.setSeverityScore(8);
        rec.setSeverityLevel("CRITICAL");
        rec.setRecommendedResources("");

        var result = llmAnalysisService.getResourceRecommendation(rec);

        assertEquals(true, result.get("needsBed"));
        assertEquals(true, result.get("needsICU"));
        assertEquals(true, result.get("needsOT"));
    }
}
