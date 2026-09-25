# ADR-001: PostgreSQL on Supabase (`yojna_setu` Schema) with Flyway

## Status
ACCEPTED

## Context
The legacy Yojna Setu implementation relied on local MySQL 8.x, unversioned schema updates via Hibernate `spring.jpa.hibernate.ddl-auto=update`, and destructive startup SQL scripts (`DELETE FROM schemes;` in `data.sql`).

Furthermore, the target ecosystem utilizes **Supabase Project #2**, a managed PostgreSQL database shared across multiple projects (such as `whatsapp_agent` and `myca`). 

Running unversioned schema auto-updates in a shared database is unacceptable:
- It risks collision with sibling applications.
- It lacks rollback capabilities.
- It cannot support custom PostgreSQL features (UUIDs, ENUMs, partial indexes, JSONB).

## Decision
1. **Target Engine:** Migrate exclusively to **PostgreSQL** hosted on Supabase (Project #2).
2. **Schema Isolation:** All Yojna Setu tables, types, sequences, and indexes MUST reside strictly inside the dedicated PostgreSQL schema `yojna_setu`. The `public` schema shall not be touched.
3. **Migration Tooling:** Introduce **Flyway** (`org.flywaydb:flyway-database-postgresql`) as the authoritative schema migration engine. Disable Hibernate `ddl-auto` (`validate` in production, `none` in CI).
4. **Primary Keys:** Standardize on UUIDv4 (`gen_random_uuid()`) for all externally visible and relational entities, eliminating sequential integer ID enumeration vulnerabilities.
5. **Connection Search Path:** Configure HikariCP connection string and startup hooks to enforce `search_path = yojna_setu, public`.

## Consequences
### Positive
- Strict physical and logical isolation from sibling projects in Supabase Project #2.
- Full version-controlled, repeatable, and reversible schema history via Flyway.
- Ability to utilize PostgreSQL-specific features: JSONB session caching, typed ENUMs, and native UUID generation.
- Zero risk of auto-ddl table corruption during application restarts.

### Negative / Trade-offs
- Migration scripts must be explicitly written in PostgreSQL-compliant SQL syntax.
- Local development requires either a local PostgreSQL container (Docker/Testcontainers) or a dedicated Supabase branch.

### Risks & Mitigations
- *Risk:* Accidental table creation in `public` schema.  
  *Mitigation:* Configure Flyway with `spring.flyway.schemas=yojna_setu` and `spring.flyway.default-schema=yojna_setu`. Grant the application user database permissions exclusively on `yojna_setu`.
