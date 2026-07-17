# LEAD-93 SQL Index

SQL is split by operation type and target table.

Open business, code, contract, and data readiness gates are tracked in the
[LEAD-93 open questions register](../LEAD-93_Open_Questions_Register_CN.md).
An item listed as open or blocked there must not be inferred as approved by
the presence of a candidate SQL file.

## Naming

- `DDL_<table>.sql`: one-time versioned schema changes.
- `DML_<table>.sql`: seed, migration, and rollback DML for the target table.
- `QUERY_<table>.sql`: pre-check, runtime query templates, and validation queries.

## Execution Order

The order below is a target sequence, not current approval to execute every
file. Check the review gates in **Readiness** first.

1. Run only the pre-DDL checks that reference existing columns and tables; do not run queries against new LEAD-93 tables yet.
2. Run `DDL_iic_msg_email_category.sql`, then the remaining approved DDL files.
3. Run new-table/new-column baseline checks, including `QUERY_iic_msg_email_category.sql`; expected anomaly counts must be zero.
4. Set migration variables and load the temporary staging tables defined in `DML_lead93_staging.sql`.
5. Run snapshot DML before any Tag/Category seed or mapping DML, then register Migration Log STARTED in an independent log transaction.
6. Run Tag and Category seed DML.
7. Run version Category/relation/config migration DML.
8. Run all post-migration validation queries, then mark the Migration Log SUCCESS; after rollback, mark it FAILED from the independent log transaction.
9. Set `@lead93_rollback = 1` only when an approved rollback is required.

`DML_iic_msg_email_category_runtime.sql` and
`DML_iic_msg_email_category_delete.sql`, plus
`DML_iic_msg_email_config_version_runtime.sql`,
`DML_iic_msg_template_category_rel_runtime.sql`, and
`DML_iic_msg_template_tag_rel_runtime.sql` are runtime Mapper templates
and are not part of the deployment execution sequence.

## Required Variables

```sql
SET @migration_batch_id = 'LEAD93_YYYYMMDD_01';
SET @migration_user = 'LEAD93_MIGRATION';
SET @migration_reason = 'LEAD-93 taxonomy and metadata backfill';
SET @template_tenant_id = 0;              -- replace with target tenant
SET @template_country_code = NULL;         -- replace per deployment
SET @lead93_rollback = 0;                  -- change to 1 only for rollback
SET @lead93_apply_deactivate = 0;         -- enable only with approved Q5 mapping
SET @tag_code_to_deactivate = NULL;        -- set only for approved Tag maintenance
SET @tag_group_code_to_deactivate = NULL;  -- set only for approved Tag maintenance
```

## Readiness

### Updated from confirmed decisions

- `DDL_iic_msg_email_category.sql` (dedicated Template taxonomy table,
  active-name reuse and backend Snowflake code uniqueness)
- `DDL_iic_msg_email_config_version.sql` (`category_id` on the version row)
- `DDL_iic_msg_template_category_rel.sql`
- `DDL_iic_msg_template_tag_rel.sql`
- `DML_lead93_staging.sql` (mapping schema only; mapping data still needs Q5)
- `DML_iic_msg_email_config_version.sql` (version Category section)
- `DML_iic_msg_email_config_version_runtime.sql` (Draft Category initialization; Metadata primary-Category replacement; Expired/Schedule Save Draft; Scheduled Version Delete)
- `DML_iic_msg_template_category_rel_runtime.sql` (Draft initialization; Metadata full replacement; Version Delete/Working Copy Discard; Template Delete)
- `DML_iic_msg_template_tag_rel_runtime.sql` (Draft initialization; Metadata full replacement; Version Delete/Working Copy Discard; Template Delete)
- `DML_iic_msg_email_category.sql` (seed and rollback)
- `DML_iic_msg_email_category_runtime.sql` (single Create, atomic 1-5 Subcategory batch Create, Rename/Reorder templates)
- `DML_iic_msg_email_category_delete.sql` (atomic Active/Draft/Schedule Metadata reassignment and cascade soft delete)
- `DDL_iic_msg_template_migration_log.sql` / `DML_iic_msg_template_migration_log.sql` / `QUERY_iic_msg_template_migration_log.sql` (one-time execution evidence; not runtime audit)
- `DML_iic_msg_tag_group.sql` / `DML_iic_msg_tag_value.sql` (seed, rollback,
  and reference-protected controlled deactivation)
