package com.hospital.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Service
public class GoogleFitService {
	@Value("${google.fit.client.id}")
    private String clientId;

    @Value("${google.fit.client.secret}")
    private String clientSecret;

    @Value("${google.fit.redirect.uri}")
    private String redirectUri;

    private final RestTemplate restTemplate = new RestTemplate();

    // Step 1 — Generate Google OAuth URL
    public String getAuthUrl() {
        return "https://accounts.google.com/o/oauth2/v2/auth"
            + "?client_id=" + clientId
            + "&redirect_uri=" + redirectUri
            + "&response_type=code"
            + "&scope=https://www.googleapis.com/auth/fitness.activity.read"
            + "%20https://www.googleapis.com/auth/fitness.heart_rate.read"
            + "%20https://www.googleapis.com/auth/fitness.sleep.read"
            + "%20https://www.googleapis.com/auth/fitness.body.read"
            + "&access_type=offline"
            + "&prompt=consent";
    }

    // Step 2 — Exchange auth code for tokens
    public Map<String, String> exchangeCodeForTokens(String code) {
        String url = "https://oauth2.googleapis.com/token";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        String body = "code=" + code
            + "&client_id=" + clientId
            + "&client_secret=" + clientSecret
            + "&redirect_uri=" + redirectUri
            + "&grant_type=authorization_code";

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);
            Map<String, Object> responseBody = response.getBody();
            if (responseBody != null) {
                Map<String, String> tokens = new HashMap<>();
                tokens.put("access_token",
                    (String) responseBody.get("access_token"));
                tokens.put("refresh_token",
                    (String) responseBody.getOrDefault("refresh_token", ""));
                return tokens;
            }
        } catch (Exception e) {
            System.err.println("Token exchange error: " + e.getMessage());
        }
        return null;
    }

    // Step 3 — Refresh expired access token
    public String refreshAccessToken(String refreshToken) {
        String url = "https://oauth2.googleapis.com/token";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        String body = "client_id=" + clientId
            + "&client_secret=" + clientSecret
            + "&refresh_token=" + refreshToken
            + "&grant_type=refresh_token";

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);
            if (response.getBody() != null) {
                return (String) response.getBody().get("access_token");
            }
        } catch (Exception e) {
            System.err.println("Token refresh error: " + e.getMessage());
        }
        return null;
    }

    // Step 4 — Fetch steps for today
    public int getTodaySteps(String accessToken) {
        long now = System.currentTimeMillis();
        long startOfDay = now - (now % 86400000); // midnight today

        String url = "https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        String body = "{"
            + "\"aggregateBy\": [{\"dataTypeName\": \"com.google.step_count.delta\"}],"
            + "\"bucketByTime\": {\"durationMillis\": 86400000},"
            + "\"startTimeMillis\": " + startOfDay + ","
            + "\"endTimeMillis\": " + now
            + "}";

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);
            return extractIntValue(response.getBody(), "intVal");
        } catch (Exception e) {
            System.err.println("Steps error: " + e.getMessage());
            return 0;
        }
    }

    // Step 5 — Fetch calories for today
    public int getTodayCalories(String accessToken) {
        long now = System.currentTimeMillis();
        long startOfDay = now - (now % 86400000);

        String url = "https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        String body = "{"
            + "\"aggregateBy\": [{\"dataTypeName\": \"com.google.calories.expended\"}],"
            + "\"bucketByTime\": {\"durationMillis\": 86400000},"
            + "\"startTimeMillis\": " + startOfDay + ","
            + "\"endTimeMillis\": " + now
            + "}";

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);
            return extractIntValue(response.getBody(), "fpVal");
        } catch (Exception e) {
            System.err.println("Calories error: " + e.getMessage());
            return 0;
        }
    }

    // Step 6 — Fetch heart rate
    public int getTodayHeartRate(String accessToken) {
        long now = System.currentTimeMillis();
        long startOfDay = now - (now % 86400000);

        String url = "https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        String body = "{"
            + "\"aggregateBy\": [{"
            + "\"dataTypeName\": \"com.google.heart_rate.bpm\","
            + "\"dataSourceId\": \"derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm\""
            + "}],"
            + "\"bucketByTime\": {\"durationMillis\": 86400000},"
            + "\"startTimeMillis\": " + startOfDay + ","
            + "\"endTimeMillis\": " + now
            + "}";

        HttpEntity<String> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response =
                restTemplate.postForEntity(url, entity, Map.class);
            return extractIntValue(response.getBody(), "fpVal");
        } catch (Exception e) {
            System.err.println("Heart rate error: " + e.getMessage());
            return 0;
        }
    }

    // Helper to extract numeric value from Google Fit response
    private int extractIntValue(Map<String, Object> body, String valueKey) {
        if (body == null) return 0;
        try {
            List<Map<String, Object>> buckets =
                (List<Map<String, Object>>) body.get("bucket");
            if (buckets == null || buckets.isEmpty()) return 0;

            for (Map<String, Object> bucket : buckets) {
                List<Map<String, Object>> datasets =
                    (List<Map<String, Object>>) bucket.get("dataset");
                if (datasets == null) continue;

                for (Map<String, Object> dataset : datasets) {
                    List<Map<String, Object>> points =
                        (List<Map<String, Object>>) dataset.get("point");
                    if (points == null || points.isEmpty()) continue;

                    for (Map<String, Object> point : points) {
                        List<Map<String, Object>> values =
                            (List<Map<String, Object>>) point.get("value");
                        if (values == null || values.isEmpty()) continue;

                        Object val = values.get(0).get(valueKey);
                        if (val != null)
                            return ((Number) val).intValue();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Parse error: " + e.getMessage());
        }
        return 0;
    }
}
