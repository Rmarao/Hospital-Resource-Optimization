package com.hospital.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * Repopulates the same session attributes LoginController used to set
 * manually, so the JSP sidebar/navbar fragments (which read
 * session.getAttribute("userName")/"loggedInId") keep working unchanged.
 */
@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                         HttpServletResponse response,
                                         Authentication authentication) throws IOException, ServletException {

        AppUserPrincipal principal = (AppUserPrincipal) authentication.getPrincipal();

        HttpSession session = request.getSession();
        session.setAttribute("role", principal.getRole());
        session.setAttribute("userName", principal.getName());
        session.setAttribute("loggedInId", principal.getId());

        String redirectUrl = switch (principal.getRole()) {
            case "ADMIN" -> "/admin/dashboard";
            case "DOCTOR" -> "/doctor/dashboard";
            case "PATIENT" -> "/patient/dashboard";
            default -> "/";
        };

        response.sendRedirect(request.getContextPath() + redirectUrl);
    }
}
