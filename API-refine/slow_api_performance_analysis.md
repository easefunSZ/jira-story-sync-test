# LEAD-93 / DAE v2 表现最差 (慢 API) 专项分析与修改建议报告

在全量 46 步回归测试中，我们筛选出了 **HTTP 响应耗时超过 1000ms 的 5 个表现最差 ( slowest ) 接口**。通过 `DevLogController` 抓取到的真实后端 SQL 事务链条，下面为您深入分析**为什么慢**以及**具体的代码修改意见**：

---

## 🔝 慢接口 Top 5 排行榜

| 排名 | 接口名称 / URL | HTTP 响应耗时 | SQL 读 (SELECT) | SQL 写 (WRITE) | 性能等级 |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 🥇 **1** | `POST /v2/copy` (复制草稿) | **1439 ms** | 6 次 | 7 次 | 🔴 极慢 |
| 🥈 **2** | `POST /v2/category/delete` (转移并删除分类) | **1429 ms** | 4 次 | 5 次 | 🔴 极慢 |
| 🥉 **3** | `POST /v2/update` (更新模版元数据) | **1302 ms** | 5 次 | 6 次 | 🔴 极慢 |
| 🏅 **4** | `POST /v2/version/add` (新增版本) | **1235 ms** | 4 次 | 5 次 | 🔴 极慢 |
| 🏅 **5** | `POST /v2/reassign` (批量转移模版) | **1114 ms** | 3 次 | 5 次 | 🔴 极慢 |

---

## 🔍 慢接口根因剖析与具体修改建议

---

### 🔴 慢接口 1：`POST /v2/copy` (复制独立草稿 — 1439ms)

#### 1. 为什么慢 (根因分析)：
- **SQL 写入暴增 (单请求 7 次物理写)**：
  复制一个模版时，后端在 Java 代码里发起了多达 7 次写操作：
  1. `INSERT` 拷贝主表 (`iic_msg_email_config`)
  2. `INSERT` 拷贝版本表 (`iic_msg_email_config_version`)
  3. `INSERT` 拷贝分类关联表 (`iic_msg_template_category_rel`)
  4. `INSERT` 拷贝 4 组标签关联表 (`iic_msg_template_tag_rel`)
  5. `INSERT` 变更加快照记录 1
  6. `INSERT` 变更加快照记录 2
  7. `INSERT` 审计日志表 (`iic_msg_email_config_log`)
- **冗余数据拉取**：Java 端先通过 6 次 `SELECT` 把源模版的分类和标签读到内存中，再通过 Java 拼接后做 `INSERT`。

#### 💡 修改建议 (Proposal)：
1. **改为 SQL 层直接 `INSERT ... SELECT` 拷贝 (省去 4 次 SELECT + 2 次写)**：
   不要先把源模版的标签和分类查出来放 Java 内存，直接使用一条数据库 `INSERT INTO iic_msg_template_tag_rel (email_code, ...) SELECT ?, group_code, tag_code ... FROM iic_msg_template_tag_rel WHERE email_code = ?` 即可完成高效率复制。
2. **预计提升**：响应耗时可从 **1439ms 降至 600ms 左右 (提速 58%)**。

---

### 🔴 慢接口 2：`POST /v2/category/delete` (带转移删除 — 1429ms)

#### 1. 为什么慢 (根因分析)：
- **循环单条插入快照 (N 次单条 Insert)**：
  当删除带有子分类的父分类节点时，后端在 Java `for` 循环中**对每个子节点依次调用了一次 `changeHistoryMapper.insert()`**，导致发生了多笔单条 SQL 写操作。

#### 💡 修改建议 (Proposal)：
1. **使用批量插入 `batchInsert` 替换循环 `insert`**：
   在 `IicMsgEmailCategoryChangeHistoryMapper` 中增加 `batchInsert(List<History> list)` 接口，把父节点和所有子节点的删除快照一条 SQL 批量插入：
   ```sql
   INSERT INTO iic_msg_email_category_change_history (operation_id, category_id, ...) 
   VALUES (?, ?, ...), (?, ?, ...);
   ```
2. **预计提升**：响应耗时可从 **1429ms 降至 750ms 左右 (提速 47%)**。

---

### 🔴 慢接口 3 & 4：`POST /v2/update` & `POST /v2/version/add` (1302ms / 1235ms)

#### 1. 为什么慢 (根因分析)：
- **“先全删再全插”策略 (Delete-and-Reinsert)**：
  即使更新模版时**根本没有修改标签或子分类**，后端的逻辑也是盲目执行：
  ```sql
  DELETE FROM iic_msg_template_tag_rel WHERE email_code = ?; -- 148ms
  INSERT INTO iic_msg_template_tag_rel VALUES (...);        -- 148ms
  ```
  无谓地增加了 2 次物理写盘（耗时接近 300ms）。
- **主线程同步生成 JSON 快照并插入**：
  在 HTTP 请求主线程中同步生成 `before_snapshot` 和 `after_snapshot` JSON 并执行写库。

#### 💡 修改建议 (Proposal)：
1. **增加 Diff 变更检查 (无变动免 Delete/Insert)**：
   在 Service 层更新关联关系前，判断前端传入的 `tagGroups` 和 `subCategoryIds` 是否与旧数据一致。如果完全一致，**直接跳过 `DELETE` 和 `INSERT` 过程**！
2. **变更历史与审计日志异步化 (@Async)**：
   把 `recordMetadataChangeWithSnapshots` 的快照写入标记为 `@Async` 异步线程池执行。
3. **预计提升**：无标签变动的 Update 操作耗时可从 **1302ms 降至 450ms 左右 (提速 65%)**！

---

## 🛠️ 交付修改提示词（可直接发送给内网 AI 实现）

```text
你是 DAE 项目的后端开发工程师。请基于最新性能日志分析结果，对以下 3 个慢 API 执行最小范围代码优化：

变更编号：CHG-20260725-PERF-OPT
Story/Task：LEAD-93 v2 慢接口性能优化

确认的优化点：
1. 【POST /v2/update】增加标签与子分类 Diff 校验：若 tagGroups / subCategoryIds 未发生改变，跳过 DELETE 和 INSERT 操作。
2. 【POST /v2/category/delete】子分类删除快照改为 batchInsert 批量插入，避免在 for 循环中多次调用 insert。
3. 【POST /v2/copy】关联标签/分类拷贝改为单个 SQL `INSERT INTO ... SELECT` 语句。

要求：
- 不改变任何现有 API 契约与返回结构。
- 确保事务完整性。
- 修改后返回影响的文件列表与代码 Diff。
```
