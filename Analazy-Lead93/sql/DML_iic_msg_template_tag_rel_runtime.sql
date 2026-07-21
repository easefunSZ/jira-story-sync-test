-- Soft-replace the complete current Tag set for one Template. The Service captures
-- the before snapshot and validates the complete submitted taxonomy first.
UPDATE iic_msg_template_tag_rel
SET status = -1, updated_by = :operator, updated_date = CURRENT_TIMESTAMP
WHERE email_code = :email_code AND status = 0;

INSERT INTO iic_msg_template_tag_rel (email_code, group_code, tag_code, status, created_by, updated_by)
SELECT :email_code, value_node.group_code, value_node.tag_code, 0, :operator, :operator
FROM iic_msg_tag_value value_node
JOIN iic_msg_tag_group group_node ON group_node.group_code = value_node.group_code AND group_node.status = 0
WHERE value_node.tag_code = :tag_code AND value_node.group_code = :group_code AND value_node.status = 0
ON DUPLICATE KEY UPDATE group_code = VALUES(group_code), status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;

-- Copy and Create uses the same validated Insert once per submitted Tag value,
-- with :email_code bound to B's new email_code. Draft may submit an empty set;
-- Publish will later enforce the four mandatory groups.

-- Template soft-delete also soft-deletes current relation rows. DELETE history
-- is captured separately in the change-history table before the mutation.
