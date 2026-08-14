package com.hospital.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LoginController {

    // Authentication itself (POST /login, GET /logout) is handled by
    // Spring Security's form-login/logout filters — see SecurityConfig.
    @GetMapping("/")
    public String showLogin() {
        return "login";
    }
}
