package com.hospital.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Deque;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.concurrent.TimeUnit;

/**
 * Simple sliding-window rate limiter (no external dependency needed at this
 * scale). Tracks failed attempts per key (email or IP) and blocks once the
 * threshold is exceeded within the window.
 *
 * Backed by a Caffeine cache (bounded size + write-TTL) rather than a plain
 * ConcurrentHashMap so keys that fail once and are never retried don't
 * accumulate forever — the cache evicts them on its own.
 */
@Service
public class RateLimiterService {

    private static final int MAX_ATTEMPTS = 5;
    private static final long WINDOW_MILLIS = 15 * 60 * 1000L; // 15 minutes

    private final Cache<String, Deque<Long>> attempts = Caffeine.newBuilder()
        .expireAfterWrite(15, TimeUnit.MINUTES)
        .maximumSize(50_000)
        .build();

    public boolean isBlocked(String key) {
        Deque<Long> timestamps = attempts.getIfPresent(normalize(key));
        if (timestamps == null) return false;
        prune(timestamps);
        return timestamps.size() >= MAX_ATTEMPTS;
    }

    public void recordFailure(String key) {
        Deque<Long> timestamps = attempts.get(normalize(key), k -> new ConcurrentLinkedDeque<>());
        timestamps.addLast(Instant.now().toEpochMilli());
        prune(timestamps);
    }

    public void recordSuccess(String key) {
        attempts.invalidate(normalize(key));
    }

    private void prune(Deque<Long> timestamps) {
        long cutoff = Instant.now().toEpochMilli() - WINDOW_MILLIS;
        while (!timestamps.isEmpty() && timestamps.peekFirst() < cutoff) {
            timestamps.pollFirst();
        }
    }

    private String normalize(String key) {
        return key == null ? "" : key.trim().toLowerCase();
    }
}
