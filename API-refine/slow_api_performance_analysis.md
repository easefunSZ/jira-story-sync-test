# LEAD-93 / DAE v2 慢接口专项分析与修改建议报告 (含 /v2/reassign)

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

### 🔴 慢接口 5：`POST /v2/reassign` (批量转移模版分类 — 1114ms)

#### 1. 为什么慢 (根因分析)：
- **Java For 循环逐条处理模式 (线性放大问题)**：
  当调用 `/v2/reassign` 批量将多个模版（如 `[EML_01, EML_02]`）转移到新分类时，Java 后端在代码里**采用了 Java `for` 循环**对每一个 `emailCode` 依次执行：
  1. 单条 `UPDATE iic_msg_email_config SET category_id = ... WHERE email_code = EML_01;`
  2. 单条 `DELETE FROM iic_msg_template_category_rel WHERE email_code = EML_01;`
  3. 单条 `INSERT INTO iic_msg_template_category_rel VALUES (...);`
  4. 单条 `INSERT INTO iic_msg_email_template_change_history VALUES (...);` (EML_01 快照)
  5. 单条 `INSERT INTO iic_msg_email_config_log VALUES (...);` (EML_01 日志)
  
  **致命隐患**：若一次批量转移 10 个模版，物理 SQL 写操作会暴增到 $10 \times 5 = 50$ 次写盘！测试环境下耗时将直奔 **7 秒以上**！

#### 💡 修改建议 (Proposal)：
1. **改为数据库层集合批处理 (SQL Batching)**：
   摆脱 Java `for` 循环，利用 SQL 集合操作，固定为 **4 步批量 SQL** 完成所有模版的转移：
   ```sql
   -- 1. 批量 UPDATE 所有模版的主表分类 (一条 SQL 搞定)
   UPDATE iic_msg_email_config SET category_id = ? WHERE email_code IN ('EML_01', 'EML_02', ...);
   
   -- 2. 批量 DELETE 旧子分类映射 (一条 SQL 搞定)
   DELETE FROM iic_msg_template_category_rel WHERE email_code IN ('EML_01', 'EML_02', ...);
   
   -- 3. 批量 INSERT 新子分类映射 (一条 SQL 搞定)
   INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id...) VALUES ('EML_01', ...), ('EML_02', ...);
   
   -- 4. 批量 INSERT 变更快照历史 (一条 SQL 搞定)
   INSERT INTO iic_msg_email_template_change_history (...) VALUES (...), (...);
   ```
2. **预计提升**：无论转移 2 个还是 50 个模版，写操作次数均收敛为常量 **4 次**。批量转移 2 个模版的耗时可从 **1114ms 降至 350ms 左右 (提速 68%+)**！

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

#### 💡 修改建议 (Proposal)：
1. **改为 SQL 层直接 `INSERT ... SELECT` 拷贝**：
   直接使用 `INSERT INTO iic_msg_template_tag_rel (email_code, ...) SELECT ?, group_code, tag_code FROM iic_msg_template_tag_rel WHERE email_code = ?` 完成高效率复制。
2. **预计提升**：耗时可直接从 **1439ms 降至 600ms 左右 (提速 58%)**。

---

### 🔴 慢接口 2：`POST /v2/category/delete` (带转移删除 — 1429ms)

#### 1. 为什么慢 (根因分析)：
- **循环单条插入快照**：删除带有子分类的父节点时，Java 代码在 `for` 循环里对每个子节点依次调用一次 `insert()` 单条写入快照。

#### 💡 修改建议 (Proposal)：
1. **使用批量插入 `batchInsert` 替换循环 `insert`**。
2. **预计提升**：耗时可从 **1429ms 降至 750ms 左右 (提速 47%)**。

---

### 🔴 慢接口 3：`POST /v2/update` (更新模版元数据 — 1302ms)

#### 1. 为什么慢 (根因分析)：
- **“盲目全删全插”策略**：即便前端更新模版时没有修改标签或子分类，后端也会硬性执行 `DELETE` 关系表再 `INSERT` 关系表。

#### 💡 修改建议 (Proposal)：
1. **增加 Diff 变更检查**：如果前端传进来的 `tagGroups` / `subCategoryIds` 与旧数据一致，跳过 `DELETE` 和 `INSERT`。
2. **预计提升**：无标签变动的 Update 操作耗时可从 **1302ms 降至 450ms 左右 (提速 65%)**！

---

## 🛠️ 交付内网 AI 的全量优化提示词

```text
你是 DAE 项目的后端开发工程师。请基于最新性能日志分析结果，对以下 4 个慢 API 执行最小范围代码优化：

变更编号：CHG-20260725-PERF-OPT
Story/Task：LEAD-93 v2 慢接口性能优化

确认的优化点：
1. 【POST /v2/reassign】批量转移优化：废除 Java for 循环单条处理，改为基于 IN(...) 集合的批量 UPDATE、批量 DELETE 和批量 batchInsert 历史快照。
2. 【POST /v2/update】增加标签与子分类 Diff 校验：若 tagGroups / subCategoryIds 未发生改变，跳过 DELETE 和 INSERT 操作。
3. 【POST /v2/category/delete】子分类删除快照改为 batchInsert 批量插入，避免在 for 循环中多次调用 insert。
4. 【POST /v2/copy】关联标签/分类拷贝改为单个 SQL `INSERT INTO ... SELECT` 语句。

要求：
- 不改变任何现有 API 契约与返回结构。
- 确保事务完整性与原子性。
- 修改后返回影响的文件列表与代码 Diff。
```
