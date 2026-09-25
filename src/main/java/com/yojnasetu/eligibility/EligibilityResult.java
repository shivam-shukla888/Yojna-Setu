package com.yojnasetu.eligibility;

import com.yojnasetu.model.Scheme;

import java.util.List;

public record EligibilityResult(
        Scheme scheme,
        boolean isEligible,
        List<CriterionEvaluation> evaluations,
        String summaryReason
) {
    public static EligibilityResult eligible(Scheme scheme, List<CriterionEvaluation> evaluations) {
        return new EligibilityResult(scheme, true, evaluations, "All criteria satisfied");
    }

    public static EligibilityResult ineligible(Scheme scheme, List<CriterionEvaluation> evaluations, String reason) {
        return new EligibilityResult(scheme, false, evaluations, reason);
    }
}
