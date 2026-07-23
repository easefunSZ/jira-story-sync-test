-- LEAD-93 one-time Template migration release template.
--
-- This file is a GENERATOR TEMPLATE, not a deployable migration. After BA/PO
-- approves BUS-01, generate one immutable release file named:
--   V<release>__lead93_template_mapping_<approved_batch>.sql
--
-- The generated file must contain literal approved mapping rows in every CTE
-- below. It must not create temporary tables, read an uploaded Excel file,
-- depend on another SQL file's connection, or require external bind variables.
-- The Release Runner executes the generated file as one DML unit.

-- Generated-file constants. Replace these literals during generation.
SET @lead93_batch_id = 'LEAD93_APPROVED_BATCH';
SET @lead93_actor = 'LEAD93_MIGRATION';

-- The release tool owns FAILED handling. This row makes an interrupted release
-- visible as STARTED until the tool records FAILED, or this file reaches SUCCESS.
INSERT INTO iic_msg_template_migration_log
  (batch_id, execution_status, total_count, success_count, failed_count, executed_by)
VALUES
  (@lead93_batch_id, 'STARTED', 0, 0, 0, @lead93_actor)
ON DUPLICATE KEY UPDATE
  execution_status = 'STARTED', total_count = VALUES(total_count), success_count = 0,
  failed_count = 0, error_message = NULL, executed_by = VALUES(executed_by),
  started_date = CURRENT_TIMESTAMP, completed_date = NULL;

START TRANSACTION;

-- 1. Seed root Categories. There is no database unique key for active names,
-- so the generator first refreshes an existing active node, then inserts only
-- when no matching root exists.
WITH category_seed AS (
  SELECT '__ROOT_CATEGORY_NAME__' AS category_name, 10 AS sort_order
  -- UNION ALL SELECT 'Retirement', 20
)
UPDATE iic_msg_email_category category_node
JOIN category_seed s
  ON category_node.parent_id = 0
 AND category_node.is_deleted = 0
 AND LOWER(TRIM(category_node.category_name)) = LOWER(TRIM(s.category_name))
SET category_node.sort_order = s.sort_order,
    category_node.updated_by = @lead93_actor,
    category_node.updated_date = CURRENT_TIMESTAMP
WHERE s.category_name <> '__ROOT_CATEGORY_NAME__';

-- The generator emits one SELECT row per approved node.
WITH category_seed AS (
  SELECT '__ROOT_CATEGORY_NAME__' AS category_name, 10 AS sort_order
  -- UNION ALL SELECT 'Retirement', 20
)
INSERT INTO iic_msg_email_category
  (category_name, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_name, 0, s.sort_order, 0, @lead93_actor, @lead93_actor
FROM category_seed s
WHERE s.category_name <> '__ROOT_CATEGORY_NAME__'
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_email_category existing_node
    WHERE existing_node.parent_id = 0
      AND existing_node.is_deleted = 0
      AND LOWER(TRIM(existing_node.category_name)) = LOWER(TRIM(s.category_name))
  );

-- 2. Seed Subcategories. Parent IDs are resolved from the persisted Category
-- table in this same statement; no seed_key/category_id map is persisted.
WITH subcategory_seed AS (
  SELECT '__ROOT_CATEGORY_NAME__' AS parent_name,
         '__SUBCATEGORY_NAME__' AS category_name,
         10 AS sort_order
  -- UNION ALL SELECT 'Retirement', 'Retirement Planning', 20
)
UPDATE iic_msg_email_category child
JOIN iic_msg_email_category parent
  ON parent.id = child.parent_id
 AND parent.parent_id = 0
 AND parent.is_deleted = 0
JOIN subcategory_seed s
  ON LOWER(TRIM(parent.category_name)) = LOWER(TRIM(s.parent_name))
 AND LOWER(TRIM(child.category_name)) = LOWER(TRIM(s.category_name))
