package com.hospital.controller;

import com.hospital.repository.AuditLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminAuditController {

    @Autowired
    private AuditLogRepository auditLogRepository;

    @GetMapping("/audit-log")
    public String auditLogPage(Model model) {
        model.addAttribute("logs", auditLogRepository.findTop100ByOrderByCreatedAtDesc());
        return "admin/audit-log";
    }
}
