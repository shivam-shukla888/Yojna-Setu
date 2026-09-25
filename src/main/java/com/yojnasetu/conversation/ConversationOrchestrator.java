package com.yojnasetu.conversation;

import com.yojnasetu.conversation.handler.ConversationStateHandler;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.OutboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;
import com.yojnasetu.repository.ConversationSessionRepository;
import com.yojnasetu.repository.UserProfileRepository;
import com.yojnasetu.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class ConversationOrchestrator {

    private static final Logger logger = LoggerFactory.getLogger(ConversationOrchestrator.class);

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final ConversationSessionRepository sessionRepository;
    private final MessageFormatter formatter;
    private final Map<SessionStateType, ConversationStateHandler> handlerMap = new EnumMap<>(SessionStateType.class);

    @Value("${security.phone.hash-pepper:default-yojna-setu-pepper}")
    private String hashPepper;

    public ConversationOrchestrator(UserRepository userRepository,
                                    UserProfileRepository userProfileRepository,
                                    ConversationSessionRepository sessionRepository,
                                    MessageFormatter formatter,
                                    List<ConversationStateHandler> handlers) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.sessionRepository = sessionRepository;
        this.formatter = formatter;
        for (ConversationStateHandler handler : handlers) {
            handlerMap.put(handler.getSupportedState(), handler);
        }
    }

    @Transactional
    public OutboundMessage processInbound(InboundMessage message) {
        String senderId = message.senderId();
        String text = message.text() != null ? message.text().trim() : "";

        // 1. Blind Hash for Data Minimization (DPDPA 2023)
        String phoneHash = computeSha256(senderId + hashPepper);

        // 2. Find or Create User
        User user = userRepository.findByPhoneNumberHash(phoneHash)
                .orElseGet(() -> {
                    User newUser = new User(senderId, phoneHash, "hi");
                    return userRepository.save(newUser);
                });

        // 3. Find or Create UserProfile
        UserProfile profile = userProfileRepository.findByUser(user)
                .orElseGet(() -> {
                    UserProfile newProfile = new UserProfile(user);
                    return userProfileRepository.save(newProfile);
                });

        // 4. Find or Create ConversationSession
        ConversationSession session = sessionRepository.findByUser(user)
                .orElseGet(() -> {
                    ConversationSession newSession = new ConversationSession(user);
                    return sessionRepository.save(newSession);
                });

        session.setLastInteractionAt(LocalDateTime.now());

        // 5. Global Command Interceptors
        String lowerText = text.toLowerCase();
        if (lowerText.equals("reset") || lowerText.equals("restart") || lowerText.contains("शुरू")) {
            // Reset profile & session safely
            session.setCurrentState(SessionStateType.INIT);
            session.setPaginationOffset(0);
            session.setCachedEligibleSchemes(null);
            sessionRepository.save(session);

            profile.setProfileComplete(false);
            profile.setAge(null);
            profile.setGender((com.yojnasetu.model.enums.GenderType) null);
            profile.setState(null);
            profile.setCaste((com.yojnasetu.model.enums.CasteType) null);
            profile.setAnnualIncome(null);
            profile.setOccupation(null);
            userProfileRepository.save(profile);

            String welcome = formatter.formatWelcome(user.getPreferredLanguage());
            return OutboundMessage.ofText(senderId, "🔄 *सत्र रीसेट कर दिया गया है (Session Reset).*\n\n" + welcome);
        }

        if (lowerText.equals("help") || lowerText.equals("मदद") || lowerText.equals("menu")) {
            return OutboundMessage.ofText(senderId, formatter.formatHelp(user.getPreferredLanguage()));
        }

        // 6. Route to active state handler
        SessionStateType currentState = session.getCurrentState();
        ConversationStateHandler handler = handlerMap.get(currentState);

        StateTransitionResult result;
        if (handler != null) {
            result = handler.handle(message, user, profile, session);
        } else {
            logger.warn("No handler found for state: {}. Falling back to INIT", currentState);
            handler = handlerMap.get(SessionStateType.INIT);
            result = handler.handle(message, user, profile, session);
        }

        // 7. Persist State Changes
        if (result.nextState() != null && result.nextState() != currentState) {
            session.setCurrentState(result.nextState());
        }
        sessionRepository.save(session);

        return OutboundMessage.ofText(senderId, result.replyText());
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
