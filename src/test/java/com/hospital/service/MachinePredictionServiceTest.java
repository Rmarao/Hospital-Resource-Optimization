package com.hospital.service;

import org.junit.jupiter.api.Test;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

/**
 * Plain unit test — no Spring context. A freshly-constructed
 * MachinePredictionService never runs @PostConstruct, so modelTrained stays
 * false and predict() always exercises the rule-based fallback, which is
 * exactly the logic under test here.
 */
class MachinePredictionServiceTest {

    private final MachinePredictionService service = new MachinePredictionService();

    @Test
    void lowRiskInputsYieldLowRisk() {
        Map<String, Object> result = service.predict(
            "X_RAY", 25f, 35f, 0.3f, 0.2f, 50f, 0, 0.1f, 10);

        assertEquals("LOW", result.get("risk"));
        assertFalse((Boolean) result.get("modelBased"));
    }

    @Test
    void highRiskInputsYieldHighRisk() {
        Map<String, Object> result = service.predict(
            "MRI", 50f, 65f, 0.9f, 0.9f, 450f, 15, 0.8f, 200);

        assertEquals("HIGH", result.get("risk"));
    }

    @Test
    void mediumRiskInputsYieldMediumRisk() {
        // room temp 40 (+1), internal temp 55 (+1), hours 250 (+1), errors 7 (+1) = score 4
        Map<String, Object> result = service.predict(
            "CT_SCAN", 40f, 55f, 0.5f, 0.5f, 250f, 7, 0.1f, 10);

        assertEquals("MEDIUM", result.get("risk"));
    }

    @Test
    void probabilityIsCappedAt99() {
        Map<String, Object> result = service.predict(
            "MRI", 60f, 80f, 1.0f, 1.0f, 600f, 20, 1.0f, 300);

        int probability = (Integer) result.get("probability");
        assertEquals(true, probability <= 99);
    }
}
