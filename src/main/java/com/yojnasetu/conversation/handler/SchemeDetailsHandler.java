package com.yojnasetu.conversation.handler;

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

import java.util.Optional;
import java.util.UUID;

@Component
public class SchemeDetailsHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;
    private final SchemeRepository schemeRepository;

    public SchemeDetailsHandler(MessageFormatter formatter, SchemeRepository schemeRepository) {
        this.formatter = formatter;
        this.schemeRepository = schemeRepository;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.SCHEME_DETAILS;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String input = message.text().trim().toLowerCase();
        String lang = user != null ? user.getPreferredLanguage() : "hi";

        if (input.equals("back") || input.contains("wapas") || input.contains("वापस") || input.equals("list")) {
            return StateTransitionResult.of(SessionStateType.SCHEMES_LIST,
                    "👉 योजनाओं की सूची पर वापस आ गए हैं। अन्य योजना देखने के लिए नंबर या *more* भेजें।");
        }

        // Active scheme lookup from session
        String activeSchemeIdStr = session.getLastPromptSent();
        if (activeSchemeIdStr != null) {
            try {
                UUID schemeId = UUID.fromString(activeSchemeIdStr);
                Optional<Scheme> schemeOpt = schemeRepository.findById(schemeId);
                if (schemeOpt.isPresent()) {
                    Scheme s = schemeOpt.get();
                    if (input.contains("doc") || input.contains("दस्तावेज") || input.contains("paper")) {
                        return StateTransitionResult.noChange(SessionStateType.SCHEME_DETAILS,
                                "📄 *" + s.getName() + " के लिए ज़रूरी दस्तावेज़:*\n\n" + s.getRequiredDocuments() +
                                        "\n\n👉 वापस जाने के लिए *back* भेजें।");
                    }
                    if (input.contains("apply") || input.contains("link") || input.contains("आवेदन")) {
                        return StateTransitionResult.noChange(SessionStateType.SCHEME_DETAILS,
                                "🌐 *" + s.getName() + " आवेदन लिंक व प्रक्रिया:*\n\n" +
                                        "लिंक: " + s.getOfficialUrl() + "\n" +
                                        "प्रक्रिया: " + (s.getApplicationProcess() != null ? s.getApplicationProcess() : "आधिकारिक वेबसाइट पर जाएं।") +
                                        "\n\n👉 वापस जाने के लिए *back* भेजें।");
                    }
                }
            } catch (Exception ignored) {}
        }

        return StateTransitionResult.noChange(SessionStateType.SCHEME_DETAILS,
                "👉 दस्तावेज़ देखने के लिए *docs* भेजें।\n" +
                        "👉 आवेदन लिंक के लिए *apply* भेजें।\n" +
                        "👉 वापस सूची के लिए *back* भेजें।");
    }
}
