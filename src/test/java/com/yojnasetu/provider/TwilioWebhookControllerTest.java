package com.yojnasetu.provider;

import com.yojnasetu.model.WebhookEvent;
import com.yojnasetu.repository.WebhookEventRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {"app.env=local"})
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TwilioWebhookControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private WebhookEventRepository webhookEventRepository;

    @Test
    @DisplayName("Webhook should reject requests missing the 'From' parameter on /api/v1/webhooks/twilio/whatsapp")
    void shouldRejectMissingFrom() throws Exception {
        mockMvc.perform(post("/api/v1/webhooks/twilio/whatsapp")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("Body", "Hello"))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Missing 'From' parameter"));
    }

    @Test
    @DisplayName("Hardened webhook alias /webhook/whatsapp should also reject missing 'From' parameter")
    void shouldRejectMissingFromOnWebhookAlias() throws Exception {
        mockMvc.perform(post("/webhook/whatsapp")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("Body", "Hello"))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Missing 'From' parameter"));
    }

    @Test
    @DisplayName("Webhook should be idempotent and return 200 OK without re-processing for duplicate MessageSid")
    void shouldHandleDuplicateMessageSidIdempotently() throws Exception {
        String testSid = "SM_test_idempotent_12345";
        webhookEventRepository.save(new WebhookEvent("TWILIO", testSid, null, "COMPLETED"));

        mockMvc.perform(post("/api/v1/webhooks/twilio/whatsapp")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("From", "whatsapp:+919876543210")
                        .param("Body", "Namaste")
                        .param("MessageSid", testSid))
                .andExpect(status().isOk())
                .andExpect(content().string("<Response></Response>"));
    }

    @Test
    @DisplayName("Rate limiter should trigger HTTP 429 Too Many Requests after 20 rapid messages from the same sender")
    void shouldEnforceRateLimitExhaustion() throws Exception {
        String testPhone = "whatsapp:+919111222333";

        // Consume all 20 tokens
        for (int i = 0; i < 20; i++) {
            mockMvc.perform(post("/webhook/whatsapp")
                            .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                            .param("From", testPhone)
                            .param("Body", "Message " + i)
                            .param("MessageSid", "SM_burst_" + UUID.randomUUID()))
                    .andExpect(status().isOk());
        }

        // 21st request must trigger HTTP 429 Too Many Requests
        mockMvc.perform(post("/webhook/whatsapp")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("From", testPhone)
                        .param("Body", "Excess Message")
                        .param("MessageSid", "SM_burst_limit_reached"))
                .andExpect(status().isTooManyRequests())
                .andExpect(content().string("Rate limit exceeded"));
    }
}
