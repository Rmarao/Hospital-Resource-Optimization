package com.hospital.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.format.DateTimeParseException;

/**
 * Catches Bean Validation failures and common bad-input parsing exceptions
 * (malformed dates/numbers/enums from @RequestParam) and redirects back to
 * the page the form was submitted from with an error param, instead of a
 * raw 500. Deliberately scoped to known input-parsing failure modes rather
 * than a catch-all Exception handler, which would risk masking real bugs.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ConstraintViolationException.class)
    public String handleConstraintViolation(ConstraintViolationException ex, HttpServletRequest request) {
        return "redirect:" + backTo(request, "validation");
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public String handleMethodArgumentNotValid(MethodArgumentNotValidException ex, HttpServletRequest request) {
        return "redirect:" + backTo(request, "validation");
    }

    @ExceptionHandler({DateTimeParseException.class, NumberFormatException.class, IllegalArgumentException.class})
    public String handleBadInput(Exception ex, HttpServletRequest request) {
        logger.warn("Bad input on {}", request.getRequestURI(), ex);
        return "redirect:" + backTo(request, "badinput");
    }

    // A concurrent duplicate insert (e.g. two signups racing on the same
    // email) throws this after the app-level existence check already
    // passed — without this handler it surfaces as a raw 500.
    @ExceptionHandler(DataIntegrityViolationException.class)
    public String handleDataIntegrityViolation(DataIntegrityViolationException ex, HttpServletRequest request) {
        logger.warn("Data integrity violation on {}", request.getRequestURI(), ex);
        return "redirect:" + backTo(request, "conflict");
    }

    /**
     * Builds the redirect target from the Referer header, but only ever
     * keeps the path + query of THIS app — never the scheme/host — so a
     * spoofed Referer can't turn this into an open redirect (CWE-601).
     */
    private String backTo(HttpServletRequest request, String errorCode) {
        String path = safeRelativePath(request.getHeader("Referer"));
        String separator = path.contains("?") ? "&" : "?";
        return path + separator + "error=" + errorCode;
    }

    private String safeRelativePath(String referer) {
        if (referer == null || referer.isBlank()) {
            return "/";
        }
        try {
            URI uri = new URI(referer);
            String path = uri.getRawPath();
            if (path == null || path.isBlank()) {
                return "/";
            }
            String query = uri.getRawQuery();
            return query != null ? path + "?" + query : path;
        } catch (URISyntaxException e) {
            return "/";
        }
    }
}
