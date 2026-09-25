package com.yojnasetu.controller.dto;

import com.yojnasetu.model.enums.ApplicationModeType;
import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.model.enums.SchemeCategoryType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

public record CreateSchemeRequest(
        @NotBlank(message = "Scheme code is required")
        String code,

        @NotBlank(message = "Scheme name is required")
        String name,

        @NotBlank(message = "Ministry is required")
        String ministry,

        SchemeCategoryType category,

        @NotBlank(message = "Short description is required")
        String shortDescription,

        @NotBlank(message = "Benefits description is required")
        String benefits,

        ApplicationModeType applicationMode,
        String applicationProcess,
        String officialUrl,

        @NotNull(message = "Minimum age is required")
        Integer minAge,

        @NotNull(message = "Maximum age is required")
        Integer maxAge,

        BigDecimal maxIncome,
        Boolean requiresDisability,
        String targetState,
        LocalDate startDate,
        LocalDate endDate,
        Set<CasteType> applicableCastes,
        Set<GenderType> applicableGenders,
        Set<String> applicableOccupations
) {
}
