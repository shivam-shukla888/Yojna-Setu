# YOJNA SETU V2 — DETERMINISTIC ELIGIBILITY ENGINE
**Document:** `docs/v2/ELIGIBILITY_ENGINE.md`  
**Version:** 2.0.0  
**Status:** APPROVED (PHASE 7 SPECIFICATION)  

---

## 1. Objective & Authority Boundary

The Eligibility Engine is the **sole authoritative decision-maker** for welfare qualifications in Yojna Setu V2. 
- **Non-Negotiable Rule:** Generative AI models (Groq LLMs) are **strictly forbidden** from determining, modifying, or guessing citizen eligibility.
- Every match or disqualification must be backed by deterministic, mathematically verifiable rules evaluated against structured database records.

---

## 2. Elimination of Critical Legacy Matching Bugs

### 2.1 The `"FEMALE".contains("MALE")` Bug
In legacy V1, `Scheme.java` evaluated gender eligibility using string substring contains:
```java
// Legacy V1 (FATAL BUG)
if (!applicableGender.toUpperCase().contains(userGender.toUpperCase())) return false;
```
Because `"FEMALE".contains("MALE")` evaluates to `true` in Java, all male applicants were incorrectly evaluated as eligible for female-only welfare schemes (e.g. Sukanya Samriddhi Yojana, Ladli Behna Yojana).

### 2.2 The V2 Architectural Resolution
V2 enforces exact PostgreSQL enum matching via `GenderType`:
```java
// V2 Deterministic Match
GenderType userGender = profile.getGenderType();
Set<GenderType> schemeGenders = scheme.getApplicableGenders();
boolean hasAll = schemeGenders.contains(GenderType.ALL);
boolean exactMatch = userGender != null && schemeGenders.contains(userGender);
if (!hasAll && !exactMatch) {
    // Rejected deterministically
}
```

---

## 3. Seven-Dimensional Rule Evaluation

Every scheme is evaluated against seven distinct demographic dimensions:

1. **Age Range (`min_age <= user_age <= max_age`):** Evaluates lower and upper boundaries. Handles `0` for newborn infant schemes and `70+` for senior citizen healthcare.
2. **Gender (`gender_type`):** Matches `MALE`, `FEMALE`, `TRANSGENDER`, or `ALL`.
3. **Category / Caste (`caste_type`):** Matches `GENERAL`, `OBC`, `SC`, `ST`, `EWS`, or `ALL`.
4. **Income Ceiling (`annual_income <= max_income`):** Precise comparison using `BigDecimal` currency types. If `max_income IS NULL`, the scheme has no income ceiling.
5. **State / Geographic Restriction (`target_state`):** Matches the citizen's state of domicile or `ALL` for central pan-India schemes.
6. **Disability Requirement (`requires_disability`):** If true, applicant must have `is_differently_abled == true`.
7. **Occupation (`scheme_occupations`):** Evaluates matching profession (`FARMER`, `STUDENT`, `BUSINESS`, `SALARIED`, `OTHER`, or `ALL`).

---

## 4. Explainable Eligibility Results

Instead of returning a simple boolean, the engine produces an `EligibilityResult` containing itemized `CriterionEvaluation` records:
```json
{
  "schemeCode": "PM-KISAN",
  "isEligible": true,
  "summaryReason": "All criteria satisfied",
  "evaluations": [
    {"criterion": "AGE", "passed": true, "explanation": "Age 28 qualifies (Range: 18 - 130)"},
    {"criterion": "GENDER", "passed": true, "explanation": "Open to all genders"},
    {"criterion": "CASTE", "passed": true, "explanation": "Category requirement satisfied"},
    {"criterion": "INCOME", "passed": true, "explanation": "Income ₹150000.00 is within ceiling of ₹200000.00"},
    {"criterion": "STATE", "passed": true, "explanation": "Applicable across all States (Pan-India)"},
    {"criterion": "OCCUPATION", "passed": true, "explanation": "Occupation requirement satisfied"}
  ]
}
```
This enables the chatbot to explain to citizens exactly *why* they qualify or *why* they missed a cutoff.
