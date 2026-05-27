package com.yojnasetu.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HealthController {

    public record HealthResponse(String status, String service) {}

    @GetMapping("/health")
    public HealthResponse getHealth() {
        return new HealthResponse("UP", "yojna-setu");
    }
}
