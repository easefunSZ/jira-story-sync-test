-- LEAD-93 runtime mapper templates for atomic Category/Subcategory
-- Reassign-and-Delete. This is not a deployment migration script.
--
-- The service first runs the locking/affected-version queries in
-- QUERY_iic_msg_email_category.sql. It then freezes that email_code + version
-- list for the transaction and expands each derived table below, for example:
--   SELECT :email_code_1 AS email_code, :version_1 AS version
--   UNION ALL SELECT :email_code_2, :version_2
-- Active/Draft/Schedule are migrated; Expired and soft-deleted versions are
-- intentionally absent. Tag relations and version_status are never changed.

-- Level-1 delete, step 1: replace the main Category for every affected version.
UPDATE iic_msg_email_config_version v
JOIN (
  SELECT :email_code_1 AS email_code, :version_1 AS version
  UNION ALL SELECT :email_code_2, :version_2
) a ON a.email_code = v.email_code AND a.version = v.version
SET v.category_id = :target_category_id, v.updated_by = :operator, v.updated_date = CURRENT_TIMESTAMP
WHERE v.status = 0 AND v.version_status IN (0, 1, 3) AND v.category_id = :source_category_id;

-- Require matched/affected rows = affected version count for a level-1 delete.

-- Level-1 delete, step 2: remove the complete old Subcategory snapshot for the
-- affected versions. It will be replaced with the submitted target snapshot.
UPDATE iic_msg_template_category_rel r
JOIN (
  SELECT :email_code_1 AS email_code, :version_1 AS version
  UNION ALL SELECT :email_code_2, :version_2
) a ON a.email_code = r.email_code AND a.version = r.version
SET r.status = -1, r.updated_by = :operator, r.updated_date = CURRENT_TIMESTAMP
WHERE r.status = 0;

-- Level-2 delete: remove only the source Subcategory. Existing valid sibling
-- Subcategories remain. The target Subcategory must share the original parent.
UPDATE iic_msg_template_category_rel r
JOIN (
  SELECT :email_code_1 AS email_code, :version_1 AS version
  UNION ALL SELECT :email_code_2, :version_2
) a ON a.email_code = r.email_code AND a.version = r.version
SET r.status = -1, r.updated_by = :operator, r.updated_date = CURRENT_TIMESTAMP
WHERE r.subcategory_id = :source_subcategory_id AND r.status = 0;

-- Both levels: insert the approved target Subcategory snapshot. The mapper
-- expands the Cartesian product of affected versions and unique submitted
-- target_subcategory_ids. For level 1 this is the full replacement set; for
-- level 2 these rows are added while untouched siblings remain active.
INSERT INTO iic_msg_template_category_rel (email_code, version, subcategory_id, status, created_by, updated_by)
VALUES (:email_code_1, :version_1, :target_subcategory_id_1, 0, :operator, :operator),
       (:email_code_1, :version_1, :target_subcategory_id_2, 0, :operator, :operator),
       (:email_code_2, :version_2, :target_subcategory_id_1, 0, :operator, :operator)
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- The VALUES tuples are illustrative. The service must validate the exact
-- expected relation set after this statement and roll back on any mismatch.

-- Final step after all version Metadata checks pass: soft-delete the source
-- node. A level-1 delete also soft-deletes all active direct children.
UPDATE iic_msg_email_category
SET is_deleted = 1, deleted_by = :operator, deleted_date = CURRENT_TIMESTAMP, updated_by = :operator, updated_date = CURRENT_TIMESTAMP
WHERE (id = :source_category_id OR parent_id = :source_category_id)
  AND category_level IN (1, 2)
  AND is_deleted = 0;

-- For a level-2 delete bind source_category_id to the Subcategory id; because
-- level-2 nodes cannot have children, only that row is updated. Require the
-- exact source-node count captured while locking; zero rows is a conflict.
