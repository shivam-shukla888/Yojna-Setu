package com.yojnasetu.conversation.handler;

import com.yojnasetu.conversation.MessageFormatter;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;
import com.yojnasetu.repository.UserRepository;
import org.springframework.stereotype.Component;

@Component
public class LanguageSelectionHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;
    private final UserRepository userRepository;

    public LanguageSelectionHandler(MessageFormatter formatter, UserRepository userRepository) {
        this.formatter = formatter;
        this.userRepository = userRepository;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.LANGUAGE_SELECTION;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String input = message.text().trim();
        String selectedLang = "hi";

        if ("1".equals(input) || input.toLowerCase().contains("hindi") || input.toLowerCase().contains("हिंदी")) {
            selectedLang = "hi";
        } else if ("2".equals(input) || input.toLowerCase().contains("hinglish")) {
            selectedLang = "hinglish";
        } else if ("3".equals(input) || input.toLowerCase().contains("english") || input.toLowerCase().contains("en")) {
            selectedLang = "en";
        }

        if (user != null) {
            user.setPreferredLanguage(selectedLang);
            userRepository.save(user);
        }

        String ack;
        if ("hi".equals(selectedLang)) {
            ack = "✅ भाषा चुनी गई: *हिंदी*\n\nयोजनाओं की पात्रता जाँचने के लिए कृपया अपनी कुछ जानकारी दें।\n\n";
        } else if ("hinglish".equals(selectedLang)) {
            ack = "✅ Language set to *Hinglish*.\n\nYojna eligibility check karne ke liye please thodi details batayein.\n\n";
        } else {
            ack = "✅ Language set to *English*.\n\nTo find schemes you qualify for, please provide a few details.\n\n";
        }

        String nextQuestion = formatter.formatAskAge(selectedLang);
        return StateTransitionResult.of(SessionStateType.PROFILE_COLLECTION, ack + nextQuestion);
    }
}
