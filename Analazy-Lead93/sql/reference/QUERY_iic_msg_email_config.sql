-- Parameters are mapper placeholders. Expand IN lists with safe bind variables.
-- Cross-dimension filters use AND. Add one Tag EXISTS block per selected group.
--
-- REVIEW STATUS:
-- - Confirmed deltas in this file: Web Template Library is Email-only
--   (is_campaign = 0); Category/Tag
--   metadata is current Template-level data keyed by email_code;
--   same-dimension multi-select uses OR/ANY;
--   Keyword matches Template Name, Email Subject, Description and Tag Name;
--   Category/Subcategory Name remains excluded.
-- - Draft/Admin returns one row per email_code and selects the greatest numeric
--   V(N). Never compare version strings lexicographically (V10 must be newer
--   than V9).
-- - Template Name is iic_msg_email_config.email_name. Email Subject is
--   iic_msg_email_config_version.title. The PRD requires both fields in the
--   same keyword search scope.

-- Published Search / Filter: first page distinct email_code values.
WITH published_scope AS (
  SELECT DISTINCT c.email_code, v.version AS result_version
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  WHERE c.status = 0
    AND c.email_status = 1
    AND c.is_campaign = 0
    AND v.status = 0
    AND v.version_status = 1
),
published_filtered AS (
  SELECT s.email_code, s.result_version,
         MAX(c.updated_date) AS sort_updated_date
  FROM published_scope s
  JOIN iic_msg_email_config c
    ON c.email_code = s.email_code AND c.status = 0
  JOIN iic_msg_email_config_version rv
    ON rv.email_code = s.email_code
   AND rv.version = s.result_version
   AND rv.status = 0
  WHERE (:category_id IS NULL OR c.category_id = :category_id)
    /* Optional Subcategory ANY:
    AND EXISTS (
      SELECT 1 FROM iic_msg_template_category_rel cr
      WHERE cr.email_code = s.email_code
        AND cr.status = 0
        AND cr.subcategory_id IN (:subcategory_ids)
    ) */
    /* Optional Tag Group ANY; repeat per selected group:
    AND EXISTS (
      SELECT 1 FROM iic_msg_template_tag_rel tr
      JOIN iic_msg_tag_value tv ON tv.tag_code = tr.tag_code AND tv.group_code = tr.group_code AND tv.status = 0
      WHERE tr.email_code = s.email_code
        AND tr.status = 0
        AND tr.group_code = :group_code
        AND tr.tag_code IN (:tag_codes_in_group)
    ) */
    AND (
      :keyword IS NULL OR :keyword = ''
      OR c.email_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR rv.title LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR c.description LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel tr
        JOIN iic_msg_tag_value tv
          ON tv.tag_code = tr.tag_code AND tv.group_code = tr.group_code AND tv.status = 0
        WHERE tr.email_code = s.email_code
          AND tr.status = 0
          AND tv.tag_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
    )
  GROUP BY s.email_code, s.result_version
)
SELECT email_code, result_version
FROM published_filtered
ORDER BY sort_updated_date DESC, email_code DESC
LIMIT :limit OFFSET :offset;

-- Draft Search / Filter: preserve the three confirmed OR branches, then select
-- exactly one result version per email_code by greatest numeric V(N).
WITH draft_candidates AS (
  SELECT c.email_code,
         v.version AS result_version,
         ROW_NUMBER() OVER (
           PARTITION BY c.email_code
           ORDER BY CAST(SUBSTRING(v.version, 2) AS UNSIGNED) DESC, v.id DESC
         ) AS version_rank
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  WHERE c.is_campaign = 0
    AND v.status = 0
    AND (
      c.email_status = 0
      OR (c.status = 0 AND v.version_status IN (0, 3) AND v.version <> 'V1')
      OR (v.version_status IN (0, 3) AND v.version = 'V1')
    )
),
draft_scope AS (
  SELECT email_code, result_version
  FROM draft_candidates
  WHERE version_rank = 1
),
draft_filtered AS (
  SELECT s.email_code, s.result_version,
         MAX(c.updated_date) AS sort_updated_date
  FROM draft_scope s
  JOIN iic_msg_email_config c ON c.email_code = s.email_code
  JOIN iic_msg_email_config_version rv
    ON rv.email_code = s.email_code
   AND rv.version = s.result_version
   AND rv.status = 0
  WHERE (:category_id IS NULL OR c.category_id = :category_id)
    /* Insert the same optional Subcategory/Tag EXISTS blocks as Published. */
    AND (
      :keyword IS NULL OR :keyword = ''
      OR c.email_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR rv.title LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR c.description LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel tr
        JOIN iic_msg_tag_value tv
          ON tv.tag_code = tr.tag_code AND tv.group_code = tr.group_code AND tv.status = 0
        WHERE tr.email_code = s.email_code
          AND tr.status = 0
          AND tv.tag_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
    )
  GROUP BY s.email_code, s.result_version
)
SELECT email_code, result_version
FROM draft_filtered
ORDER BY sort_updated_date DESC, email_code DESC
LIMIT :limit OFFSET :offset;

-- Count: reuse the same CTE and replace the final SELECT.
-- SELECT COUNT(*) AS total FROM published_filtered;
-- SELECT COUNT(*) AS total FROM draft_filtered;

-- Append to the existing detail mapper to preserve page order:
-- AND existing_result.email_code IN (:paged_email_codes)
-- ORDER BY FIELD(existing_result.email_code, :paged_email_codes);

-- Template Title uniqueness in one main Category. Run only after the service
-- validates the non-empty, maximum-120 length and character whitelist and
-- category_id is present.
-- Exclude the current logical Template so its Active and Draft rows do not
-- conflict with each other. Active/Draft/Schedule references block reuse;
-- Expired-only history does not. Expected 0 rows before Save/Publish/Active
-- Metadata Update.
SELECT c.email_code, v.version, v.version_status
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v
  ON v.email_code = c.email_code
 AND v.status = 0
 AND v.version_status IN (0, 1, 3)
WHERE c.status = 0
  AND c.category_id = :category_id
  AND LOWER(TRIM(c.email_name)) = LOWER(TRIM(:email_name))
  AND (:email_code IS NULL OR c.email_code <> :email_code)
LIMIT 1;

-- Admin Template Detail only: expose the Copy source so the frontend can show
-- a non-blocking reminder immediately before publishing B. Ordinary list APIs,
-- Adviser Detail, filters, lifecycle selection, and Version History must not use
-- or return this field.
SELECT c.copy_from_email_code
FROM iic_msg_email_config c
WHERE c.email_code = :email_code
  AND c.status = 0
LIMIT 1;
