-- Initial values combine Tag_Taxonomy_with_Descriptions.xlsx with the values
-- already used by Final_Template_Tag_Mapping_Business_Review v1.0.xlsx.
-- Descriptions absent from both approved inputs remain NULL.
SET @migration_user = 'LEAD93_MIGRATION';

UPDATE iic_msg_tag_value
SET status = -1, updated_by = @migration_user, updated_date = CURRENT_TIMESTAMP
WHERE group_code = 'PROPOSITION_SOURCE' AND status = 0;

INSERT INTO iic_msg_tag_value (group_code, tag_code, tag_name, description, sort_order, status, created_by, updated_by)
VALUES ('CONTENT_TYPE', 'CONTENT_TYPE_EMAIL', 'Email', 'Standard email communication', 10, 0, @migration_user, @migration_user),
       ('CONTENT_TYPE', 'CONTENT_TYPE_VIDEO', 'Video', 'Video-based content', 20, 0, @migration_user, @migration_user),
       ('CONTENT_TYPE', 'CONTENT_TYPE_INFOGRAPHIC', 'Infographic', 'Visual informational content', 30, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_BIRTHDAY', 'Birthday', 'Client birthday communication trigger', 10, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_MARRIAGE', 'Marriage', 'Client marriage life event', 20, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_BIRTH_NEW_CHILD', 'Birth / New Child', 'New child life event', 30, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_RETIREMENT', 'Retirement', 'Client retirement milestone', 40, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_ANNUAL_REVIEW', 'Annual Review', 'Scheduled annual financial review', 50, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_TAX_SEASON', 'Tax Season', 'Tax period engagement', 60, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_FESTIVE_SEASON', 'Festive Season', 'End-of-year seasonal communication', 70, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_ADVISER_ACTIVITY', 'Adviser Activity', NULL, 80, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_AWARENESS_MONTHS', 'Awareness Months', NULL, 90, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_DEATH_BEREAVEMENT', 'Death / Bereavement', NULL, 100, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_FATHERS_DAY', 'Father’s Day', NULL, 110, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_NEW_ADVISER_INTRODUCTION', 'New Adviser Introduction', NULL, 120, 0, @migration_user, @migration_user),
       ('TRIGGER', 'TRIGGER_SPECIAL_OFFER', 'Special Offer', NULL, 130, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_PROSPECT', 'Prospect', 'Potential new client', 10, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_EXISTING_CLIENT', 'Existing Client', 'Current client', 20, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_RETENTION', 'Retention', 'Client retention focus', 30, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_NEW_CLIENT', 'New Client', NULL, 40, 0, @migration_user, @migration_user),
       ('LIFECYCLE_STAGE', 'LIFECYCLE_STAGE_REVIEW', 'Review', NULL, 50, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_PROTECT', 'Protect', 'Insurance and risk protection needs', 10, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_GROW_WEALTH', 'Grow Wealth', 'Investment and wealth growth', 20, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_SAVE', 'Save', 'Savings and short-term goals', 30, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_AWARENESS', 'Awareness', NULL, 40, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_ENGAGEMENT', 'Engagement', NULL, 50, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_FINANCIAL_EDUCATION', 'Financial Education', NULL, 60, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_MANAGE_LIFE_CHANGES', 'Manage Life Changes', NULL, 70, 0, @migration_user, @migration_user),
       ('FINANCIAL_NEED', 'FINANCIAL_NEED_PLAN_RETIREMENT', 'Plan Retirement', NULL, 80, 0, @migration_user, @migration_user)
ON DUPLICATE KEY UPDATE group_code = VALUES(group_code), tag_name = VALUES(tag_name), description = VALUES(description), sort_order = VALUES(sort_order), status = 0, updated_by = VALUES(updated_by), updated_date = CURRENT_TIMESTAMP;
