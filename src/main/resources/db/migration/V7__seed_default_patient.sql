-- Default patient login, matching the existing admin/doctor seed pattern:
-- patient@hospital.com / patient123 (BCrypt-hashed)
INSERT INTO patients (name, email, password, phone, date_of_birth, gender, blood_group,
                       address, emergency_contact, medical_history, created_at)
VALUES ('Sample Patient', 'patient@hospital.com', '$2a$10$4nIsISGWbn2al5WNva13J.fns/QPX1qGuHeB6xvSH12HEGmJUEmqW',
        '9777777777', '1995-04-12', 'Female', 'O+', '123 Main Street', '9666666666',
        'No known allergies. No significant medical history.', NOW());
