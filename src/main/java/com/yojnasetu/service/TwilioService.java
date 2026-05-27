package com.yojnasetu.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class TwilioService {

    private static final Logger logger = LoggerFactory.getLogger(TwilioService.class);

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.whatsapp.from}")
    private String whatsappFrom;

    @PostConstruct
    public void init() {
        logger.info("Initializing Twilio with Account SID: {}", accountSid);
        Twilio.init(accountSid, authToken);
    }

    public void sendWhatsAppMessage(String toPhoneNumber, String message) {
        try {
            String to = toPhoneNumber;
            if (!to.startsWith("whatsapp:")) {
                to = "whatsapp:" + to;
            }
            logger.info("Sending WhatsApp message to: {}, from: {}", to, whatsappFrom);
            
            Message.creator(
                    new PhoneNumber(to),
                    new PhoneNumber(whatsappFrom),
                    message
            ).create();
            
            logger.info("WhatsApp message sent successfully to {}", toPhoneNumber);
        } catch (Exception e) {
            logger.error("Failed to send WhatsApp message to {}", toPhoneNumber, e);
            throw new RuntimeException("Twilio sending failed: " + e.getMessage(), e);
        }
    }
}
