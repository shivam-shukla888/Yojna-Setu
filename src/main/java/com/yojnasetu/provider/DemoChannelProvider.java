package com.yojnasetu.provider;

import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class DemoChannelProvider implements WhatsAppMessageProvider {

    private final Map<String, String> lastResponses = new ConcurrentHashMap<>();

    @Override
    public String getProviderName() {
        return "DEMO";
    }

    @Override
    public boolean sendTextMessage(String recipientId, String text) {
        lastResponses.put(recipientId, text);
        return true;
    }

    public String getLastResponse(String recipientId) {
        return lastResponses.getOrDefault(recipientId, "");
    }

    public void clear(String recipientId) {
        lastResponses.remove(recipientId);
    }
}
