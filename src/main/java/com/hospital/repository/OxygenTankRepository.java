package com.hospital.repository;

import com.hospital.model.OxygenTank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OxygenTankRepository extends JpaRepository<OxygenTank, Integer> {
    List<OxygenTank> findByStatus(String status);
    long countByStatus(String status);
    OxygenTank findByTankNo(Integer tankNo);
}