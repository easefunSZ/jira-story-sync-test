# Brainstorming Report: High-Level Analysis & Architectural Roadmap for DAE PF Leads

本报告针对 DAE PF Leads 需求库（25个 Candidate Epic/Feature, 80个 Stories）进行高级技术与业务分析，旨在明确系统需要解决的核心痛点，剖析业务核心关注功能与需求拆分逻辑，并作为**高级技术专家（Tech Lead）**，针对该系统的准备工作、架构设计和演进提供系统化的建议。

---

## 🎯 1. 核心要解决的问题 (Problems to Solve)

从整体需求集来看，DAE PF Leads 系统主要解决三大核心痛点：

1. **“线索漏斗”的数据污染与派单损耗**
   - **痛点**：上游 Everlytic Webhook 频繁推入重复线索，MADM 手动批量上传的大文件中存在格式残缺、Sales Code（PSI 编码）缺失以及客户已过世（Deceased）的死单。
   - **解决目标**：通过前置校验管道（Validation Pipeline），在最前端拦截并自动修复（如根据客户关联补齐 PSI Code）或直接过滤无效线索，保障分发给顾问的每一条线索都具有“高服务价值”和“可转换性”。

2. **硬编码校验规则带来的“发布冗余”**
   - **痛点**：当前校验逻辑硬编码在系统内，一旦业务部门需要新增一个校验项（例如针对某个特定 Campaign 的首选顾问过滤规则），必须修改代码、打包、测试并走漫长的变更发布流程。
   - **解决目标**：提供一套**元数据驱动的动态校验引擎**，使业务运营人员可以直接通过配置（决策表、SpEL 表达式）随时热插拔校验规则。

3. **分发引擎（Allocation Engine）黑盒化与顾问展业效率低下**
   - **痛点**：分配路由逻辑不透明，业务方无法动态调节各理财团队的派单权重；且顾问收到线索后缺乏辅助展业工具，点击跟进路径过长（多次状态确认）。
   - **解决目标**：将分配逻辑配置化，并集成“理财顾问实时可用状态”；同时引入 AI 技术富化线索意图，为顾问生成“开场白（Opening Pitch）”和个性化营销文案（AI Created Templates）。

---

## 💎 2. 业务最重视的是什么功能 (Business Priorities)

根据需求的状态和描述，业务方关注的优先级（Business Value Core）呈现以下梯度：

1. **P0 级核心：线索去重（Deduplication）与数据防阻断**
   - **代表需求**：`LEAD-62`（线索与活动校验）、`LEAD-13`（Everlytic 重复线索转 Hot Lead 提权）。
   - **原因**：将重复的线索多次派发给不同顾问不仅严重降低客户体验，还会造成顾问之间的内耗；同时，大文件批量上传时，单条记录报错绝对不能阻断整批线索的摄入（`LEAD-87`）。

2. **P1 级核心：PSI（中介/顾问代码）的智能校验与自动补齐**
   - **代表需求**：`LEAD-4`（中介与客户校验）、`LEAD-84`（自动补齐缺失的 Lead PSI）。
   - **原因**：PSI 关系到佣金归属和分发路由。当线索缺少 PSI 时，系统能够自动反查客户主数据进行智能匹配，避免因数据质量问题将线索分发给错误的顾问。

3. **P2 级：动态分配规则与顾问状态感知**
   - **代表需求**：`LEAD-8`（附加分配规则）、`LEAD-7`（顾问休假/可用状态拦截）。
   - **原因**：将线索只分发给“处于工作状态、且符合该线索属性（如邮编、收入段）”的顾问，避免死单堆积在离职或休假顾问的信箱中。

---

## 🗂️ 3. 为什么要这么拆分需求 (Splitting Rationale)

当前的 25 个 Epic/Feature 呈现了清晰的**“六大职能板块（Ingestion -> Validation -> Enrichment -> Allocation -> Content -> UI/Reporting）”**。这种拆分方式蕴含了深度的系统设计哲学：

1. **按“线索生命周期（Lead Lifecycle）”线性解耦**
   - **原因**：线索从流入到跟进是一个标准的漏斗模型。通过将 **Ingestion（摄入）** 与 **Validation（校验）** 解耦，可以独立扩展接收端（例如未来新增渠道只需扩展 Ingestion，不影响校验）；将 **Validation（准入限制）** 与 **Allocation（分配流向）** 解耦，能确保只有干净的数据才能触及复杂的分配决策表，极大降低了分配引擎的计算复杂度。

2. **区分“高动态业务逻辑”与“高性能技术底座”**
   - **原因**：把“硬编码规则改造（`LEAD-145`）”作为独立 Feature 提出来，是在底层做“引擎升级”；而“添加具体分配规则（`LEAD-8`）”是应用层规则的叠加。这样拆分能够让研发团队在重构底层引擎时不干扰现有业务分配逻辑。

3. **独立封装“展业辅助（Content/AI）”与“核心交易流”**
   - **原因**：AI 辅助功能（如 AI 开场白、视频上传等）虽然能提升效率，但它们不属于派单主链路。将其拆分为独立的 Feature，可以采用微前端、异步加载等方式引入，防止外部大视频文件上传或 LLM 延迟阻塞主派单线程。

---

