package com.yojnasetu.conversation.model;

import java.util.Map;

public record InboundMessage(
        String senderId,          // E.164 phone number or Demo session ID
        String text,              // Cleaned message body
        String rawProviderId,     // MessageSid, wamid, or demo uuid
        String providerName,      // "TWILIO", "META", "DEMO"
        String mediaUrl,          // Optional media attachment URL
        String mediaContentType,  // Optional media MIME type
        Map<String, String> rawAttributes
) {
    public static InboundMessage ofText(String senderId, String text, String providerName) {
        return new InboundMessage(senderId, text != null ? text.trim() : "", null, providerName, null, null, Map.of());
    }

    public static InboundMessage ofDemo(String sessionId, String text) {
        return new InboundMessage(sessionId, text != null ? text.trim() : "", sessionId, "DEMO", null, null, Map.of());
    }
}
