# ADR-008: Zero-Loss Scheme Data Migration & Normalization Strategy

## Status
ACCEPTED

## Context
The legacy application includes `src/main/resources/data.sql` with 62 scheme insert statements. These records contain valuable domain data regarding Indian central and state welfare initiatives (PM Kisan, Ayushman Bharat, PMAY, Beti Bachao, Sukanya Samriddhi, etc.).

However, the legacy format violates First Normal Form:
- Multiple caste values are stored as a single comma-separated string (e.g. `"SC,ST,OBC,General"`).
- Multiple states are stored as a comma-separated string (e.g. `"Maharashtra,Uttar Pradesh"`).
- Multiple occupations are stored as a comma-separated string (e.g. `"Farmer,Student"`).
- Requirements and documents are packed into arbitrary text blobs.

Simply discarding this data would discard substantial research effort. On the other hand, importing it as-is would preserve the database design flaws that caused the legacy bugs.

## Decision
1. **Preserve & Normalize:** Extract all 62 schemes from `data.sql` and transform them into relational First Normal Form (1NF) datasets for Supabase PostgreSQL.
2. **Flyway Migration Pipeline:**
   - `V1__init_yojna_setu_schema.sql`: Creates schema, enums, tables, and indexes.
   - `V2__seed_normalized_schemes.sql`: Inserts the 62 schemes into `yojna_setu.schemes`, and tokenizes multi-value fields into the respective junction tables:
     - `yojna_setu.scheme_castes`
     - `yojna_setu.scheme_genders`
     - `yojna_setu.scheme_occupations`
     - `yojna_setu.scheme_documents`
3. **Idempotent Seeding:**
   - Every scheme receives a unique alphanumeric `code` (e.g. `PM-KISAN`, `AYUSHMAN-BHARAT`, `PMAY-G`).
   - Seeding uses `INSERT ... ON CONFLICT (code) DO UPDATE` to ensure migrations can re-run without duplicate key errors and without executing destructive `DELETE FROM schemes;`.
4. **Data Verification:** Document exact mappings, assumptions, and transformations in `docs/v2/DATA_MIGRATION.md`.

## Consequences
### Positive
- Retains 100% of valid scheme domain knowledge from legacy prototype.
- Fully normalized relational schema enables fast indexed database queries.
- Zero data destruction on application startup.

### Negative / Trade-offs
- Requires careful parsing and validation of existing strings into standardized PostgreSQL ENUMs.
