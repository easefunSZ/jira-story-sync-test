`Create Category`（新建分类/子分类，`POST /v2/category`）接口很慢，通常是由**数据库缺少索引导致的全表扫描**或**大事务内包含了网络开销**造成的。

下面为您分析 5 大常见根因，并提供**可以直接复制给内网 AI 的专项性能调查提示词**：

---

### 一、 `Create Category` 变慢的 5 大常见后端根因

1. **查重 SQL 缺失联合索引（最常见原因）**
   - 新建分类时，后端必须执行重名校验：
     `SELECT count(1) FROM iic_msg_email_category WHERE parent_id = ? AND category_name = ? AND is_deleted = 0;`
   - 如果 `(parent_id, is_deleted, category_name)` 上没有联合索引，MySQL 会执行 **Full Table Scan（全表扫描）**！随着表数据增加，耗时成倍暴增。
2. **计算 `MAX(sort_order)` 触发全表扫描**
   - 新建分类时，为了获取最新序号，后端通常会查：
     `SELECT COALESCE(MAX(sort_order), 0) FROM iic_msg_email_category WHERE parent_id = ? AND is_deleted = 0;`
   - 若缺失 `(parent_id, is_deleted, sort_order)` 索引，`MAX()` 运算也会导致全表扫描。
3. **`@Transactional` 事务过大（大事务阻塞）**
   - 如果在同一个数据库事务方法内，同步发起了远程 RPC 调用、HTTP 外部请求或同步刷新集中式 Redis 缓存，数据库连接与行锁被长期占用无法释放。
4. **雪花算法/ID 生成器锁竞争**
   - 后端生成 Snowflake ID 时，若使用了全局 `synchronized` 同步锁或触发了时钟回拨等待。
5. **同步写审计历史表开销**
   - 每次新建都同步写 `iic_msg_email_category_change_history`。若历史表巨大且缺乏合适索引，写入延迟变高。

---

### 二、 给内网 AI 的【专项性能调查提示词】

请直接全选复制以下提示词发给内网 AI：

```text
你是 DAE 项目的代码与数据库性能分析工程师。请只分析代码和 SQL 性能，不要修改任何文件。

变更编号：CHG-20260724-PERF
Feature/Story：LEAD-93 / LEAD-293 Create Category Performance
业务背景：现网/QA 环境中 POST /web/msg/template/email/v2/category (Create Category) 接口响应极慢。请排查后端实现逻辑与数据库 SQL 性能瓶颈。

本次调查排查目标：

1. 查重 SQL 索引排查：
   - 定位校验 category_name 是否重复的 SQL 语句。
   - 查看 iic_msg_email_category 表上是否有 (parent_id, is_deleted, category_name) 的联合索引。
   - 确认该查询是否引发了全表扫描 (Full Table Scan)。

2. 排序号 MAX() SQL 排查：
   - 定位计算最新 sort_order 序号的 SQL。
   - 检查是否有 (parent_id, is_deleted, sort_order) 索引支持覆盖索引查询。

3. 事务与外部调用排查：
   - 检查 Create Category 对应的 Service 方法上的 @Transactional 声明范围。
   - 确认事务内部是否包含了 RPC、HTTP 外部调用、日志同步落盘或 Redis 缓存刷新等非 DB 瓶颈操作。

4. 历史表同步写入开销：
   - 排查同步写入 iic_msg_email_category_change_history 的逻辑与 SQL 执行耗时。

请按以下格式返回：
一、找到的代码与 SQL 路径（Controller / Service / Mapper / XML）
二、性能瓶颈根因诊断（SQL 执行计划、索引缺失情况、大事务问题）
三、建议的优化方案（索引加建 SQL、代码异步化/大事务拆分建议）
```

---

### 三、 预期后端的最佳优化标准

内网 AI 调查后，标准的优化结果应该包含以下两项：

1. **加建联合索引（数据库层面）**：
   ```sql
   -- 1. 解决重名校验全表扫描
   ALTER TABLE iic_msg_email_category 
   ADD INDEX idx_parent_name_deleted (parent_id, category_name, is_deleted);

   -- 2. 解决计算最大 sort_order 的全表扫描
   ALTER TABLE iic_msg_email_category 
   ADD INDEX idx_parent_deleted_sort (parent_id, is_deleted, sort_order);
   ```

2. **代码层面缩小事务**：
   - 将“重名校验与 Snowflake ID 生成”移到 `@Transactional` 事务体**外部**。
   - 事务内部只保留单条 `INSERT` 动作，将数据库锁持有时间缩短到 1 毫秒以内。