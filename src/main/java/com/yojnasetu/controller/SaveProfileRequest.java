package com.yojnasetu.controller;

import jakarta.validation.constraints.NotBlank;

public record SaveProfileRequest(
    @NotBlank(message = "Phone number is required")
    String phoneNumber,

    Integer age,
    String gender,
    String state,
    String district,
    Long income,
    String caste,
    String religion,
    String occupation,
    String maritalStatus,
    Boolean isDisabled
) {}
