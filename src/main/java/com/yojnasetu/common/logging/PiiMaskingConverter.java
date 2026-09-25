package com.yojnasetu.common.logging;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.pattern.CompositeConverter;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Logback composite converter that redacts sensitive PII (phone numbers, tokens, API keys)
 * from wrapped log outputs. Aligned with DPDPA 2023 compliance (ADR-007).
 */
public class PiiMaskingConverter extends CompositeConverter<ILoggingEvent> {

    // E.164 and Indian phone number pattern (matches +919876543210, 919876543210, 9876543210)
    private static final Pattern PHONE_PATTERN = Pattern.compile("(\\+?91)?[6-9]\\d{9}");

    // Sensitive secret tokens, keys, passwords
    private static final Pattern SECRET_PATTERN = Pattern.compile(
            "(?i)(password|token|secret|apiKey|api_key|auth_token)\\s*[=:]\\s*['\"]?([^'\"\\s,;]+)['\"]?"
    );

    @Override
    protected String transform(ILoggingEvent event, String in) {
        if (in == null || in.isEmpty()) {
            return in;
        }

        // 1. Mask Phone Numbers: keep country code and last 4 digits
        Matcher phoneMatcher = PHONE_PATTERN.matcher(in);
        StringBuilder sb = new StringBuilder();
        while (phoneMatcher.find()) {
            String fullMatch = phoneMatcher.group();
            String masked;
            if (fullMatch.length() >= 10) {
                String last4 = fullMatch.substring(fullMatch.length() - 4);
                masked = "+91-XXXXXX" + last4;
            } else {
                masked = "[MASKED_PHONE]";
            }
            phoneMatcher.appendReplacement(sb, Matcher.quoteReplacement(masked));
        }
        phoneMatcher.appendTail(sb);
        String maskedText = sb.toString();

        // 2. Redact sensitive configuration values / credentials
        Matcher secretMatcher = SECRET_PATTERN.matcher(maskedText);
        sb = new StringBuilder();
        while (secretMatcher.find()) {
            String key = secretMatcher.group(1);
            secretMatcher.appendReplacement(sb, Matcher.quoteReplacement(key + "=[REDACTED]"));
        }
        secretMatcher.appendTail(sb);

        return sb.toString();
    }
}