SET child.sort_order = s.sort_order,
    child.updated_by = @lead93_actor,
    child.updated_date = CURRENT_TIMESTAMP
WHERE child.is_deleted = 0
  AND s.parent_name <> '__ROOT_CATEGORY_NAME__';

WITH subcategory_seed AS (
  SELECT '__ROOT_CATEGORY_NAME__' AS parent_name,
         '__SUBCATEGORY_NAME__' AS category_name,
         10 AS sort_order
  -- UNION ALL SELECT 'Retirement', 'Retirement Planning', 20
)
INSERT INTO iic_msg_email_category
  (category_name, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_name, p.id, s.sort_order, 0, @lead93_actor, @lead93_actor
FROM subcategory_seed s
JOIN iic_msg_email_category p
  ON p.parent_id = 0
 AND p.is_deleted = 0
 AND LOWER(TRIM(p.category_name)) = LOWER(TRIM(s.parent_name))
WHERE s.parent_name <> '__ROOT_CATEGORY_NAME__'
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_email_category existing_node
    WHERE existing_node.parent_id = p.id
      AND existing_node.is_deleted = 0
      AND LOWER(TRIM(existing_node.category_name)) = LOWER(TRIM(s.category_name))
  );

-- 3. Update Template master fields and current main Category. One generated row
-- exists for every approved email_code. A migration must never infer a mapping
-- from email_name alone.
WITH template_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code,
         NULL AS new_email_name,
         NULL AS new_description,
         NULL AS new_subject,
         'KEEP' AS migration_action,
         NULL AS action_note,
         '__ROOT_CATEGORY_NAME__' AS category_name
  -- UNION ALL SELECT '123456', 'Approved Name', 'Approved description',
  --                  'Approved Subject', 'KEEP', NULL, 'Retirement'
)
UPDATE iic_msg_email_config c
JOIN template_mapping m ON m.email_code = c.email_code
JOIN iic_msg_email_category category_node
  ON category_node.parent_id = 0
 AND category_node.is_deleted = 0
 AND LOWER(TRIM(category_node.category_name)) = LOWER(TRIM(m.category_name))
SET c.email_name = COALESCE(NULLIF(m.new_email_name, ''), c.email_name),
    c.description = COALESCE(m.new_description, c.description),
    c.category_id = category_node.id,
    c.updated_by = @lead93_actor,
    c.updated_date = CURRENT_TIMESTAMP
WHERE c.status = 0
  AND m.email_code <> '__EMAIL_CODE__';

-- 4. Update the current published Version subject only when mapping provides it.
WITH template_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code, NULL AS new_subject
  -- UNION ALL SELECT '123456', 'Approved Subject'
)
UPDATE iic_msg_email_config_version v
JOIN template_mapping m ON m.email_code = v.email_code
SET v.title = m.new_subject,
    v.updated_by = @lead93_actor,
    v.updated_date = CURRENT_TIMESTAMP
WHERE v.version_status = 1
  AND v.status = 0
  AND m.new_subject IS NOT NULL
  AND m.email_code <> '__EMAIL_CODE__';

-- 5. Soft-replace current Subcategory relations. The generator writes all
-- approved rows directly; no cross-file staging data is required.
WITH subcategory_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code,
         '__ROOT_CATEGORY_NAME__' AS parent_name,
         '__SUBCATEGORY_NAME__' AS subcategory_name
  -- UNION ALL SELECT '123456', 'Retirement', 'Retirement Planning'
)
UPDATE iic_msg_template_category_rel r
JOIN (SELECT DISTINCT email_code FROM subcategory_mapping
      WHERE email_code <> '__EMAIL_CODE__') target ON target.email_code = r.email_code
SET r.status = -1, r.updated_by = @lead93_actor, r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

WITH subcategory_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code,
         '__ROOT_CATEGORY_NAME__' AS parent_name,
         '__SUBCATEGORY_NAME__' AS subcategory_name
  -- UNION ALL SELECT '123456', 'Retirement', 'Retirement Planning'
)
INSERT INTO iic_msg_template_category_rel
  (email_code, subcategory_id, status, created_by, updated_by)
