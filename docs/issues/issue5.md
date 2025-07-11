## 🧠 General Task

### 🧭 Objective

Convert `state` and `config` fields in the Kepler map database schema from `TEXT` to `JSONB` for improved performance, queryability, and storage efficiency.

### 🗺️ Plan

- [ ] Audit current usages of the `state` and `config` fields to ensure JSON structure compliance
- [ ] Create a database migration to alter the column types from `TEXT` → `JSONB`
- [ ] Backfill and cast existing data: `ALTER TABLE maps ALTER COLUMN config TYPE JSONB USING config::jsonb`
- [ ] Add GIN index if we want to query/filter by parts of the JSON
- [ ] Verify no breakage in frontend or deserialization logic
- [ ] Update ORM/model definitions (e.g., SQLAlchemy, Prisma) if needed

### 🔗 References / Resources

- [Postgres JSONB docs](https://www.postgresql.org/docs/current/datatype-json.html)
- Example migration:
  ```sql
  ALTER TABLE kepler_maps
    ALTER COLUMN state TYPE JSONB USING state::jsonb,
    ALTER COLUMN config TYPE JSONB USING config::jsonb;
  ```
