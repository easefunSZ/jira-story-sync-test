-- LEAD-93 runtime mapper template: initialize Draft Tag relations from the
-- current Active version. Execute once, in the same transaction as the new
-- Draft version insert. Updating an existing Draft uses its own saved relations.
INSERT INTO iic_msg_template_tag_rel (email_code, version, group_code, tag_code, source_batch_id, status, created_by, updated_by)
SELECT r.email_code, :draft_version, r.group_code, r.tag_code, NULL, 0, :operator, :operator
FROM iic_msg_template_tag_rel r
JOIN iic_msg_email_config_version active ON active.email_code = r.email_code AND active.version = r.version AND active.status = 0 AND active.version_status = 1
JOIN iic_msg_tag_group g ON g.group_code = r.group_code AND g.status = 0
JOIN iic_msg_tag_value v ON v.group_code = r.group_code AND v.tag_code = r.tag_code AND v.status = 0
WHERE r.email_code = :email_code AND r.version = :active_version AND r.status = 0
ON DUPLICATE KEY UPDATE tag_code = VALUES(tag_code), status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Extend the existing Template Delete transaction: soft-delete Tag relations
-- for every version of the logical Template.
UPDATE iic_msg_template_tag_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND status = 0;

-- Discard one Draft Working Copy: only the target Draft relations are removed.
-- The service must first prove the target version is a valid Draft row.
UPDATE iic_msg_template_tag_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND version = :draft_version AND status = 0;
