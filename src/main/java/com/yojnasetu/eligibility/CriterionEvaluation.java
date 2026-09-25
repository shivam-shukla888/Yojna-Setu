package com.yojnasetu.eligibility;

public record CriterionEvaluation(
        String criterionName,
        boolean passed,
        String explanation
) {
    public static CriterionEvaluation pass(String criterion, String explanation) {
        return new CriterionEvaluation(criterion, true, explanation);
    }

    public static CriterionEvaluation fail(String criterion, String explanation) {
        return new CriterionEvaluation(criterion, false, explanation);
    }
}
