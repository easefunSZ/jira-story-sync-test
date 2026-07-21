-- Update existing active level-1 Categories by approved category_code.
UPDATE iic_msg_email_category c
JOIN tmp_lead93_category_seed s ON s.category_code = c.category_code AND s.parent_category_code IS NULL
SET c.description = s.description, c.sort_order = s.sort_order, c.updated_by = @migration_user, c.updated_date = CURRENT_TIMESTAMP
WHERE c.parent_id IS NULL AND c.is_deleted = 0;

-- Insert missing level-1 Categories.
INSERT INTO iic_msg_email_category (category_code, category_name, description, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_code, s.category_name, s.description, NULL, s.sort_order, 0, @migration_user, @migration_user
FROM tmp_lead93_category_seed s
WHERE s.parent_category_code IS NULL
  AND NOT EXISTS (SELECT 1 FROM iic_msg_email_category c WHERE c.category_code = s.category_code);

-- Update existing active Subcategories by approved category_code and parent code.
UPDATE iic_msg_email_category c
JOIN iic_msg_email_category p ON p.id = c.parent_id AND p.is_deleted = 0 AND p.parent_id IS NULL
JOIN tmp_lead93_category_seed s ON s.category_code = c.category_code AND s.parent_category_code = p.category_code
SET c.description = s.description, c.sort_order = s.sort_order, c.updated_by = @migration_user, c.updated_date = CURRENT_TIMESTAMP
WHERE c.is_deleted = 0;

-- Insert missing Subcategories after all parents exist.
INSERT INTO iic_msg_email_category (category_code, category_name, description, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_code, s.category_name, s.description, p.id, s.sort_order, 0, @migration_user, @migration_user
FROM tmp_lead93_category_seed s
JOIN iic_msg_email_category p ON p.category_code = s.parent_category_code AND p.parent_id IS NULL AND p.is_deleted = 0
WHERE s.parent_category_code IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM iic_msg_email_category c WHERE c.category_code = s.category_code);
