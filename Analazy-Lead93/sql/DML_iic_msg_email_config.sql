-- REVIEW GATE: Q5 must supply and approve the concrete migration mapping before
-- this file can run. The SQL structure is retained for review only.
UPDATE iic_msg_email_config c
JOIN tmp_lead93_template_mapping m ON m.email_code = c.email_code
SET c.email_name = COALESCE(NULLIF(m.new_email_name, ''), c.email_name),
    c.description = COALESCE(m.new_description, c.description),
    c.updated_by = @migration_user,
    c.updated_date = CURRENT_TIMESTAMP
WHERE c.status = 0;

-- Mapping-gated deactivation; no effect unless the approved migration mapping
-- contains the action and the release variable is explicitly enabled.
UPDATE iic_msg_email_config c
JOIN tmp_lead93_template_mapping m ON m.email_code = c.email_code
SET c.email_status = 0,
    c.description = CASE
      WHEN m.action_note IS NOT NULL THEN CONCAT(
        COALESCE(c.description, ''),
        CASE WHEN c.description IS NULL OR c.description = '' THEN '' ELSE ' ' END,
        m.action_note)
      ELSE c.description
    END,
    c.updated_by = @migration_user,
    c.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_apply_deactivate = 1
  AND c.status = 0
  AND m.migration_action IN ('DEACTIVATE_DUPLICATE', 'DEACTIVATE_OUTDATED');

-- Assign the approved current main Category once per Template.
UPDATE iic_msg_email_config c
JOIN tmp_lead93_template_category_mapping m ON m.email_code = c.email_code
JOIN iic_msg_email_category category_node ON category_node.category_name = m.category_name AND category_node.parent_id IS NULL AND category_node.is_deleted = 0
SET c.category_id = category_node.id,
    c.updated_by = @migration_user,
    c.updated_date = CURRENT_TIMESTAMP
WHERE c.status = 0;
