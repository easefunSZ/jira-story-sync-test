-- Fixed Tag Group seed. Trigger's maximum of five selections is enforced by
-- the Service constant, not persisted in this table.
INSERT INTO iic_msg_tag_group (group_code, group_name, is_mandatory, sort_order, status, created_by, updated_by)
VALUES ('CONTENT_TYPE', 'Content Type', 1, 10, 0, @migration_user, @migration_user),
       ('TRIGGER', 'Trigger Event', 1, 20, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'Lifecycle Stage', 1, 30, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'Financial Need', 1, 40, 0, @migration_user, @migration_user),
       ('PROPOSITION_SOURCE', 'Proposition / Source', 0, 50, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE group_name = VALUES(group_name), is_mandatory = VALUES(is_mandatory), sort_order = VALUES(sort_order), status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;
