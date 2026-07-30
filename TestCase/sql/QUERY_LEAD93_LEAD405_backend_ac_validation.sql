-- LEAD-93 / LEAD-405 backend AC validation (read-only)
--
-- Usage:
-- 1. Run the Postman collection LEAD-93-405-backend-ac.postman_collection.json.
-- 2. Copy runtime values from the exported Newman environment/report into the
--    parameters below. This script performs no DDL/DML and is safe in QA.
-- 3. Run the numbered sections after the corresponding API step. Expected
--    results are documented before each query.

SET @active_email_code = 'REPLACE_WITH_acActiveEmailCode';
SET @draft_email_code = 'REPLACE_WITH_acDraftEmailCode';
SET @copy_email_code = 'REPLACE_WITH_acCopyEmailCode';
SET @source_category_id = 0; -- acSourceCategoryId
SET @target_category_id = 0; -- acTargetCategoryId
SET @recreated_category_id = 0; -- acRecreatedCategoryId
SET @invalid_publish_name = 'REPLACE_WITH_acInvalidPublishName';
SET @invalid_batch_name = 'REPLACE_WITH_acInvalidBatchName';

-- 01. EX-05 valid Draft / Active creation.
-- Expected: one current config row for each code; Draft V1 has version_status=3;
-- Active Template has exactly one current Active Version before V2 publish.
SELECT c.email_code, c.email_name, c.description, c.category_id,
       c.status AS config_status, c.email_status,
       v.version, v.version_status, v.status AS version_row_status,
       v.effective_from, v.effective_until
FROM iic_msg_email_config c
LEFT JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
WHERE c.email_code IN (@active_email_code, @draft_email_code)
ORDER BY c.email_code, CAST(SUBSTRING(v.version, 2) AS UNSIGNED);

-- 02. EX-05 invalid publish aggregate validation rollback.
-- Expected: zero rows. A fieldErrors response must not leave config or version rows.
SELECT c.email_code, c.email_name, c.status, v.version, v.version_status, v.status AS version_row_status
FROM iic_msg_email_config c
LEFT JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
WHERE c.email_name = @invalid_publish_name;

-- 03. LEAD-277 / LEAD-301 / LEAD-276 current Category and Subcategory metadata.
-- Run after EX-06 / NEW-11 / NEW-12. Expected: one active main Category equal
-- to @target_category_id and active Subcategory relations only under that parent.
SELECT c.email_code, c.category_id, main_node.category_name AS category_name,
       rel.subcategory_id, sub_node.category_name AS subcategory_name,
       sub_node.parent_id, rel.status AS relation_status
FROM iic_msg_email_config c
LEFT JOIN iic_msg_email_category main_node ON main_node.id = c.category_id
LEFT JOIN iic_msg_email_template_category_rel rel
  ON rel.email_code = c.email_code AND rel.status = 0
LEFT JOIN iic_msg_email_category sub_node ON sub_node.id = rel.subcategory_id
WHERE c.email_code = @active_email_code
ORDER BY rel.subcategory_id;

-- 04. Current Template Tag metadata and taxonomy integrity.
-- Expected: four mandatory groups exist; the selected multi-value group contains
-- at least two active values after Postman step 24; no inactive/mismatched tag.
SELECT rel.email_code, rel.group_code, rel.tag_code,
       grp.is_mandatory, grp.status AS group_status,
       val.tag_name, val.status AS value_status
FROM iic_msg_email_template_tag_rel rel
JOIN iic_msg_email_tag_group grp ON grp.group_code = rel.group_code
JOIN iic_msg_email_tag_value val
  ON val.group_code = rel.group_code AND val.tag_code = rel.tag_code
WHERE rel.email_code = @active_email_code
  AND rel.status = 0
ORDER BY rel.group_code, rel.tag_code;

-- 05. Metadata uniqueness and parent consistency.
-- Expected: both queries return zero rows.
SELECT email_code, subcategory_id, COUNT(*) AS duplicate_count
FROM iic_msg_email_template_category_rel
WHERE status = 0 AND email_code = @active_email_code
GROUP BY email_code, subcategory_id
HAVING COUNT(*) > 1;

SELECT rel.email_code, rel.subcategory_id, sub_node.parent_id, c.category_id
FROM iic_msg_email_template_category_rel rel
JOIN iic_msg_email_config c ON c.email_code = rel.email_code AND c.status = 0
LEFT JOIN iic_msg_email_category sub_node
  ON sub_node.id = rel.subcategory_id AND sub_node.is_deleted = 0
WHERE rel.status = 0
  AND rel.email_code = @active_email_code
  AND (sub_node.id IS NULL OR sub_node.parent_id <> c.category_id);

SELECT email_code, group_code, tag_code, COUNT(*) AS duplicate_count
FROM iic_msg_email_template_tag_rel
WHERE status = 0 AND email_code = @active_email_code
GROUP BY email_code, group_code, tag_code
HAVING COUNT(*) > 1;

