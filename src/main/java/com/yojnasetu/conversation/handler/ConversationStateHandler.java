package com.yojnasetu.conversation.handler;

import com.yojnasetu.conversation.model.InboundMessage;
import com.yojnasetu.conversation.model.StateTransitionResult;
import com.yojnasetu.model.ConversationSession;
import com.yojnasetu.model.User;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.SessionStateType;

public interface ConversationStateHandler {
    SessionStateType getSupportedState();
    StateTransitionResult handle(InboundMessage message, User user, UserProfile profile, ConversationSession session);
}
