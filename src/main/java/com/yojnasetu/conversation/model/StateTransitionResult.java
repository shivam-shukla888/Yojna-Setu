package com.yojnasetu.conversation.model;

import com.yojnasetu.model.enums.SessionStateType;

public record StateTransitionResult(
        SessionStateType nextState,
        String replyText,
        boolean requiresPersistence
) {
    public static StateTransitionResult of(SessionStateType nextState, String replyText) {
        return new StateTransitionResult(nextState, replyText, true);
    }

    public static StateTransitionResult noChange(SessionStateType currentState, String replyText) {
        return new StateTransitionResult(currentState, replyText, false);
    }
}
