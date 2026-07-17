-- LEAD-308 Adviser Template Library query design.
-- Scope: QUERY only. LEAD-308 adds no DDL or DML and reuses LEAD-93 tables.
--
-- Frozen rules:
--   * Adviser can only read enabled, non-deleted Active/Published versions.
--   * Metadata is resolved by email_code + version.
--   * Keyword fields are Template Title, Description and Tag Name.
--   * Cross-dimension filters use AND; values in the same dimension use OR/ANY.
--   * Status is not accepted from the Adviser request.
--
-- Not frozen; do not bind this file directly to a Mapper before resolution:
--   * Whether one request may return both is_campaign = 0 and 1.
--   * Most Relevant score.
--   * Whether Published Date is effective_from.
--   * Whether Category counts are global or reflect current search/tag filters.

-- ---------------------------------------------------------------------------
-- 1. Published base scope for one requested template format.
-- ---------------------------------------------------------------------------
WITH adviser_published_scope AS (
  SELECT c.email_code, c.email_name, c.description, c.is_campaign,
         v.version AS result_version, v.title AS email_subject,
         v.email_content, v.text_content, v.file_keys, v.thumbnail_key,
         v.category_id, v.effective_from, v.updated_date AS version_updated_date
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  JOIN iic_msg_email_category mc ON mc.id = v.category_id
  WHERE c.status = 0
    AND c.email_status = 1
    AND c.is_campaign = :is_campaign
    AND v.status = 0
    AND v.version_status = 1
    AND mc.category_level = 1
    AND mc.is_deleted = 0
    AND EXISTS (
      SELECT 1
      FROM iic_msg_template_category_rel cr
      JOIN iic_msg_email_category sc
        ON sc.id = cr.subcategory_id
       AND sc.category_level = 2
       AND sc.is_deleted = 0
       AND sc.parent_id = v.category_id
      WHERE cr.email_code = v.email_code
        AND cr.version = v.version
        AND cr.status = 0
    )
    AND NOT EXISTS (
      SELECT 1
      FROM iic_msg_tag_group g
      WHERE g.status = 0
        AND g.is_mandatory = 1
        AND NOT EXISTS (
          SELECT 1
          FROM iic_msg_template_tag_rel tr
          JOIN iic_msg_tag_value tv
            ON tv.tag_code = tr.tag_code
           AND tv.group_code = tr.group_code
           AND tv.status = 0
          WHERE tr.email_code = v.email_code
            AND tr.version = v.version
            AND tr.group_code = g.group_code
            AND tr.status = 0
        )
    )
),
adviser_filtered_scope AS (
  SELECT s.*
  FROM adviser_published_scope s
  WHERE (:category_id IS NULL OR s.category_id = :category_id)
    /* Optional Subcategory ANY:
    AND EXISTS (
      SELECT 1
      FROM iic_msg_template_category_rel cr
      WHERE cr.email_code = s.email_code
        AND cr.version = s.result_version
        AND cr.status = 0
        AND cr.subcategory_id IN (:subcategory_ids)
    ) */
    /* Optional Tag Group ANY. Repeat this EXISTS block once per selected group:
    AND EXISTS (
      SELECT 1
      FROM iic_msg_template_tag_rel tr
      WHERE tr.email_code = s.email_code
        AND tr.version = s.result_version
        AND tr.status = 0
        AND tr.group_code = :group_code
        AND tr.tag_code IN (:tag_codes_in_group)
    ) */
    AND (
      :keyword IS NULL OR :keyword = ''
      OR LOWER(s.email_name) LIKE CONCAT('%', LOWER(:keyword), '%') ESCAPE '\\'
      OR LOWER(s.description) LIKE CONCAT('%', LOWER(:keyword), '%') ESCAPE '\\'
      OR EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel tr
        JOIN iic_msg_tag_value tv
          ON tv.tag_code = tr.tag_code
         AND tv.group_code = tr.group_code
         AND tv.status = 0
        WHERE tr.email_code = s.email_code
          AND tr.version = s.result_version
          AND tr.status = 0
          AND LOWER(tv.tag_name) LIKE CONCAT('%', LOWER(:keyword), '%') ESCAPE '\\'
      )
    )
)
SELECT s.email_code, s.result_version, s.email_name, s.description,
       s.is_campaign, s.email_subject, s.thumbnail_key,
       s.category_id, s.effective_from AS published_date
FROM adviser_filtered_scope s
-- Use exactly one server-side allow-listed ORDER BY branch; never concatenate
-- arbitrary request text. Candidate branches:
-- ORDER BY s.effective_from DESC, s.email_code DESC;  -- NEWEST
-- ORDER BY s.effective_from ASC,  s.email_code ASC;   -- OLDEST
-- ORDER BY s.email_name ASC, s.email_code ASC;        -- TITLE_ASC
-- ORDER BY s.email_name DESC, s.email_code DESC;      -- TITLE_DESC
-- MOST_RELEVANT remains blocked until the score is approved.
ORDER BY s.effective_from DESC, s.email_code DESC
LIMIT :limit OFFSET :offset;

