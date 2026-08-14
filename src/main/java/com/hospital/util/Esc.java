package com.hospital.util;

import org.springframework.web.util.HtmlUtils;

/**
 * HTML-escapes user-controlled entity fields before they are echoed into JSPs
 * via scriptlet output. Null-safe wrapper around Spring's HtmlUtils, since
 * most entity getters can return null.
 */
public final class Esc {

    private Esc() {
    }

    public static String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    public static String h(Object value) {
        return value == null ? "" : HtmlUtils.htmlEscape(String.valueOf(value));
    }
}
