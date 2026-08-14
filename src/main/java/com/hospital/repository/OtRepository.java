package com.hospital.repository;

import com.hospital.model.Ot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OtRepository extends JpaRepository<Ot, Integer> {
    List<Ot> findByStatus(String status);
    long countByStatus(String status);
}