package com.hospital.service;

import com.hospital.model.Bed;
import com.hospital.model.BedAdmission;
import com.hospital.repository.*;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AutoDischargeServiceTest {

    @Mock private BedAdmissionRepository bedAdmissionRepository;
    @Mock private IcuAdmissionRepository icuAdmissionRepository;
    @Mock private OtScheduleRepository otScheduleRepository;
    @Mock private BedRepository bedRepository;
    @Mock private IcuRepository icuRepository;
    @Mock private OtRepository otRepository;
    @Mock private MachinePredictionService machinePredictionService;

    @InjectMocks
    private AutoDischargeService autoDischargeService;

    @Test
    void dischargesBedAdmissionPastDischargeDateAndFreesTheBed() {
        BedAdmission admission = new BedAdmission();
        admission.setId(1);
        admission.setBedId(5);
        admission.setDischargeDate(LocalDate.now().minusDays(1)); // due yesterday
        admission.setStatus("ACTIVE");

        Bed bed = new Bed();
        bed.setId(5);
        bed.setStatus("OCCUPIED");

        when(bedAdmissionRepository.findByStatus("ACTIVE")).thenReturn(List.of(admission));
        when(bedRepository.findById(5)).thenReturn(Optional.of(bed));
        when(icuAdmissionRepository.findByStatus("ACTIVE")).thenReturn(List.of());
        when(otScheduleRepository.findByStatus("SCHEDULED")).thenReturn(List.of());

        autoDischargeService.autoDischarge();

        assert admission.getStatus().equals("DISCHARGED");
        assert bed.getStatus().equals("AVAILABLE");
        verify(bedAdmissionRepository).save(admission);
        verify(bedRepository).save(bed);
    }

    @Test
    void leavesBedAdmissionWithFutureDischargeDateUntouched() {
        BedAdmission admission = new BedAdmission();
        admission.setId(2);
        admission.setBedId(6);
        admission.setDischargeDate(LocalDate.now().plusDays(3)); // not due yet
        admission.setStatus("ACTIVE");

        when(bedAdmissionRepository.findByStatus("ACTIVE")).thenReturn(List.of(admission));
        when(icuAdmissionRepository.findByStatus("ACTIVE")).thenReturn(List.of());
        when(otScheduleRepository.findByStatus("SCHEDULED")).thenReturn(List.of());

        autoDischargeService.autoDischarge();

        assert admission.getStatus().equals("ACTIVE");
        verify(bedAdmissionRepository, never()).save(any());
        verify(bedRepository, never()).findById(any());
    }
}
