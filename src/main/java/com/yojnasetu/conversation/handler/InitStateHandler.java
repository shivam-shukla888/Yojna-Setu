package com.yojnasetu.conversation.handler;

import com.yojnasetu.conversation.MessageFormatter;
import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;
import org.springframework.stereotype.Component;

@Component
public class InitStateHandler implements ConversationStateHandler {

    private final MessageFormatter formatter;

    public InitStateHandler(MessageFormatter formatter) {
        this.formatter = formatter;
    }

    @Override
    public SessionStateType getSupportedState() {
        return SessionStateType.INIT;
    }

    @Override
    public StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session) {
        String lang = user != null ? user.getPreferredLanguage() : "hi";
        String welcome = formatter.formatWelcome(lang);
        return StateTransitionResult.of(SessionStateType.LANGUAGE_SELECTION, welcome);
    }
}
