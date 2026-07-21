# LEAD-93 SQL Index

SQL is split by operation type and target table:

- `DDL_<table>.sql`: one-time schema changes.
- `DML_<table>.sql`: seed, migration, or runtime mapper templates.
- `QUERY_<table>.sql`: pre-check, runtime query, and validation templates.

Open business and migration-data decisions remain in
[LEAD-93_Open_Questions_Register_CN.md](../LEAD-93_Open_Questions_Register_CN.md).

## Execution Order

Fresh environment:

1. Run pre-DDL checks that reference existing tables only.
2. Run the approved table-specific DDL files; do not run
   `DDL_LEAD93_upgrade_existing_schema.sql` on this path.
3. Create the temporary staging tables in `DML_lead93_staging.sql` and load the approved mappings.
4. Register migration batch `STARTED` in an independent log transaction.
5. Run fixed Tag seed and Category seed DML.
6. Run config Category, Template relation, Subject, and approved Template mapping DML.
7. Run all validation queries and commit business DML.
8. Mark the batch `SUCCESS`; after a business rollback, mark it `FAILED`.

Environment that already ran the previous LEAD-93 draft DDL:

1. Do not rerun the individual changed-table DDL files.
2. Run the pre-checks and then `DDL_LEAD93_upgrade_existing_schema.sql`.
3. Continue with the seed, migration, validation, and migration-log steps above.

Runtime files ending in `_runtime.sql` and
`DML_iic_msg_email_category_delete.sql` are Mapper templates, not release DML.

## Required Variables

```sql
SET @migration_batch_id = 'LEAD93_YYYYMMDD_01';
SET @migration_user = 'LEAD93_MIGRATION';
SET @lead93_apply_deactivate = 0;
```

The release executor binds `:total_count`, `:success_count`, `:failed_count`,
and `:error_message` when updating the batch log.

## Final Data Model

- Main Category is stored in `iic_msg_email_config.category_id` as the Template current value.
- Category/Subcategory share `iic_msg_email_category`; `parent_id IS NULL`
  means Category and a non-NULL `parent_id` means Subcategory.
- Category nodes are soft-deleted with `is_deleted`; level is not persisted.
- Active-name uniqueness is checked by the Service, not a database unique key.
- Subcategory relations use `(email_code, subcategory_id)` as the key.
- Tag relations use `(email_code, tag_code)` as the business key and redundantly
  retain `group_code`; write validation requires it to match
  `iic_msg_tag_value.group_code`.
- Tag Value keeps the optional taxonomy `description`; the read-only Tag API
  returns it for frontend display without making it part of template relations.
- Relation rows are soft-replaced when Template current Metadata changes:
  old active rows become `status=-1`, while selected rows are inserted or
  reactivated as `status=0`. Runtime reads only return active relation rows.
- Copy and Create creates a new logical Template: one transaction inserts B's
  config, V1 Draft, submitted current relations and CREATE history. B's config
  stores immutable `copy_from_email_code=A` only for the management-side publish
  reminder; there is no relation table, automatic replacement, visibility rule,
  status cascade, or shared Version history between A and B.
- Copy and Create reuses Version `file_keys`/`thumbnail_key` references. It does
  not copy S3 objects or insert attachment-upload rows.
- Trigger allows at most five selected Tags; the Service enforces this constant.
- The fixed taxonomy contains five Groups: four mandatory Groups plus one
  optional `Proposition / Source` Group. The initial seed contains 31 Values.
- The 18 Values present in `Tag_Taxonomy_with_Descriptions.xlsx` keep their
  approved descriptions. The 13 additional Values already used by
  `Final_Template_Tag_Mapping_Business_Review v 1.0.xlsx` keep their Mapping
  groups and use `NULL` descriptions until business descriptions are approved.
- Draft may leave any Tag Group empty; an empty selection persists as zero
  relation rows. Publish still requires all four mandatory Groups.
- Every successful Template basic-info or Metadata change writes one immutable
  before/after snapshot plus field-level `changed_fields` to
  `iic_msg_email_template_change_history`. Snapshots include the existing and
  LEAD-93 business fields of `iic_msg_email_config` and current Metadata names.
- Every successful Category/Subcategory reassign-and-delete writes one operation
  row to `iic_msg_email_category_delete_audit` and one Template change-history
  row per affected Template in the same transaction. The history before-snapshot
  keeps the associated `emailCode`, Template Name, and source node names; audit
  support queries join both records through `operation_id`.
- The migration log stores one row per execution batch. It is not a runtime
  audit log and no permanent migration snapshot table is created.

Migration DML writes one current Category/Subcategory/Tag set per `email_code`.
Subject mapping remains version-specific because Subject belongs to Version.

## Readiness

- Category, Tag, Template relation, change-history, runtime Metadata, and batch-log SQL reflect confirmed decisions.
- `QUERY_iic_msg_email_config.sql` preserves the confirmed Draft three-branch scope and selects one result per `email_code` by greatest numeric V(N).
- `DML_iic_msg_email_config.sql` and `DML_iic_msg_email_config_version.sql` require approved migration mappings before execution.
- No speculative query indexes are included; production indexes must be assessed from actual SQL and `EXPLAIN` in the inner network.

## Constraints

- MySQL 8.0, InnoDB, `utf8mb4_bin`.
- No new FK or CHECK constraints.
- DDL is executed once by the release process.
- Search placeholders use mapper binding and must never be concatenated.

## Files

### DDL

- `DDL_LEAD93_upgrade_existing_schema.sql` (only for a previously deployed LEAD-93 draft schema)
- `DDL_iic_msg_email_category.sql`
- `DDL_iic_msg_email_config.sql`
- `DDL_iic_msg_template_category_rel.sql`
- `DDL_iic_msg_tag_group.sql`
- `DDL_iic_msg_tag_value.sql`
- `DDL_iic_msg_template_tag_rel.sql`
- `DDL_iic_msg_email_template_change_history.sql`
- `DDL_iic_msg_template_migration_log.sql`
- `DDL_iic_msg_email_category_delete_audit.sql`

### DML

- `DML_lead93_staging.sql`
- `DML_iic_msg_email_category.sql`
- `DML_iic_msg_email_category_runtime.sql`
- `DML_iic_msg_email_category_delete.sql`
- `DML_iic_msg_email_config.sql`
- `DML_iic_msg_email_config_runtime.sql`
- `DML_iic_msg_email_config_version.sql`
- `DML_iic_msg_email_config_version_runtime.sql`
- `DML_iic_msg_template_category_rel.sql`
- `DML_iic_msg_template_category_rel_runtime.sql`
- `DML_iic_msg_tag_group.sql`
- `DML_iic_msg_tag_value.sql`
- `DML_iic_msg_template_tag_rel.sql`
- `DML_iic_msg_template_tag_rel_runtime.sql`
- `DML_iic_msg_template_migration_log.sql`
- `DML_iic_msg_email_category_delete_audit.sql`
- `DML_iic_msg_email_template_change_history.sql`

### QUERY

- `QUERY_iic_msg_email_category.sql`
- `QUERY_iic_msg_email_config.sql`
- `QUERY_iic_msg_email_config_version.sql`
- `QUERY_iic_msg_template_category_rel.sql`
- `QUERY_iic_msg_tag_group.sql`
- `QUERY_iic_msg_tag_value.sql`
- `QUERY_iic_msg_template_tag_rel.sql`
- `QUERY_iic_msg_template_migration_log.sql`
- `QUERY_iic_msg_email_category_delete_audit.sql`
- `QUERY_iic_msg_email_template_change_history.sql`