-- Count must reuse adviser_filtered_scope unchanged.
-- SELECT COUNT(*) AS total FROM adviser_filtered_scope;

-- ---------------------------------------------------------------------------
-- 2. Active Category tree with Published template counts.
-- Current version counts the frozen Published base scope for one format.
-- Reuse the same current-filter EXISTS blocks only after count semantics are
-- confirmed as contextual rather than global.
-- ---------------------------------------------------------------------------
WITH adviser_published_keys AS (
  SELECT DISTINCT c.email_code, v.version, v.category_id
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  JOIN iic_msg_email_category mc
    ON mc.id = v.category_id
   AND mc.category_level = 1
   AND mc.is_deleted = 0
  WHERE c.status = 0
    AND c.email_status = 1
    AND c.is_campaign = :is_campaign
    AND v.status = 0
    AND v.version_status = 1
    AND EXISTS (
      SELECT 1
      FROM iic_msg_template_category_rel cr
      JOIN iic_msg_email_category sc
        ON sc.id = cr.subcategory_id
       AND sc.category_level = 2
       AND sc.is_deleted = 0
       AND sc.parent_id = v.category_id
      WHERE cr.email_code = v.email_code
        AND cr.version = v.version
        AND cr.status = 0
    )
    AND NOT EXISTS (
      SELECT 1
      FROM iic_msg_tag_group g
      WHERE g.status = 0
        AND g.is_mandatory = 1
        AND NOT EXISTS (
          SELECT 1
          FROM iic_msg_template_tag_rel tr
          JOIN iic_msg_tag_value tv
            ON tv.tag_code = tr.tag_code
           AND tv.group_code = tr.group_code
           AND tv.status = 0
          WHERE tr.email_code = v.email_code
            AND tr.version = v.version
            AND tr.group_code = g.group_code
            AND tr.status = 0
        )
    )
)
SELECT result.id, result.category_code, result.category_name,
       result.parent_id, result.category_level, result.sort_order,
       result.published_template_count
FROM (
  SELECT n.id, n.category_code, n.category_name, n.parent_id,
         n.category_level, n.sort_order,
         COUNT(DISTINCT k.email_code) AS published_template_count
  FROM iic_msg_email_category n
  LEFT JOIN adviser_published_keys k ON k.category_id = n.id
  WHERE n.category_level = 1
    AND n.is_deleted = 0
  GROUP BY n.id, n.category_code, n.category_name, n.parent_id,
           n.category_level, n.sort_order

  UNION ALL

  SELECT n.id, n.category_code, n.category_name, n.parent_id,
         n.category_level, n.sort_order,
         COUNT(DISTINCT k.email_code) AS published_template_count
  FROM iic_msg_email_category n
  LEFT JOIN iic_msg_template_category_rel r
    ON r.subcategory_id = n.id
   AND r.status = 0
  LEFT JOIN adviser_published_keys k
    ON k.email_code = r.email_code
   AND k.version = r.version
  WHERE n.category_level = 2
    AND n.is_deleted = 0
  GROUP BY n.id, n.category_code, n.category_name, n.parent_id,
           n.category_level, n.sort_order
) result
ORDER BY result.category_level, result.parent_id,
         result.sort_order, result.id;

-- ---------------------------------------------------------------------------
-- 3. Adviser filter values used by at least one Published template.
-- Adviser UI exposes only the four mandatory groups.
-- ---------------------------------------------------------------------------
WITH adviser_published_versions AS (
  SELECT DISTINCT c.email_code, v.version
  FROM iic_msg_email_config c
  JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
  JOIN iic_msg_email_category mc
    ON mc.id = v.category_id
   AND mc.category_level = 1
   AND mc.is_deleted = 0
  WHERE c.status = 0
    AND c.email_status = 1
    AND c.is_campaign = :is_campaign
    AND v.status = 0
    AND v.version_status = 1
    AND EXISTS (
      SELECT 1
      FROM iic_msg_template_category_rel cr
      JOIN iic_msg_email_category sc
        ON sc.id = cr.subcategory_id
       AND sc.category_level = 2
       AND sc.is_deleted = 0
       AND sc.parent_id = v.category_id
      WHERE cr.email_code = v.email_code
        AND cr.version = v.version
        AND cr.status = 0
    )
    AND NOT EXISTS (
      SELECT 1
      FROM iic_msg_tag_group required_group
      WHERE required_group.status = 0
        AND required_group.is_mandatory = 1
        AND NOT EXISTS (
          SELECT 1
          FROM iic_msg_template_tag_rel required_rel
          JOIN iic_msg_tag_value required_value
            ON required_value.tag_code = required_rel.tag_code
           AND required_value.group_code = required_rel.group_code
           AND required_value.status = 0
          WHERE required_rel.email_code = v.email_code
            AND required_rel.version = v.version
            AND required_rel.group_code = required_group.group_code
            AND required_rel.status = 0
        )
    )
)
SELECT g.group_code, g.group_name, g.sort_order AS group_sort_order,
       tv.tag_code, tv.tag_name, tv.sort_order AS value_sort_order,
       COUNT(DISTINCT pv.email_code) AS published_template_count
