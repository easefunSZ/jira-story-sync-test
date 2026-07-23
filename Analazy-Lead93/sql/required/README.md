# 运维发布 SQL

本目录是唯一可提交给运维自动执行的 SQL 目录。

## 执行顺序

上线交付时，按以下序号为文件增加前缀，并按序执行：

| 顺序 | 文件 |
|---:|---|
| 01 | `DDL_iic_msg_email_category.sql` |
| 02 | `DDL_iic_msg_tag_group.sql` |
| 03 | `DDL_iic_msg_tag_value.sql` |
| 04 | `DDL_iic_msg_email_config.sql` |
| 05 | `DDL_iic_msg_template_category_rel.sql` |
| 06 | `DDL_iic_msg_template_tag_rel.sql` |
| 07 | `DDL_iic_msg_email_template_change_history.sql` |
| 08 | `DDL_iic_msg_email_category_change_history.sql` |
| 09 | `DDL_iic_msg_template_migration_log.sql` |
| 10 | `DDL_iic_msg_email_category_delete_audit.sql` |
| 11 | `DML_iic_msg_tag_group.sql` |
| 12 | `DML_iic_msg_tag_value.sql` |
| 13 | `DML_LEAD93_template_mapping_<batch>.sql`（`BUS-01` 确认后生成） |

第 13 个文件当前不生成、不提交。不要将 `reference/` 中的文件加入运维发布包。
