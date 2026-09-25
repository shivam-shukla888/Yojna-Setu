package com.yojnasetu.provider;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class TwilioWhatsAppProvider implements WhatsAppMessageProvider {

    private static final Logger logger = LoggerFactory.getLogger(TwilioWhatsAppProvider.class);

    @Value("${twilio.account.sid:}")
    private String accountSid;

    @Value("${twilio.auth.token:}")
    private String authToken;

    @Value("${twilio.whatsapp.from:whatsapp:+14155238886}")
    private String fromNumber;

    private boolean isInitialized = false;

    @PostConstruct
    public void init() {
        if (accountSid != null && !accountSid.trim().isEmpty() &&
                authToken != null && !authToken.trim().isEmpty() &&
                !accountSid.startsWith("YOUR_")) {
            try {
                Twilio.init(accountSid, authToken);
                isInitialized = true;
                logger.info("Twilio SDK initialized successfully.");
            } catch (Exception e) {
                logger.warn("Twilio initialization deferred: {}", e.getMessage());
            }
        } else {
            logger.info("Twilio credentials not configured; running in mock/demo channel mode.");
        }
    }

    @Override
    public String getProviderName() {
        return "TWILIO";
    }

    @Override
    public boolean sendTextMessage(String recipientId, String text) {
        if (!isInitialized) {
            logger.info("[MOCK DISPATCH] Outgoing WhatsApp to {}: {}", recipientId, text);
            return true;
        }

        try {
            String to = recipientId.startsWith("whatsapp:") ? recipientId : "whatsapp:" + recipientId;
            Message message = Message.creator(
                    new PhoneNumber(to),
                    new PhoneNumber(fromNumber),
                    text
            ).create();

            logger.info("WhatsApp message dispatched successfully. SID: {}", message.getSid());
            return true;
        } catch (Exception e) {
            logger.error("Failed to dispatch WhatsApp message via Twilio: {}", e.getMessage());
            return false;
        }
    }
}
