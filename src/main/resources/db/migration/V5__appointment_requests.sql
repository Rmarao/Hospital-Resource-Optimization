CREATE TABLE `appointment_requests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `patient_id` bigint NOT NULL,
  `doctor_id` bigint NOT NULL,
  `reason` varchar(500) NOT NULL,
  `preferred_date` date NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `doctor_note` varchar(500) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `responded_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
