-- LEAD-93 / LEAD-405 automated backend AC database assertions (read-only).
--
-- This is a template consumed by run-db-ac-checks.mjs. The runner prefixes
-- runtime SET variables from the Newman exported environment and executes only
-- the named CHECKPOINT after its matching API phase.
--
-- Every statement returns: check_id, result (PASS/FAIL), evidence.

-- CHECKPOINT: template_metadata
SELECT 'DB-01 Draft V1 is persisted as Draft' AS check_id,
       CASE WHEN EXISTS (SELECT 1 FROM iic_msg_email_config c JOIN iic_msg_email_config_version v ON v.email_code = c.email_code WHERE c.email_code = @draft_email_code AND c.status = 0 AND v.version = 'V1' AND v.status = 0 AND v.version_status = 3) THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('draft=', @draft_email_code) AS evidence;

SELECT 'DB-02 Published V1 is the only Active Version before lifecycle' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config_version WHERE email_code = @active_email_code AND status = 0 AND version = 'V1' AND version_status = 1) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('active=', @active_email_code) AS evidence;

SELECT 'DB-03 Invalid Publish does not create rows' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config WHERE email_name = @invalid_publish_name) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('invalidName=', @invalid_publish_name) AS evidence;

SELECT 'DB-04 Current Category and Subcategory relations are valid' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config c JOIN iic_msg_email_template_category_rel r ON r.email_code = c.email_code AND r.status = 0 JOIN iic_msg_email_category s ON s.id = r.subcategory_id AND s.is_deleted = 0 WHERE c.email_code = @active_email_code AND c.category_id = @target_category_id AND s.parent_id = c.category_id) >= 2 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code, ', targetCategory=', @target_category_id) AS evidence;

SELECT 'DB-05 Current Tag relations contain all four mandatory groups' AS check_id,
       CASE WHEN (SELECT COUNT(DISTINCT r.group_code) FROM iic_msg_email_template_tag_rel r JOIN iic_msg_email_tag_group g ON g.group_code = r.group_code AND g.status = 0 AND g.is_mandatory = 1 WHERE r.email_code = @active_email_code AND r.status = 0) = 4 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code) AS evidence;

SELECT 'DB-06 Current Metadata relations are deduplicated and parent-consistent' AS check_id,
       CASE WHEN NOT EXISTS (SELECT 1 FROM iic_msg_email_template_category_rel r WHERE r.email_code = @active_email_code AND r.status = 0 GROUP BY r.email_code, r.subcategory_id HAVING COUNT(*) > 1)
                   AND NOT EXISTS (SELECT 1 FROM iic_msg_email_template_tag_rel r WHERE r.email_code = @active_email_code AND r.status = 0 GROUP BY r.email_code, r.group_code, r.tag_code HAVING COUNT(*) > 1)
                   AND NOT EXISTS (SELECT 1 FROM iic_msg_email_template_category_rel r JOIN iic_msg_email_config c ON c.email_code = r.email_code AND c.status = 0 LEFT JOIN iic_msg_email_category s ON s.id = r.subcategory_id AND s.is_deleted = 0 WHERE r.email_code = @active_email_code AND r.status = 0 AND (s.id IS NULL OR s.parent_id <> c.category_id)) THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code) AS evidence;

SELECT 'DB-07 Invalid Subcategory batch is atomic' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_category WHERE category_name = @invalid_batch_name) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('invalidBatchName=', @invalid_batch_name) AS evidence;

-- CHECKPOINT: copy
SELECT 'DB-08 Copy is an independent V1 Draft with source linkage' AS check_id,
       CASE WHEN EXISTS (SELECT 1 FROM iic_msg_email_config c JOIN iic_msg_email_config_version v ON v.email_code = c.email_code WHERE c.email_code = @copy_email_code AND c.email_code <> @active_email_code AND c.copy_from_email_code = @active_email_code AND c.status = 0 AND v.version = 'V1' AND v.status = 0 AND v.version_status = 3) THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('copy=', @copy_email_code, ', source=', @active_email_code) AS evidence;

SELECT 'DB-09 Copy does not change source Active Version or status' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config_version WHERE email_code = @active_email_code AND version = 'V1' AND status = 0 AND version_status = 1) = 1
                   AND (SELECT email_status FROM iic_msg_email_config WHERE email_code = @active_email_code AND status = 0) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('source=', @active_email_code) AS evidence;

