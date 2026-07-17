-- Duplicate Template node codes; expected 0 rows.
SELECT category_code, COUNT(*) AS cnt
FROM iic_msg_email_category
WHERE category_level IN (1, 2)
GROUP BY category_code
HAVING COUNT(*) > 1;

-- Duplicate active Template node names after trim/case normalization;
-- expected 0 rows. Soft-deleted names may be reused.
SELECT LOWER(TRIM(category_name)) AS normalized_name, COUNT(*) AS cnt
FROM iic_msg_email_category
WHERE category_level IN (1, 2)
  AND is_deleted = 0
GROUP BY LOWER(TRIM(category_name))
HAVING COUNT(*) > 1;

-- Template Category tree.
SELECT
  c.id, c.category_code, c.category_name, c.description,
  c.parent_id, c.category_level, c.sort_order
FROM iic_msg_email_category c
WHERE c.category_level IN (1, 2)
  AND c.is_deleted = 0
ORDER BY c.category_level, c.parent_id, c.sort_order, c.id;

-- Runtime Batch Subcategory Create: lock and validate the active level-1
-- parent. The service separately rejects empty input, more than 5 items and
-- duplicate normalized names inside the request.
SELECT c.id, c.category_level, c.is_deleted
FROM iic_msg_email_category c
WHERE c.id = :parent_id
  AND c.category_level = 1
  AND c.is_deleted = 0
FOR UPDATE;

-- Runtime Batch Subcategory Create: expected 0 rows. The mapper expands the
-- submitted 1-5 normalized names. Name uniqueness is global among active
-- Template taxonomy nodes, not just within the parent.
SELECT c.id, c.category_name, c.category_level, c.parent_id
FROM iic_msg_email_category c
WHERE c.category_level IN (1, 2)
  AND c.is_deleted = 0
  AND c.normalized_name IN (LOWER(TRIM(:name_1)), LOWER(TRIM(:name_2)))
FOR UPDATE;

-- Invalid two-level hierarchy; expected 0 rows.
SELECT c.id, c.category_code, c.category_level, c.parent_id
FROM iic_msg_email_category c
LEFT JOIN iic_msg_email_category p
  ON p.id = c.parent_id
 AND p.category_level = 1
 AND p.is_deleted = 0
WHERE c.category_level IN (1, 2)
  AND c.is_deleted = 0
  AND (
    (c.category_level = 1 AND c.parent_id IS NOT NULL)
    OR (c.category_level = 2 AND p.id IS NULL)
  );

-- Runtime Reassign-and-Delete: lock the source node inside the service
-- transaction. For level 1, lock active direct children immediately after it.
SELECT c.id, c.category_level, c.parent_id, c.is_deleted
FROM iic_msg_email_category c
WHERE c.id = :source_category_id
  AND c.category_level IN (1, 2)
  AND c.is_deleted = 0
FOR UPDATE;

SELECT c.id, c.parent_id
FROM iic_msg_email_category c
WHERE c.parent_id = :source_category_id
  AND c.category_level = 2
  AND c.is_deleted = 0
ORDER BY c.id
FOR UPDATE;

-- Delete Impact API source summary. This is a non-locking UI preview.
SELECT src.id, src.category_level,
       COUNT(child.id) AS active_child_count
FROM iic_msg_email_category src
LEFT JOIN iic_msg_email_category child ON child.parent_id = src.id AND child.category_level = 2 AND child.is_deleted = 0
WHERE src.id = :source_category_id
  AND src.category_level IN (1, 2)
  AND src.is_deleted = 0
GROUP BY src.id, src.category_level;

-- Delete Impact API for a level-1 source. This is a non-locking UI preview;
-- the command must rerun the locking query before write.
SELECT COUNT(DISTINCT v.email_code) AS affected_template_count,
       COUNT(DISTINCT CONCAT(v.email_code, '|', v.version)) AS affected_version_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 1 THEN CONCAT(v.email_code, '|', v.version) END) AS active_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 3 THEN CONCAT(v.email_code, '|', v.version) END) AS draft_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 0 THEN CONCAT(v.email_code, '|', v.version) END) AS schedule_count
