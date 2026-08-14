package com.hospital.util;

/**
 * Escapes a single CSV field per RFC 4180: quote the field and double any
 * embedded quotes whenever it contains a comma, quote, or newline.
 */
public final class Csv {

    private Csv() {
    }

    public static String field(Object value) {
        String s = value == null ? "" : String.valueOf(value);
        if (s.indexOf(',') >= 0 || s.indexOf('"') >= 0 || s.indexOf('\n') >= 0 || s.indexOf('\r') >= 0) {
            s = "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }
}