-- CHECKPOINT: lifecycle
SELECT 'DB-10 Publish promotes V2 and expires V1' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config_version WHERE email_code = @active_email_code AND version = @v2_version AND status = 0 AND version_status = 1) = 1
                   AND (SELECT COUNT(*) FROM iic_msg_email_config_version WHERE email_code = @active_email_code AND version = 'V1' AND status = 0 AND version_status = 2) = 1 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code, ', v2=', @v2_version) AS evidence;

SELECT 'DB-11 Final lifecycle has no current Draft or Schedule' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config_version WHERE email_code = @active_email_code AND status = 0 AND version_status IN (0, 3)) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code) AS evidence;

-- CHECKPOINT: reassignment
SELECT 'DB-12 Source Category and descendants are soft-deleted' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_category WHERE id = @source_category_id OR parent_id = @source_category_id) > 0
                   AND (SELECT COUNT(*) FROM iic_msg_email_category WHERE (id = @source_category_id OR parent_id = @source_category_id) AND is_deleted = 0) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('sourceCategory=', @source_category_id) AS evidence;

SELECT 'DB-13 Reassignment moves current Template to Target without deleted relations' AS check_id,
       CASE WHEN (SELECT category_id FROM iic_msg_email_config WHERE email_code = @active_email_code AND status = 0) = @target_category_id
                   AND EXISTS (SELECT 1 FROM iic_msg_email_template_category_rel r JOIN iic_msg_email_category s ON s.id = r.subcategory_id AND s.is_deleted = 0 WHERE r.email_code = @active_email_code AND r.status = 0 AND s.parent_id = @target_category_id)
                   AND NOT EXISTS (SELECT 1 FROM iic_msg_email_template_category_rel r JOIN iic_msg_email_category s ON s.id = r.subcategory_id WHERE r.email_code = @active_email_code AND r.status = 0 AND s.is_deleted = 1) THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('template=', @active_email_code, ', targetCategory=', @target_category_id) AS evidence;

SELECT 'DB-14 Soft-deleted name can be recreated as an active Category' AS check_id,
       CASE WHEN EXISTS (SELECT 1 FROM iic_msg_email_category WHERE id = @recreated_category_id AND is_deleted = 0) THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('recreatedCategory=', @recreated_category_id) AS evidence;

-- CHECKPOINT: cleanup
SELECT 'DB-15 Cleanup soft-deletes all temporary Templates' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_config WHERE email_code IN (@active_email_code, @draft_email_code, @copy_email_code) AND status = 0) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('active=', @active_email_code, ', draft=', @draft_email_code, ', copy=', @copy_email_code) AS evidence;

SELECT 'DB-16 Cleanup leaves no active current Metadata relations' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_template_category_rel WHERE email_code IN (@active_email_code, @draft_email_code, @copy_email_code) AND status = 0) = 0
                   AND (SELECT COUNT(*) FROM iic_msg_email_template_tag_rel WHERE email_code IN (@active_email_code, @draft_email_code, @copy_email_code) AND status = 0) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('temporaryTemplates=', @active_email_code, ',', @draft_email_code, ',', @copy_email_code) AS evidence;

SELECT 'DB-17 Cleanup soft-deletes temporary Categories' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_category WHERE id IN (@target_category_id, @recreated_category_id) AND is_deleted = 0) = 0 THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('targetCategory=', @target_category_id, ', recreatedCategory=', @recreated_category_id) AS evidence;

SELECT 'DB-18 Same-name Category history is retained after cleanup' AS check_id,
       CASE WHEN (SELECT COUNT(*) FROM iic_msg_email_category WHERE id IN (@source_category_id, @recreated_category_id) AND is_deleted = 1) = 2
                   AND (SELECT COUNT(DISTINCT category_name) FROM iic_msg_email_category WHERE id IN (@source_category_id, @recreated_category_id) AND is_deleted = 1) = 1
            THEN 'PASS' ELSE 'FAIL' END AS result,
       CONCAT('sourceCategory=', @source_category_id, ', recreatedCategory=', @recreated_category_id, ', expectedDeletedSameName=2') AS evidence;