FROM iic_msg_tag_group g
JOIN iic_msg_tag_value tv
  ON tv.group_code = g.group_code
 AND tv.status = 0
JOIN iic_msg_template_tag_rel tr
  ON tr.group_code = tv.group_code
 AND tr.tag_code = tv.tag_code
 AND tr.status = 0
JOIN adviser_published_versions pv
  ON pv.email_code = tr.email_code
 AND pv.version = tr.version
WHERE g.status = 0
  AND g.group_code IN (
    'CONTENT_TYPE', 'TRIGGER', 'LIFECYCLE_STAGE', 'FINANCIAL_NEED'
  )
GROUP BY g.group_code, g.group_name, g.sort_order,
         tv.tag_code, tv.tag_name, tv.sort_order
HAVING COUNT(DISTINCT pv.email_code) > 0
ORDER BY g.sort_order, tv.sort_order, tv.tag_name;

-- ---------------------------------------------------------------------------
-- 4. Preview / Detail: resolve current Active version by email_code.
-- The service must not accept a client-selected version for Adviser Preview.
-- file_keys is intentionally not selected for Preview.
-- ---------------------------------------------------------------------------
SELECT c.email_code, c.email_name, c.description, c.is_campaign,
       v.version, v.title AS email_subject,
       v.email_content, v.text_content, v.thumbnail_key,
       v.category_id, v.effective_from AS published_date
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
JOIN iic_msg_email_category mc
  ON mc.id = v.category_id
 AND mc.category_level = 1
 AND mc.is_deleted = 0
WHERE c.email_code = :email_code
  AND c.status = 0
  AND c.email_status = 1
  AND v.status = 0
  AND v.version_status = 1
  AND EXISTS (
    SELECT 1
    FROM iic_msg_template_category_rel cr
    JOIN iic_msg_email_category sc
      ON sc.id = cr.subcategory_id
     AND sc.category_level = 2
     AND sc.is_deleted = 0
     AND sc.parent_id = v.category_id
    WHERE cr.email_code = v.email_code
      AND cr.version = v.version
      AND cr.status = 0
  )
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_tag_group required_group
    WHERE required_group.status = 0
      AND required_group.is_mandatory = 1
      AND NOT EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel required_rel
        JOIN iic_msg_tag_value required_value
          ON required_value.tag_code = required_rel.tag_code
         AND required_value.group_code = required_rel.group_code
         AND required_value.status = 0
        WHERE required_rel.email_code = v.email_code
          AND required_rel.version = v.version
          AND required_rel.group_code = required_group.group_code
          AND required_rel.status = 0
      )
  );

-- Category/Subcategory/Tag detail queries must use the email_code + version
-- returned above. Reuse the LEAD-93 relation queries; never read Draft metadata.

-- ---------------------------------------------------------------------------
-- 5. Use Template: re-resolve latest Active at click time.
-- Unlike Preview, activation may return file_keys to the downstream workflow.
-- ---------------------------------------------------------------------------
SELECT c.email_code, c.is_campaign,
       v.version, v.title AS email_subject,
       v.email_content, v.text_content, v.file_keys
FROM iic_msg_email_config c
JOIN iic_msg_email_config_version v ON v.email_code = c.email_code
JOIN iic_msg_email_category mc
  ON mc.id = v.category_id
 AND mc.category_level = 1
 AND mc.is_deleted = 0
WHERE c.email_code = :email_code
  AND c.status = 0
  AND c.email_status = 1
  AND v.status = 0
  AND v.version_status = 1
  AND EXISTS (
    SELECT 1
    FROM iic_msg_template_category_rel cr
    JOIN iic_msg_email_category sc
      ON sc.id = cr.subcategory_id
     AND sc.category_level = 2
     AND sc.is_deleted = 0
     AND sc.parent_id = v.category_id
    WHERE cr.email_code = v.email_code
      AND cr.version = v.version
      AND cr.status = 0
  )
  AND NOT EXISTS (
    SELECT 1
    FROM iic_msg_tag_group required_group
    WHERE required_group.status = 0
      AND required_group.is_mandatory = 1
      AND NOT EXISTS (
        SELECT 1
        FROM iic_msg_template_tag_rel required_rel
        JOIN iic_msg_tag_value required_value
          ON required_value.tag_code = required_rel.tag_code
         AND required_value.group_code = required_rel.group_code
         AND required_value.status = 0
        WHERE required_rel.email_code = v.email_code
          AND required_rel.version = v.version
          AND required_rel.group_code = required_group.group_code
          AND required_rel.status = 0
      )
  );
