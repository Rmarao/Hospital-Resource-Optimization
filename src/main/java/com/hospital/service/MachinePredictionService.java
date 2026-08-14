package com.hospital.service;

import com.hospital.model.EquipmentLog;
import com.hospital.repository.EquipmentLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.tribuo.*;
import org.tribuo.classification.*;
import org.tribuo.classification.dtree.CARTClassificationTrainer;
import org.tribuo.data.csv.CSVLoader;
import org.tribuo.impl.ArrayExample;

import jakarta.annotation.PostConstruct;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.logging.Logger;

@Service
public class MachinePredictionService {

    private static final Logger logger =
        Logger.getLogger(MachinePredictionService.class.getName());

    @Autowired
    private EquipmentLogRepository equipmentLogRepository;

    private Model<Label> model;
    private boolean modelTrained = false;

    // Feature names matching AI4I dataset columns
    private static final String[] FEATURE_NAMES = {
        "Type",
        "Air temperature [K]",
        "Process temperature [K]",
        "Rotational speed [rpm]",
        "Torque [Nm]",
        "Tool wear [min]"
    };

    @PostConstruct
    public void initModel() {
        try {
            Path modelPath = Paths.get("equipment_failure_model.ser");
            if (Files.exists(modelPath)) {
                loadModel(modelPath);
                logger.info("Model loaded from file.");
            } else {
                trainModel();
                logger.info("Model trained successfully.");
            }
            modelTrained = true;
        } catch (Exception e) {
            logger.warning("Model init failed: " + e.getMessage()
                + " — using rule-based fallback.");
            modelTrained = false;
        }
    }

    private void trainModel() throws Exception {
        InputStream csvStream = getClass()
            .getClassLoader()
            .getResourceAsStream("ai4i2020.csv");

        if (csvStream == null) {
            throw new FileNotFoundException(
                "ai4i2020.csv not found in resources folder");
        }

        // ── Step 1: Read CSV and create a cleaned version ──────
        // Original columns:
        // UDI, Product ID, Type, Air temperature [K],
        // Process temperature [K], Rotational speed [rpm],
        // Torque [Nm], Tool wear [min], Machine failure,
        // TWF, HDF, PWF, OSF, RNF

        // We keep only:
        // Type(index 2), Air temp(3), Process temp(4),
        // Rotational speed(5), Torque(6), Tool wear(7),
        // Machine failure(8)

        Path cleanedCsv = Files.createTempFile("ai4i_clean", ".csv");

        try (
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(csvStream));
            BufferedWriter writer = Files.newBufferedWriter(cleanedCsv)
        ) {
            String line;
            boolean isHeader = true;

            while ((line = reader.readLine()) != null) {
                String[] cols = line.split(",");

                if (isHeader) {
                    // Write only the columns we want
                    writer.write(
                        "Type,Air temperature [K]," +
                        "Process temperature [K]," +
                        "Rotational speed [rpm]," +
                        "Torque [Nm],Tool wear [min]," +
                        "Machine failure");
                    writer.newLine();
                    isHeader = false;
                    continue;
                }

                // Skip rows that don't have enough columns
                if (cols.length < 9) continue;

                // Convert Type: L→0, M→1, H→2
                String typeVal;
                String rawType = cols[2].trim().replace("\"", "");
                switch (rawType) {
                    case "L": typeVal = "0"; break;
                    case "M": typeVal = "1"; break;
                    case "H": typeVal = "2"; break;
                    default:  typeVal = "1"; break;
                }

                // Write cleaned row with only numeric columns
                writer.write(
                    typeVal + "," +
                    cols[3].trim() + "," +  // Air temp
                    cols[4].trim() + "," +  // Process temp
                    cols[5].trim() + "," +  // Rotational speed
                    cols[6].trim() + "," +  // Torque
                    cols[7].trim() + "," +  // Tool wear
                    cols[8].trim()          // Machine failure (target)
                );
                writer.newLine();
            }
        }

