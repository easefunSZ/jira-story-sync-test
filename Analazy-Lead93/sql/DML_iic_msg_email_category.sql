-- Update existing active level-1 Categories by exact approved name.
UPDATE iic_msg_email_category c
JOIN tmp_lead93_category_seed s ON s.category_name = c.category_name AND s.parent_category_name IS NULL
SET c.description = s.description, c.sort_order = s.sort_order, c.updated_by = @migration_user, c.updated_date = CURRENT_TIMESTAMP
WHERE c.parent_id IS NULL AND c.is_deleted = 0;

-- Insert missing level-1 Categories.
INSERT INTO iic_msg_email_category (category_name, description, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_name, s.description, NULL, s.sort_order, 0, @migration_user, @migration_user
FROM tmp_lead93_category_seed s
WHERE s.parent_category_name IS NULL
  AND NOT EXISTS (SELECT 1 FROM iic_msg_email_category c WHERE c.category_name = s.category_name AND c.is_deleted = 0);

-- Update existing active Subcategories by exact approved name and parent.
UPDATE iic_msg_email_category c
JOIN iic_msg_email_category p ON p.id = c.parent_id AND p.is_deleted = 0 AND p.parent_id IS NULL
JOIN tmp_lead93_category_seed s ON s.category_name = c.category_name AND s.parent_category_name = p.category_name
SET c.description = s.description, c.sort_order = s.sort_order, c.updated_by = @migration_user, c.updated_date = CURRENT_TIMESTAMP
WHERE c.is_deleted = 0;

-- Insert missing Subcategories after all parents exist.
INSERT INTO iic_msg_email_category (category_name, description, parent_id, sort_order, is_deleted, created_by, updated_by)
SELECT s.category_name, s.description, p.id, s.sort_order, 0, @migration_user, @migration_user
FROM tmp_lead93_category_seed s
JOIN iic_msg_email_category p ON p.category_name = s.parent_category_name AND p.parent_id IS NULL AND p.is_deleted = 0
WHERE s.parent_category_name IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM iic_msg_email_category c WHERE c.category_name = s.category_name AND c.parent_id = p.id AND c.is_deleted = 0);
