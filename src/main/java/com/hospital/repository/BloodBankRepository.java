package com.hospital.repository;

import com.hospital.model.BloodBank;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BloodBankRepository extends JpaRepository<BloodBank, Integer> {
    List<BloodBank> findByStatus(String status);
    List<BloodBank> findByBloodGroupAndComponent(String bloodGroup, String component);
    List<BloodBank> findByComponent(String component);
}