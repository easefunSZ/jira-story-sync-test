-- Replace the complete current Tag set for one Template. The Service captures
-- the before snapshot and validates the complete submitted taxonomy first.
DELETE FROM iic_msg_template_tag_rel WHERE email_code = :email_code;

INSERT INTO iic_msg_template_tag_rel (email_code, tag_code)
SELECT :email_code, value_node.tag_code
FROM iic_msg_tag_value value_node
JOIN iic_msg_tag_group group_node ON group_node.group_code = value_node.group_code
WHERE value_node.tag_code = :tag_code AND value_node.group_code = :group_code
ON DUPLICATE KEY UPDATE tag_code = VALUES(tag_code);

-- Copy and Create uses the same validated Insert once per submitted Tag value,
-- with :email_code bound to B's new email_code. Draft may submit an empty set;
-- Publish will later enforce the four mandatory groups.

-- Template and Version soft-delete do not physically remove current Template
-- Metadata. DELETE history is captured separately in the change-history table.
