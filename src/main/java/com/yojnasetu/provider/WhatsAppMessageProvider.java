package com.yojnasetu.provider;

public interface WhatsAppMessageProvider {
    String getProviderName();
    boolean sendTextMessage(String recipientId, String text);
}
