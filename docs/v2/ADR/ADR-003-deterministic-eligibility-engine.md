# ADR-003: Deterministic Eligibility Engine & Normalized Rule Evaluation

## Status
ACCEPTED

## Context
In the legacy project, eligibility evaluation suffered from two catastrophic flaws:
1. **The Substring Matching Bug:** Gender and caste matching were performed using Java `String.contains()`. Specifically, `applicableGender.contains(userGender)` caused `"FEMALE".contains("MALE")` to evaluate to `true`. Consequently, male users were evaluated as eligible for female-only welfare schemes (e.g., Ladli Behna Yojana, Sukanya Samriddhi).
2. **In-Memory O(N) Table Scan:** `EligibilityService.findAll()` loaded every single scheme into JVM memory on every single message turn, evaluating Java conditionals sequentially. This pattern does not scale beyond trivial datasets and leads to high GC pressure.

Furthermore, relying on LLMs (such as Groq or GPT) to determine eligibility is non-deterministic, hallucinatory, and legally unviable for government welfare distribution.

## Decision
1. **Deterministic Authority:** Eligibility decisions MUST be 100% deterministic and rule-based. LLMs shall NEVER decide or override whether a citizen qualifies for a scheme.
2. **Relational Normalization (1NF):** Eliminate all comma-separated eligibility columns in `schemes`. Split rules into dedicated junction tables with typed PostgreSQL ENUMs:
   - `yojna_setu.scheme_castes` (`scheme_id`, `caste_type`)
   - `yojna_setu.scheme_genders` (`scheme_id`, `gender_type`)
   - `yojna_setu.scheme_occupations` (`scheme_id`, `occupation`)
3. **Database-Offloaded Matching Query:** Pre-filter qualifying schemes via an indexed, parameterized PostgreSQL query checking:
   - Age ranges: `min_age <= :userAge AND max_age >= :userAge`
   - Income ceilings: `max_income IS NULL OR max_income >= :userIncome`
   - Geographic restrictions: `target_state = 'ALL' OR target_state = :userState`
   - Exact relational joins on caste, gender, and occupation.
4. **Explainable Output:** The eligibility engine outputs an `EligibilityResult` containing exact boolean evaluation codes (`AGE_QUALIFIED`, `INCOME_QUALIFIED`, `GENDER_QUALIFIED`, `CASTE_QUALIFIED`), allowing the bot to explain *why* a scheme matched or failed.

## Consequences
### Positive
- Completely eradicates substring collision bugs (`"FEMALE".contains("MALE")`).
- High-speed query execution (< 10ms for 50,000+ schemes) utilizing PostgreSQL composite B-tree and GIN indexes.
- Transparent, auditable, and explainable decision paths suitable for public sector scrutiny.

### Negative / Trade-offs
- Schema changes require an explicit migration step to tokenize legacy comma-separated values.
