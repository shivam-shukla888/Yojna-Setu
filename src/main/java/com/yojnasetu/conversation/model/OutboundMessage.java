package com.yojnasetu.conversation.model;

public record OutboundMessage(
        String recipientId,
        String text,
        String mediaUrl
) {
    public static OutboundMessage ofText(String recipientId, String text) {
        return new OutboundMessage(recipientId, text, null);
    }
}
