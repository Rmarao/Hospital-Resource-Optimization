CREATE TABLE `doctor_availability` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `doctor_id` bigint NOT NULL,
  `day_of_week` varchar(9) NOT NULL,
  `available` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_doctor_day` (`doctor_id`, `day_of_week`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
