-- Duplicate active node names; expected 0 rows. The database does not enforce
-- this rule; the Service runs the same active-name check before create/rename.
SELECT LOWER(TRIM(category_name)) AS comparison_name, COUNT(*) AS cnt
FROM iic_msg_email_category
WHERE is_deleted = 0
GROUP BY LOWER(TRIM(category_name))
HAVING COUNT(*) > 1;

-- Template Category tree. category_level is a derived API field.
SELECT c.id, c.category_name, c.description, c.parent_id,
       CASE WHEN c.parent_id IS NULL THEN 1 ELSE 2 END AS category_level,
       c.sort_order
FROM iic_msg_email_category c
WHERE c.is_deleted = 0
ORDER BY CASE WHEN c.parent_id IS NULL THEN 1 ELSE 2 END, c.parent_id, c.sort_order, c.id;

-- Batch Subcategory Create: lock and validate an active level-1 parent.
SELECT c.id, c.parent_id, c.is_deleted
FROM iic_msg_email_category c
WHERE c.id = :parent_id AND c.parent_id IS NULL AND c.is_deleted = 0
FOR UPDATE;

-- Expected 0 rows. The mapper expands 1-5 submitted names. Active-name
-- uniqueness is a Service rule, not a database unique constraint.
SELECT c.id, c.category_name, c.parent_id
FROM iic_msg_email_category c
WHERE c.is_deleted = 0
  AND LOWER(TRIM(c.category_name)) IN (LOWER(TRIM(:name_1)), LOWER(TRIM(:name_2)))
FOR UPDATE;

-- Reorder: lock the complete active sibling set in deterministic ID order.
-- The Service compares this result with ordered_category_ids as an exact set;
-- a missing/new/deleted node means the client order is stale and must fail.
SELECT c.id, c.parent_id, c.sort_order
FROM iic_msg_email_category c
WHERE c.parent_id <=> :parent_id AND c.is_deleted = 0
ORDER BY c.id
FOR UPDATE;

-- Invalid hierarchy; expected 0 rows. A child must reference an active root.
SELECT c.id, c.parent_id
FROM iic_msg_email_category c
LEFT JOIN iic_msg_email_category p ON p.id = c.parent_id AND p.parent_id IS NULL AND p.is_deleted = 0
WHERE c.is_deleted = 0 AND c.parent_id IS NOT NULL AND p.id IS NULL;

-- Reassign-and-Delete: lock source and direct children.
SELECT c.id, c.parent_id, c.is_deleted
FROM iic_msg_email_category c
WHERE c.id = :source_category_id AND c.is_deleted = 0
FOR UPDATE;

SELECT c.id, c.parent_id
FROM iic_msg_email_category c
WHERE c.parent_id = :source_category_id AND c.is_deleted = 0
ORDER BY c.id
FOR UPDATE;

-- Delete Impact source summary. category_level is derived from parent_id.
SELECT src.id, CASE WHEN src.parent_id IS NULL THEN 1 ELSE 2 END AS category_level,
       COUNT(child.id) AS active_child_count
FROM iic_msg_email_category src
LEFT JOIN iic_msg_email_category child ON child.parent_id = src.id AND child.is_deleted = 0
WHERE src.id = :source_category_id AND src.is_deleted = 0
GROUP BY src.id, src.parent_id;

-- Delete Impact for a level-1 source. Counts are Template counts; one Template
-- may contribute to more than one lifecycle count when Active and Draft coexist.
SELECT COUNT(DISTINCT template.email_code) AS affected_template_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 1 THEN template.email_code END) AS active_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 3 THEN template.email_code END) AS draft_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 0 THEN template.email_code END) AS schedule_count
FROM iic_msg_email_config template
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
LEFT JOIN iic_msg_template_category_rel relation ON relation.email_code = template.email_code AND relation.status = 0
LEFT JOIN iic_msg_email_category subcategory ON subcategory.id = relation.subcategory_id
WHERE template.status = 0
  AND (template.category_id = :source_category_id OR subcategory.parent_id = :source_category_id);

-- Delete Impact for a level-2 source.
SELECT COUNT(DISTINCT template.email_code) AS affected_template_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 1 THEN template.email_code END) AS active_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 3 THEN template.email_code END) AS draft_count,
       COUNT(DISTINCT CASE WHEN version.version_status = 0 THEN template.email_code END) AS schedule_count
FROM iic_msg_template_category_rel relation
JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
WHERE relation.subcategory_id = :source_subcategory_id AND relation.status = 0;

-- Lock target Category/Subcategories. The Service derives each node's level
-- from parent_id and validates source/target hierarchy rules.
SELECT c.id, c.parent_id
FROM iic_msg_email_category c
WHERE c.id IN (:target_category_id, :target_subcategory_id_1, :target_subcategory_id_2)
  AND c.is_deleted = 0
ORDER BY c.id
FOR UPDATE;

-- Freeze affected Templates for a level-1 source. The Service then locks the
-- returned iic_msg_email_config rows in deterministic email_code order.
SELECT DISTINCT template.email_code
FROM iic_msg_email_config template
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
LEFT JOIN iic_msg_template_category_rel relation ON relation.email_code = template.email_code AND relation.status = 0
LEFT JOIN iic_msg_email_category subcategory ON subcategory.id = relation.subcategory_id
WHERE template.status = 0
  AND (template.category_id = :source_category_id OR subcategory.parent_id = :source_category_id)
ORDER BY template.email_code;

-- Freeze affected Templates for a level-2 source.
SELECT DISTINCT template.email_code
FROM iic_msg_template_category_rel relation
JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
WHERE relation.subcategory_id = :source_subcategory_id AND relation.status = 0
ORDER BY template.email_code;

-- Deleted nodes referenced by current Metadata of a Template with an
-- Active/Draft/Schedule version indicate an incomplete transaction.
SELECT DISTINCT template.email_code, template.category_id
FROM iic_msg_email_config template
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
JOIN iic_msg_email_category node ON node.id = template.category_id AND node.is_deleted = 1
WHERE template.status = 0;

SELECT DISTINCT relation.email_code, relation.subcategory_id
FROM iic_msg_template_category_rel relation
JOIN iic_msg_email_config template ON template.email_code = relation.email_code AND template.status = 0
JOIN iic_msg_email_config_version version ON version.email_code = template.email_code AND version.status = 0 AND version.version_status IN (0, 1, 3)
JOIN iic_msg_email_category node ON node.id = relation.subcategory_id AND node.is_deleted = 1
WHERE relation.status = 0;
