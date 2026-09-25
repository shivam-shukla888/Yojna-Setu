package com.yojnasetu.provider;

import com.twilio.security.RequestValidator;
import com.yojnasetu.ai.AiGateway;
import com.yojnasetu.conversation.ConversationOrchestrator;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.OutboundMessage;
import com.yojnasetu.model.WebhookEvent;
import com.yojnasetu.repository.WebhookEventRepository;
import com.yojnasetu.security.ssrf.SafeMediaDownloadService;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@RestController
public class TwilioWebhookController {

    private static final Logger logger = LoggerFactory.getLogger(TwilioWebhookController.class);

    private final ConversationOrchestrator orchestrator;
    private final TwilioWhatsAppProvider twilioProvider;
    private final WebhookEventRepository webhookEventRepository;
    private final AiGateway aiGateway;
    private final SafeMediaDownloadService safeMediaDownloadService;

    @Value("${twilio.auth.token:}")
    private String authToken;

    @Value("${app.env:local}")
    private String appEnv;

    // Rate Limiter: 20 messages per minute per phone number
    private final Map<String, Bucket> rateLimitBuckets = new ConcurrentHashMap<>();

    public TwilioWebhookController(ConversationOrchestrator orchestrator,
                                   TwilioWhatsAppProvider twilioProvider,
                                   WebhookEventRepository webhookEventRepository,
                                   AiGateway aiGateway,
                                   SafeMediaDownloadService safeMediaDownloadService) {
        this.orchestrator = orchestrator;
        this.twilioProvider = twilioProvider;
        this.webhookEventRepository = webhookEventRepository;
        this.aiGateway = aiGateway;
        this.safeMediaDownloadService = safeMediaDownloadService;
    }

    @PostMapping(value = {"/api/v1/webhooks/twilio/whatsapp", "/webhook/whatsapp"})
    public ResponseEntity<String> handleIncomingWebhook(
            @RequestParam Map<String, String> payload,
            HttpServletRequest request) {

        String messageSid = payload.get("MessageSid");
        String from = payload.get("From");
        String body = payload.get("Body");
        String mediaUrl = payload.get("MediaUrl0");
        String mediaContentType = payload.get("MediaContentType0");

        if (from == null || from.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Missing 'From' parameter");
        }

        String rawPhone = from.replace("whatsapp:", "").trim();

        // 1. Cryptographic Signature Verification (Enforced in non-local environments)
        if (!"local".equalsIgnoreCase(appEnv) && authToken != null && !authToken.trim().isEmpty()) {
            String twilioSignature = request.getHeader("X-Twilio-Signature");
            if (twilioSignature == null) {
                logger.warn("Webhook rejected: missing X-Twilio-Signature header");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Missing Signature");
            }

            RequestValidator validator = new RequestValidator(authToken);
            String fullUrl = request.getRequestURL().toString();
            if (!validator.validate(fullUrl, payload, twilioSignature)) {
                logger.warn("Webhook rejected: invalid X-Twilio-Signature for URL: {}", fullUrl);
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Invalid Signature");
            }
        }

        // 2. Rate Limiting Protection (Bucket4j)
        Bucket bucket = rateLimitBuckets.computeIfAbsent(rawPhone, k ->
                Bucket.builder()
                        .addLimit(Bandwidth.classic(20, Refill.intervally(20, Duration.ofMinutes(1))))
                        .build()
        );

        if (!bucket.tryConsume(1)) {
            logger.warn("Rate limit exceeded for sender");
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body("Rate limit exceeded");
        }

        // 3. Durable Idempotency Check (Eliminates Duplicate Retries)
        if (messageSid != null) {
            if (webhookEventRepository.existsByProviderMessageId(messageSid)) {
                logger.info("Duplicate webhook delivery detected for MessageSid: {}. Acknowledging with 200 OK without re-processing.", messageSid);
                return ResponseEntity.ok("<Response></Response>");
            }
            try {
                WebhookEvent event = new WebhookEvent("TWILIO", messageSid, null, "PROCESSING");
                webhookEventRepository.save(event);
            } catch (Exception e) {
                logger.warn("Idempotency lock already acquired for MessageSid: {}", messageSid);
                return ResponseEntity.ok("<Response></Response>");
            }
        }

        // 4. Voice / Media Handling with Hardened SSRF Protection
        String messageText = body != null ? body : "";
        if (mediaUrl != null && !mediaUrl.trim().isEmpty()) {
            messageText = processVoiceMedia(mediaUrl, mediaContentType, messageText);
        }

        // 5. Hand off to Conversation State Orchestrator
        InboundMessage inbound = new InboundMessage(
                rawPhone,
                messageText,
                messageSid,
                "TWILIO",
                mediaUrl,
                mediaContentType,
                payload
        );

        OutboundMessage outbound = orchestrator.processInbound(inbound);

        // 6. Dispatch Outbound Message
        if (outbound != null && outbound.text() != null && !outbound.text().isEmpty()) {
            twilioProvider.sendTextMessage(outbound.recipientId(), outbound.text());
        }

        return ResponseEntity.ok("<Response></Response>");
    }

    private String processVoiceMedia(String mediaUrl, String contentType, String fallbackText) {
        try {
            Optional<byte[]> mediaBytesOpt = safeMediaDownloadService.downloadAudioSafely(mediaUrl, contentType);
            if (mediaBytesOpt.isPresent() && mediaBytesOpt.get().length > 0) {
                var transcriptionOpt = aiGateway.transcribeAudio(mediaBytesOpt.get(), "audio.ogg", contentType);
                if (transcriptionOpt.isPresent()) {
                    return transcriptionOpt.get();
                }
            }
        } catch (Exception e) {
            logger.warn("Voice media processing error: {}", e.getMessage());
        }
        return fallbackText;
    }
}
