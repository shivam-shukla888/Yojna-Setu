package com.yojnasetu.controller;

import com.yojnasetu.common.api.ApiResponse;
import com.yojnasetu.conversation.ConversationOrchestrator;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.OutboundMessage;
import com.yojnasetu.eligibility.EligibilityEngine;
import com.yojnasetu.eligibility.EligibilityResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.repository.ConversationSessionRepository;
import com.yojnasetu.repository.SchemeRepository;
import com.yojnasetu.repository.UserProfileRepository;
import com.yojnasetu.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;

@RestController
@RequestMapping("/api/v1/demo")
public class DemoChatController {

    private final ConversationOrchestrator orchestrator;
    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final ConversationSessionRepository sessionRepository;
    private final SchemeRepository schemeRepository;
    private final EligibilityEngine eligibilityEngine;

    @Value("${security.phone.hash-pepper:default-yojna-setu-pepper}")
    private String hashPepper;

    public DemoChatController(ConversationOrchestrator orchestrator,
                              UserRepository userRepository,
                              UserProfileRepository userProfileRepository,
                              ConversationSessionRepository sessionRepository,
                              SchemeRepository schemeRepository,
                              EligibilityEngine eligibilityEngine) {
        this.orchestrator = orchestrator;
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.sessionRepository = sessionRepository;
        this.schemeRepository = schemeRepository;
        this.eligibilityEngine = eligibilityEngine;
    }

    public record DemoChatRequest(String phone, String message) {}

    public record DemoProfileDto(
            Integer age,
            String gender,
            String caste,
            String state,
            java.math.BigDecimal annualIncome,
            String occupation,
            boolean differentlyAbled,
            boolean profileComplete
    ) {}

    public record DemoSchemeSummary(
            UUID id,
            String code,
            String name,
            String ministry,
            String category,
            String benefits
    ) {}

    public record DemoChatResponse(
            String replyText,
            String currentState,
            String preferredLanguage,
            DemoProfileDto profile,
            int eligibleSchemesCount,
            List<DemoSchemeSummary> eligibleSchemesPreview
    ) {}

    @PostMapping("/chat")
    public ResponseEntity<ApiResponse<DemoChatResponse>> chat(@RequestBody DemoChatRequest request) {
        String phone = (request.phone() != null && !request.phone().isBlank())
                ? request.phone().trim()
                : "+919876543210";
        String messageText = request.message() != null ? request.message().trim() : "";

        // Process message through conversational state machine
        InboundMessage inbound = InboundMessage.ofDemo(phone, messageText);
        OutboundMessage outbound = orchestrator.processInbound(inbound);

        // Fetch updated user & session context
        String phoneHash = computeSha256(phone + hashPepper);
        Optional<User> userOpt = userRepository.findByPhoneNumberHash(phoneHash);

        UserProfile profile = userOpt.flatMap(userProfileRepository::findByUser).orElse(null);
        ConversationSession session = userOpt.flatMap(sessionRepository::findByUser).orElse(null);

        String currentState = (session != null && session.getCurrentState() != null)
                ? session.getCurrentState().name()
                : "INIT";

        String language = userOpt.map(User::getPreferredLanguage).orElse("hi");

        DemoProfileDto profileDto = null;
        List<DemoSchemeSummary> eligiblePreviews = Collections.emptyList();
        int eligibleCount = 0;

        if (profile != null) {
            profileDto = new DemoProfileDto(
                    profile.getAge(),
                    profile.getGender(),
                    profile.getCaste(),
                    profile.getState(),
                    profile.getAnnualIncome(),
                    profile.getOccupation(),
                    profile.isDifferentlyAbled(),
                    profile.isProfileComplete()
            );

            // Deterministic eligibility evaluation
            List<EligibilityResult> results = eligibilityEngine.evaluateAll(profile);
            List<Scheme> eligibleSchemes = results.stream()
                    .filter(EligibilityResult::isEligible)
                    .map(EligibilityResult::scheme)
                    .toList();

            eligibleCount = eligibleSchemes.size();
            eligiblePreviews = eligibleSchemes.stream()
                    .limit(5)
                    .map(s -> new DemoSchemeSummary(
                            s.getId(),
                            s.getCode(),
                            s.getName(),
                            s.getMinistry(),
                            s.getCategory() != null ? s.getCategory().name() : "",
                            s.getBenefits()
                    ))
                    .toList();
        }

        DemoChatResponse response = new DemoChatResponse(
                outbound.text(),
                currentState,
                language,
                profileDto,
                eligibleCount,
                eligiblePreviews
        );

        return ResponseEntity.ok(ApiResponse.success("Demo interaction processed", response));
    }

    @PostMapping("/reset")
    public ResponseEntity<ApiResponse<String>> reset(@RequestBody(required = false) DemoChatRequest request) {
        String phone = (request != null && request.phone() != null && !request.phone().isBlank())
                ? request.phone().trim()
                : "+919876543210";

        InboundMessage resetMsg = InboundMessage.ofDemo(phone, "reset");
        orchestrator.processInbound(resetMsg);

        return ResponseEntity.ok(ApiResponse.success("Session reset successfully", "RESET_SUCCESS"));
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStats() {
        long totalSchemes = schemeRepository.count();
        long activeSchemes = schemeRepository.findByIsActiveTrue().size();

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalSchemes", totalSchemes);
        stats.put("activeSchemes", activeSchemes);
        stats.put("supportedLanguages", List.of("Hindi (hi)", "English (en)", "Hinglish (hi-en)"));
        stats.put("engine", "Deterministic Hybrid (Exact Rules + Groq Demographics Extractor)");

        return ResponseEntity.ok(ApiResponse.success("Demo stats retrieved", stats));
    }

    private String computeSha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}
