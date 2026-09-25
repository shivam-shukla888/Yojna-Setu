package com.yojnasetu.security;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class LegacyRouteEliminationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("Public eligibility IDOR endpoint /api/eligibility/{phone} must NOT be accessible")
    void shouldRejectPublicEligibilityLookup() throws Exception {
        // Must NOT return 200 OK. Either 404 (removed) or 401/403 (blocked)
        mockMvc.perform(get("/api/eligibility/+919876543210"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Legacy unauthenticated conversation endpoint /api/conversation must NOT be accessible")
    void shouldRejectLegacyConversationEndpoint() throws Exception {
        mockMvc.perform(post("/api/conversation")
                        .contentType("application/json")
                        .content("{\"phoneNumber\":\"+919876543210\",\"message\":\"Hi\"}"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Legacy profile lookup /api/profile/{phone} must NOT be accessible")
    void shouldRejectLegacyProfileLookup() throws Exception {
        mockMvc.perform(get("/api/profile/+919876543210"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    @DisplayName("Legacy user registration /api/users/register must NOT be accessible without authentication")
    void shouldRejectLegacyUserRegistration() throws Exception {
        mockMvc.perform(post("/api/users/register")
                        .contentType("application/json")
                        .content("{\"phoneNumber\":\"+919876543210\",\"name\":\"Test\"}"))
                .andExpect(status().is4xxClientError());
    }
}
