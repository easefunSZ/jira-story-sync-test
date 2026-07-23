# LEAD-93 SQL

本目录只保留两个入口。

| 目录 | 用途 | 谁使用 |
|---|---|---|
| [required](required/README.md) | 运维自动执行的 DDL、固定 Seed，以及后续生成的一次性 Mapping DML | 开发提交、运维执行 |
| [reference](reference/README.md) | Runtime Mapper、查询校验、历史迁移片段和 Mapping 生成模板 | 开发、QA、技术评审 |

**运维只接收 `required/` 中列出的文件。** `reference/` 中的 SQL 不进入发布包，也不由运维自动执行。

正式 Template Mapping 尚待 `BUS-01` 签字。签字后，开发从 `reference/` 的 Mapping 模板生成一个带批次号的 DML 文件，并将该生成文件放入 `required/` 后提交。
