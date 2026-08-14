package com.hospital.controller;

import com.hospital.model.*;
import com.hospital.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDate;

@Controller
@RequestMapping("/admin")
public class AdminResourceController {

    @Autowired private BedRepository bedRepository;
    @Autowired private IcuRepository icuRepository;
    @Autowired private OtRepository otRepository;
    @Autowired private OxygenTankRepository oxygenTankRepository;
    @Autowired private BloodBankRepository bloodBankRepository;

    // ─── RESOURCES PAGE ───────────────────────────────────────

    @GetMapping("/resources")
    public String resourcesPage(HttpSession session, Model model) {

        // Beds
        model.addAttribute("beds", bedRepository.findAll());
        model.addAttribute("totalBeds", bedRepository.count());
        model.addAttribute("availableBeds", bedRepository.countByStatus("AVAILABLE"));
        model.addAttribute("occupiedBeds", bedRepository.countByStatus("OCCUPIED"));

        // ICU
        model.addAttribute("icus", icuRepository.findAll());
        model.addAttribute("totalIcu", icuRepository.count());
        model.addAttribute("availableIcu", icuRepository.countByStatus("AVAILABLE"));
        model.addAttribute("occupiedIcu", icuRepository.countByStatus("OCCUPIED"));

        // OT
        model.addAttribute("ots", otRepository.findAll());
        model.addAttribute("totalOt", otRepository.count());
        model.addAttribute("availableOt", otRepository.countByStatus("AVAILABLE"));

        // Oxygen
        model.addAttribute("oxygenTanks", oxygenTankRepository.findAll());
        model.addAttribute("totalOxygen", oxygenTankRepository.count());
        model.addAttribute("availableOxygen", oxygenTankRepository.countByStatus("AVAILABLE"));

        // Blood Bank
        model.addAttribute("bloodBanks", bloodBankRepository.findAll());

        return "admin/resources";
    }

    // ─── BEDS ─────────────────────────────────────────────────

    @PostMapping("/resources/beds/add")
    public String addBed(@RequestParam String bedNumber,
                         @RequestParam String ward,
                         @RequestParam Integer floor,
                         HttpSession session) {
        Bed bed = new Bed();
        bed.setBedNumber(bedNumber);
        bed.setWard(ward);
        bed.setFloor(floor);
        bed.setStatus("AVAILABLE");
        bedRepository.save(bed);
        return "redirect:/admin/resources?tab=beds&success=Bed added successfully";
    }

    @PostMapping("/resources/beds/status")
    public String updateBedStatus(@RequestParam Integer id,
                                  @RequestParam String status,
                                  HttpSession session) {
        Bed bed = bedRepository.findById(id).orElse(null);
        if (bed != null) {
            bed.setStatus(status);
            bedRepository.save(bed);
        }
        return "redirect:/admin/resources?tab=beds";
    }

    @PostMapping("/resources/beds/delete")
    public String deleteBed(@RequestParam Integer id, HttpSession session) {
        bedRepository.deleteById(id);
        return "redirect:/admin/resources?tab=beds&success=Bed removed successfully";
    }

    // ─── ICU ──────────────────────────────────────────────────

    @PostMapping("/resources/icu/add")
    public String addIcu(@RequestParam Boolean ventilator,
                         HttpSession session) {
        Icu icu = new Icu();
        icu.setVentilator(ventilator);
        icu.setStatus("AVAILABLE");
        icuRepository.save(icu);
        return "redirect:/admin/resources?tab=icu&success=ICU unit added successfully";
    }

    @PostMapping("/resources/icu/status")
    public String updateIcuStatus(@RequestParam Integer id,
                                  @RequestParam String status,
                                  HttpSession session) {
        Icu icu = icuRepository.findById(id).orElse(null);
        if (icu != null) {
            icu.setStatus(status);
            icuRepository.save(icu);
        }
        return "redirect:/admin/resources?tab=icu";
    }

    @PostMapping("/resources/icu/delete")
    public String deleteIcu(@RequestParam Integer id, HttpSession session) {
        icuRepository.deleteById(id);
        return "redirect:/admin/resources?tab=icu&success=ICU unit removed successfully";
    }

