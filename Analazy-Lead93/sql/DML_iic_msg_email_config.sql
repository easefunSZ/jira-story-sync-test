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

UPDATE iic_msg_email_config c
JOIN iic_msg_template_migration_snapshot s
  ON s.record_type = 'CONFIG'
 AND s.action_type = 'UPDATE'
 AND s.record_id = c.id
 AND s.source_batch_id = @migration_batch_id
SET c.email_name = JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.email_name')),
    c.description = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.description')), 'null'),
    c.email_status = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.email_status')) AS SIGNED),
    c.status = CAST(JSON_UNQUOTE(JSON_EXTRACT(s.snapshot_json, '$.status')) AS SIGNED),
    c.updated_by = @migration_user,
    c.updated_date = CURRENT_TIMESTAMP
WHERE @lead93_rollback = 1;
