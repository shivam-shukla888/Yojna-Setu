package com.yojnasetu.controller;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.repository.SchemeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/schemes")
public class SchemeController {

    private final SchemeRepository schemeRepository;

    @Autowired
    public SchemeController(SchemeRepository schemeRepository) {
        this.schemeRepository = schemeRepository;
    }

    @GetMapping("/all")
    public ResponseEntity<List<Scheme>> getAllActiveSchemes() {
        List<Scheme> activeSchemes = schemeRepository.findByIsActiveTrue();
        return ResponseEntity.ok(activeSchemes);
    }
}