    // ─── OT ───────────────────────────────────────────────────

    @PostMapping("/resources/ot/add")
    public String addOt(HttpSession session) {
        Ot ot = new Ot();
        ot.setStatus("AVAILABLE");
        otRepository.save(ot);
        return "redirect:/admin/resources?tab=ot&success=OT added successfully";
    }

    @PostMapping("/resources/ot/status")
    public String updateOtStatus(@RequestParam Integer id,
                                 @RequestParam String status,
                                 HttpSession session) {
        Ot ot = otRepository.findById(id).orElse(null);
        if (ot != null) {
            ot.setStatus(status);
            otRepository.save(ot);
        }
        return "redirect:/admin/resources?tab=ot";
    }

    @PostMapping("/resources/ot/delete")
    public String deleteOt(@RequestParam Integer id, HttpSession session) {
        otRepository.deleteById(id);
        return "redirect:/admin/resources?tab=ot&success=OT removed successfully";
    }

    // ─── OXYGEN TANKS ─────────────────────────────────────────

    @PostMapping("/resources/oxygen/add")
    public String addOxygenTank(@RequestParam Integer tankNo,
                                @RequestParam Integer capacity,
                                @RequestParam Float currentLevel,
                                HttpSession session) {
        OxygenTank tank = new OxygenTank();
        tank.setTankNo(tankNo);
        tank.setCapacity(capacity);
        tank.setCurrentLevel(currentLevel);
        tank.setStatus("AVAILABLE");
        oxygenTankRepository.save(tank);
        return "redirect:/admin/resources?tab=oxygen&success=Oxygen tank added successfully";
    }

    @PostMapping("/resources/oxygen/update")
    public String updateOxygenTank(@RequestParam Integer id,
                                   @RequestParam Float currentLevel,
                                   @RequestParam String status,
                                   HttpSession session) {
        OxygenTank tank = oxygenTankRepository.findById(id).orElse(null);
        if (tank != null) {
            tank.setCurrentLevel(currentLevel);
            tank.setStatus(status);
            oxygenTankRepository.save(tank);
        }
        return "redirect:/admin/resources?tab=oxygen";
    }

    @PostMapping("/resources/oxygen/delete")
    public String deleteOxygenTank(@RequestParam Integer id, HttpSession session) {
        oxygenTankRepository.deleteById(id);
        return "redirect:/admin/resources?tab=oxygen&success=Oxygen tank removed successfully";
    }

    // ─── BLOOD BANK ───────────────────────────────────────────

    @PostMapping("/resources/blood/add")
    public String addBloodBank(@RequestParam String component,
                               @RequestParam String bloodGroup,
                               @RequestParam Integer quantityUnits,
                               @RequestParam String collectionDate,
                               @RequestParam String expiryDate,
                               HttpSession session) {
        BloodBank blood = new BloodBank();
        blood.setComponent(component);
        blood.setBloodGroup(bloodGroup);
        blood.setQuantityUnits(quantityUnits);
        blood.setCollectionDate(LocalDate.parse(collectionDate));
        blood.setExpiryDate(LocalDate.parse(expiryDate));
        blood.setStatus("AVAILABLE");
        bloodBankRepository.save(blood);
        return "redirect:/admin/resources?tab=blood&success=Blood component added successfully";
    }

    @PostMapping("/resources/blood/update")
    public String updateBloodBank(@RequestParam Integer id,
                                  @RequestParam Integer quantityUnits,
                                  @RequestParam String status,
                                  HttpSession session) {
        BloodBank blood = bloodBankRepository.findById(id).orElse(null);
        if (blood != null) {
            blood.setQuantityUnits(quantityUnits);
            blood.setStatus(status);
            bloodBankRepository.save(blood);
        }
        return "redirect:/admin/resources?tab=blood";
    }

    @PostMapping("/resources/blood/delete")
    public String deleteBloodBank(@RequestParam Integer id, HttpSession session) {
        bloodBankRepository.deleteById(id);
        return "redirect:/admin/resources?tab=blood&success=Blood component removed successfully";
    }
}