SELECT m.email_code, child.id, 0, @lead93_actor, @lead93_actor
FROM subcategory_mapping m
JOIN iic_msg_email_config c
  ON c.email_code = m.email_code AND c.status = 0
JOIN iic_msg_email_category parent
  ON parent.parent_id = 0
 AND parent.is_deleted = 0
 AND LOWER(TRIM(parent.category_name)) = LOWER(TRIM(m.parent_name))
JOIN iic_msg_email_category child
  ON child.parent_id = parent.id
 AND child.is_deleted = 0
 AND LOWER(TRIM(child.category_name)) = LOWER(TRIM(m.subcategory_name))
WHERE m.email_code <> '__EMAIL_CODE__'
  AND c.category_id = parent.id
ON DUPLICATE KEY UPDATE
  status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- 6. Soft-replace current Tag relations.
WITH tag_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code,
         '__GROUP_CODE__' AS group_code,
         '__TAG_CODE__' AS tag_code
  -- UNION ALL SELECT '123456', 'CONTENT_TYPE', 'CONTENT_TYPE_EMAIL'
)
UPDATE iic_msg_template_tag_rel r
JOIN (SELECT DISTINCT email_code FROM tag_mapping
      WHERE email_code <> '__EMAIL_CODE__') target ON target.email_code = r.email_code
SET r.status = -1, r.updated_by = @lead93_actor, r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

WITH tag_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code,
         '__GROUP_CODE__' AS group_code,
         '__TAG_CODE__' AS tag_code
  -- UNION ALL SELECT '123456', 'CONTENT_TYPE', 'CONTENT_TYPE_EMAIL'
)
INSERT INTO iic_msg_template_tag_rel
  (email_code, group_code, tag_code, status, created_by, updated_by)
SELECT m.email_code, value_node.group_code, value_node.tag_code, 0,
       @lead93_actor, @lead93_actor
FROM tag_mapping m
JOIN iic_msg_email_config c
  ON c.email_code = m.email_code AND c.status = 0
JOIN iic_msg_tag_value value_node
  ON value_node.group_code = m.group_code
 AND value_node.tag_code = m.tag_code
 AND value_node.status = 0
WHERE m.email_code <> '__EMAIL_CODE__'
ON DUPLICATE KEY UPDATE
  group_code = VALUES(group_code), status = 0, updated_by = VALUES(updated_by),
  updated_date = CURRENT_TIMESTAMP;

-- 7. Apply only approved deactivation rows. The generator emits literal rows;
-- there is no release-time toggle and no inferred deactivation.
WITH deactivation_mapping AS (
  SELECT '__EMAIL_CODE__' AS email_code, '__ACTION_NOTE__' AS action_note
  -- UNION ALL SELECT '123456', 'Duplicate of email_code 987654'
)
UPDATE iic_msg_email_config c
JOIN deactivation_mapping m ON m.email_code = c.email_code
SET c.email_status = 0,
    c.description = CASE
      WHEN m.action_note IS NULL OR m.action_note = '' THEN c.description
      WHEN c.description IS NULL OR c.description = '' THEN m.action_note
      ELSE CONCAT(c.description, ' ', m.action_note)
    END,
    c.updated_by = @lead93_actor,
    c.updated_date = CURRENT_TIMESTAMP
WHERE c.status = 0
  AND m.email_code <> '__EMAIL_CODE__';

COMMIT;

-- The generator replaces 0 with the number of approved mapped email_code rows.
UPDATE iic_msg_template_migration_log
SET execution_status = 'SUCCESS', total_count = 0, success_count = 0,
    failed_count = 0, error_message = NULL, completed_date = CURRENT_TIMESTAMP
WHERE batch_id = @lead93_batch_id
  AND execution_status = 'STARTED';
