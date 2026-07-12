-- Pre-check before adding UNIQUE(flag, category_code).
SELECT flag, category_code, COUNT(*) AS cnt
FROM iic_msg_category_config
GROUP BY flag, category_code
HAVING COUNT(*) > 1;

-- Template Category tree.
SELECT
  c.id, c.category_code, c.category_name, c.description,
  c.parent_id, c.category_level, c.sort_order
FROM iic_msg_category_config c
WHERE c.flag = :template_category_flag
  AND c.is_deleted = 0
ORDER BY c.category_level, c.parent_id, c.sort_order, c.id;

-- Invalid two-level hierarchy; expected 0 rows.
SELECT c.id, c.category_code, c.category_level, c.parent_id
FROM iic_msg_category_config c
LEFT JOIN iic_msg_category_config p
  ON p.id = c.parent_id
 AND p.category_level = 1
 AND p.is_deleted = 0
WHERE c.flag = :template_category_flag
  AND c.is_deleted = 0
  AND (
    (c.category_level = 1 AND c.parent_id IS NOT NULL)
    OR (c.category_level = 2 AND p.id IS NULL)
  );

