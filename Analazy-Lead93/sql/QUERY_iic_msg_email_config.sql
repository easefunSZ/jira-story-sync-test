-- Parameters are mapper placeholders. Expand IN lists with safe bind variables.
-- Cross-dimension filters use AND. Add one Tag EXISTS block per selected group.

-- Published Search / Filter: first page distinct email_code values.
WITH published_scope AS (
  SELECT DISTINCT c.email_code
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  WHERE c.status = 0
    AND c.email_status = 1
    AND c.is_campaign <> 1
    AND v.status = 0
    AND v.version_status = 1
),
published_filtered AS (
  SELECT s.email_code, MAX(c.updated_date) AS sort_updated_date
  FROM published_scope s
  JOIN iic_msg_email_config c
    ON c.email_code = s.email_code AND c.status = 0
  LEFT JOIN iic_msg_template_metadata m
    ON m.email_code = s.email_code AND m.status = 0
  WHERE (:category_id IS NULL OR m.category_id = :category_id)
    /* Optional Subcategory ANY:
    AND EXISTS (
      SELECT 1 FROM iic_msg_template_category_rel cr
      WHERE cr.email_code = s.email_code AND cr.status = 0
        AND cr.subcategory_id IN (:subcategory_ids)
    ) */
    /* Optional Tag Group ANY; repeat per selected group:
    AND EXISTS (
      SELECT 1 FROM iic_msg_template_tag_rel tr
      WHERE tr.email_code = s.email_code AND tr.status = 0
        AND tr.group_code = :group_code
        AND tr.tag_code IN (:tag_codes_in_group)
    ) */
    AND (
      :keyword IS NULL OR :keyword = ''
      OR c.email_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR c.description LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR EXISTS (
        SELECT 1 FROM iic_msg_email_config_version pv
        WHERE pv.email_code = s.email_code
          AND pv.status = 0 AND pv.version_status = 1
          AND pv.title LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_metadata km
        JOIN iic_msg_category_config kc
          ON kc.id = km.category_id
         AND kc.flag = :template_category_flag
         AND kc.is_deleted = 0
        WHERE km.email_code = s.email_code AND km.status = 0
          AND kc.category_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_category_rel kr
        JOIN iic_msg_category_config ks
          ON ks.id = kr.subcategory_id
         AND ks.flag = :template_category_flag
         AND ks.is_deleted = 0
        WHERE kr.email_code = s.email_code AND kr.status = 0
          AND ks.category_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel tr
        JOIN iic_msg_tag_value tv
          ON tv.tag_code = tr.tag_code AND tv.status = 0
        WHERE tr.email_code = s.email_code AND tr.status = 0
          AND tv.tag_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
    )
  GROUP BY s.email_code
)
SELECT email_code
FROM published_filtered
ORDER BY sort_updated_date DESC, email_code DESC
LIMIT :limit OFFSET :offset;

-- Draft Search / Filter: preserve the three confirmed OR branches.
WITH draft_scope AS (
  SELECT DISTINCT c.email_code
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  WHERE c.email_status = 0
     OR (c.status = 0 AND v.version_status IN (0, 3) AND v.version <> 'V1')
     OR (v.version_status IN (0, 3) AND v.version = 'V1')
),
draft_filtered AS (
  SELECT s.email_code, MAX(c.updated_date) AS sort_updated_date
  FROM draft_scope s
  JOIN iic_msg_email_config c ON c.email_code = s.email_code
  LEFT JOIN iic_msg_template_metadata m
    ON m.email_code = s.email_code AND m.status = 0
  WHERE (:category_id IS NULL OR m.category_id = :category_id)
    /* Insert the same optional Subcategory/Tag EXISTS blocks as Published. */
    AND (
      :keyword IS NULL OR :keyword = ''
      OR c.email_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR c.description LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      OR EXISTS (
        SELECT 1 FROM iic_msg_email_config_version dv
        WHERE dv.email_code = s.email_code
          AND (dv.version_status IN (0, 3) OR c.email_status = 0)
          AND dv.title LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_metadata km
        JOIN iic_msg_category_config kc
          ON kc.id = km.category_id
         AND kc.flag = :template_category_flag
         AND kc.is_deleted = 0
        WHERE km.email_code = s.email_code AND km.status = 0
          AND kc.category_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_category_rel kr
        JOIN iic_msg_category_config ks
          ON ks.id = kr.subcategory_id
         AND ks.flag = :template_category_flag
         AND ks.is_deleted = 0
        WHERE kr.email_code = s.email_code AND kr.status = 0
          AND ks.category_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel tr
        JOIN iic_msg_tag_value tv
          ON tv.tag_code = tr.tag_code AND tv.status = 0
        WHERE tr.email_code = s.email_code AND tr.status = 0
          AND tv.tag_name LIKE CONCAT('%', :keyword, '%') ESCAPE '\\'
      )
    )
  GROUP BY s.email_code
)
SELECT email_code
FROM draft_filtered
ORDER BY sort_updated_date DESC, email_code DESC
LIMIT :limit OFFSET :offset;

-- Count: reuse the same CTE and replace the final SELECT.
-- SELECT COUNT(*) AS total FROM published_filtered;
-- SELECT COUNT(*) AS total FROM draft_filtered;

-- Append to the existing detail mapper to preserve page order:
-- AND existing_result.email_code IN (:paged_email_codes)
-- ORDER BY FIELD(existing_result.email_code, :paged_email_codes);

-- Q8 alternative: replace an ANY EXISTS block with ALL semantics when approved.
/*
AND (
  SELECT COUNT(DISTINCT cr.subcategory_id)
  FROM iic_msg_template_category_rel cr
  WHERE cr.email_code = s.email_code
    AND cr.status = 0
    AND cr.subcategory_id IN (:subcategory_ids)
) = :subcategory_selected_count

AND (
  SELECT COUNT(DISTINCT tr.tag_code)
  FROM iic_msg_template_tag_rel tr
  WHERE tr.email_code = s.email_code
    AND tr.status = 0
    AND tr.group_code = :group_code
    AND tr.tag_code IN (:tag_codes_in_group)
) = :tag_selected_count_in_group
*/
