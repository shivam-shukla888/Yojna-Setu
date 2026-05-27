package com.yojnasetu.controller;

import com.yojnasetu.service.ConversationService;
import com.yojnasetu.service.TwilioService;
import com.yojnasetu.service.GroqService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class WhatsAppWebhookController {

    private static final Logger logger = LoggerFactory.getLogger(WhatsAppWebhookController.class);

    private final ConversationService conversationService;
    private final TwilioService twilioService;
    private final GroqService groqService;

    @Autowired
    public WhatsAppWebhookController(ConversationService conversationService,
                                     TwilioService twilioService,
                                     GroqService groqService) {
        this.conversationService = conversationService;
        this.twilioService = twilioService;
        this.groqService = groqService;
    }

    @PostMapping("/webhook/whatsapp")
    public ResponseEntity<Void> receiveWhatsApp(@RequestParam("From") String from,
                                                @RequestParam(value = "Body", required = false) String body,
                                                @RequestParam(value = "MediaUrl0", required = false) String mediaUrl,
                                                @RequestParam(value = "MediaContentType0", required = false) String mediaContentType) {
        logger.info("Received WhatsApp webhook from: {}, body: {}, mediaUrl: {}, contentType: {}", from, body, mediaUrl, mediaContentType);

        // Extract phone number from From by removing the "whatsapp:" prefix
        String phoneNumber = from;
        if (from != null && from.startsWith("whatsapp:")) {
            phoneNumber = from.substring("whatsapp:".length());
        }

        String finalMessage = body;
        if (mediaUrl != null && mediaContentType != null && mediaContentType.toLowerCase().contains("audio")) {
            String transcribed = groqService.transcribeAudio(mediaUrl);
            if (transcribed == null) {
                logger.warn("Audio transcription failed for phone: {}", phoneNumber);
                twilioService.sendWhatsAppMessage(phoneNumber, "Sorry, voice message samajh nahi aaya. Please text mein likhein.");
                return ResponseEntity.ok().build();
            }
            finalMessage = transcribed;
            logger.info("Successfully transcribed voice message for {}: {}", phoneNumber, finalMessage);
        }

        // Process message through eligibility/conversation engine
        String reply = conversationService.processMessage(phoneNumber, finalMessage);

        // Send reply back to the user via Twilio WhatsApp API
        twilioService.sendWhatsAppMessage(phoneNumber, reply);

        return ResponseEntity.ok().build();
    }
}
