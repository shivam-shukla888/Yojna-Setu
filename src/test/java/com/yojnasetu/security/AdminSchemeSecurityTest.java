package com.yojnasetu.security;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AdminSchemeSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    private static final String VALID_API_KEY = "test-secret-key-32-chars-long-12345";
    private static final String INVALID_API_KEY = "wrong-unauthorized-key";

    @Test
    @DisplayName("Admin endpoint should return 401 when X-API-KEY header is missing")
    void shouldRejectRequestWithoutApiKey() throws Exception {
        mockMvc.perform(get("/api/v1/admin/schemes"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("Missing or invalid API key"));
    }

    @Test
    @DisplayName("Admin endpoint should return 401 when X-API-KEY header is incorrect")
    void shouldRejectRequestWithInvalidApiKey() throws Exception {
        mockMvc.perform(get("/api/v1/admin/schemes")
                        .header("X-API-KEY", INVALID_API_KEY))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    @DisplayName("Admin endpoint should return 200 when valid X-API-KEY is provided")
    void shouldAllowRequestWithValidApiKey() throws Exception {
        mockMvc.perform(get("/api/v1/admin/schemes")
                        .header("X-API-KEY", VALID_API_KEY))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    @DisplayName("Audit logs endpoint should return 200 when valid X-API-KEY is provided")
    void shouldAllowAuditLogsWithValidApiKey() throws Exception {
        mockMvc.perform(get("/api/v1/admin/audit-logs")
                        .header("X-API-KEY", VALID_API_KEY))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
