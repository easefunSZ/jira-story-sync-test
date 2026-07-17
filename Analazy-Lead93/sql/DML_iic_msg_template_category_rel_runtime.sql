-- LEAD-93 runtime mapper template: initialize Draft Subcategory relations from
-- the current Active version. Execute once, in the same transaction as the new
-- Draft version insert. Updating an existing Draft uses its own saved relations.
INSERT INTO iic_msg_template_category_rel (email_code, version, subcategory_id, status, created_by, updated_by)
SELECT r.email_code, :draft_version, r.subcategory_id, 0, :operator, :operator
FROM iic_msg_template_category_rel r
JOIN iic_msg_email_config_version active ON active.email_code = r.email_code AND active.version = r.version AND active.status = 0 AND active.version_status = 1
JOIN iic_msg_email_category node ON node.id = r.subcategory_id AND node.is_deleted = 0 AND node.category_level = 2
WHERE r.email_code = :email_code AND r.version = :active_version AND r.status = 0
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Metadata Update API, step 1: deactivate the complete existing Subcategory
-- snapshot for the explicit target version.
UPDATE iic_msg_template_category_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND version = :version AND status = 0;

-- Metadata Update API, step 2: execute once per unique submitted
-- :subcategory_id. An empty subcategory_ids array intentionally skips this
-- statement after step 1. Pre-validate that every unique submitted ID resolves
-- to one valid node; do not assume MySQL ON DUPLICATE KEY affected_rows is 1.
INSERT INTO iic_msg_template_category_rel (email_code, version, subcategory_id, status, created_by, updated_by)
SELECT :email_code, :version, node.id, 0, :operator, :operator
FROM iic_msg_email_category node
WHERE node.id = :subcategory_id AND node.parent_id = :category_id AND node.is_deleted = 0 AND node.category_level = 2
ON DUPLICATE KEY UPDATE status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Extend the existing Template Delete transaction: soft-delete Subcategory
-- relations for every version of the logical Template.
UPDATE iic_msg_template_category_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND status = 0;

-- Extend the existing Version Delete transaction, including Published Working
-- Copy Discard and Scheduled Version Delete: soft-delete relations for only the
-- target version. There is no independent Discard API.
UPDATE iic_msg_template_category_rel SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP WHERE email_code = :email_code AND version = :version AND status = 0;
