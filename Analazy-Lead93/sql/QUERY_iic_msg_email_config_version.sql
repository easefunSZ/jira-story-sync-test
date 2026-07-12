-- More than one Active version per logical template; expected 0 rows.
SELECT email_code, COUNT(*) AS active_count
FROM iic_msg_email_config_version
WHERE status = 0
  AND version_status = 1
GROUP BY email_code
HAVING COUNT(*) > 1;

-- Scheduler candidate query used by changeVersionStatusByEffectiveFrom().
SELECT id, email_code, version, effective_from
FROM iic_msg_email_config_version
WHERE version_status = 0
  AND status = 0
  AND effective_from <= CURRENT_TIMESTAMP
ORDER BY effective_from, id;

