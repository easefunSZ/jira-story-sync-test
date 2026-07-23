# 开发参考 SQL

本目录不属于运维发布包。

| 类型 | 用途 |
|---|---|
| `DML_*_runtime.sql` | Service / Mapper 的运行时写入参考，不独立执行 |
| `QUERY_*.sql` | 查询设计、迁移核对和 QA 校验参考 |
| `DML_iic_msg_email_category_delete.sql` | 分类删除的事务内 Mapper 参考 |
| `DML_iic_msg_email_category_change_history.sql` | 分类/子分类创建、修改、排序、删除的事务内 History 写入参考 |
| `DML_iic_msg_*` 无 `_runtime` 后缀的旧片段 | 已由一次性 Mapping 发布脚本整合，禁止单独执行 |
| `DML_LEAD93_template_mapping_RELEASE_TEMPLATE.sql` | 从批准 Mapping 生成实际发布 DML 的模板；模板本身禁止执行 |

运行时 SQL 由应用代码调用；查询 SQL 由开发或 QA 在对应环境执行；二者都不交由运维自动发布。
