-- Indexes on the columns actually filtered by the app's hot-path queries:
-- status lookups (findByStatus), the overlap-detection queries
-- (bed/icu/ot id + status), and the various patient/doctor foreign-key
-- lookups used throughout the admin/doctor/patient dashboards.

CREATE INDEX idx_bed_admissions_bed_status ON bed_admissions (bed_id, status);
CREATE INDEX idx_bed_admissions_patient ON bed_admissions (patient_id);
CREATE INDEX idx_bed_admissions_doctor ON bed_admissions (doctor_id);

CREATE INDEX idx_icu_admissions_icu_status ON icu_admissions (icu_id, status);
CREATE INDEX idx_icu_admissions_patient ON icu_admissions (patient_id);
CREATE INDEX idx_icu_admissions_doctor ON icu_admissions (doctor_id);

CREATE INDEX idx_ot_schedules_ot_date_status ON ot_schedules (ot_id, schedule_date, status);
CREATE INDEX idx_ot_schedules_doctor_date_status ON ot_schedules (doctor_id, schedule_date, status);
CREATE INDEX idx_ot_schedules_patient ON ot_schedules (patient_id);

CREATE INDEX idx_doctor_patient_doctor_status ON doctor_patient (doctor_id, status);
CREATE INDEX idx_doctor_patient_patient_status ON doctor_patient (patient_id, status);

CREATE INDEX idx_patient_notes_patient ON patient_notes (patient_id);
CREATE INDEX idx_patient_notes_doctor ON patient_notes (doctor_id);

CREATE INDEX idx_patient_recommendations_patient ON patient_recommendations (patient_id);

CREATE INDEX idx_equipment_logs_type_time ON equipment_logs (equipment_type, log_time);

CREATE INDEX idx_audit_logs_entity ON audit_logs (entity_type, entity_id);
