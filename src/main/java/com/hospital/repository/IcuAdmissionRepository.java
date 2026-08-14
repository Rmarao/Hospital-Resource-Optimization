package com.hospital.repository;

import com.hospital.model.IcuAdmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface IcuAdmissionRepository extends JpaRepository<IcuAdmission, Integer> {
    List<IcuAdmission> findByPatientId(Long patientId);
    List<IcuAdmission> findByDoctorId(Long doctorId);
    List<IcuAdmission> findByStatus(String status);
    IcuAdmission findByIcuIdAndStatus(Integer icuId, String status);
    @Query("SELECT i FROM IcuAdmission i WHERE i.icuId = :icuId " +
    	       "AND i.status = 'ACTIVE' " +
    	       "AND i.admittedDate < :dischargeDate " +
    	       "AND i.dischargeDate > :admittedDate")
    	List<IcuAdmission> findOverlappingIcuBookings(
    	    @Param("icuId") Integer icuId,
    	    @Param("admittedDate") LocalDate admittedDate,
    	    @Param("dischargeDate") LocalDate dischargeDate
    	);
}