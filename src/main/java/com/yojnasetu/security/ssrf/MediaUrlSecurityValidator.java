package com.yojnasetu.security.ssrf;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.URI;
import java.net.UnknownHostException;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Enterprise SSRF and Media URL Security Validator.
 * Replaces flawed suffix matching with strict allowlisting, protocol enforcement,
 * IP range boundaries, and DNS resolution validation.
 */
@Component
public class MediaUrlSecurityValidator {

    private static final Logger log = LoggerFactory.getLogger(MediaUrlSecurityValidator.class);

    // Strict regex matching exact allowed Twilio domains and subdomains
    private static final Pattern APPROVED_HOST_PATTERN = Pattern.compile(
            "^(api\\.twilio\\.com|media\\.twiliocdn\\.com|mms\\.twiliocdn\\.com|[a-zA-Z0-9-]+\\.twilio\\.com|[a-zA-Z0-9-]+\\.twiliocdn\\.com)$",
            Pattern.CASE_INSENSITIVE
    );

    private static final String CLOUD_METADATA_IP = "169.254.169.254";

    private static final Set<String> ALLOWED_AUDIO_TYPES = Set.of(
            "audio/ogg", "audio/amr", "audio/wav", "audio/mpeg", "audio/mp4",
            "audio/x-m4a", "audio/webm", "audio/aac", "audio/3gpp"
    );

    // Functional interface for DNS resolution to allow deterministic mock testing
    @FunctionalInterface
    public interface DnsResolver {
        InetAddress[] resolve(String host) throws UnknownHostException;
    }

    private final DnsResolver dnsResolver;

    public MediaUrlSecurityValidator() {
        this(InetAddress::getAllByName);
    }

    public MediaUrlSecurityValidator(DnsResolver dnsResolver) {
        this.dnsResolver = dnsResolver;
    }

    /**
     * Validates that a media URL is strictly HTTPS, belongs to an approved Twilio domain,
     * and resolves only to public, non-private, non-loopback IP addresses.
     */
    public void validateUrl(String urlString) {
        if (urlString == null || urlString.isBlank()) {
            throw new SsrfValidationException("Media URL must not be empty");
        }

        URI uri;
        try {
            uri = URI.create(urlString.trim());
        } catch (Exception e) {
            throw new SsrfValidationException("Invalid URL syntax: " + e.getMessage());
        }

        // 1. Enforce HTTPS only
        String scheme = uri.getScheme();
        if (scheme == null || !scheme.equalsIgnoreCase("https")) {
            throw new SsrfValidationException("Insecure protocol: only HTTPS media URLs are permitted");
        }

        // 2. Enforce Hostname Allowlist (Defeats suffix tricks like attacker-twilio.com)
        String host = uri.getHost();
        if (host == null || host.isBlank()) {
            throw new SsrfValidationException("Missing or empty hostname in media URL");
        }

        host = host.toLowerCase().trim();

        if (!APPROVED_HOST_PATTERN.matcher(host).matches()) {
            log.warn("SSRF Blocked: Hostname [{}] is not in approved Twilio media allowlist", host);
            throw new SsrfValidationException("Hostname not allowed: " + host);
        }

        // Explicit rejection of localhost & raw IP representations in host string
        if (host.equals("localhost") || host.endsWith(".localhost") || host.equals("127.0.0.1") || host.equals("::1")) {
            throw new SsrfValidationException("SSRF Blocked: Loopback host rejected: " + host);
        }

        // 3. DNS Resolution & Revalidated IP Address Boundary Check
        try {
            InetAddress[] resolvedIps = dnsResolver.resolve(host);
            if (resolvedIps == null || resolvedIps.length == 0) {
                throw new SsrfValidationException("DNS resolution returned no IP addresses for host: " + host);
            }

            for (InetAddress ip : resolvedIps) {
                validateIpAddress(ip, host);
            }
        } catch (UnknownHostException e) {
            throw new SsrfValidationException("DNS resolution failed for host: " + host);
        }
    }

    /**
     * Revalidates an IP address against loopback, private, link-local, multicast,
     * and cloud metadata ranges.
     */
    public void validateIpAddress(InetAddress ip, String host) {
        if (ip == null) {
            throw new SsrfValidationException("Null IP address resolved for host: " + host);
        }

        String ipStr = ip.getHostAddress();

        // Loopback (127.0.0.0/8, ::1)
        if (ip.isLoopbackAddress() || ipStr.equals("127.0.0.1") || ipStr.equals("::1") || ipStr.equals("0:0:0:0:0:0:0:1")) {
            log.warn("SSRF Blocked: Loopback address resolved: {} for host: {}", ipStr, host);
            throw new SsrfValidationException("Loopback address rejected: " + ipStr);
        }

        // Private / Site-Local (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, fec0::/10)
        if (ip.isSiteLocalAddress()) {
            log.warn("SSRF Blocked: Private/Site-local address resolved: {} for host: {}", ipStr, host);
            throw new SsrfValidationException("Private site-local address rejected: " + ipStr);
        }

        // Link-Local (169.254.0.0/16, fe80::/10)
        if (ip.isLinkLocalAddress()) {
            log.warn("SSRF Blocked: Link-local address resolved: {} for host: {}", ipStr, host);
            throw new SsrfValidationException("Link-local address rejected: " + ipStr);
        }

        // Cloud Metadata Service (169.254.169.254)
        if (CLOUD_METADATA_IP.equals(ipStr)) {
            log.warn("SSRF Blocked: Cloud metadata address resolved: {} for host: {}", ipStr, host);
            throw new SsrfValidationException("Cloud metadata address rejected: " + ipStr);
        }

        // AnyLocal / Multicast
        if (ip.isAnyLocalAddress() || ip.isMulticastAddress()) {
            throw new SsrfValidationException("Wildcard or multicast address rejected: " + ipStr);
        }

        // IPv6 Unique Local Address (fc00::/7)
        if (ip instanceof Inet6Address) {
            byte[] bytes = ip.getAddress();
            if ((bytes[0] & 0xfe) == 0xfc) {
                log.warn("SSRF Blocked: IPv6 unique local address resolved: {} for host: {}", ipStr, host);
                throw new SsrfValidationException("IPv6 unique local address rejected: " + ipStr);
            }
        }
    }

    /**
     * Validates that the media Content-Type represents a recognized audio format.
     */
    public void validateContentType(String contentType) {
        if (contentType == null || contentType.isBlank()) {
            throw new SsrfValidationException("Missing Media Content-Type header");
        }

        String normalized = contentType.split(";")[0].trim().toLowerCase();
        if (!ALLOWED_AUDIO_TYPES.contains(normalized) && !normalized.startsWith("audio/")) {
            log.warn("SSRF/Media Blocked: Disallowed media Content-Type: {}", contentType);
            throw new SsrfValidationException("Disallowed media Content-Type: " + contentType);
        }
    }
}
