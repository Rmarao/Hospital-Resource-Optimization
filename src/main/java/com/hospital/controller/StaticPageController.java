package com.hospital.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StaticPageController {
	@GetMapping("/admin/labs")
    public String adminLabs() {
        return "admin/labs";
    }

    @GetMapping("/admin/external")
    public String adminExternal() {
        return "admin/external";
    }
}
