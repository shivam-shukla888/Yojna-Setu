package com.yojnasetu.security.ssrf;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.net.InetAddress;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SafeMediaDownloadServiceTest {

    @Test
    @DisplayName("Should block download attempt for attacker domain and return empty")
    void shouldBlockAttackerDomain() {
        MediaUrlSecurityValidator validator = new MediaUrlSecurityValidator(host -> new InetAddress[]{InetAddress.getByName("198.51.100.1")});
        SafeMediaDownloadService service = new SafeMediaDownloadService(validator);

        Optional<byte[]> result = service.downloadAudioSafely("https://attacker-twilio.com/audio.ogg", "audio/ogg");
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("Should block download attempt with non-audio content type")
    void shouldBlockNonAudioContentType() {
        MediaUrlSecurityValidator validator = new MediaUrlSecurityValidator();
        SafeMediaDownloadService service = new SafeMediaDownloadService(validator);

        Optional<byte[]> result = service.downloadAudioSafely("https://api.twilio.com/payload.sh", "application/x-sh");
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("Should block download attempt resolving to cloud metadata IP")
    void shouldBlockCloudMetadataIp() {
        MediaUrlSecurityValidator validator = new MediaUrlSecurityValidator(host -> new InetAddress[]{InetAddress.getByName("169.254.169.254")});
        SafeMediaDownloadService service = new SafeMediaDownloadService(validator);

        Optional<byte[]> result = service.downloadAudioSafely("https://api.twilio.com/latest/meta-data/", "audio/ogg");
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("Should block download attempt resolving to loopback 127.0.0.1")
    void shouldBlockLoopbackIp() {
        MediaUrlSecurityValidator validator = new MediaUrlSecurityValidator(host -> new InetAddress[]{InetAddress.getByName("127.0.0.1")});
        SafeMediaDownloadService service = new SafeMediaDownloadService(validator);

        Optional<byte[]> result = service.downloadAudioSafely("https://api.twilio.com/internal-service", "audio/ogg");
        assertTrue(result.isEmpty());
    }
}
