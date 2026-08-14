package com.hospital.repository;

import com.hospital.model.Bed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BedRepository extends JpaRepository<Bed, Integer> {
    List<Bed> findByStatus(String status);
    long countByStatus(String status);
}