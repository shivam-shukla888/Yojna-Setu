package com.yojnasetu.eligibility;

import com.yojnasetu.model.Scheme;
import com.yojnasetu.model.UserProfile;
import com.yojnasetu.model.enums.CasteType;
import com.yojnasetu.model.enums.GenderType;
import com.yojnasetu.repository.SchemeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class EligibilityEngineTest {

    private SchemeRepository schemeRepository;
    private EligibilityEngine engine;

    @BeforeEach
    void setUp() {
        schemeRepository = Mockito.mock(SchemeRepository.class);
        engine = new EligibilityEngine(schemeRepository);
    }

    @Test
    @DisplayName("CRITICAL: Male applicant MUST NOT match female-only schemes (Fixes FEMALE.contains(MALE) bug)")
    void testMaleApplicantRejectedForFemaleOnlyScheme() {
        Scheme femaleOnlyScheme = new Scheme();
        femaleOnlyScheme.setName("Sukanya Samriddhi Yojana");
        femaleOnlyScheme.setApplicableGenders(Set.of(GenderType.FEMALE));
        femaleOnlyScheme.setMinAge(0);
        femaleOnlyScheme.setMaxAge(10);

        UserProfile maleProfile = new UserProfile();
        maleProfile.setAge(8);
        maleProfile.setGender(GenderType.MALE);

        EligibilityResult result = engine.evaluateScheme(femaleOnlyScheme, maleProfile);

        assertFalse(result.isEligible(), "Male applicant should NOT qualify for female-only scheme");
        assertTrue(result.summaryReason().contains("GENDER"), "Failure summary must explain gender mismatch");
    }

    @Test
    @DisplayName("Female applicant qualifies for female-only scheme")
    void testFemaleApplicantQualifiesForFemaleScheme() {
        Scheme femaleScheme = new Scheme();
        femaleScheme.setName("PM Matru Vandana Yojana");
        femaleScheme.setApplicableGenders(Set.of(GenderType.FEMALE));
        femaleScheme.setMinAge(18);
        femaleScheme.setMaxAge(50);

        UserProfile femaleProfile = new UserProfile();
        femaleProfile.setAge(25);
        femaleProfile.setGender(GenderType.FEMALE);

        EligibilityResult result = engine.evaluateScheme(femaleScheme, femaleProfile);

        assertTrue(result.isEligible(), "Female applicant should qualify");
    }

    @Test
    @DisplayName("Income ceiling test: Income exceeding maxIncome is rejected")
    void testIncomeCeilingEnforcement() {
        Scheme lowIncomeScheme = new Scheme();
        lowIncomeScheme.setName("Ayushman Bharat PMJAY");
        lowIncomeScheme.setMaxIncome(new BigDecimal("250000.00"));
        lowIncomeScheme.setMinAge(0);
        lowIncomeScheme.setMaxAge(100);

        UserProfile richProfile = new UserProfile();
        richProfile.setAge(30);
        richProfile.setAnnualIncome(new BigDecimal("300000.00"));

        EligibilityResult result = engine.evaluateScheme(lowIncomeScheme, richProfile);

        assertFalse(result.isEligible(), "Applicant with income 300,000 should exceed 250,000 ceiling");
        assertTrue(result.summaryReason().contains("INCOME"));
    }

    @Test
    @DisplayName("State restriction test: UP resident rejected for Maharashtra scheme")
    void testStateRestrictionEnforcement() {
        Scheme maharashtraScheme = new Scheme();
        maharashtraScheme.setName("Maharashtra Swadhar Gruh");
        maharashtraScheme.setTargetState("Maharashtra");
        maharashtraScheme.setMinAge(15);
        maharashtraScheme.setMaxAge(30);

        UserProfile upProfile = new UserProfile();
        upProfile.setAge(20);
        upProfile.setState("Uttar Pradesh");

        EligibilityResult result = engine.evaluateScheme(maharashtraScheme, upProfile);

        assertFalse(result.isEligible(), "UP resident should not qualify for Maharashtra scheme");
        assertTrue(result.summaryReason().contains("STATE"));
    }

    @Test
    @DisplayName("Disability requirement: Non-disabled applicant rejected for disability scheme")
    void testDisabilityRequirementEnforcement() {
        Scheme disabilityScheme = new Scheme();
        disabilityScheme.setName("ADIP Assistive Devices");
        disabilityScheme.setRequiresDisability(true);
        disabilityScheme.setMinAge(0);
        disabilityScheme.setMaxAge(100);

        UserProfile nonDisabledProfile = new UserProfile();
        nonDisabledProfile.setAge(40);
        nonDisabledProfile.setDifferentlyAbled(false);

        EligibilityResult result = engine.evaluateScheme(disabilityScheme, nonDisabledProfile);

        assertFalse(result.isEligible(), "Non-disabled applicant should be rejected");
        assertTrue(result.summaryReason().contains("DISABILITY"));
    }

    @Test
    @DisplayName("Age boundary test: Underage and overage applicants rejected")
    void testAgeBoundaryEnforcement() {
        Scheme youthScheme = new Scheme();
        youthScheme.setName("Youth Skill Scheme");
        youthScheme.setMinAge(18);
        youthScheme.setMaxAge(35);

        UserProfile child = new UserProfile();
        child.setAge(17);
        assertFalse(engine.evaluateScheme(youthScheme, child).isEligible(), "17yo should be rejected when min age is 18");

        UserProfile senior = new UserProfile();
        senior.setAge(36);
        assertFalse(engine.evaluateScheme(youthScheme, senior).isEligible(), "36yo should be rejected when max age is 35");

        UserProfile valid = new UserProfile();
        valid.setAge(25);
        assertTrue(engine.evaluateScheme(youthScheme, valid).isEligible(), "25yo should qualify for 18-35 range");
    }
}
