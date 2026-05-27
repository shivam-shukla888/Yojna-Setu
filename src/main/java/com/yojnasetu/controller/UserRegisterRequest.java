package com.yojnasetu.controller;

import jakarta.validation.constraints.NotBlank;

public record UserRegisterRequest(
    @NotBlank(message = "Phone number is required")
    String phoneNumber,
    
    @NotBlank(message = "Name is required")
    String name
) {}
