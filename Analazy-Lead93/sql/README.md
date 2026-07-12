# LEAD-93 SQL Index

SQL is split by operation type and target table.

## Naming

- `DDL_<table>.sql`: one-time versioned schema changes.
- `DML_<table>.sql`: seed, migration, and rollback DML for the target table.
- `QUERY_<table>.sql`: pre-check, runtime query templates, and validation queries.

## Execution Order

1. Run all `QUERY_*` pre-check sections.
2. Run `DDL_iic_msg_category_config.sql`, then the remaining DDL files.
3. Set migration variables and load the temporary staging tables defined in `DML_lead93_staging.sql`.
4. Run Tag and Category seed DML.
5. Run snapshot DML before modifying existing config/version rows.
6. Run metadata/relation/config/version migration DML.
7. Run all validation queries.
8. Set `@lead93_rollback = 1` only when an approved rollback is required.

## Required Variables

```sql
SET @template_category_flag = 'TPL';      -- proposed; confirm before production
SET @migration_batch_id = 'LEAD93_YYYYMMDD_01';
SET @migration_user = 'LEAD93_MIGRATION';
SET @template_tenant_id = 0;              -- replace with target tenant
SET @template_country_code = NULL;         -- replace per deployment
SET @lead93_rollback = 0;                  -- change to 1 only for rollback
SET @lead93_apply_deactivate = 0;           -- change to 1 only after Q6 approval
```

## Constraints

- MySQL 8.0, InnoDB, `utf8mb4_bin`.
- No FK or CHECK constraints.
- DDL is executed once by the release process.
- Seed and mapping DML is idempotent.
- Search query placeholders use mapper syntax and must be bound safely.

## Files

### DDL

- `DDL_iic_msg_category_config.sql`
- `DDL_iic_msg_email_config.sql`
- `DDL_iic_msg_email_config_version.sql`
- `DDL_iic_msg_template_metadata.sql`
- `DDL_iic_msg_template_category_rel.sql`
- `DDL_iic_msg_tag_group.sql`
- `DDL_iic_msg_tag_value.sql`
- `DDL_iic_msg_template_tag_rel.sql`
- `DDL_iic_msg_template_migration_snapshot.sql`

### DML

- `DML_lead93_staging.sql`
- `DML_iic_msg_category_config.sql`
- `DML_iic_msg_email_config.sql`
- `DML_iic_msg_email_config_version.sql`
- `DML_iic_msg_template_metadata.sql`
- `DML_iic_msg_template_category_rel.sql`
- `DML_iic_msg_tag_group.sql`
- `DML_iic_msg_tag_value.sql`
- `DML_iic_msg_template_tag_rel.sql`
- `DML_iic_msg_template_migration_snapshot.sql`

### QUERY

- `QUERY_iic_msg_category_config.sql`
- `QUERY_iic_msg_email_config.sql`
- `QUERY_iic_msg_email_config_version.sql`
- `QUERY_iic_msg_template_metadata.sql`
- `QUERY_iic_msg_template_category_rel.sql`
- `QUERY_iic_msg_tag_group.sql`
- `QUERY_iic_msg_tag_value.sql`
- `QUERY_iic_msg_template_tag_rel.sql`
