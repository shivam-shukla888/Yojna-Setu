package com.yojnasetu.conversation.handler;

import com.fasterxml.jackson.core.type.TypeReference;
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
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.stream.Collectors;

@Component
public class SchemesListHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;
    private final SchemeRepository schemeRepository;
    private final ObjectMapper objectMapper;

    public SchemesListHandler(MessageFormatter formatter, SchemeRepository schemeRepository, ObjectMapper objectMapper) {
        this.formatter = formatter;
        this.schemeRepository = schemeRepository;
        this.objectMapper = objectMapper;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.SCHEMES_LIST;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String input = message.text().trim().toLowerCase();
        String lang = user != null ? user.getPreferredLanguage() : "hi";

        List<UUID> schemeIds = getCachedSchemeIds(session);
        if (schemeIds.isEmpty()) {
            return StateTransitionResult.of(SessionStateType.INIT,
                    "कोई योजना सूची नहीं मिली। नई खोज के लिए 'hi' भेजें।");
        }

        // 1. Pagination Request ("more" / "aur" / "next")
        if (input.equals("more") || input.contains("aur") || input.contains("next") || input.contains("अगला")) {
            int currentOffset = session.getPaginationOffset() + 3;
            if (currentOffset >= schemeIds.size()) {
                currentOffset = 0; // wrap around to beginning
            }
            session.setPaginationOffset(currentOffset);

            List<UUID> pageIds = schemeIds.stream().skip(currentOffset).limit(3).collect(Collectors.toList());
            List<Scheme> pageSchemes = schemeRepository.findAllById(pageIds);
            String listMsg = formatter.formatSchemeList(pageSchemes, currentOffset / 3, 3, schemeIds.size(), lang);
            return StateTransitionResult.of(SessionStateType.SCHEMES_LIST, listMsg);
        }

        // 2. Select Scheme by Number (e.g. "1", "2", "3")
        try {
            int selectedNum = Integer.parseInt(input);
            if (selectedNum >= 1 && selectedNum <= schemeIds.size()) {
                UUID selectedId = schemeIds.get(selectedNum - 1);
                Optional<Scheme> schemeOpt = schemeRepository.findById(selectedId);
                if (schemeOpt.isPresent()) {
                    session.setLastPromptSent(selectedId.toString());
                    String detailMsg = formatter.formatSchemeDetail(schemeOpt.get(), lang);
                    return StateTransitionResult.of(SessionStateType.SCHEME_DETAILS, detailMsg);
                }
            }
        } catch (NumberFormatException ignored) {}

        // 3. Select Scheme by Name / Code lookup
        Optional<Scheme> byCode = schemeRepository.findByCode(input.toUpperCase());
        if (byCode.isPresent()) {
            session.setLastPromptSent(byCode.get().getId().toString());
            return StateTransitionResult.of(SessionStateType.SCHEME_DETAILS, formatter.formatSchemeDetail(byCode.get(), lang));
        }

        // Fallback / Unknown instruction
        return StateTransitionResult.noChange(SessionStateType.SCHEMES_LIST,
                "👉 अगली योजनाओं के लिए *more* भेजें, या पूरी जानकारी के लिए योजना का नंबर (उदा. *1*) भेजें।");
    }

    private List<UUID> getCachedSchemeIds(ConversationSession session) {
        if (session == null || session.getCachedEligibleSchemes() == null) {
            return Collections.emptyList();
        }
        try {
            List<String> rawIds = objectMapper.readValue(session.getCachedEligibleSchemes(), new TypeReference<>() {});
            return rawIds.stream().map(UUID::fromString).collect(Collectors.toList());
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }
}
