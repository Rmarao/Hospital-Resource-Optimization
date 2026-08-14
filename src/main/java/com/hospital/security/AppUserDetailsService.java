package com.hospital.security;

import com.hospital.model.Admin;
import com.hospital.model.Doctor;
import com.hospital.model.Patient;
import com.hospital.repository.AdminRepository;
import com.hospital.repository.DoctorRepository;
import com.hospital.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * Admin/Doctor/Patient are three separate tables with no shared identity —
 * this tries each in turn and wraps whichever matches into a single
 * UserDetails type carrying one role authority.
 */
@Service
public class AppUserDetailsService implements UserDetailsService {

    @Autowired private AdminRepository adminRepository;
    @Autowired private DoctorRepository doctorRepository;
    @Autowired private PatientRepository patientRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        Doctor doctor = doctorRepository.findByEmail(email);
        if (doctor != null) {
            return new AppUserPrincipal(doctor.getId(), doctor.getName(),
                doctor.getEmail(), doctor.getPassword(), "DOCTOR");
        }

        Admin admin = adminRepository.findByEmail(email);
        if (admin != null) {
            return new AppUserPrincipal(admin.getId(), admin.getName(),
                admin.getEmail(), admin.getPassword(), "ADMIN");
        }

        Patient patient = patientRepository.findByEmail(email);
        if (patient != null) {
            return new AppUserPrincipal(patient.getId(), patient.getName(),
                patient.getEmail(), patient.getPassword(), "PATIENT");
        }

        throw new UsernameNotFoundException("No account found for " + email);
    }
}
