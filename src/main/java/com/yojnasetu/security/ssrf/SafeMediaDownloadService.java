package com.yojnasetu.security.ssrf;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Optional;

/**
 * Hardened Media Download Service with comprehensive SSRF protection,
 * redirect re-validation, response size bounds, and timeout enforcement.
 */
@Service
public class SafeMediaDownloadService {

    private static final Logger log = LoggerFactory.getLogger(SafeMediaDownloadService.class);

    public static final int MAX_MEDIA_BYTES = 5 * 1024 * 1024; // 5 MB Max
    public static final int CONNECT_TIMEOUT_MS = 3000;          // 3 seconds
    public static final int READ_TIMEOUT_MS = 5000;             // 5 seconds
    public static final int MAX_REDIRECT_DEPTH = 2;

    private final MediaUrlSecurityValidator validator;

    @Value("${twilio.account.sid:}")
    private String twilioAccountSid;

    @Value("${twilio.auth.token:}")
    private String twilioAuthToken;

    public SafeMediaDownloadService(MediaUrlSecurityValidator validator) {
        this.validator = validator;
    }

    /**
     * Safely downloads media bytes from an external Twilio URL.
     * Re-validates redirects, strictly limits byte size, and enforces timeouts.
     */
    public Optional<byte[]> downloadAudioSafely(String initialUrl, String expectedContentType) {
        try {
            validator.validateContentType(expectedContentType);
            byte[] bytes = downloadWithRedirectValidation(initialUrl, 0);
            return Optional.ofNullable(bytes);
        } catch (Exception e) {
            log.warn("Safe media download blocked or failed: {}", e.getMessage());
            return Optional.empty();
        }
    }

    private byte[] downloadWithRedirectValidation(String targetUrl, int redirectDepth) throws Exception {
        if (redirectDepth > MAX_REDIRECT_DEPTH) {
            throw new SsrfValidationException("Too many redirects: exceeded max depth of " + MAX_REDIRECT_DEPTH);
        }

        // Validate current target URL before initiating connection
        validator.validateUrl(targetUrl);

        URL url = URI.create(targetUrl).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setInstanceFollowRedirects(false); // Manual redirect handling for re-validation
        conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
        conn.setReadTimeout(READ_TIMEOUT_MS);
        conn.setRequestMethod("GET");
        conn.setRequestProperty("User-Agent", "YojnaSetu-MediaFetcher/2.0");

        // Send Twilio basic auth ONLY to validated Twilio hosts
        if (twilioAccountSid != null && !twilioAccountSid.isBlank() &&
                twilioAuthToken != null && !twilioAuthToken.isBlank()) {
            String credentials = twilioAccountSid.trim() + ":" + twilioAuthToken.trim();
            String authHeader = "Basic " + Base64.getEncoder().encodeToString(credentials.getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", authHeader);
        }

        int responseCode = conn.getResponseCode();

        // Handle Redirects (301, 302, 303, 307, 308)
        if (responseCode == HttpURLConnection.HTTP_MOVED_PERM ||
                responseCode == HttpURLConnection.HTTP_MOVED_TEMP ||
                responseCode == HttpURLConnection.HTTP_SEE_OTHER ||
                responseCode == 307 || responseCode == 308) {

            String redirectLocation = conn.getHeaderField("Location");
            conn.disconnect();

            if (redirectLocation == null || redirectLocation.isBlank()) {
                throw new SsrfValidationException("Redirect response missing Location header");
            }

            // Resolve relative redirects against original URL
            URI redirectUri = URI.create(targetUrl).resolve(redirectLocation);
            String safeRedirectUrl = redirectUri.toString();

            log.info("SafeMediaDownloader following validated redirect to: {}", redirectUri.getHost());
            return downloadWithRedirectValidation(safeRedirectUrl, redirectDepth + 1);
        }

        if (responseCode != HttpURLConnection.HTTP_OK) {
            conn.disconnect();
            throw new SsrfValidationException("HTTP request failed with status code: " + responseCode);
        }

        // Content-Type Verification from response header
        String responseContentType = conn.getContentType();
        if (responseContentType != null) {
            validator.validateContentType(responseContentType);
        }

        // Size-bounded Streaming Read
        long declaredLength = conn.getContentLengthLong();
        if (declaredLength > MAX_MEDIA_BYTES) {
            conn.disconnect();
            throw new SsrfValidationException("Content-Length " + declaredLength + " exceeds maximum limit of " + MAX_MEDIA_BYTES + " bytes");
        }

        try (InputStream in = conn.getInputStream();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            byte[] buffer = new byte[8192];
            int totalBytes = 0;
            int bytesRead;

            while ((bytesRead = in.read(buffer)) != -1) {
                totalBytes += bytesRead;
                if (totalBytes > MAX_MEDIA_BYTES) {
                    throw new SsrfValidationException("Streamed response exceeded maximum limit of " + MAX_MEDIA_BYTES + " bytes");
                }
                out.write(buffer, 0, bytesRead);
            }

            return out.toByteArray();
        } finally {
            conn.disconnect();
        }
    }
}
