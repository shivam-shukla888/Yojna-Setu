package com.yojnasetu.controller;

import com.yojnasetu.service.GroqService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/groq")
public class GroqController {

    private final GroqService groqService;

    @Autowired
    public GroqController(GroqService groqService) {
        this.groqService = groqService;
    }

    public record ExtractRequest(String message) {}

    @PostMapping("/extract")
    public ResponseEntity<Map<String, Object>> extractFields(@RequestBody ExtractRequest request) {
        if (request == null || request.message() == null || request.message().trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        Map<String, Object> result = groqService.extractUserInformation(request.message());
        return ResponseEntity.ok(result);
    }
}
