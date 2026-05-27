package com.yojnasetu.controller;

import com.yojnasetu.service.ConversationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ConversationController {

    private final ConversationService conversationService;

    @Autowired
    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    public record ConversationRequest(String phoneNumber, String message) {}
    public record ConversationResponse(String reply) {}

    @PostMapping("/conversation")
    public ResponseEntity<ConversationResponse> chat(@RequestBody ConversationRequest request) {
        if (request == null || request.phoneNumber() == null || request.phoneNumber().trim().isEmpty() ||
            request.message() == null || request.message().trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        String reply = conversationService.processMessage(request.phoneNumber(), request.message());
        return ResponseEntity.ok(new ConversationResponse(reply));
    }
}
