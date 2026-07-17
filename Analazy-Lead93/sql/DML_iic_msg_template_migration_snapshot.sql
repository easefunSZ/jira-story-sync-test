-- Run after staging is loaded and before any LEAD-93 seed or mapping DML.
-- The snapshot table is the only permanent place that stores migration batch IDs.
-- INSERT means the business row did not exist before this batch; UPDATE stores
-- the pre-migration values required for rollback.

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'CATEGORY', seed.category_code,
       CASE WHEN c.id IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
       c.id, NULL,
       CASE WHEN c.id IS NULL THEN NULL ELSE JSON_OBJECT(
         'category_name', c.category_name,
         'normalized_name', c.normalized_name,
         'description', c.description,
         'parent_id', c.parent_id,
         'category_level', c.category_level,
         'sort_order', c.sort_order,
         'is_deleted', c.is_deleted,
         'deleted_by', c.deleted_by,
         'deleted_date', c.deleted_date) END,
       @migration_user
FROM tmp_lead93_category_seed seed
LEFT JOIN iic_msg_email_category c ON c.category_code = seed.category_code
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'TAG_GROUP', seed.group_code,
       CASE WHEN g.id IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
       g.id, NULL,
       CASE WHEN g.id IS NULL THEN NULL ELSE JSON_OBJECT(
         'group_name', g.group_name,
         'is_mandatory', g.is_mandatory,
         'sort_order', g.sort_order,
         'status', g.status) END,
       @migration_user
FROM (
  SELECT 'CONTENT_TYPE' AS group_code
  UNION ALL SELECT 'TRIGGER'
  UNION ALL SELECT 'LIFECYCLE_STAGE'
  UNION ALL SELECT 'FINANCIAL_NEED'
  UNION ALL SELECT 'PROPOSITION'
  UNION ALL SELECT 'SOURCE'
) seed
LEFT JOIN iic_msg_tag_group g ON g.group_code = seed.group_code
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'TAG_VALUE', seed.tag_code,
       CASE WHEN v.id IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
       v.id, NULL,
       CASE WHEN v.id IS NULL THEN NULL ELSE JSON_OBJECT(
         'group_code', v.group_code,
         'tag_name', v.tag_name,
         'is_default', v.is_default,
         'sort_order', v.sort_order,
         'status', v.status) END,
       @migration_user
FROM (
  SELECT 'CONTENT_TYPE_UNCLASSIFIED' AS tag_code
  UNION ALL SELECT 'TRIGGER_UNCLASSIFIED'
  UNION ALL SELECT 'LIFECYCLE_STAGE_UNCLASSIFIED'
  UNION ALL SELECT 'FINANCIAL_NEED_UNCLASSIFIED'
) seed
LEFT JOIN iic_msg_tag_value v ON v.tag_code = seed.tag_code
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'CONFIG', CAST(c.id AS CHAR), 'UPDATE', c.id, c.email_code,
       JSON_OBJECT(
         'email_name', c.email_name,
         'description', c.description,
         'email_status', c.email_status,
         'status', c.status,
         'updated_by', c.updated_by,
         'updated_date', c.updated_date),
       @migration_user
FROM iic_msg_email_config c
JOIN tmp_lead93_template_mapping m ON m.email_code = c.email_code
WHERE c.status = 0
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'VERSION', CAST(v.id AS CHAR), 'UPDATE', v.id, v.email_code,
       JSON_OBJECT(
         'title', v.title,
         'category_id', v.category_id,
         'updated_by', v.updated_by,
         'updated_date', v.updated_date),
       @migration_user
FROM iic_msg_email_config_version v
JOIN (
  SELECT email_code, version FROM tmp_lead93_version_category_mapping
  UNION
  SELECT v2.email_code, v2.version
  FROM iic_msg_email_config_version v2
  JOIN tmp_lead93_template_mapping m2 ON m2.email_code = v2.email_code
  WHERE v2.version_status = 1 AND v2.status = 0 AND m2.new_subject IS NOT NULL
) target ON target.email_code = v.email_code AND target.version = v.version
WHERE v.status = 0
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'SUBCATEGORY_REL',
       CONCAT(m.email_code, '|', m.version, '|', m.subcategory_code),
       CASE WHEN r.id IS NULL THEN 'INSERT' ELSE 'UPDATE' END,
       r.id, m.email_code,
       CASE WHEN r.id IS NULL THEN NULL ELSE JSON_OBJECT('status', r.status) END,
       @migration_user
FROM tmp_lead93_subcategory_mapping m
LEFT JOIN iic_msg_email_category c ON c.category_code = m.subcategory_code AND c.category_level = 2
LEFT JOIN iic_msg_template_category_rel r
  ON r.email_code = m.email_code AND r.version = m.version AND r.subcategory_id = c.id
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'TAG_REL',
       CONCAT(r.email_code, '|', r.version, '|', r.group_code, '|', r.tag_code),
       'UPDATE', r.id, r.email_code,
       JSON_OBJECT('status', r.status),
       @migration_user
FROM iic_msg_template_tag_rel r
JOIN (SELECT DISTINCT email_code, version FROM tmp_lead93_tag_mapping) target
  ON target.email_code = r.email_code AND target.version = r.version
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

INSERT INTO iic_msg_template_migration_snapshot
  (source_batch_id, record_type, record_key, action_type, record_id, email_code, snapshot_json, created_by)
SELECT @migration_batch_id, 'TAG_REL',
       CONCAT(m.email_code, '|', m.version, '|', m.group_code, '|', m.tag_code),
       'INSERT', NULL, m.email_code, NULL, @migration_user
FROM tmp_lead93_tag_mapping m
LEFT JOIN iic_msg_template_tag_rel r
  ON r.email_code = m.email_code
 AND r.version = m.version
 AND r.group_code = m.group_code
 AND r.tag_code = m.tag_code
WHERE r.id IS NULL
ON DUPLICATE KEY UPDATE record_id = VALUES(record_id);

-- Release evidence: compare these counts with the approved staging/seed input
-- before running any business-table DML.
SELECT record_type, action_type, COUNT(*) AS record_count
FROM iic_msg_template_migration_snapshot
WHERE source_batch_id = @migration_batch_id
GROUP BY record_type, action_type
ORDER BY record_type, action_type;
