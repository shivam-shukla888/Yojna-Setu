package com.yojnasetu.security.ssrf;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.net.InetAddress;
import java.net.UnknownHostException;

import static org.junit.jupiter.api.Assertions.*;

class MediaUrlSecurityValidatorTest {

    // Helper returning deterministic mock DNS resolver
    private MediaUrlSecurityValidator createValidatorWithIp(String mockIp) {
        return new MediaUrlSecurityValidator(host -> new InetAddress[]{InetAddress.getByName(mockIp)});
    }

    @Test
    @DisplayName("Should allow valid approved Twilio media hosts with public IP over HTTPS")
    void shouldAllowValidTwilioHost() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("34.200.10.5"); // Public AWS IP

        assertDoesNotThrow(() -> validator.validateUrl("https://api.twilio.com/2010-04-01/Accounts/AC123/Messages/MM123/Media/ME123"));
        assertDoesNotThrow(() -> validator.validateUrl("https://media.twiliocdn.com/AC123/audio.ogg"));
        assertDoesNotThrow(() -> validator.validateUrl("https://mms.twiliocdn.com/AC123/audio.amr"));
    }

    @Test
    @DisplayName("Should reject HTTP protocol even for approved Twilio hosts")
    void shouldRejectHttpProtocol() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("34.200.10.5");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("http://api.twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("only HTTPS media URLs are permitted"));
    }

    @Test
    @DisplayName("Should reject attacker suffix trick domains (attacker-twilio.com)")
    void shouldRejectAttackerSuffixDomain() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("198.51.100.1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://attacker-twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("Hostname not allowed"));
    }

    @Test
    @DisplayName("Should reject subdomain trick domains (twilio.com.attacker.com)")
    void shouldRejectSubdomainAttackerDomain() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("198.51.100.1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://twilio.com.attacker.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("Hostname not allowed"));
    }

    @Test
    @DisplayName("Should reject arbitrary attacker domains (attacker.com)")
    void shouldRejectArbitraryAttackerDomain() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("198.51.100.1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://attacker.com/malicious.ogg"));
        assertTrue(ex.getMessage().contains("Hostname not allowed"));
    }

    @Test
    @DisplayName("Should reject localhost hostname")
    void shouldRejectLocalhost() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("127.0.0.1");

        assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://localhost/audio.ogg"));
    }

    @Test
    @DisplayName("Should reject loopback IP (127.0.0.1)")
    void shouldRejectLoopbackIpv4() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("127.0.0.1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://api.twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("Loopback address rejected"));
    }

    @Test
    @DisplayName("Should reject loopback IPv6 (::1)")
    void shouldRejectLoopbackIpv6() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("::1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://api.twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("Loopback address rejected"));
    }

    @Test
    @DisplayName("Should reject private IPv4 ranges (10.0.0.1, 192.168.1.1, 172.16.0.1)")
    void shouldRejectPrivateIpv4Ranges() {
        for (String privateIp : new String[]{"10.0.0.1", "192.168.1.50", "172.16.5.10"}) {
            MediaUrlSecurityValidator validator = createValidatorWithIp(privateIp);
            SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                    validator.validateUrl("https://api.twilio.com/audio.ogg"));
            assertTrue(ex.getMessage().contains("Private site-local address rejected"));
        }
    }

    @Test
    @DisplayName("Should reject IPv6 unique local address (fc00::1)")
    void shouldRejectIpv6UniqueLocal() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("fc00::1");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://api.twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("IPv6 unique local address rejected"));
    }

    @Test
    @DisplayName("Should reject cloud metadata IP (169.254.169.254)")
    void shouldRejectCloudMetadataIp() {
        MediaUrlSecurityValidator validator = createValidatorWithIp("169.254.169.254");

        SsrfValidationException ex = assertThrows(SsrfValidationException.class, () ->
                validator.validateUrl("https://api.twilio.com/audio.ogg"));
        assertTrue(ex.getMessage().contains("Link-local") || ex.getMessage().contains("Cloud metadata"));
    }

    @Test
    @DisplayName("Should validate Content-Type allowlist")
    void shouldValidateAudioContentType() {
        MediaUrlSecurityValidator validator = new MediaUrlSecurityValidator();

        assertDoesNotThrow(() -> validator.validateContentType("audio/ogg"));
        assertDoesNotThrow(() -> validator.validateContentType("audio/amr"));
        assertDoesNotThrow(() -> validator.validateContentType("audio/wav; codecs=opus"));

        assertThrows(SsrfValidationException.class, () -> validator.validateContentType("text/html"));
        assertThrows(SsrfValidationException.class, () -> validator.validateContentType("application/json"));
        assertThrows(SsrfValidationException.class, () -> validator.validateContentType("application/x-sh"));
    }
}
