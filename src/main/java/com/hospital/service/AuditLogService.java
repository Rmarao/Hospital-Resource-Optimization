package com.hospital.service;

import com.hospital.model.AuditLog;
import com.hospital.repository.AuditLogRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * Records who did what to which record and when — the actor comes from the
 * current session (already populated by LoginSuccessHandler), so callers
 * only need to say what happened.
 */
@Service
public class AuditLogService {

    @Autowired private AuditLogRepository auditLogRepository;

    public void record(HttpSession session, String action, String entityType, Object entityId, String details) {
        AuditLog log = new AuditLog();
        Object loggedInId = session.getAttribute("loggedInId");
        log.setActorId(loggedInId != null ? Long.valueOf(loggedInId.toString()) : null);
        log.setActorRole((String) session.getAttribute("role"));
        log.setAction(action);
        log.setEntityType(entityType);
        log.setEntityId(entityId != null ? entityId.toString() : null);
        log.setDetails(details);
        auditLogRepository.save(log);
    }
}
