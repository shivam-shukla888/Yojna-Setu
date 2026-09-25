# YOJNA SETU V2 — DATA MIGRATION SPECIFICATION
**Document:** `docs/v2/DATA_MIGRATION.md`  
**Version:** 2.0.0  
**Source:** Legacy MySQL Seed (`src/main/resources/data.sql`)  
**Target:** Supabase PostgreSQL (`yojna_setu` schema)  
**Migration Artifact:** `src/main/resources/db/migration/V2__seed_normalized_schemes.sql`  
**Status:** APPROVED (PHASE 3 SPECIFICATION)  

---

## 1. Migration Source Analysis

### 1.1 Source Inventory
The legacy data source is `src/main/resources/data.sql` (38 KB).
- **Physical Structure:**
  - Block 1: 52 central, agriculture, health, education, housing, financial, and private schemes.
  - Block 2: 20 unorganized worker, minority, and disability schemes.
  - Intermediate Update: Religion filter update on minority initiatives.
  - Block 3: 10 state-specific welfare programs (Uttar Pradesh, Bihar, Rajasthan, Madhya Pradesh, West Bengal, Maharashtra).
  - Trailing Updates: Deadline updates for 2026 application windows.
- **Total Valid Scheme Records:** **Exactly 82 unique schemes**.
- **Audit Clarification:** The README statement *"82+ Central & State Schemes"* is **VERIFIED** by counting all 82 tuples across the three insert blocks in `data.sql`.

---

## 2. Relational Transformations & 1NF Normalization

Legacy storage violated First Normal Form (1NF) by combining multi-valued attributes into comma-delimited strings. The V2 migration systematically tokenizes and maps these into normalized relational tables.

### 2.1 Transformation Matrix

| Legacy Field in `data.sql` | Legacy Example | V2 Target Table & Field | Normalization Transformation |
|---|---|---|---|
| `eligible_castes` | `'SC,ST,OBC,GENERAL'` | `yojna_setu.scheme_castes` (`caste`) | Tokenized into individual rows with `caste_type` ENUM (`SC`, `ST`, `OBC`, `GENERAL`, `EWS`, `ALL`) |
| `eligible_gender` | `'FEMALE'` / `'ALL'` | `yojna_setu.scheme_genders` (`gender`) | Tokenized into individual rows with `gender_type` ENUM (`MALE`, `FEMALE`, `ALL`) |
| `eligible_occupations` | `'FARMER,OTHER'` | `yojna_setu.scheme_occupations` (`occupation`) | Tokenized into individual rows (`FARMER`, `STUDENT`, `BUSINESS`, `SALARIED`, `OTHER`) |
| `eligible_religions` | `'MUSLIM,CHRISTIAN,SIKH...'` | `yojna_setu.scheme_religions` (`religion`) | Tokenized into individual rows (`MUSLIM`, `CHRISTIAN`, `SIKH`, `BUDDHIST`, `JAIN`, `ALL`) |
| `required_documents` | `'Aadhaar, Bank Passbook, Ration Card'` | `yojna_setu.scheme_documents` (`document_name`) | Split by comma into discrete records linked by `scheme_id` |
| `ministry` | `'Tata Capital (Private)'` | `schemes.category` | Categorized as `PRIVATE` if containing `(Private)`, `STATE_GOVERNMENT` if targeting a single state, else `CENTRAL_GOVERNMENT` |
| `max_income` | `200000` (stored as Double) | `schemes.max_income` (NUMERIC(15,2)) | Converted from floating-point to exact decimal |
| `min_age` / `max_age` | `null` | `schemes.min_age` / `max_age` | Normalized to `0` and `130` for boundary evaluation |

---

## 3. Scheme Classification Breakdown (82 Schemes)

