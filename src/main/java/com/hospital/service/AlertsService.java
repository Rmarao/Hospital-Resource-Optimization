package com.hospital.service;

import com.hospital.model.BloodBank;
import com.hospital.model.EquipmentLog;
import com.hospital.model.OxygenTank;
import com.hospital.repository.BloodBankRepository;
import com.hospital.repository.EquipmentLogRepository;
import com.hospital.repository.OxygenTankRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Aggregates low blood stock, low oxygen, and high-risk equipment into a
 * single alert summary — shared by the admin Alerts page and the navbar
 * notification bell so the two never drift out of sync.
 */
@Service
public class AlertsService {

    private static final int LOW_BLOOD_UNITS_THRESHOLD = 5;
    private static final int EXPIRING_SOON_DAYS = 3;
    private static final float LOW_OXYGEN_PERCENT_THRESHOLD = 20f;

    @Autowired private BloodBankRepository bloodBankRepository;
    @Autowired private OxygenTankRepository oxygenTankRepository;
    @Autowired private EquipmentLogRepository equipmentLogRepository;

    public static class Summary {
        public List<BloodBank> expiredBlood;
        public List<BloodBank> expiringSoonBlood;
        public List<BloodBank> lowStockBlood;
        public List<OxygenTank> lowOxygenTanks;
        public List<EquipmentLog> highRiskEquipment;
        public int totalAlerts;
    }

    @Cacheable("alertsSummary")
    public Summary getSummary() {
        List<BloodBank> allBlood = bloodBankRepository.findAll();

        List<BloodBank> expiredBlood = allBlood.stream()
            .filter(b -> b.isExpired())
            .collect(Collectors.toList());

        List<BloodBank> expiringSoonBlood = allBlood.stream()
            .filter(b -> !b.isExpired() && b.getDaysUntilExpiry() <= EXPIRING_SOON_DAYS)
            .collect(Collectors.toList());

        List<BloodBank> lowStockBlood = allBlood.stream()
            .filter(b -> !b.isExpired()
                && b.getQuantityUnits() != null
                && b.getQuantityUnits() < LOW_BLOOD_UNITS_THRESHOLD)
            .collect(Collectors.toList());

        List<OxygenTank> lowOxygenTanks = oxygenTankRepository.findAll().stream()
            .filter(t -> t.getCurrentLevel() != null && t.getCapacity() != null && t.getCapacity() > 0
                && (t.getCurrentLevel() / t.getCapacity() * 100f) < LOW_OXYGEN_PERCENT_THRESHOLD)
            .collect(Collectors.toList());

        Map<String, EquipmentLog> latestPerDevice = new LinkedHashMap<>();
        for (EquipmentLog log : equipmentLogRepository.findAll()) {
            String key = log.getEquipmentType() + "#" + log.getEquipmentId();
            EquipmentLog existing = latestPerDevice.get(key);
            if (existing == null || (log.getLogTime() != null && log.getLogTime().isAfter(existing.getLogTime()))) {
                latestPerDevice.put(key, log);
            }
        }
        List<EquipmentLog> highRiskEquipment = latestPerDevice.values().stream()
            .filter(l -> "HIGH".equals(l.getPredictedRisk()))
            .sorted((l1, l2) -> {
                java.time.LocalDateTime t1 = l1.getLogTime();
                java.time.LocalDateTime t2 = l2.getLogTime();
                if (t1 == null && t2 == null) return 0;
                if (t1 == null) return 1;
                if (t2 == null) return -1;
                return t2.compareTo(t1);
            })
            .collect(Collectors.toList());

        Summary summary = new Summary();
        summary.expiredBlood = expiredBlood;
        summary.expiringSoonBlood = expiringSoonBlood;
        summary.lowStockBlood = lowStockBlood;
        summary.lowOxygenTanks = lowOxygenTanks;
        summary.highRiskEquipment = highRiskEquipment;
        summary.totalAlerts = expiredBlood.size() + expiringSoonBlood.size() + lowStockBlood.size()
            + lowOxygenTanks.size() + highRiskEquipment.size();
        return summary;
    }
}