- `DML_iic_msg_template_category_rel.sql`
- `DML_iic_msg_template_tag_rel.sql`
- `QUERY_iic_msg_template_category_rel.sql`
- `QUERY_iic_msg_template_tag_rel.sql`
- `QUERY_iic_msg_tag_group.sql`
- `QUERY_iic_msg_tag_value.sql`
- `QUERY_iic_msg_email_config_version.sql`
- `QUERY_iic_msg_email_category.sql`

Main Category is stored directly in `iic_msg_email_config_version.category_id`.
Subcategory and Tag relations use `email_code + version`. Migration DML executes
only for versions explicitly supplied by the approved staging mapping; it does
not infer or copy metadata to historical versions.

Each Tag Group supports multiple Tag Values. The Tag relation unique key is
`email_code + version + group_code + tag_code`; the runtime and migration DML
replace the complete Tag snapshot for the explicit target version.

Template Category/Subcategory rows are stored only in
`iic_msg_email_category` and are valid when `is_deleted = 0` and
`category_level IN (1, 2)`.
Category/Subcategory deletion atomically reassigns Active/Draft/Schedule
Metadata before soft-deleting the source node. Expired versions are not
reassigned and their historical relation rows may remain; LEAD-93 exposes no
historical Metadata view. Soft-deleted names may be reused. `category_code` is
generated by the backend with Snowflake.

### Partially updated; not deployable yet

- `QUERY_iic_msg_email_config.sql`: confirmed filter deltas are present, but
  Draft selected-version rules still require C03/C04.
- `DDL_iic_msg_email_config.sql` and
  `DDL_iic_msg_email_config_version.sql`: indexes require inner-network
  `EXPLAIN` and existing-index comparison.

### Blocked

- `DML_iic_msg_email_config.sql`: final migration data requires Q5.
- `DML_iic_msg_email_config_version.sql`: Category/Subject mapping data requires Q5.
- No runtime audit SQL is required. LEAD-307 deletion retention is satisfied by
  `deleted_by`, `deleted_date`, and the retained Category/Subcategory row.
- Q8 still blocks final migration target data: the approved mapping must state
  exactly which `email_code + version` rows are migrated.

## Constraints

- MySQL 8.0, InnoDB, `utf8mb4_bin`.
- No FK or CHECK constraints.
- DDL is executed once by the release process.
- Seed and mapping DML is idempotent.
- Migration batch IDs exist only in the one-time snapshot/log tables and release
  variables; runtime Template business tables never store deployment metadata.
- Search query placeholders use mapper syntax and must be bound safely.

## Files

### DDL

- `DDL_iic_msg_email_category.sql`
- `DDL_iic_msg_email_config.sql`
- `DDL_iic_msg_email_config_version.sql`
- `DDL_iic_msg_template_category_rel.sql`
- `DDL_iic_msg_tag_group.sql`
- `DDL_iic_msg_tag_value.sql`
- `DDL_iic_msg_template_tag_rel.sql`
- `DDL_iic_msg_template_migration_snapshot.sql`
- `DDL_iic_msg_template_migration_log.sql`

### DML

- `DML_lead93_staging.sql`
- `DML_iic_msg_email_category.sql`
- `DML_iic_msg_email_category_runtime.sql` (runtime Category mapper templates)
- `DML_iic_msg_email_category_delete.sql` (runtime Category/Subcategory Reassign-and-Delete templates)
- `DML_iic_msg_email_config.sql`
- `DML_iic_msg_email_config_version.sql`
- `DML_iic_msg_email_config_version_runtime.sql` (runtime Draft Category initialization, Metadata primary-Category replacement, Expired/Schedule Save Draft, Scheduled Version Delete)
- `DML_iic_msg_template_category_rel.sql`
- `DML_iic_msg_template_category_rel_runtime.sql` (runtime Draft initialization, Metadata full replacement, Version Delete/Working Copy Discard, Template Delete)
- `DML_iic_msg_tag_group.sql`
- `DML_iic_msg_tag_value.sql`
- `DML_iic_msg_template_tag_rel.sql`
- `DML_iic_msg_template_tag_rel_runtime.sql` (runtime Draft initialization, Metadata full replacement, Version Delete/Working Copy Discard, Template Delete)
- `DML_iic_msg_template_migration_snapshot.sql`
- `DML_iic_msg_template_migration_log.sql`

### QUERY

- `QUERY_iic_msg_email_category.sql`
- `QUERY_iic_msg_email_config.sql`
- `QUERY_iic_msg_email_config_version.sql`
- `QUERY_iic_msg_template_category_rel.sql`
- `QUERY_iic_msg_tag_group.sql`
- `QUERY_iic_msg_tag_value.sql`
- `QUERY_iic_msg_template_tag_rel.sql`
- `QUERY_iic_msg_template_migration_log.sql`