-- 06. Copy and Create independence.
-- Run before Postman discards the copy. Expected: two distinct email_code values;
-- B points to A through copy_from_email_code, and B V1 is Draft.
SELECT c.email_code, c.email_name, c.copy_from_email_code, c.status, c.email_status,
       v.version, v.version_status, v.status AS version_row_status
FROM iic_msg_email_config c
LEFT JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
WHERE c.email_code IN (@active_email_code, @copy_email_code)
ORDER BY c.email_code, CAST(SUBSTRING(v.version, 2) AS UNSIGNED);

-- 07. Version lifecycle after EX-09 / EX-10 Schedule, Cancel Schedule and Publish.
-- Expected after final publish: exactly one current Active Version (V2), V1 is
-- current Expired, and no current Schedule/Draft exists for the active Template.
SELECT v.email_code, v.version, v.version_status, v.status,
       v.effective_from, v.effective_until, v.title
FROM iic_msg_email_config_version v
WHERE v.email_code = @active_email_code
ORDER BY CAST(SUBSTRING(v.version, 2) AS UNSIGNED);

SELECT email_code,
       SUM(CASE WHEN status = 0 AND version_status = 1 THEN 1 ELSE 0 END) AS active_versions,
       SUM(CASE WHEN status = 0 AND version_status = 0 THEN 1 ELSE 0 END) AS scheduled_versions,
       SUM(CASE WHEN status = 0 AND version_status = 3 THEN 1 ELSE 0 END) AS draft_versions
FROM iic_msg_email_config_version
WHERE email_code = @active_email_code
GROUP BY email_code;

-- 08. NEW-02 atomic aggregate-create assertion.
-- Expected: zero rows. An invalid aggregate request must never create its otherwise-valid item.
SELECT id, category_name, parent_id, is_deleted, created_date
FROM iic_msg_email_category
WHERE category_name = @invalid_batch_name;

-- 09. NEW-12 delete/reassign outcome.
-- Expected after Step 51: Source root and all source children are soft deleted;
-- active Template current metadata is moved to Target; no active relation points
-- at a deleted node.
SELECT id, category_name, parent_id, sort_order, is_deleted, deleted_by, deleted_date
FROM iic_msg_email_category
WHERE id = @source_category_id OR parent_id = @source_category_id
ORDER BY parent_id, id;

SELECT c.email_code, c.category_id, rel.subcategory_id
FROM iic_msg_email_config c
LEFT JOIN iic_msg_email_template_category_rel rel
  ON rel.email_code = c.email_code AND rel.status = 0
WHERE c.email_code = @active_email_code;

SELECT c.email_code, c.category_id, node.is_deleted AS category_deleted
FROM iic_msg_email_config c
JOIN iic_msg_email_category node ON node.id = c.category_id
WHERE c.email_code = @active_email_code
  AND c.status = 0;

-- 10. Soft-delete name reuse.
-- Expected: @recreated_category_id is active after its create call, proving that
-- uniqueness applies to active nodes only. Run before cleanup.
SELECT id, category_name, parent_id, is_deleted, created_by, created_date
FROM iic_msg_email_category
WHERE id = @recreated_category_id;

-- 11. Required operational history where deployed.
-- Expected after create/update/reassign/delete: relevant rows exist. The schema
-- uses iic_msg_email_config_log in the current SQL package; if this table has
-- not yet been deployed, record the environment gap rather than treating the
-- API assertion as failed.
SELECT email_code, log_type, operation_id, operator, created_date,
       change_summary
FROM iic_msg_email_config_log
WHERE email_code IN (@active_email_code, @draft_email_code, @copy_email_code)
ORDER BY created_date, id;

SELECT category_id, change_type, operation_id, changed_by, changed_date
FROM iic_msg_email_category_change_history
WHERE category_id IN (@source_category_id, @target_category_id, @recreated_category_id)
ORDER BY changed_date, id;

-- 12. Final cleanup verification.
-- Run after Postman cleanup. Expected: active config/relations for test IDs are
-- absent; Category rows can remain but must be soft-deleted.
SELECT c.email_code, c.email_name, c.status, c.email_status
FROM iic_msg_email_config c
WHERE c.email_code IN (@active_email_code, @draft_email_code, @copy_email_code);

SELECT rel.email_code, rel.subcategory_id, rel.status
FROM iic_msg_email_template_category_rel rel
WHERE rel.email_code IN (@active_email_code, @draft_email_code, @copy_email_code)
  AND rel.status = 0;

SELECT rel.email_code, rel.group_code, rel.tag_code, rel.status
FROM iic_msg_email_template_tag_rel rel
WHERE rel.email_code IN (@active_email_code, @draft_email_code, @copy_email_code)
  AND rel.status = 0;
