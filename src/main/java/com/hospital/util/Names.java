package com.hospital.util;

public final class Names {

    private Names() {
    }

    /**
     * Strips any leading "Dr."/"Dr" honorific from a doctor's submitted name.
     * Every doctor-name template in the app prepends its own "Dr. " prefix,
     * so the stored name must always be the bare name — otherwise pages end
     * up rendering "Dr. Dr. Jane Doe".
     */
    public static String stripDoctorTitle(String name) {
        if (name == null) {
            return null;
        }
        return name.replaceFirst("(?i)^(dr\\.?\\s+)+", "").trim();
    }
}
