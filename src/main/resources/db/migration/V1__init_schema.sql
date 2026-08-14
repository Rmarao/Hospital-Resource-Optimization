-- Baseline schema, captured from the live Hibernate-managed dev database
-- (spring.jpa.hibernate.ddl-auto was `update` before this migration).
-- Flyway now owns schema changes going forward; ddl-auto is `validate`.

CREATE TABLE `admins` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK47bvqemyk6vlm0w7crc3opdd4` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `audit_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `action` varchar(255) DEFAULT NULL,
  `actor_id` bigint DEFAULT NULL,
  `actor_role` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `details` text,
  `entity_id` varchar(255) DEFAULT NULL,
  `entity_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `bed_admissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admitted_date` date DEFAULT NULL,
  `bed_id` int DEFAULT NULL,
  `discharge_date` date DEFAULT NULL,
  `doctor_id` bigint DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `beds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bed_number` varchar(255) DEFAULT NULL,
  `floor` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `ward` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `blood_bank` (
  `id` int NOT NULL AUTO_INCREMENT,
  `blood_group` varchar(255) DEFAULT NULL,
  `collection_date` date DEFAULT NULL,
  `component` varchar(255) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_units` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `doctor_patient` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assigned_date` date DEFAULT NULL,
  `doctor_id` bigint DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `doctors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `practice_start_date` date DEFAULT NULL,
  `qualification` varchar(255) DEFAULT NULL,
  `specialization` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKcaifv0va46t2mu85cg5afmayf` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `equipment_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `days_since_maintenance` int DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  `equipment_type` varchar(255) DEFAULT NULL,
  `error_count` int DEFAULT NULL,
  `internal_temperature` float DEFAULT NULL,
  `log_time` datetime(6) DEFAULT NULL,
  `mechanical_load` float DEFAULT NULL,
  `operating_hours` float DEFAULT NULL,
  `power_fluctuation` float DEFAULT NULL,
  `predicted_risk` varchar(255) DEFAULT NULL,
  `risk_probability` float DEFAULT NULL,
  `room_temperature` float DEFAULT NULL,
  `usage_intensity` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `icu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `ventilator` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `icu_admissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admitted_date` date DEFAULT NULL,
  `discharge_date` date DEFAULT NULL,
  `doctor_id` bigint DEFAULT NULL,
  `icu_id` int DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ot` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ot_schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` bigint DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `ot_id` int DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `procedure_name` varchar(255) DEFAULT NULL,
  `schedule_date` date DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `oxygen_tanks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capacity` int DEFAULT NULL,
  `current_level` float DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `tank_no` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK7t2r9yufywueetksa54o9ippe` (`tank_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `patient_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `advice` text,
  `created_at` datetime(6) DEFAULT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `doctor_id` bigint DEFAULT NULL,
  `follow_up_date` date DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `prescription` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `patient_recommendations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `doctor_specialization` varchar(255) DEFAULT NULL,
  `patient_id` bigint DEFAULT NULL,
  `reasoning` text,
  `recommended_resources` varchar(255) DEFAULT NULL,
  `severity_level` varchar(255) DEFAULT NULL,
  `severity_score` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `urgency` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `patients` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `blood_group` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `emergency_contact` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `google_fit_token` text,
  `google_fit_refresh_token` text,
  `medical_history` text,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKa370hmxgv0l5c9panryr1ji7d` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
