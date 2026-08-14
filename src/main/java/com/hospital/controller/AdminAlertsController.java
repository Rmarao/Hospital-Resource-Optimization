package com.hospital.controller;

import com.hospital.service.AlertsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminAlertsController {

    @Autowired private AlertsService alertsService;

    @GetMapping("/alerts")
    public String alertsPage(Model model) {
        AlertsService.Summary summary = alertsService.getSummary();

        model.addAttribute("expiredBlood", summary.expiredBlood);
        model.addAttribute("expiringSoonBlood", summary.expiringSoonBlood);
        model.addAttribute("lowStockBlood", summary.lowStockBlood);
        model.addAttribute("lowOxygenTanks", summary.lowOxygenTanks);
        model.addAttribute("highRiskEquipment", summary.highRiskEquipment);
        model.addAttribute("totalAlerts", summary.totalAlerts);

        return "admin/alerts";
    }
}