### 3.1 Central Government Welfare Schemes (64 Schemes)
- **Agriculture & Farmers (5):** PM-KISAN, PM Fasal Bima Yojana, Kisan Credit Card, PM Kisan Maandhan Yojana, Paramparagat Krishi Vikas Yojana.
- **Health & Medical (4):** Ayushman Bharat PMJAY, Ayushman Bharat Senior Citizens (70+), Janani Suraksha Yojana, PM Surakshit Matritva Abhiyan.
- **Education & Scholarships (7):** Post Matric SC, Post Matric ST, Post Matric OBC, National Means Cum Merit, Central Sector Scholarship, PM Vidya Lakshmi, Ishan Uday NE.
- **Housing (2):** PM Awas Yojana Urban, PM Awas Yojana Gramin.
- **Financial Inclusion & Social Security (6):** PM Jan Dhan Yojana, PM Jeevan Jyoti Bima, PM Suraksha Bima, Atal Pension Yojana, PM Mudra Yojana, Stand Up India.
- **Skill Development & MSME (4):** PM Kaushal Vikas Yojana 4.0, PM Vishwakarma Yojana, PMEGP, Deen Dayal Upadhyaya Grameen Kaushalya.
- **Women Empowerment (5):** Beti Bachao Beti Padhao, Sukanya Samriddhi Yojana, PM Matru Vandana Yojana, One Stop Centre Sakhi, PM Ujjwala Yojana 2.0.
- **Elderly, Widows & Disability (4):** Indira Gandhi Old Age Pension, Indira Gandhi Widow Pension, Indira Gandhi Disability Pension, Unique Disability ID (UDID).
- **Rural Employment & Food Security (3):** Mahatma Gandhi NREGA, PM Garib Kalyan Anna Yojana, Annapurna Scheme.
- **Startups & Street Vendors (2):** Startup India Seed Fund, PM SVANidhi.
- **SC/ST Specialized Programs (3):** Venture Capital Fund for SC, National Overseas Scholarship SC/ST, Eklavya Residential Schools.
- **Unorganized Workers & Employment (5):** e-Shram Card, PM Shram Yogi Maandhan, Building Construction Workers Welfare, National Career Service, Employment Linked Incentive.
- **Minority Welfare (8):** Pre Matric Minority, Post Matric Minority, Naya Savera Free Coaching, Nai Udaan UPSC, PM VIKAS, NMDFC Loan, Nai Roshni, Maulana Azad Fellowship.
- **Disability Assistance & Sports (4):** ADIP Assistive Devices, Scholarship for Disabled Students, NHFDC Concessional Loan, Divyangjan Sports Award.
- **Newly Launched 2024-2025 (2):** PM Surya Ghar Muft Bijli Yojana, Vishwakarma Credit Guarantee.

### 3.2 Private & Philanthropic Scholarships (8 Schemes)
*Clearly distinguished via `category = 'PRIVATE'` to ensure users are not misled about government sponsorship:*
1. Tata Capital Pankh Scholarship
2. Reliance Foundation Undergraduate Scholarship
3. HDFC Badhte Kadam Scholarship
4. Infosys Foundation STEM Stars
5. SBI Asha Scholarship
6. Aditya Birla Scholarship
7. Bharti Airtel Scholarship
8. Buddy4Study India Foundation Scholarship

### 3.3 State-Specific Welfare Programs (10 Schemes)
*Categorized as `category = 'STATE_GOVERNMENT'` with explicit `target_state` values:*
1. **Uttar Pradesh (4):** UP Kanya Sumangala Yojana, UP Mukhyamantri Abhyudaya Yojana (UPSC Coaching), UP Berojgari Bhatta, UP Vridha Pension Yojana.
2. **Bihar (2):** Bihar Student Credit Card, Bihar Mukhyamantri Kanya Utthan Yojana.
3. **Rajasthan (1):** Rajasthan Mukhyamantri Chiranjeevi Health Insurance.
4. **Madhya Pradesh (1):** MP Mukhyamantri Medhavi Vidyarthi Yojana.
5. **West Bengal (1):** West Bengal Kanyashree Prakalpa.
6. **Maharashtra (1):** Maharashtra Swadhar Gruh Scheme.

---

## 4. Idempotency & Zero-Downtime Migration Execution

1. **Upsert Pattern:** Every scheme has a deterministic, alphanumeric code (e.g. `PM-KISAN`, `UP-KANYA-SUMANGALA`).
2. **Conflict Resolution:** `INSERT INTO yojna_setu.schemes ... ON CONFLICT (code) DO UPDATE` ensures migrations can run repeatedly without primary key collisions or sequence corruption.
3. **Child Synchronization:** Existing child junction rows for the scheme are atomically purged and re-populated inside a single transactional block (`DO $$ BEGIN ... END $$;`), guaranteeing referential consistency.
4. **Elimination of Destructive DDL:** The legacy command `DELETE FROM schemes;` is completely eliminated.
