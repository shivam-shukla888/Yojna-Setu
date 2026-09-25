package com.yojnasetu.ai.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record ExtractedDemographicsRecord(
        Integer age,
        String gender,
        String state,
        String district,
        String caste,
        Long annualIncome,
        String occupation,
        String religion,
        String maritalStatus,
        Boolean isDifferentlyAbled
) {
    public boolean hasAnyField() {
        return age != null || gender != null || state != null || caste != null ||
                annualIncome != null || occupation != null || isDifferentlyAbled != null;
    }
}
