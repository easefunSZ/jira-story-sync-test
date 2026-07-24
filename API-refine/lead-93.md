太棒了！加了 `(is_deleted, parent_id, category_name)` 联合索引后数据库能直接通过 B+Tree 索引快速定位，提速一倍说明之前的瓶颈正是**全表扫描**。

对于 **`POST /v2/add`（保存草稿/创建新模板）** 接口，它的业务链路更长，涉及到**主表、分类关联表、标签关联表、版本表、审计表 5 张表**的写入。如果依然很慢，通常有以下 **5 个核心性能死穴**：

---

### 一、 `POST /v2/add` 的 5 大性能死穴诊断

#### 1. 模板标题重名校验 SQL 缺失索引（最主要全表扫描）
- **后台逻辑**：保存草稿前，后端必须在指定分类下校验标题是否重名：
  ```sql
  SELECT count(1) FROM iic_msg_email_config 
  WHERE category_id = :category_id AND email_name = :email_name AND is_deleted = 0 AND email_code <> :email_code;
  ```
- **病因**：如果 `iic_msg_email_config` 主表上没有 `(category_id, is_deleted, email_name)` 联合索引，**每一次保存草稿都会触发整张模板主表的全表扫描！**

#### 2. 草稿存在性与版本号计算 SQL 缺失索引
- **后台逻辑**：为了保证“同一模板最多只能有一份草稿 (Draft) 或定时任务 (Schedule)”，后端会查询：
  ```sql
  SELECT count(1) FROM iic_msg_email_version WHERE email_code = :email_code AND version_status IN (0, 3);
  SELECT MAX(version) FROM iic_msg_email_version WHERE email_code = :email_code;
  ```
- **病因**：`iic_msg_email_version` 表体积巨大（存放完整邮件正文与文件列表），若缺少 `(email_code, version_status)` 索引，版本查询极其缓慢。

#### 3. 标签/子分类关联表“先删后插”导致的表锁与多次 RTT
- **后台逻辑**：更新模板草稿的标签/子分类时，后端采用的是：
  ```sql
  DELETE FROM iic_msg_template_tag_rel WHERE email_code = :email_code;
  -- 然后循环插入新的 tag_code
  ```
- **病因**：
  - 如果 `iic_msg_template_tag_rel` 表的 `email_code` 字段**没有加索引**，`DELETE` 语句会直接升级为**行锁爆满甚至表锁/间隙锁**！
  - 循环逐条 `INSERT`（多次网络 RTT）而不是使用 `INSERT INTO ... VALUES (...), (...)` 单次批量写入。

#### 4. 在 `@Transactional` 大事务内部做 AES 加密与序列化
- `email_content` (AES 密文) 加解密、大 JSON 序列化如果放在数据库事务内部，拉长了事务持锁时间。

---

### 二、 给内网 AI 的【`POST /v2/add` 专项性能调查提示词】

请直接复制以下提示词发给内网 AI：

```text
你是 DAE 项目的代码与数据库性能分析工程师。请只分析代码和 SQL 性能，不要修改任何文件。

变更编号：CHG-20260724-PERF2
Feature/Story：LEAD-93 / LEAD-293 POST /web/msg/template/email/v2/add (Save Draft) Performance Optimization
业务背景：QA/测试环境中 POST /v2/add 接口保存草稿耗时较长。该接口涉及主表、分类关联表、标签关联表、版本表的多表校验与写入，请排查其后端性能瓶颈。

本次调查排查目标：

1. 标题重名校验 SQL 索引检查：
   - 定位校验 email_name 重名的 Mapper SQL。
   - 查看 iic_msg_email_config 表上是否有 (category_id, is_deleted, email_name) 联合索引。

2. 草稿存在性与版本号计算 SQL 检查：
   - 定位查询 version_status IN (0, 3) 及获取 MAX(version) 的 SQL。
   - 检查 iic_msg_email_version 表上是否有 (email_code, version_status) 索引。

3. 关联表 DELETE-INSERT 锁与批量写入检查：
   - 检查 iic_msg_template_category_rel 和 iic_msg_template_tag_rel 表上 email_code 字段是否有索引（防止 DELETE 锁表）。
   - 检查新增关联关系时是否使用了单条批量插入 SQL (VALUES ...)，还是 Java For 循环逐条插入。

4. 事务范围检查：
   - 检查 @Transactional 声明的方法体中，AES 加密 (emailContent) 与 JSON 序列化是否放在了事务内部。

请按以下格式返回：
一、涉及的代码与 Mapper SQL 文件路径
二、发现的性能根因（缺失的索引、锁风险、多次 RTT、大事务）
三、建议的优化 SQL 索引与代码重构方案
```

---

### 三、 推荐后台加建的 3 个关键索引

内网 AI 排查后，建议后端执行以下 3 个索引加建，预计可将 `/v2/add` 的响应耗时再降低 50% 以上：

```sql
-- 1. 主表：优化标题重名校验全表扫描
ALTER TABLE iic_msg_email_config 
ADD INDEX idx_email_config_category_name (category_id, is_deleted, email_name);

-- 2. 版本表：优化单草稿校验与版本号获取
ALTER TABLE iic_msg_email_version 
ADD INDEX idx_version_email_status (email_code, version_status, version);

-- 3. 标签关联表：防止 DELETE 锁表与加速关联查询
ALTER TABLE iic_msg_template_tag_rel 
ADD INDEX idx_template_tag_rel_email (email_code, status);
```