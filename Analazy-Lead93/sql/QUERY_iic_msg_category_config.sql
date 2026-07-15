-- Duplicate Template node codes before adding the generated unique key;
-- expected 0 rows. Existing category_level NULL rows are outside LEAD-93.
SELECT category_code, COUNT(*) AS cnt
FROM iic_msg_category_config
WHERE category_level IN (1, 2)
GROUP BY category_code
HAVING COUNT(*) > 1;

-- Duplicate active Template node names after trim/case normalization;
-- expected 0 rows. Soft-deleted names may be reused.
SELECT LOWER(TRIM(category_name)) AS normalized_name, COUNT(*) AS cnt
FROM iic_msg_category_config
WHERE category_level IN (1, 2)
  AND is_deleted = 0
GROUP BY LOWER(TRIM(category_name))
HAVING COUNT(*) > 1;

-- Template Category tree.
SELECT
  c.id, c.category_code, c.category_name, c.description,
  c.parent_id, c.category_level, c.sort_order
FROM iic_msg_category_config c
WHERE c.category_level IN (1, 2)
  AND c.is_deleted = 0
ORDER BY c.category_level, c.parent_id, c.sort_order, c.id;

-- Invalid two-level hierarchy; expected 0 rows.
SELECT c.id, c.category_code, c.category_level, c.parent_id
FROM iic_msg_category_config c
LEFT JOIN iic_msg_category_config p
  ON p.id = c.parent_id
 AND p.category_level = 1
 AND p.is_deleted = 0
WHERE c.category_level IN (1, 2)
  AND c.is_deleted = 0
  AND (
    (c.category_level = 1 AND c.parent_id IS NOT NULL)
    OR (c.category_level = 2 AND p.id IS NULL)
  );

-- Runtime Category Delete: lock target node inside the service transaction.
SELECT c.id, c.category_level, c.parent_id, c.is_deleted
FROM iic_msg_category_config c
WHERE c.id = :category_id
  AND c.category_level IN (1, 2)
  AND c.is_deleted = 0
FOR UPDATE;

-- Runtime Category Delete: enumerate active direct children for the eventual
-- same-transaction cascade. Children alone do not block parent deletion.
SELECT COUNT(*) AS active_child_count
FROM iic_msg_category_config c
WHERE c.parent_id = :category_id
  AND c.category_level = 2
  AND c.is_deleted = 0;

-- Runtime Category Delete: blocking main Category references.
SELECT COUNT(DISTINCT m.email_code) AS main_category_reference_count
FROM iic_msg_email_config_version m
JOIN iic_msg_email_config c
  ON c.email_code = m.email_code
 AND c.status = 0
WHERE m.category_id = :category_id
  AND m.status = 0
  AND m.version_status IN (0, 1, 3);

-- Runtime Category/Subcategory Delete: blocking Subcategory references. For a
-- level-1 target this includes all direct children; for level 2, only itself.
SELECT COUNT(DISTINCT r.email_code) AS subcategory_reference_count
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version v
  ON v.email_code = r.email_code
 AND v.version = r.version
 AND v.status = 0
 AND v.version_status IN (0, 1, 3)
JOIN iic_msg_email_config c
  ON c.email_code = r.email_code
 AND c.status = 0
JOIN iic_msg_category_config s
  ON s.id = r.subcategory_id
 AND s.category_level = 2
WHERE r.status = 0
  AND (r.subcategory_id = :category_id OR s.parent_id = :category_id);

-- Deleted taxonomy nodes referenced by non-Expired live versions indicate an
-- invalid delete or relation race; expected 0 rows. Expired references are valid.
SELECT v.email_code, v.version, v.version_status, v.category_id
FROM iic_msg_email_config_version v
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
JOIN iic_msg_category_config n ON n.id = v.category_id AND n.is_deleted = 1
WHERE v.status = 0
  AND v.version_status IN (0, 1, 3);

-- Deleted Subcategory nodes referenced by non-Expired live versions indicate
-- an invalid delete or relation race; expected 0 rows.
SELECT v.email_code, v.version, v.version_status, r.subcategory_id
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version v
  ON v.email_code = r.email_code
 AND v.version = r.version
 AND v.status = 0
 AND v.version_status IN (0, 1, 3)
JOIN iic_msg_email_config c ON c.email_code = v.email_code AND c.status = 0
JOIN iic_msg_category_config n ON n.id = r.subcategory_id AND n.is_deleted = 1
WHERE r.status = 0;
