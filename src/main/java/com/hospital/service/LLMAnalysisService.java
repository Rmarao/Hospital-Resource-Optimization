package com.hospital.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import com.hospital.model.*;
import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class LLMAnalysisService {
	@Value("${groq.api.key}")
    private String groqApiKey;

    @Value("${groq.api.url}")
    private String groqApiUrl;

    @Value("${groq.model}")
    private String groqModel;

    @Autowired
    private PatientRecommendationRepository recommendationRepository;

    @Autowired
    private DoctorRepository doctorRepository;

    @Autowired
    private DoctorPatientRepository doctorPatientRepository;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // ── Analyse patient medical history ──────────────────────

    public PatientRecommendation analysePatient(Patient patient) {
        String medicalHistory = patient.getMedicalHistory();

        if (medicalHistory == null || medicalHistory.trim().isEmpty()) {
            return createDefaultRecommendation(patient.getId());
        }

        try {
            String llmResponse = callGroqAPI(medicalHistory);
            PatientRecommendation recommendation =
                parseRecommendation(llmResponse, patient.getId());
            return recommendationRepository.save(recommendation);

        } catch (Exception e) {
            System.err.println("LLM analysis failed: " + e.getMessage()
                + " — using rule-based fallback.");
            return createDefaultRecommendation(patient.getId());
        }
    }

    // ── Call Groq API ─────────────────────────────────────────

    private String callGroqAPI(String medicalHistory) throws Exception {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(groqApiKey);

        String prompt = buildPrompt(medicalHistory);

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", groqModel);
        requestBody.put("temperature", 0.1);
        requestBody.put("max_tokens", 500);

        List<Map<String, String>> messages = new ArrayList<>();
        Map<String, String> message = new HashMap<>();
        message.put("role", "user");
        message.put("content", prompt);
        messages.add(message);
        requestBody.put("messages", messages);

        HttpEntity<Map<String, Object>> entity =
            new HttpEntity<>(requestBody, headers);

        ResponseEntity<String> response = restTemplate.postForEntity(
            groqApiUrl, entity, String.class);

        // Extract content from Groq response
        JsonNode root = objectMapper.readTree(response.getBody());
        return root.path("choices")
                   .get(0)
                   .path("message")
                   .path("content")
                   .asText();
    }

    // ── Build prompt ──────────────────────────────────────────

    private String buildPrompt(String medicalHistory) {
        return "You are a medical AI assistant helping a hospital " +
               "management system. Analyze the following patient " +
               "medical history and return ONLY a JSON object with " +
               "no other text, no markdown, no explanation.\n\n" +
               "Medical History: \"" + medicalHistory + "\"\n\n" +
               "Return ONLY this JSON:\n" +
               "{\n" +
               "  \"department\": \"one of: GENERAL_MEDICINE, " +
               "CARDIOLOGY, ORTHOPEDICS, NEUROLOGY, ONCOLOGY, " +
               "PEDIATRICS, GYNECOLOGY, PULMONOLOGY, EMERGENCY\",\n" +
               "  \"severity_score\": (integer 1-10),\n" +
               "  \"severity_level\": \"one of: LOW, MEDIUM, " +
               "HIGH, CRITICAL\",\n" +
               "  \"recommended_resources\": [\"BED\" and/or " +
               "\"ICU\" and/or \"OT\"],\n" +
               "  \"doctor_specialization\": \"specific type " +
               "of specialist needed\",\n" +
               "  \"reasoning\": \"explanation under 80 words\",\n" +
               "  \"urgency\": \"one of: ROUTINE, SOON, " +
               "IMMEDIATE, EMERGENCY\"\n" +
               "}";
    }

    // ── Parse LLM response ────────────────────────────────────

    private PatientRecommendation parseRecommendation(
            String llmResponse, Long patientId) throws Exception {

        // Clean response — remove markdown if present
        String cleaned = llmResponse.trim();
        if (cleaned.startsWith("```")) {
            cleaned = cleaned.replaceAll("```json", "")
                             .replaceAll("```", "")
                             .trim();
        }

        JsonNode json = objectMapper.readTree(cleaned);

        PatientRecommendation rec = new PatientRecommendation();
        rec.setPatientId(patientId);
        rec.setDepartment(json.path("department").asText("GENERAL_MEDICINE"));
        rec.setSeverityScore(json.path("severity_score").asInt(3));
        rec.setSeverityLevel(json.path("severity_level").asText("LOW"));
        rec.setDoctorSpecialization(json.path("doctor_specialization").asText("General Physician"));
        rec.setReasoning(json.path("reasoning").asText(""));
        rec.setUrgency(json.path("urgency").asText("ROUTINE"));
        rec.setStatus("PENDING");

        // Parse recommended resources array
        JsonNode resources = json.path("recommended_resources");
        List<String> resourceList = new ArrayList<>();
        if (resources.isArray()) {
            for (JsonNode r : resources) {
                resourceList.add(r.asText());
            }
        }
        rec.setRecommendedResources(String.join(",", resourceList));

        return rec;
    }

    // ── Auto assign best doctor ───────────────────────────────

    public Map<String, Object> autoAssignDoctor(
            Long patientId,
            PatientRecommendation recommendation) {

        Map<String, Object> result = new HashMap<>();

        // Get all doctors
        List<Doctor> allDoctors = doctorRepository.findAll();

        if (allDoctors.isEmpty()) {
            result.put("success", false);
            result.put("message", "No doctors available");
            return result;
        }

        // Filter by department if possible
        String dept = recommendation.getDepartment()
            .replace("_", " ");

        List<Doctor> deptDoctors = new ArrayList<>();
        for (Doctor d : allDoctors) {
            if (d.getDepartment() != null &&
                d.getDepartment().toUpperCase()
                 .contains(dept.toUpperCase().split(" ")[0])) {
                deptDoctors.add(d);
            }
        }

        // Fall back to all doctors if none in department
        List<Doctor> candidates = deptDoctors.isEmpty()
            ? allDoctors : deptDoctors;

        // Score each doctor
        Doctor bestDoctor = null;
        double bestScore = -1;

        for (Doctor doctor : candidates) {
            // Count current patients
            long currentPatients = doctorPatientRepository
                .findByDoctorId(doctor.getId()).stream()
                .filter(dp -> "ACTIVE".equals(dp.getStatus()))
                .count();

            // Score: more experience = higher, more patients = lower
            int experience = doctor.getYearsOfExperience();
            int severityScore = recommendation.getSeverityScore();

            // High severity — prioritize experience more
            double score;
            if (severityScore >= 7) {
                score = (experience * 3.0) - (currentPatients * 1.0);
            } else {
                score = (experience * 1.0) - (currentPatients * 2.0);
            }

            if (score > bestScore) {
                bestScore = score;
                bestDoctor = doctor;
            }
        }

        if (bestDoctor == null) {
            result.put("success", false);
            result.put("message", "Could not find suitable doctor");
            return result;
        }

        result.put("success", true);
        result.put("doctor", bestDoctor);
        result.put("message", "Doctor assigned successfully");
        return result;
    }

    // ── Auto allocate resources based on severity ─────────────

    public Map<String, Object> getResourceRecommendation(
            PatientRecommendation recommendation) {

        Map<String, Object> result = new HashMap<>();
        int severity = recommendation.getSeverityScore();
        String resources = recommendation.getRecommendedResources();

        boolean needsBed = resources.contains("BED") || severity >= 1;
        boolean needsICU = resources.contains("ICU") || severity >= 7;
        boolean needsOT  = resources.contains("OT")  || severity >= 6;

        result.put("needsBed", needsBed);
        result.put("needsICU", needsICU);
        result.put("needsOT", needsOT);
        result.put("severity", severity);
        result.put("severityLevel",
            recommendation.getSeverityLevel());

        return result;
    }

    // ── Default recommendation when no history ────────────────

    private PatientRecommendation createDefaultRecommendation(
            Long patientId) {

        PatientRecommendation rec = new PatientRecommendation();
        rec.setPatientId(patientId);
        rec.setDepartment("GENERAL_MEDICINE");
        rec.setSeverityScore(2);
        rec.setSeverityLevel("LOW");
        rec.setRecommendedResources("BED");
        rec.setDoctorSpecialization("General Physician");
        rec.setReasoning("No medical history provided. " +
            "Assigned to General Medicine for assessment.");
        rec.setUrgency("ROUTINE");
        rec.setStatus("PENDING");

        return recommendationRepository.save(rec);
    }
}
