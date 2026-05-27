package com.yojnasetu.controller;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.service.EligibilityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/eligibility")
public class EligibilityController {

    private final EligibilityService eligibilityService;

    @Autowired
    public EligibilityController(EligibilityService eligibilityService) {
        this.eligibilityService = eligibilityService;
    }

    @GetMapping("/{phoneNumber}")
    public ResponseEntity<?> getEligibleSchemes(@PathVariable String phoneNumber) {
        try {
            List<Scheme> eligibleSchemes = eligibilityService.getEligibleSchemes(phoneNumber);
            return ResponseEntity.ok(eligibleSchemes);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }
}
