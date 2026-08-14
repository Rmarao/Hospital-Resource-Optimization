package com.hospital.repository;

import com.hospital.model.EquipmentLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EquipmentLogRepository extends JpaRepository<EquipmentLog, Integer> {
    List<EquipmentLog> findByEquipmentTypeOrderByLogTimeDesc(String equipmentType);
    EquipmentLog findTopByEquipmentTypeOrderByLogTimeDesc(String equipmentType);
    List<EquipmentLog> findTop10ByEquipmentTypeOrderByLogTimeDesc(String equipmentType);
    List<EquipmentLog> findByPredictedRisk(String risk);
}