package com.hospital.repository;

import com.hospital.model.Icu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface IcuRepository extends JpaRepository<Icu, Integer> {
    List<Icu> findByStatus(String status);
    long countByStatus(String status);
}