-- Default admin login: admin@hospital.com / admin123 (BCrypt-hashed)
INSERT INTO admins (name, email, password, phone, created_at)
VALUES ('System Admin', 'admin@hospital.com', '$2a$10$I6NDyaLUFHHVVLG73fB5.u04aPK1Z3N2qiz0MKMcEMX2oaeerEAEW', '9999999999', NOW());

-- A sample doctor: doctor@hospital.com / doctor123 (BCrypt-hashed)
INSERT INTO doctors (name, email, password, phone, specialization, qualification, department, practice_start_date, created_at)
VALUES ('Dr. Asha Rao', 'doctor@hospital.com', '$2a$10$.HQFA5lB6CQ4FvwGL4JaV.TLDf1ciiMG.2qlpmMFaVZLUZNz8sgMK', '9888888888',
        'Cardiology', 'MD, DM Cardiology', 'CARDIOLOGY', '2015-06-01', NOW());

-- Some starter resources so the admin dashboard isn't empty
INSERT INTO beds (bed_number, ward, floor, status) VALUES
 ('B-101', 'General Ward', 1, 'AVAILABLE'),
 ('B-102', 'General Ward', 1, 'AVAILABLE'),
 ('B-201', 'Private Ward', 2, 'AVAILABLE');

INSERT INTO icu (ventilator, status) VALUES
 (true, 'AVAILABLE'),
 (false, 'AVAILABLE');

INSERT INTO ot (status) VALUES ('AVAILABLE'), ('AVAILABLE');

INSERT INTO oxygen_tanks (tank_no, capacity, current_level, status) VALUES
 (1, 100, 85.5, 'AVAILABLE'),
 (2, 100, 40.0, 'AVAILABLE');

INSERT INTO blood_bank (component, blood_group, quantity_units, collection_date, expiry_date, status) VALUES
 ('WHOLE_BLOOD', 'O+', 12, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 35 DAY), 'AVAILABLE'),
 ('PLASMA', 'A+', 8, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), 'AVAILABLE');
