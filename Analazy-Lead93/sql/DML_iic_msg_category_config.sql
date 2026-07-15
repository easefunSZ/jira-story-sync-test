-- Level-1 Categories.
INSERT INTO iic_msg_category_config
  (tenant_id, category_code, category_name, normalized_name, description,
   parent_id, category_level, sort_order, is_deleted,
   created_by, updated_by, dae_country_code, source_batch_id)
SELECT
  @template_tenant_id, s.category_code, s.category_name,
  LOWER(TRIM(s.category_name)), s.description, NULL, 1, s.sort_order, 0,
  @migration_user, @migration_user, @template_country_code,
  @migration_batch_id
FROM tmp_lead93_category_seed s
WHERE s.category_level = 1
ON DUPLICATE KEY UPDATE
  category_name = VALUES(category_name),
  normalized_name = VALUES(normalized_name),
  description = VALUES(description),
  sort_order = VALUES(sort_order),
  source_batch_id = VALUES(source_batch_id),
  is_deleted = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

-- Level-2 Subcategories.
INSERT INTO iic_msg_category_config
  (tenant_id, category_code, category_name, normalized_name, description,
   parent_id, category_level, sort_order, is_deleted,
   created_by, updated_by, dae_country_code, source_batch_id)
SELECT
  @template_tenant_id, s.category_code, s.category_name,
  LOWER(TRIM(s.category_name)), s.description, p.id, 2, s.sort_order, 0,
  @migration_user, @migration_user, @template_country_code,
  @migration_batch_id
FROM tmp_lead93_category_seed s
JOIN iic_msg_category_config p
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
  source_batch_id = VALUES(source_batch_id),
  is_deleted = 0,
  updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

UPDATE iic_msg_category_config
SET is_deleted = 1,
    deleted_by = @migration_user,
    deleted_date = CURRENT_TIMESTAMP,
    updated_by = @migration_user,
    updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1
  AND source_batch_id = @migration_batch_id;
