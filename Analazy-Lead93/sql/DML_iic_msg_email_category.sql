-- Level-1 Categories.
INSERT INTO iic_msg_email_category
  (tenant_id, category_code, category_name, normalized_name, description,
   parent_id, category_level, sort_order, is_deleted,
   created_by, updated_by, dae_country_code)
SELECT
  @template_tenant_id, s.category_code, s.category_name,
  LOWER(TRIM(s.category_name)), s.description, NULL, 1, s.sort_order, 0,
  @migration_user, @migration_user, @template_country_code
FROM tmp_lead93_category_seed s
WHERE s.category_level = 1
ON DUPLICATE KEY UPDATE
  category_name = VALUES(category_name),
  normalized_name = VALUES(normalized_name),
  description = VALUES(description),
  sort_order = VALUES(sort_order),
  is_deleted = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

-- Level-2 Subcategories.
INSERT INTO iic_msg_email_category
  (tenant_id, category_code, category_name, normalized_name, description,
   parent_id, category_level, sort_order, is_deleted,
   created_by, updated_by, dae_country_code)
SELECT
  @template_tenant_id, s.category_code, s.category_name,
  LOWER(TRIM(s.category_name)), s.description, p.id, 2, s.sort_order, 0,
  @migration_user, @migration_user, @template_country_code
FROM tmp_lead93_category_seed s
JOIN iic_msg_email_category p
  ON p.category_code = s.parent_category_code
 AND p.category_level = 1
 AND p.is_deleted = 0
WHERE s.category_level = 2
ON DUPLICATE KEY UPDATE
  category_name = VALUES(category_name),
  normalized_name = VALUES(normalized_name),
  description = VALUES(description),
  parent_id = VALUES(parent_id),
  sort_order = VALUES(sort_order),
  is_deleted = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_email_category c
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'CATEGORY' AND s.record_key = c.category_code AND s.action_type = 'UPDATE'
SET c.category_name = JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.category_name')),
    c.normalized_name = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.normalized_name')), 'null'),
    c.description = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.description')), 'null'),
    c.parent_id = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.parent_id')), 'null') AS SIGNED),
    c.category_level = CAST(NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.category_level')), 'null') AS UNSIGNED),
    c.sort_order = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.sort_order')) AS SIGNED),
    c.is_deleted = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.is_deleted')) AS UNSIGNED),
    c.deleted_by = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.deleted_by')), 'null'),
    c.deleted_date = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.deleted_date')), 'null'),
    c.updated_by = @migration_user,
    c.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;

UPDATE iic_msg_email_category c
JOIN iic_msg_template_migration_snapshot s ON s.source_batch_id = @migration_batch_id AND s.record_type = 'CATEGORY' AND s.record_key = c.category_code AND s.action_type = 'INSERT'
SET c.is_deleted = 1, c.deleted_by = @migration_user, c.deleted_date = CURRENT_TIMESTAMP, c.updated_by = @migration_user, c.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
