package com.yojnasetu.conversation.handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.yojnasetu.conversation.MessageFormatter;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;
import com.yojnasetu.repository.SchemeRepository;
import com.yojnasetu.repository.UserProfileRepository;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class ProfileReviewHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;
    private final UserProfileRepository userProfileRepository;
    private final SchemeRepository schemeRepository;
    private final ObjectMapper objectMapper;

    public ProfileReviewHandler(MessageFormatter formatter,
                                UserProfileRepository userProfileRepository,
                                SchemeRepository schemeRepository,
                                ObjectMapper objectMapper) {
        this.formatter = formatter;
        this.userProfileRepository = userProfileRepository;
        this.schemeRepository = schemeRepository;
        this.objectMapper = objectMapper;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.PROFILE_REVIEW;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String input = message.text().trim().toLowerCase();
        String lang = user != null ? user.getPreferredLanguage() : "hi";

        if (input.equals("1") || input.contains("yes") || input.contains("हाँ") || input.contains("ha") || input.contains("confirm")) {
            // 1. Confirm and complete profile
            profile.setProfileComplete(true);
            userProfileRepository.save(profile);

            // 2. Perform Scheme Matching
            List<Scheme> allActive = schemeRepository.findByIsActiveTrue();
            List<Scheme> matched = allActive.stream()
                    .filter(s -> s.isEligible(profile))
                    .collect(Collectors.toList());

            // 3. Cache eligible scheme UUIDs into session (JSONB)
            try {
                List<String> matchedIds = matched.stream().map(s -> s.getId().toString()).collect(Collectors.toList());
                session.setCachedEligibleSchemes(objectMapper.writeValueAsString(matchedIds));
                session.setPaginationOffset(0);
            } catch (Exception ignored) {}

            // 4. Return first page of 3 schemes
            int pageSize = 3;
            List<Scheme> firstPage = matched.stream().limit(pageSize).collect(Collectors.toList());
            String listMsg = formatter.formatSchemeList(firstPage, 0, pageSize, matched.size(), lang);

            return StateTransitionResult.of(SessionStateType.SCHEMES_LIST, listMsg);

        } else if (input.equals("2") || input.contains("no") || input.contains("नहीं") || input.contains("edit") || input.contains("nahi")) {
            // Reset profile fields for fresh collection
            profile.setAge(null);
            profile.setGender((com.yojnasetu.model.enums.GenderType) null);
            profile.setState(null);
            profile.setCaste((com.yojnasetu.model.enums.CasteType) null);
            profile.setAnnualIncome(null);
            profile.setOccupation(null);
            profile.setProfileComplete(false);
            userProfileRepository.save(profile);

            String askAge = formatter.formatAskAge(lang);
            return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, "ठीक है, आइए दोबारा शुरू करते हैं।\n\n" + askAge);
        }

        return StateTransitionResult.noChange(SessionStateType.PROFILE_REVIEW,
                "कृपया पुष्टि के लिए *1* (हाँ) या सुधार के लिए *2* (नहीं) भेजें।\n\n" + formatter.formatProfileReview(profile, lang));
    }
}
