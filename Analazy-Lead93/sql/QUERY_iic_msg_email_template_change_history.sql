-- Template modification history, newest first. Snapshot names are authoritative
-- historical display values and must not be replaced by current taxonomy joins.
SELECT id, operation_id, email_code, change_type, before_snapshot, after_snapshot, changed_by, changed_date
FROM iic_msg_email_template_change_history
WHERE email_code = :email_code
ORDER BY changed_date DESC, id DESC
LIMIT :limit OFFSET :offset;

SELECT COUNT(*) AS total
FROM iic_msg_email_template_change_history
WHERE email_code = :email_code;
