# Lead-4 & Lead-305 解决方案评审问题详细讲解与深度剖析

本文件基于 [Lead-4&305_solution_design_review_findings.docx](file:///Users/qthitsz/DAE-workspace/om/Lead-4/Lead-4&305_solution_design_review_findings.docx) 中所列出的评审问题，结合当前设计的核心模块（[solution_overview_final.md](file:///Users/qthitsz/DAE-workspace/om/Lead-4/solution_overview_final.md)、[database_design_final.md](file:///Users/qthitsz/DAE-workspace/om/Lead-4/database_design_final.md)、[Lead-4_solution_design.md](file:///Users/qthitsz/DAE-workspace/om/Lead-4/Lead-4_solution_design.md) 以及 [Lead-305_solution_design.md](file:///Users/qthitsz/DAE-workspace/om/Lead-4/Lead-305_solution_design.md)）进行的逐一详细讲解，旨在扫清开发落地、业务验收和技术实现中的所有模糊和不一致点。

---

## 1. 高优先级问题 (High Priority Issues)

### P0-1: 规则注册中心方案自相矛盾
* **发现描述**：第 3.1.3 节设计了完整的数据库配置规则表 `validation_rule_registry`，以及 Caffeine 缓存、规则热重载接口和基于 Redis Pub/Sub 的多实例广播；但第 4 章又声明“采用静态代码注册，不涉及动态数据库编排，DDL 变更为 0”。
* **深度讲解**：这是开发的首要阻碍。动态规则注册中心（包括 DB 迁移、Redis 集群广播事件、Spring 容器内动态拦截器 Bean 装配、热重载 API）与直接在代码中通过 Java 枚举或硬编码的拦截器链（Chain Pattern）在**开发周期、代码量、系统复杂度**上差异极大。
* **规避建议**：本期（Phase 1）应明确边界。如果是静态注册，则应删除文档中所有关于 Redis 广播、热更新 API 和动态规则加载的复杂技术方案，避免过渡设计；如果是动态注册，则必须保留 DDL 并增加 Redis 依赖项的确认。

### P0-2: 异常表 Schema 与 DDL=0 冲突
* **发现描述**：文档中为实现统一异常报告分类及统计，声明在 MySQL `iic_crm_leads_exception_report` 异常表中追加两列：`exception_category`（分类大类）和 `is_hard_stop`（是否属于强熔断拦截）。然而，数据库设计章节却声明“无 DDL 变更”。
* **深度讲解**：如果坚持“DDL=0”而不在异常表中新增这两个物理字段，那么代码中捕获到的异常大类和熔断性质就**无法持久化到 MySQL**。后续 DMS 或 Fivetran 就无法将这些数据自动同步到 Snowflake 分析端，PFMi 报表团队也将无法通过只读视图来统计和透视具体的异常分布。
* **规避建议**：必须确认允许对异常表进行此项增量 DDL 变更。如果确认允许，需补充正式的 `ALTER TABLE` DDL 语句并制定数据库发布脚本。

### P0-3: Hard Stop / Exception / Audit 口径不一致
* **发现描述**：对于“无效的 PSI 渠道 (Invalid PSI Channel)”和“失效的 PSI (Inactive PSI)”，在不同 Story 章节中其行为定义不一致。它们在规则状态表格中被定义为 `is_hard_stop = 0`（即软校验失败，不强行熔断），但在文字描述中又强调它们会“阻止进行正常分配流程”。
* **深度讲解**：如果 `is_hard_stop = 0`，校验引擎在抛出对应异常后，会允许责任链继续往下走，且线索的状态仍然是 `PASS` 并正常流向下游的智能分配路由；但如果业务又要求“阻止分配”，那么代码就必须在逻辑上拦截并熔断。这种前后矛盾会导致开发写出的代码与业务验收预期相悖。
* **规避建议**：由业务和技术 TL 统一口径。如果确认要拦截并阻止分配，这两种情况的 `is_hard_stop` 属性必须明确修正为 `1`（即 Hard Stop 强拦截，状态直接变更为 `Validation Failed`）。

### P0-4: 新客户 PSI 校验失败是否阻断不明确
* **发现描述**：新客户（系统中无匹配老客）若自带了 PSI 销售顾问代码，在调用 EDR / OMIPAY 等外部接口校验该 PSI 是否存在或 Active 时，若校验失败，docx 文档要求“阻断后续流转”，而 Jira Story `LEAD-230` 则侧重于“记录校验失败的 reason，然后流转”。
* **深度讲解**：直接拦截（Hard Stop）意味着将线索废弃，不再允许路由分发，这会直接降低线索量，可能导致潜在业务流失；而不拦截则意味着该带有无效 PSI 的线索将流向下游分配，由于 PSI 无效，下游可能遭遇分配给未激活顾问的异常。
* **规避建议**：需要业务方确认，对于新客户自带无效 PSI 的情况，是应该作为硬熔断废弃（Hard Stop），还是应该将其降级为“无 PSI 的普通线索”进行常规分配（如分派给公共池，仅在审计中记录错误原因）。

### P0-5: 校验执行顺序没有最终定稿
* **发现描述**：团队在 Jira 评论区中讨论过 Channel 校验、Campaign 存在性、Dedup 重复校验、以及 PSI 识别与格式化的最终顺序，但目前的解决方案中没有一份经过业务和技术共同签字确认的最终 Rule Matrix。
* **深度讲解**：在责任链模式下，**执行顺序**不仅决定了业务逻辑的正确性（如已故核查必须在客户唯一匹配成功后执行），还极大地影响系统性能。如果在耗时的外部接口调用（如 EDR 接口）之后才执行简单的本地去重或姓名格式校验，一旦去重失败触发硬拦截，之前的外部 API 调用开销就被白白浪费了。
* **规避建议**：业务与技术人员需正式敲定执行顺序矩阵，列明每条规则的代码、执行顺序、前置依赖条件和熔断行为，以此作为唯一的代码编写与验收标准。

---

## 2. 需要业务沟通确认 (Requires Business Clarification)

### B-1: want2Talk2PSI=false 的最终路由
* **需确认问题**：当客户指定顾问且选择不与默认的 PSI 联系时（`want2Talk2PSI = false`），系统是否仍执行针对客户名下原有 PSI 的识别和校验？在此情况下，线索应当如何路由？
* **背景与建议**：系统应继续进行客户 PSI 识别以便记录完整的客户画像，但路由分发层应屏蔽该 PSI，将线索路由至 General Pool 或 DFA。审计日志中需记录标准的免除路由原因，例如：`"PSI Contact Not Requested"` 或 `"Non-PSI routing applied per customer intent"`。

### B-2: Invalid PSI Channel / Inactive PSI 的业务状态
* **需确认问题**：如果校验出 PSI 渠道非法（Invalid Channel）或已失效（Inactive），该线索的主状态（Lead State）是否必须修改为 `Validation Failed`？还是仅作为异常挂起，允许降级分配？
* **背景与建议**：如果修改为主状态 `Validation Failed`，电销系统将不再跟进此线索。如果不修改，则允许线索流转但需转入异常池或公共池处理。

### B-3: Deceased Indicator 来源
* **需确认问题**：已故状态核查（Deceased Check）的数据源是仅读取 IG 本地客户主表字段 `INDIVIDUALS_CLIENT_LIST`，还是实时查询外部人口登记接口？当接口超时或缺失数据时，线索是直接拦截、打标记通过，还是转入人工审核？
* **背景与建议**：通常建议以本地 SOR 数据源为准，并在发生系统异常或缺失数据时，将已故指标标记为 `Error` 并流向人工异常处理通道，而不是直接拒单。

### B-4: Channel 判定字段 mandatory
* **需确认问题**：进线渠道合规判断依赖 `segmentCode` 和 `country` 字段。系统是否能在所有进线数据源（SQS 消息、Excel 批量上传、DAE 手动录入）中强制要求这两个字段必填？
* **背景与建议**：如果某些上游渠道本期无法强制提供这两个字段，系统就必须建立一套安全的默认降级映射规则（例如，根据 `lead.source` 映射默认渠道），并将其作为正式的验收规则写入文档。

### B-5: 标准 non-PSI route / exception route
* **需确认问题**：当进线无 PSI 且客户也无 PSI 时，线索可以通过校验，但后续的具体路由路径是什么？
* **背景与建议**：需要业务定义清晰的 non-PSI 路由规则（例如，默认分发至国家公共流量池），防止线索在通过校验后被分发引擎挂起。

### B-6: Multiple Matching Customers 的处理
* **需确认问题**：如果通过“姓名 + 手机号”模糊匹配到了多个不同的 Customer ID，是否明确为非硬拦截？后续的 PSI 校验和已故核查是否应该跳过？
* **背景与建议**：由于模糊匹配到多个人，系统无法自动关联单一客户。所以应判定此步骤为 `Non-Hard-Stop`，但由于没有唯一的 Customer ID，必须**跳过后续所有依赖该老客的校验步骤（状态记为 `SKIPPED`）**，并向异常表写入 `Multiple Matching Customers Identified`，线索最终流向人工处理。

---

## 3. 需要技术主管 (TL) / 现有代码逻辑确认

### T-1: 规则可配置的本期边界
* **需确认问题**：`LEAD-206` 中提出的“无需修改执行逻辑即可更改规则”的低代码配置设计，本期是否只以代码中的元数据字典或常量形式存在，还是必须实现完整的数据库表配置和热更新功能？
* **背景与建议**：如果项目排期紧张（如总工时受限），建议第一阶段仅通过代码内的配置类或策略模式类来实现动态链组装，暂不引入复杂的 Redis Pub/Sub 广播热重载，作为技术债在后续阶段补齐。

### T-2: PSI outcome 存储位置
* **需确认问题**：校验得出的各项决策状态（如老客匹配 `existing_customer_indicator`、已故标识 `deceased_indicator`、PSI 活跃标识 `psi_active_indicator` 等）应该持久化在交易库的什么位置？
* **背景与建议**：为了贯彻“不修改 `iic_crm_leads` 核心交易表”的原则，这些过程状态不应以字段形式加在 leads 表中。它们应当在内存的 `ValidationContext` 中传递，只在校验结束时以行记录形式插入 `lead_validation_audit` 审计流水表中。Snowflake 通过透视视图（Pivot View）聚合获取这些状态。

### T-3: 异常与审计事务策略
* **需确认问题**：异常和审计日志的写入采用 Spring 的 `REQUIRES_NEW` 独立事务传播级别，如果因数据库死锁或网络抖动导致审计表写入失败，只打印 warning 并不回滚核心线索流程提交。这样是否存在审计凭证丢失风险？是否需要额外的重试队列？
* **背景与建议**：为防止核心业务因审计库故障而挂起，不回滚是正确的。但对于需要强审计合规的业务，应当考虑在写入失败时，向本地日志文件、AWS SQS 重试队列或本地死信队列中抛送一条备份记录，以备补偿。

### T-4: 当前 DAE as-is channel fallback
* **需确认问题**：现有代码中根据 `lead.source`、`campaign`、`rewardNaCampaignIds` 进行渠道校验及 `NAM_PF / NA_PF` 映射的旧逻辑，具体位于哪些类中？
* **背景与建议**：TL 应当指出这些老代码的包名与类名入口，防止开发团队重新写一套判断逻辑，造成渠道判定规则在系统中出现多头维护。

### T-5: 客户匹配写回 Customer ID
* **需确认问题**：模糊匹配成功后，自动回填 Customer ID 至线索记录中，具体的写回字段是什么？是否会引发页面渲染的副作用？
* **背景与建议**：需要 TL 指定 leads 表中用于存放关联客户 ID 的物理字段（如 `client_id` 或 `customer_id`），并核实回填操作是否会触发下游系统（如 CRM 或电销界面）的自动拉取或页面重绘。

### T-6: 表结构章节与实际实现一致性
* **需确认问题**：数据库设计章节中列出的 `validation_rule_registry` 新表以及 `iic_crm_leads_exception_report` 的新增列，此前是否在上一阶段（Lead-62）中已随其他 DDL 部署？还是需要在本期物理创建？
* **背景与建议**：需开发人员去 Dev/Sit 环境的物理库中检查字段是否存在，若不存在，需将 DDL 整理至本次发布分支的 Liquibase 或 flyway 迁移文件中。

---

## 4. 解决方案文档建议补充内容

为使解决方案成为开发与测试的唯一正确依据，建议将本次评审结论回填并补充以下章节：

1. **增设全局唯一 Rule Matrix**：合并所有 Story 涉及的规则，列明：`rule_code`、`story`、`scope`、`dependency`、`hard_stop`、`fail behavior`、`audit/exception destination`。
2. **分离业务顺序与技术顺序**：业务顺序仅描述依赖关系；技术顺序允许进行性能优化（例如，将慢速外部 EDR/OMIPAY 接口放在所有本地快校验都通过之后执行）。
3. **补充异常分类决策表**：清晰描述 Hard Stop、Non-Hard Stop、Exception Process、Audit Only 在异常捕获后，分别如何修改 Lead 主表状态、是否继续校验链、是否允许分配路由。
4. **明确 want2Talk2PSI = false 的路由图**：将“不做 PSI 分配，流向公共池或 DFA，记录审计原因”作为正式逻辑分支写入流程图。
5. **修正数据库章节**：如果确认 DDL=0，则删去所有新增字段和表的 DDL 描述；如果需要新增，则补充完整的 Migration 脚本。
