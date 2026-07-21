-- Fixed Tag Group seed. Trigger's maximum of five selections is enforced by
-- the Service constant, not persisted in this table.
INSERT INTO iic_msg_tag_group (group_code, group_name, is_mandatory, sort_order)
VALUES ('CONTENT_TYPE', 'Content Type', 1, 10),
       ('TRIGGER', 'Trigger Event', 1, 20),
       ('LIFECYCLE_STAGE', 'Lifecycle Stage', 1, 30),
       ('FINANCIAL_NEED', 'Financial Need', 1, 40),
       ('PROPOSITION_SOURCE', 'Proposition / Source', 0, 50)
ON DUPLICATE KEY UPDATE group_name = VALUES(group_name), is_mandatory = VALUES(is_mandatory), sort_order = VALUES(sort_order);
