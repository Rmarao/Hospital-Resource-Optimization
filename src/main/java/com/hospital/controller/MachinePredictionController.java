package com.hospital.controller;

import com.hospital.model.EquipmentLog;
import com.hospital.repository.EquipmentLogRepository;
import com.hospital.service.MachinePredictionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/admin")
public class MachinePredictionController {
	@Autowired private MachinePredictionService predictionService;
    @Autowired private EquipmentLogRepository equipmentLogRepository;

    @GetMapping("/equipment-prediction")
    public String predictionPage(HttpSession session, Model model) {

        // Get latest reading for each equipment type
        EquipmentLog latestXRay = equipmentLogRepository
            .findTopByEquipmentTypeOrderByLogTimeDesc("X_RAY");
        EquipmentLog latestCT = equipmentLogRepository
            .findTopByEquipmentTypeOrderByLogTimeDesc("CT_SCAN");
        EquipmentLog latestMRI = equipmentLogRepository
            .findTopByEquipmentTypeOrderByLogTimeDesc("MRI");

        // Get recent history
        List<EquipmentLog> xrayHistory = equipmentLogRepository
            .findTop10ByEquipmentTypeOrderByLogTimeDesc("X_RAY");
        List<EquipmentLog> ctHistory = equipmentLogRepository
            .findTop10ByEquipmentTypeOrderByLogTimeDesc("CT_SCAN");
        List<EquipmentLog> mriHistory = equipmentLogRepository
            .findTop10ByEquipmentTypeOrderByLogTimeDesc("MRI");

        // Count high risk
        List<EquipmentLog> highRisk = equipmentLogRepository
            .findByPredictedRisk("HIGH");

        model.addAttribute("latestXRay", latestXRay);
        model.addAttribute("latestCT", latestCT);
        model.addAttribute("latestMRI", latestMRI);
        model.addAttribute("xrayHistory", xrayHistory);
        model.addAttribute("ctHistory", ctHistory);
        model.addAttribute("mriHistory", mriHistory);
        model.addAttribute("highRiskCount", highRisk.size());

        return "admin/equipment-prediction";
    }

    // Simulate a new reading for an equipment
    @PostMapping("/equipment-prediction/simulate")
    public String simulate(
            @RequestParam String equipmentType,
            @RequestParam(defaultValue = "1") Integer equipmentId,
            HttpSession session) {

        predictionService.simulateAndPredict(equipmentType, equipmentId);
        return "redirect:/admin/equipment-prediction?simulated=" + equipmentType;
    }

    // Simulate all equipment at once
    @PostMapping("/equipment-prediction/simulate-all")
    public String simulateAll(HttpSession session) {

        predictionService.simulateAndPredict("X_RAY", 1);
        predictionService.simulateAndPredict("CT_SCAN", 1);
        predictionService.simulateAndPredict("MRI", 1);

        return "redirect:/admin/equipment-prediction?simulated=ALL";
    }
}
