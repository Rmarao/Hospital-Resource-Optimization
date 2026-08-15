package com.hospital.controller;

import com.hospital.model.Patient;
import com.hospital.repository.PatientRepository;
import com.hospital.service.GoogleFitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import java.util.Map;

@Controller
@RequestMapping("/patient")
public class PatientFitnessController {

    @Autowired private PatientRepository patientRepository;
    @Autowired private GoogleFitService googleFitService;

    // Show fitness page
    @GetMapping("/fitness")
    public String fitnessPage(HttpSession session, Model model) {

        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);

        boolean isConnected = patient != null
            && patient.getGoogleFitAccessToken() != null
            && !patient.getGoogleFitAccessToken().isEmpty();

        model.addAttribute("isConnected", isConnected);

        if (isConnected && patient != null) {
            String accessToken = patient.getGoogleFitAccessToken();

            // Try to refresh token if needed
            if (patient.getGoogleFitRefreshToken() != null) {
                String newToken = googleFitService
                    .refreshAccessToken(patient.getGoogleFitRefreshToken());
                if (newToken != null) {
                    accessToken = newToken;
                    patient.setGoogleFitAccessToken(newToken);
                    patientRepository.save(patient);
                }
            }

            // Fetch fresh data from Google Fit
            int steps = googleFitService.getTodaySteps(accessToken);
            int calories = googleFitService.getTodayCalories(accessToken);
            int heartRate = googleFitService.getTodayHeartRate(accessToken);

            model.addAttribute("steps", steps);
            model.addAttribute("calories", calories);
            model.addAttribute("heartRate", heartRate);
        }

        // Google OAuth URL for connecting
        model.addAttribute("authUrl", googleFitService.getAuthUrl());
        return "patient/fitness";
    }

    // Google redirects here after patient authorizes
    @GetMapping("/fitness/callback")
    public String fitnessCallback(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String error,
            HttpSession session) {

        if (error != null) return "redirect:/patient/fitness?error=true";

        Long patientId = (Long) session.getAttribute("loggedInId");
        Patient patient = patientRepository.findById(patientId).orElse(null);

        if (patient != null && code != null) {
            // Exchange code for tokens
            Map<String, String> tokens =
                googleFitService.exchangeCodeForTokens(code);
            if (tokens != null) {
                patient.setGoogleFitAccessToken(tokens.get("access_token"));
                patient.setGoogleFitRefreshToken(tokens.get("refresh_token"));
                patientRepository.save(patient);
                return "redirect:/patient/fitness?connected=true";
            }
        }
        return "redirect:/patient/fitness?error=true";
    }
}