FROM iic_msg_email_config_version v
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
LEFT JOIN iic_msg_template_category_rel r ON r.email_code = v.email_code AND r.version = v.version AND r.status = 0
LEFT JOIN iic_msg_email_category s ON s.id = r.subcategory_id AND s.category_level = 2
WHERE v.status = 0
  AND v.version_status IN (0, 1, 3)
  AND (v.category_id = :source_category_id OR s.parent_id = :source_category_id);

-- Delete Impact API for a level-2 source.
SELECT COUNT(DISTINCT v.email_code) AS affected_template_count,
       COUNT(DISTINCT CONCAT(v.email_code, '|', v.version)) AS affected_version_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 1 THEN CONCAT(v.email_code, '|', v.version) END) AS active_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 3 THEN CONCAT(v.email_code, '|', v.version) END) AS draft_count,
       COUNT(DISTINCT CASE WHEN v.version_status = 0 THEN CONCAT(v.email_code, '|', v.version) END) AS schedule_count
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version v ON v.email_code = r.email_code AND v.version = r.version AND v.status = 0 AND v.version_status IN (0, 1, 3)
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
WHERE r.subcategory_id = :source_subcategory_id
  AND r.status = 0;

-- Lock and validate the requested target Category and Subcategories. Target
-- nodes cannot be the source or a child of a level-1 source. For a level-2
-- delete, every target Subcategory must share the source parent.
SELECT c.id, c.category_level, c.parent_id
FROM iic_msg_email_category c
WHERE c.id IN (:target_category_id, :target_subcategory_id_1, :target_subcategory_id_2)
  AND c.category_level IN (1, 2)
  AND c.is_deleted = 0
ORDER BY c.id
FOR UPDATE;

-- Level-1 source: lock every live Active/Draft/Schedule version whose main
-- Category or Subcategory relation belongs to the source subtree. This result
-- becomes the immutable affected-version list used by the DML transaction.
SELECT DISTINCT v.email_code, v.version, v.version_status
FROM iic_msg_email_config_version v
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
LEFT JOIN iic_msg_template_category_rel r ON r.email_code = v.email_code AND r.version = v.version AND r.status = 0
LEFT JOIN iic_msg_email_category s ON s.id = r.subcategory_id AND s.category_level = 2
WHERE v.status = 0
  AND v.version_status IN (0, 1, 3)
  AND (v.category_id = :source_category_id OR s.parent_id = :source_category_id)
ORDER BY v.email_code, v.version
FOR UPDATE;

-- Level-2 source: lock every live Active/Draft/Schedule version that has the
-- source Subcategory relation. Main Category remains unchanged.
SELECT DISTINCT v.email_code, v.version, v.version_status
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version v ON v.email_code = r.email_code AND v.version = r.version AND v.status = 0 AND v.version_status IN (0, 1, 3)
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
WHERE r.subcategory_id = :source_subcategory_id
  AND r.status = 0
ORDER BY v.email_code, v.version
FOR UPDATE;

-- Deleted taxonomy nodes referenced by non-Expired live versions indicate an
-- incomplete Reassign-and-Delete or relation race; expected 0 rows. Expired
-- references are intentionally retained.
SELECT v.email_code, v.version, v.version_status, v.category_id
FROM iic_msg_email_config_version v
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
JOIN iic_msg_email_category n ON n.id = v.category_id AND n.is_deleted = 1
WHERE v.status = 0
  AND v.version_status IN (0, 1, 3);

-- Deleted Subcategory nodes referenced by non-Expired live versions indicate
-- an incomplete Reassign-and-Delete or relation race; expected 0 rows.
SELECT v.email_code, v.version, v.version_status, r.subcategory_id
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version v
  ON v.email_code = r.email_code
 AND v.version = r.version
 AND v.status = 0
 AND v.version_status IN (0, 1, 3)
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
JOIN iic_msg_email_category n ON n.id = r.subcategory_id AND n.is_deleted = 1
WHERE r.status = 0;
