package com.hospital.security;

import com.hospital.service.RateLimiterService;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;

/**
 * Wraps the standard DaoAuthenticationProvider with a per-email sliding-window
 * rate limit, so repeated bad-password guesses against the same account get
 * locked out instead of retried indefinitely.
 */
public class RateLimitedAuthenticationProvider implements AuthenticationProvider {

    private final DaoAuthenticationProvider delegate;
    private final RateLimiterService rateLimiter;

    public RateLimitedAuthenticationProvider(DaoAuthenticationProvider delegate,
                                              RateLimiterService rateLimiter) {
        this.delegate = delegate;
        this.rateLimiter = rateLimiter;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String key = String.valueOf(authentication.getPrincipal());

        if (rateLimiter.isBlocked(key)) {
            throw new LockedException(
                "Too many failed login attempts. Please try again in 15 minutes.");
        }

        try {
            Authentication result = delegate.authenticate(authentication);
            rateLimiter.recordSuccess(key);
            return result;
        } catch (AuthenticationException e) {
            rateLimiter.recordFailure(key);
            throw e;
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return delegate.supports(authentication);
    }
}
