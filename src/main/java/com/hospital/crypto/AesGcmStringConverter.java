package com.hospital.crypto;

import jakarta.persistence.AttributeConverter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * AES-256-GCM field-level encryption for at-rest sensitive columns
 * (Google Fit tokens, medical history). Key comes from the
 * APP_ENCRYPTION_KEY env var (base64, 32 bytes) — see README.
 *
 * Decryption falls back to returning the raw stored value if it isn't
 * valid ciphertext (no "enc:" prefix), so pre-existing plaintext rows
 * (written before this converter was introduced) remain readable and get
 * encrypted on next save instead of requiring a one-off data migration.
 * A value that DOES have the "enc:" prefix but fails to decrypt (e.g. the
 * encryption key was rotated/lost) is a different, more serious case —
 * that returns a clear placeholder instead of the raw ciphertext, so it's
 * obvious to whoever's looking at the record that something's wrong
 * rather than silently displaying a base64 blob as if it were real data.
 */
@Component
public class AesGcmStringConverter implements AttributeConverter<String, String> {

    private static final Logger logger = LoggerFactory.getLogger(AesGcmStringConverter.class);
    private static final String ALGO = "AES/GCM/NoPadding";
    private static final int IV_LENGTH = 12;
    private static final int TAG_LENGTH_BITS = 128;
    private static final String UNDECRYPTABLE_PLACEHOLDER =
        "[unable to decrypt — check APP_ENCRYPTION_KEY]";

    private static byte[] KEY_BYTES;

    @Value("${app.encryption.key:}")
    public void setKey(String base64Key) {
        if (base64Key == null || base64Key.isBlank()) {
            logger.warn("APP_ENCRYPTION_KEY not set — generating an ephemeral key. "
                + "Encrypted data will be UNREADABLE after restart. Set APP_ENCRYPTION_KEY "
                + "for any persistent environment (see README).");
            byte[] ephemeral = new byte[32];
            new SecureRandom().nextBytes(ephemeral);
            KEY_BYTES = ephemeral;
        } else {
            KEY_BYTES = Base64.getDecoder().decode(base64Key);
        }
    }

    @Override
    public String convertToDatabaseColumn(String plaintext) {
        if (plaintext == null) return null;
        try {
            Cipher cipher = Cipher.getInstance(ALGO);
            byte[] iv = new byte[IV_LENGTH];
            new SecureRandom().nextBytes(iv);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec(), new GCMParameterSpec(TAG_LENGTH_BITS, iv));
            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));

            byte[] combined = new byte[iv.length + ciphertext.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(ciphertext, 0, combined, iv.length, ciphertext.length);
            return "enc:" + Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to encrypt field", e);
        }
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null) return null;
        if (!dbData.startsWith("enc:")) {
            return dbData; // legacy plaintext row, written before encryption was added
        }
        try {
            byte[] combined = Base64.getDecoder().decode(dbData.substring(4));
            byte[] iv = new byte[IV_LENGTH];
            System.arraycopy(combined, 0, iv, 0, IV_LENGTH);
            byte[] ciphertext = new byte[combined.length - IV_LENGTH];
            System.arraycopy(combined, IV_LENGTH, ciphertext, 0, ciphertext.length);

            Cipher cipher = Cipher.getInstance(ALGO);
            cipher.init(Cipher.DECRYPT_MODE, keySpec(), new GCMParameterSpec(TAG_LENGTH_BITS, iv));
            return new String(cipher.doFinal(ciphertext), StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.error("Failed to decrypt an 'enc:' field — the encryption key may have "
                + "changed or been lost. Returning a placeholder instead of raw ciphertext.", e);
            return UNDECRYPTABLE_PLACEHOLDER;
        }
    }

    private SecretKeySpec keySpec() {
        return new SecretKeySpec(KEY_BYTES, "AES");
    }
}
