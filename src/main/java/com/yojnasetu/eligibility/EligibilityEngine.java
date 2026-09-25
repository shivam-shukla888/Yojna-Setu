package com.yojnasetu.eligibility;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.repository.SchemeRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class EligibilityEngine {

    private final SchemeRepository schemeRepository;

    public EligibilityEngine(SchemeRepository schemeRepository) {
        this.schemeRepository = schemeRepository;
    }

    public List<EligibilityResult> evaluateAll(UserProfile profile) {
        List<Scheme> activeSchemes = schemeRepository.findByIsActiveTrue();
        return activeSchemes.stream()
                .map(scheme -> evaluateScheme(scheme, profile))
                .filter(EligibilityResult::isEligible)
                .collect(Collectors.toList());
    }

    public EligibilityResult evaluateScheme(Scheme scheme, UserProfile profile) {
        if (scheme == null || profile == null) {
            return EligibilityResult.ineligible(scheme, List.of(), "Profile or Scheme is null");
        }

        List<CriterionEvaluation> evaluations = new ArrayList<>();
        boolean eligible = true;

        // 1. Age Evaluation
        if (profile.getAge() != null) {
            int age = profile.getAge();
            if (scheme.getMinAge() != null && age < scheme.getMinAge()) {
                evaluations.add(CriterionEvaluation.fail("AGE", "Age " + age + " is below minimum age of " + scheme.getMinAge()));
                eligible = false;
            } else if (scheme.getMaxAge() != null && age > scheme.getMaxAge()) {
                evaluations.add(CriterionEvaluation.fail("AGE", "Age " + age + " exceeds maximum age of " + scheme.getMaxAge()));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("AGE", "Age " + age + " qualifies (Range: " + scheme.getMinAge() + " - " + scheme.getMaxAge() + ")"));
            }
        } else {
            evaluations.add(CriterionEvaluation.fail("AGE", "User age is not provided"));
            eligible = false;
        }

        // 2. Gender Evaluation (Strict Enum Match — Fixes "FEMALE".contains("MALE") Bug)
        GenderType userGender = profile.getGenderType();
        Set<GenderType> schemeGenders = scheme.getApplicableGenders();
        if (schemeGenders != null && !schemeGenders.isEmpty()) {
            boolean hasAll = schemeGenders.contains(GenderType.ALL);
            boolean exactMatch = userGender != null && schemeGenders.contains(userGender);
            if (!hasAll && !exactMatch) {
                evaluations.add(CriterionEvaluation.fail("GENDER", "Scheme requires " + schemeGenders + ", user is " + userGender));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("GENDER", "Gender requirement satisfied"));
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("GENDER", "Open to all genders"));
        }

        // 3. Caste / Category Evaluation
        CasteType userCaste = profile.getCasteType();
        Set<CasteType> schemeCastes = scheme.getApplicableCastes();
        if (schemeCastes != null && !schemeCastes.isEmpty()) {
            boolean hasAll = schemeCastes.contains(CasteType.ALL);
            boolean exactMatch = userCaste != null && schemeCastes.contains(userCaste);
            if (!hasAll && !exactMatch) {
                evaluations.add(CriterionEvaluation.fail("CASTE", "Scheme applies to " + schemeCastes + ", user is " + userCaste));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("CASTE", "Category requirement satisfied"));
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("CASTE", "Open to all categories"));
        }

        // 4. Annual Income Evaluation
        BigDecimal maxIncome = scheme.getMaxIncomeAmount();
        BigDecimal userIncome = profile.getAnnualIncome();
        if (maxIncome != null) {
            if (userIncome != null && userIncome.compareTo(maxIncome) > 0) {
                evaluations.add(CriterionEvaluation.fail("INCOME", "Income ₹" + userIncome + " exceeds ceiling of ₹" + maxIncome));
                eligible = false;
            } else if (userIncome != null) {
                evaluations.add(CriterionEvaluation.pass("INCOME", "Income ₹" + userIncome + " is within ceiling of ₹" + maxIncome));
            } else {
                evaluations.add(CriterionEvaluation.fail("INCOME", "Income not specified"));
                eligible = false;
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("INCOME", "No income ceiling"));
        }

        // 5. State / Geographic Evaluation
        String targetState = scheme.getTargetState();
        String userState = profile.getState();
        if (targetState != null && !"ALL".equalsIgnoreCase(targetState)) {
            if (userState == null || !targetState.equalsIgnoreCase(userState.trim())) {
                evaluations.add(CriterionEvaluation.fail("STATE", "Scheme is restricted to " + targetState + ", user is in " + userState));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("STATE", "State requirement satisfied (" + targetState + ")"));
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("STATE", "Applicable across all States (Pan-India)"));
        }

        // 6. Disability Evaluation
        if (scheme.isRequiresDisability()) {
            if (!profile.isDifferentlyAbled()) {
                evaluations.add(CriterionEvaluation.fail("DISABILITY", "Scheme requires applicant to be differently abled / Divyangjan"));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("DISABILITY", "Disability requirement satisfied"));
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("DISABILITY", "No disability requirement"));
        }

        // 7. Occupation Evaluation
        Set<String> schemeOccupations = scheme.getApplicableOccupations();
        String userOccupation = profile.getOccupation();
        if (schemeOccupations != null && !schemeOccupations.isEmpty()) {
            boolean hasAll = schemeOccupations.contains("ALL");
            boolean matches = userOccupation != null && schemeOccupations.stream()
                    .anyMatch(occ -> occ.equalsIgnoreCase(userOccupation.trim()));
            if (!hasAll && !matches) {
                evaluations.add(CriterionEvaluation.fail("OCCUPATION", "Scheme applies to occupations " + schemeOccupations + ", user is " + userOccupation));
                eligible = false;
            } else {
                evaluations.add(CriterionEvaluation.pass("OCCUPATION", "Occupation requirement satisfied"));
            }
        } else {
            evaluations.add(CriterionEvaluation.pass("OCCUPATION", "Open to all occupations"));
        }

        if (eligible) {
            return EligibilityResult.eligible(scheme, evaluations);
        } else {
            String failureSummary = evaluations.stream()
                    .filter(e -> !e.passed())
                    .map(e -> "[" + e.criterionName() + "] " + e.explanation())
                    .collect(Collectors.joining("; "));
            return EligibilityResult.ineligible(scheme, evaluations, failureSummary);
        }
    }
}
