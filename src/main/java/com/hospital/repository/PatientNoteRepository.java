package com.hospital.repository;

import com.hospital.model.PatientNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PatientNoteRepository extends JpaRepository<PatientNote, Integer> {
    List<PatientNote> findByPatientIdOrderByCreatedAtDesc(Long patientId);
    List<PatientNote> findByDoctorIdOrderByCreatedAtDesc(Long doctorId);
}
