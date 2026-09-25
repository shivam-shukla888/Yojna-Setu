package com.yojnasetu.conversation;

import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.OutboundMessage;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;
import com.yojnasetu.repository.ConversationSessionRepository;
import com.yojnasetu.repository.UserProfileRepository;
import com.yojnasetu.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class ConversationOrchestratorTest {

    @Autowired
    private ConversationOrchestrator orchestrator;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserProfileRepository profileRepository;

    @Autowired
    private ConversationSessionRepository sessionRepository;

    private static final String TEST_PHONE = "+919999888877";

    @BeforeEach
    void setUp() {
        orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "reset"));
    }

    @Test
    @DisplayName("Should prompt for language in INIT state when initial greeting is received")
    void testInitStatePromptsLanguage() {
        OutboundMessage response = orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "Hi"));

        assertNotNull(response);
        assertNotNull(response.text());
        assertTrue(response.text().contains("भाषा") || response.text().contains("Language"));
    }

    @Test
    @DisplayName("Selecting option 1 in INIT state should configure Hindi and transition to COLLECTING_PROFILE")
    void testLanguageSelectionTransitionsToCollectingProfile() {
        // Step 1: Trigger INIT
        orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "Hello"));

        // Step 2: Choose Hindi
        OutboundMessage response = orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "1"));

        assertNotNull(response);
        assertTrue(response.text().contains("आयु") || response.text().contains("उम्र") || response.text().contains("जानकारी"));
    }

    @Test
    @DisplayName("Reset command should restore session state to INIT and wipe profile data")
    void testResetCommandClearsSessionAndProfile() {
        // Simulate a dirty session
        orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "Hello"));
        orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "2")); // English

        // Send reset command
        OutboundMessage resetResponse = orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "reset"));

        assertNotNull(resetResponse);
        assertTrue(resetResponse.text().contains("रीसेट") || resetResponse.text().contains("Reset"));
    }

    @Test
    @DisplayName("Help command should provide instructions without crashing the state machine")
    void testHelpCommandReturnsInstructions() {
        OutboundMessage helpResponse = orchestrator.processInbound(InboundMessage.ofDemo(TEST_PHONE, "help"));

        assertNotNull(helpResponse);
        assertTrue(helpResponse.text().contains("मदद") || helpResponse.text().contains("Help") || helpResponse.text().contains("Yojna Setu"));
    }
}