## 🛠️ 4. 高级技术开发人员（Tech Lead）的准备、设计与建议

作为 DAE 系统的高级技术人员，针对这一系列需求，我提出以下架构设计与技术准备建议：

### A. 技术准备工作 (Preparations)
1. **压测环境与影子流量验证 (Shadow Routing)**
   - **行动**：由于涉及 80 个故事的规则重构，必须在 Staging 环境搭建**影子双轨运行通道**。新设计的 SpEL/URule 规则引擎与老代码并行跑同一份 Payload，比对校验结果和分配路由是否 100% 一致。
2. **基准性能压测 (Benchmark)**
   - **行动**：使用 Gatling 或 JMeter 对老系统的硬编码校验和分配进行压测，记录 TPS 和 P99 延迟，作为重构后规则引擎的性能底线指标。

### B. 架构设计建议 (Architectural Designs)

#### 1. 混合规则引擎架构 (Hybrid Rule Architecture)
不要盲目将所有规则扔进 URule。建议设计分层规则表 `leads_validation_rule`：

```sql
CREATE TABLE leads_validation_rule (
    rule_id VARCHAR(50) PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(20) NOT NULL, -- 'SPEL' (本地计算), 'URULE' (动态决策)
    expression TEXT NOT NULL,       -- SpEL 表达式 (如: 'payload.firstName != null')
    is_active BOOLEAN DEFAULT TRUE,
    error_code VARCHAR(50),
    error_message VARCHAR(255),
    version INT DEFAULT 1,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

- **格式/非空校验**：采用 **SpEL（Spring Expression Language）** 在 JVM 本地执行。通过 AOP 拦截并加载，配合 **Caffeine 本地缓存** 缓存已编译的 SpEL 表达式（缓存 Key 为 `rule_id`，Value 为编译后的 `Expression` 实例），执行时间控制在微秒级。
- **业务路由分配**：将“顾问组权重”、“复杂邮编范围”等通过 **URule 决策表** 进行配置，通过接口触发。

#### 2. 并发去重与 Redis 锁优化 (Concurrency & Locking)
在高并发 Webhook 摄入时，为了防止同 ID/邮箱的线索被重复派单，必须进行分布式加锁：
- **方案**：采用 **Redis 红锁（Redisson）**，以 `lock:lead:dedup:{email/identityNumber}` 作为锁 Key。
- **优化**：只对“去重校验阶段”加锁，锁持有时间设为极短的 `1s`（Lease Time）。去重校验通过后即释放锁。后续的 Enrichment 和 Allocation 步骤无需持锁，依靠数据库的唯一约束（`lead_id + campaign_id`）做最终防重兜底，从而释放 Webhook 的吞吐量。

#### 3. 异步富化与熔断降级 (Asynchronous Enrichment & Resiliency)
在 `LEAD-92`（线索富化）中，系统需要调用外部 API 获取客户收入段和意图数据：
- **设计**：采用 Java `CompletableFuture` 开启异步线程池执行外部 HTTP 请求。
- **熔断**：配置 `Resilience4j` 熔断器，强设超时时间为 `200ms`。
- **降级**：一旦超时或外部系统挂掉，自动触发 fallback 逻辑，填充默认收入段（如 `Unknown`），并将线索迅速流转至分配阶段，**绝不能因为外部富化系统的问题导致派单中断**。

```java
// 核心逻辑示意
CompletableFuture<EnrichmentData> enrichFuture = CompletableFuture.supplyAsync(
    () -> externalClient.fetchEnrichment(lead.getCustomerId()), enrichmentExecutor
);

try {
    EnrichmentData data = enrichFuture.get(200, TimeUnit.MILLISECONDS);
    lead.applyEnrichment(data);
} catch (TimeoutException e) {
    log.warn("Enrichment timeout, fallback to default value for lead {}", lead.getId());
    lead.applyEnrichment(EnrichmentData.defaultFallback());
}
```

#### 4. CDC 审计与分析型读写分离 (CDC & Analytics Read-Write Splitting)
对于 `LEAD-9`（导出 CDF 供 PFMi 报表分析）和 `LEAD-12`（管理层汇总看板）：
- **建议**：绝对禁止直接在生产 OLTP 数据库上执行跨活动的聚合统计 SQL。
- **方案**：使用 **Debezium CDC** 监听 `lead_record` 和 `lead_validation_history` 表的 binlog，将数据实时投影到 Kafka。下游消费端将数据写入只读分析型数据库（如 ClickHouse）或 Elasticsearch，供前端展示看板和审计团队拉取，实现读写物理隔离，保障主交易系统的高可用。

### C. 演进路线建议 (Roadmap Suggestions)
- **第一阶段：基石期**。统一入参 Payload（`LEAD-227`），落地去重和基本合法性校验（`LEAD-62` / `LEAD-4`），为后续流程建立标准输入输出模型。
- **第二阶段：引擎期**。重构动态校验引擎（`LEAD-145`），在小范围（如指定 Campaign）跑通 SpEL 动态校验，完成影子测试后全量铺开。
- **第三阶段：赋能期**。引入 AI 富化建议、Content Library 营销模板及顾问状态感知派单，实现从“能分发”到“分得准、跟得快”的业务跃迁。