        logger.info("CSV cleaned and saved to: " + cleanedCsv);

        // ── Step 2: Load cleaned CSV with Tribuo ───────────────
        var labelFactory = new LabelFactory();
        var csvLoader = new CSVLoader<>(labelFactory);

        var dataSource = csvLoader.loadDataSource(
            cleanedCsv, "Machine failure");
        var dataset = new MutableDataset<>(dataSource);

        logger.info("Dataset loaded: " + dataset.size()
            + " examples, "
            + dataset.getFeatureMap().size() + " features.");

        // ── Step 3: Train CART Decision Tree ───────────────────
        var trainer = new CARTClassificationTrainer();
        model = trainer.train(dataset);

        logger.info("Model trained successfully!");

        // ── Step 4: Save model ─────────────────────────────────
        saveModel(Paths.get("equipment_failure_model.ser"));

        // ── Cleanup ────────────────────────────────────────────
        Files.deleteIfExists(cleanedCsv);
    }

    private void saveModel(Path path) {
        try (var oos = new ObjectOutputStream(
                new FileOutputStream(path.toFile()))) {
            oos.writeObject(model);
            logger.info("Model saved to " + path);
        } catch (Exception e) {
            logger.warning("Could not save model: " + e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    private void loadModel(Path path) throws Exception {
        try (var ois = new ObjectInputStream(
                new FileInputStream(path.toFile()))) {
            model = (Model<Label>) ois.readObject();
        }
    }

    // Main prediction method
    public Map<String, Object> predict(
            String equipmentType,
            float roomTemp,
            float internalTemp,
            float usageIntensity,
            float mechanicalLoad,
            float operatingHours,
            int errorCount,
            float powerFluctuation,
            int daysSinceMaintenance) {

        if (modelTrained && model != null) {
            return mlPredict(equipmentType, roomTemp, internalTemp,
                usageIntensity, mechanicalLoad, operatingHours);
        } else {
            return ruleBasedPredict(roomTemp, internalTemp,
                operatingHours, errorCount,
                powerFluctuation, daysSinceMaintenance);
        }
    }

    private Map<String, Object> mlPredict(
            String equipmentType,
            float roomTemp,
            float internalTemp,
            float usageIntensity,
            float mechanicalLoad,
            float operatingHours) {

        try {
            // Map hospital values to AI4I feature ranges
            double[] values = {
                mapEquipmentType(equipmentType),     // Type
                roomTemp + 273.15,                   // Air temp K
                internalTemp + 273.15,               // Process temp K
                usageIntensity * 15.0 + 1000.0,      // RPM
                mechanicalLoad * 5.0 + 20.0,         // Torque Nm
                operatingHours                       // Tool wear min
            };

            // Build example
            var example = new ArrayExample<Label>(new Label("0"),
                FEATURE_NAMES, values);

            // Get prediction
            var prediction = model.predict(example);
            String label = prediction.getOutput().getLabel();

            // Get probability scores
            var scores = prediction.getOutputScores();
            double failureProb = 0.0;
            if (scores.containsKey("1")) {
                failureProb = scores.get("1").getScore();
            } else if (label.equals("1")) {
                failureProb = 0.75; // Default if predicted failure
            }

            String risk = getRiskLevel(failureProb);
            int probability = (int) Math.round(failureProb * 100);

            Map<String, Object> result = new HashMap<>();
            result.put("risk", risk);
            result.put("probability", Math.min(probability, 99));
            result.put("modelBased", true);
            return result;

        } catch (Exception e) {
            logger.warning("ML prediction failed: " + e.getMessage()
                + " — falling back to rules.");
            return ruleBasedPredict(roomTemp, internalTemp,
                operatingHours, 0, 0.0f, 0);
        }
    }

    private String getRiskLevel(double probability) {
        if (probability >= 0.7) return "HIGH";
        if (probability >= 0.35) return "MEDIUM";
        return "LOW";
    }

    // Rule-based fallback
    private Map<String, Object> ruleBasedPredict(
            float roomTemp, float internalTemp,
            float operatingHours, int errorCount,
            float powerFluctuation, int daysSinceMaintenance) {

        int score = 0;

        if (roomTemp > 45) score += 3;
        else if (roomTemp > 38) score += 1;

        if (internalTemp > 60) score += 3;
        else if (internalTemp > 50) score += 1;

        if (operatingHours > 400) score += 3;
        else if (operatingHours > 200) score += 1;

        if (errorCount > 10) score += 3;
        else if (errorCount > 5) score += 1;

        if (powerFluctuation > 0.7) score += 2;
        else if (powerFluctuation > 0.4) score += 1;

        if (daysSinceMaintenance > 180) score += 3;
        else if (daysSinceMaintenance > 90) score += 1;

        String risk;
        int probability;
        if (score >= 8) { risk = "HIGH"; probability = 70 + score; }
        else if (score >= 4) { risk = "MEDIUM"; probability = 35 + score * 3; }
        else { risk = "LOW"; probability = score * 5; }

        Map<String, Object> result = new HashMap<>();
        result.put("risk", risk);
        result.put("probability", Math.min(probability, 99));
        result.put("modelBased", false);
        return result;
    }

    private double mapEquipmentType(String type) {
        switch (type) {
            case "X_RAY":   return 0.0; // L
            case "CT_SCAN": return 1.0; // M
            case "MRI":     return 2.0; // H
            default:        return 1.0;
        }
    }

    // Simulate sensor readings and predict
    public EquipmentLog simulateAndPredict(
            String equipmentType, Integer equipmentId) {

        Random rand = new Random();

        float roomTemp, internalTemp, usageIntensity, mechanicalLoad;

        switch (equipmentType) {
            case "X_RAY":
                roomTemp = 28 + rand.nextFloat() * 22;
                internalTemp = 38 + rand.nextFloat() * 22;
                usageIntensity = 0.3f + rand.nextFloat() * 0.6f;
                mechanicalLoad = 0.2f + rand.nextFloat() * 0.5f;
                break;
            case "CT_SCAN":
                roomTemp = 32 + rand.nextFloat() * 22;
                internalTemp = 43 + rand.nextFloat() * 25;
                usageIntensity = 0.5f + rand.nextFloat() * 0.45f;
                mechanicalLoad = 0.4f + rand.nextFloat() * 0.5f;
                break;
            case "MRI":
            default:
                roomTemp = 18 + rand.nextFloat() * 22;
                internalTemp = 32 + rand.nextFloat() * 22;
                usageIntensity = 0.6f + rand.nextFloat() * 0.35f;
                mechanicalLoad = 0.5f + rand.nextFloat() * 0.45f;
                break;
        }

        float operatingHours = 20 + rand.nextFloat() * 480;
        int errorCount = rand.nextInt(16);
        float powerFluctuation = rand.nextFloat();
        int daysSinceMaintenance = rand.nextInt(210);

        Map<String, Object> prediction = predict(
            equipmentType,
            roomTemp, internalTemp,
            usageIntensity, mechanicalLoad,
            operatingHours, errorCount,
            powerFluctuation, daysSinceMaintenance
        );

        EquipmentLog log = new EquipmentLog();
        log.setEquipmentType(equipmentType);
        log.setEquipmentId(equipmentId);
        log.setRoomTemperature(roomTemp);
        log.setInternalTemperature(internalTemp);
        log.setUsageIntensity(usageIntensity);
        log.setMechanicalLoad(mechanicalLoad);
        log.setOperatingHours(operatingHours);
        log.setErrorCount(errorCount);
        log.setPowerFluctuation(powerFluctuation);
        log.setDaysSinceMaintenance(daysSinceMaintenance);
        log.setPredictedRisk((String) prediction.get("risk"));
        log.setRiskProbability(
            ((Integer) prediction.get("probability")).floatValue());

        return equipmentLogRepository.save(log);
    }
}