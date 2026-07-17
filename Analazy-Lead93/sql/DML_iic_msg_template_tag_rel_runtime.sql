-- LEAD-93 runtime mapper template: initialize Draft Tag relations from the
-- current Active version. Execute once, in the same transaction as the new
-- Draft version insert. Updating an existing Draft uses its own saved relations.
INSERT INTO iic_msg_template_tag_rel (email_code, version, group_code, tag_code, status, created_by, updated_by)
SELECT r.email_code, :draft_version, r.group_code, r.tag_code, 0, :operator, :operator
FROM iic_msg_template_tag_rel r
JOIN iic_msg_email_config_version active ON active.email_code = r.email_code AND active.version = r.version AND active.status = 0 AND active.version_status = 1
JOIN iic_msg_tag_group g ON g.group_code = r.group_code AND g.status = 0
JOIN iic_msg_tag_value v ON v.group_code = r.group_code AND v.tag_code = r.tag_code AND v.status = 0
WHERE r.email_code = :email_code AND r.version = :active_version AND r.status = 0
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Metadata Update API, step 1: deactivate the complete existing Tag snapshot
-- for the explicit target version.
UPDATE iic_msg_template_tag_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND version = :version AND status = 0;

-- Metadata Update API, step 2: execute once per submitted group_code/tag_code
-- pair. Multiple unique tag_code values in one Group are valid. The service
-- resolves an empty Draft mandatory Group to its Unclassified value.
-- Pre-validate every submitted pair; do not assume MySQL ON DUPLICATE KEY
-- affected_rows is 1.
INSERT INTO iic_msg_template_tag_rel (email_code, version, group_code, tag_code, status, created_by, updated_by)
SELECT :email_code, :version, g.group_code, v.tag_code, 0, :operator, :operator
FROM iic_msg_tag_group g
JOIN iic_msg_tag_value v ON v.group_code = g.group_code AND v.tag_code = :tag_code AND v.status = 0
WHERE g.group_code = :group_code AND g.status = 0
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Extend the existing Template Delete transaction: soft-delete Tag relations
-- for every version of the logical Template.
UPDATE iic_msg_template_tag_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND status = 0;

-- Extend the existing Version Delete transaction, including Published Working
-- Copy Discard and Scheduled Version Delete: soft-delete relations for only the
-- target version. There is no independent Discard API.
UPDATE iic_msg_template_tag_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND version = :version AND status = 0;
