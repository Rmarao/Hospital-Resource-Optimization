package com.hospital.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/**
 * @EnableCaching lives here rather than on the main @SpringBootApplication
 * class deliberately: @DataJpaTest always loads that class as root config
 * regardless of its slice-filtering, so an @EnableCaching there would force
 * every repository test to need a CacheManager bean too. Keeping it on this
 * plain @Configuration means @DataJpaTest's component-scan filtering
 * excludes it along with the bean, and repository tests stay untouched by
 * caching entirely.
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * Short-TTL cache for read-heavy dashboard aggregate counts
     * (bed/ICU/OT/oxygen/doctor/patient counts) — these change rarely
     * relative to how often the dashboard is loaded, so a 30s cache
     * turns N repeated COUNT queries per page view into one query per
     * 30 seconds without the dashboard ever showing badly stale numbers.
     */
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager manager = new CaffeineCacheManager("dashboardStats", "alertsSummary");
        manager.setCaffeine(Caffeine.newBuilder()
            .expireAfterWrite(30, TimeUnit.SECONDS)
            .maximumSize(10));
        return manager;
    }
}
