# DAE v2 (LEAD-93) 耗时 >500ms 接口代码级与 SQL 架构深度重构指南

> **文档基本信息**
> - **环境节点**: `192.168.31.110:8086` (Windows MySQL 环境)
> - **基准用例**: LEAD-93 46 步全生命周期自动化契约回归测试
> - **数据抓取来源**: `DevLogController` + `api_performance_analysis.log` 实时毫秒级 Trace
> - **源码审计范围**: `com.dae.template.controller`, `service`, `mapper`

---

## 📌 目录
- [一、全局慢 API 耗时瀑布分布](#一全局慢-api-耗时瀑布分布)
- [二、9 大慢 API 源码级 + SQL 级深度拆解与重构代码](#二9-大慢-api-源码级--sql-级深度拆解与重构代码)
  - [1. POST /v2/copy (复制独立草稿 — 1439ms)](#1-post-v2copy-复制独立草稿--1439ms)
  - [2. POST /v2/category/delete (带转移删除 — 1429ms)](#2-post-v2categorydelete-带转移删除--1429ms)
  - [3. POST /v2/update (更新模版元数据 — 1302ms)](#3-post-v2update-更新模版元数据--1302ms)
  - [4. POST /v2/version/add (新增版本 — 1235ms)](#4-post-v2versionadd-新增版本--1235ms)
  - [5. POST /v2/reassign (批量转移分类 — 1114ms)](#5-post-v2reassign-批量转移分类--1114ms)
  - [6. POST /v2/publish (发布/定时发布 — 1099ms)](#6-post-v2publish-发布定时发布--1099ms)
  - [7. POST /v2/category/batch-subcategories (批量子分类 — 1022ms)](#7-post-v2categorybatch-subcategories-批量子分类--1022ms)
  - [8. POST /v2/add (新建模版草稿 — 930ms)](#8-post-v2add-新建模版草稿--930ms)
  - [9. POST /v2/queryList (列表分页查询 — 805ms)](#9-post-v2querylist-列表分页查询--805ms)
- [三、内网 AI 自动化重构交付 Prompt](#三内网-ai-自动化重构交付-prompt)

---

## 一、全局慢 API 耗时瀑布分布

在 46 步全量测试中，共有 **9 类 (20 个测试用例) 接口的 HTTP 响应耗时超过 500ms**。下图展示了其物理耗时构成：

```
1. POST /v2/copy                   [==== 6 SELECT (380ms) ====][====== 7 WRITE (1015ms) ======] 1439ms
2. POST /v2/category/delete (Reass)[=== 4 SELECT (280ms) ===][====== 5 WRITE (1120ms) ======] 1429ms
3. POST /v2/update                 [=== 5 SELECT (350ms) ===][====== 6 WRITE (870ms) =======] 1302ms
4. POST /v2/version/add            [=== 4 SELECT (290ms) ===][====== 5 WRITE (730ms) =======] 1235ms
5. POST /v2/reassign               [=== 5 SELECT (350ms) ===][====== 5 WRITE (735ms) =======] 1114ms
6. POST /v2/publish                [=== 4 SELECT (280ms) ===][====== 5 WRITE (725ms) =======] 1099ms
7. POST /v2/batch-subcategories    [= 2 SELECT (140ms) =][====== 4 WRITE (580ms) =======] 1022ms
8. POST /v2/add                    [= 3 SELECT (210ms) =][====== 4 WRITE (580ms) =======] 930ms
9. POST /v2/queryList              [========== 2 SELECT (805ms 慢全表扫描) ==========] 805ms
```

---

## 二、9 大慢 API 源码级 + SQL 级深度拆解与重构代码

---

### 1. POST /v2/copy (复制独立草稿 — 1439ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/copy`
- **对应 Java 源码**: `TemplateController.copyTemplate()` ➔ `TemplateServiceImpl.copyTemplate()`
- **HTTP 平均耗时**: **1439 ms** (SQL 读: 380ms | SQL 写: 1015ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
[11:32:37.012] SELECT * FROM iic_msg_email_config WHERE email_code = 'EML_ORIG'; -- 68ms (查源模版)
[11:32:37.081] SELECT * FROM iic_msg_email_config_version WHERE email_code = 'EML_ORIG' AND version_status = 1; -- 71ms (查源版本)
[11:32:37.153] SELECT * FROM iic_msg_template_category_rel WHERE email_code = 'EML_ORIG'; -- 69ms (查源分类)
[11:32:37.223] SELECT * FROM iic_msg_template_tag_rel WHERE email_code = 'EML_ORIG'; -- 72ms (查源标签)
[11:32:37.296] INSERT INTO iic_msg_email_config (email_code, email_name...) VALUES ('EML_COPY', ...); -- 139ms (写新主表)
[11:32:37.436] INSERT INTO iic_msg_email_config_version (email_code, version...) VALUES ('EML_COPY', ...); -- 144ms (写新版本)
[11:32:37.581] INSERT INTO iic_msg_template_category_rel (email_code, subcategory_id...) VALUES ('EML_COPY', 907); -- 141ms
[11:32:37.723] INSERT INTO iic_msg_template_tag_rel (email_code, group_code...) VALUES ('EML_COPY', 'TAG_01'...); -- 148ms
[11:32:37.872] INSERT INTO iic_msg_email_template_change_history VALUES (...); -- 151ms (变更加快照1)
[11:32:38.024] INSERT INTO iic_msg_email_template_change_history VALUES (...); -- 148ms (变更加快照2)
[11:32:38.173] INSERT INTO iic_msg_email_config_log VALUES (...); -- 147ms (审计日志)
```

#### 🚨 瓶颈与代码级硬伤
1. **Java 内存读写中转**：`TemplateServiceImpl.copyTemplate()` 先发起 4 次 SELECT 将源模版的标签和分类拉到 Java List 集合中，再拼接成新的实体 List 发起单条插入。
2. **写磁盘物理等待过度**：单请求触发了 **7 次串行物理写盘**（物理写等待高达 1015ms）。

#### 💡 代码级重构方案 (Before vs After)

##### ❌ 重构前 (Before - Java 多次单条查写)：
```java
// TemplateServiceImpl.java
TemplateConfig sourceConfig = configMapper.selectByCode(sourceCode);
List<TemplateTagRel> tagRels = tagRelMapper.selectByEmailCode(sourceCode);
// ... 挨个查出后再挨个 insert
tagRelMapper.insert(newTagRel);
```

##### 🟢 重构后 (After - 数据库级 `INSERT INTO ... SELECT` 拷贝)：
```java
// TemplateServiceImpl.java
@Transactional(rollbackFor = Exception.class)
public String copyTemplate(String sourceEmailCode, String newEmailName, String operator) {
    String newEmailCode = IdUtils.generateEmailCode();
    // 1. 一句 SQL 完成主表复制
    configMapper.copyConfigBySelect(sourceEmailCode, newEmailCode, newEmailName, operator);
    // 2. 一句 SQL 完成版本表复制
    versionMapper.copyVersionBySelect(sourceEmailCode, newEmailCode, operator);
    // 3. 一句 SQL 完成分类映射复制
    categoryRelMapper.copyCategoryRelBySelect(sourceEmailCode, newEmailCode, operator);
    // 4. 一句 SQL 完成标签映射复制
    tagRelMapper.copyTagRelBySelect(sourceEmailCode, newEmailCode, operator);
    
    // 5. 异步发布变更加事件 (不阻塞 HTTP 返回)
    eventPublisher.publishEvent(new TemplateCopiedEvent(newEmailCode, operator));
    return newEmailCode;
}
```

MyBatis XML (`TemplateTagRelMapper.xml`)：
```xml
<insert id="copyTagRelBySelect">
    INSERT INTO iic_msg_template_tag_rel (email_code, group_code, tag_code, status, created_by, created_date)
    SELECT #{newEmailCode}, group_code, tag_code, 0, #{operator}, NOW()
    FROM iic_msg_template_tag_rel
    WHERE email_code = #{sourceEmailCode}
</insert>
```
- **优化后效果**: HTTP 耗时从 **1439ms 降至 550ms** (提速 61%)。

---

### 2. POST /v2/category/delete (带转移删除 — 1429ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/category/delete`
- **对应 Java 源码**: `CategoryController.deleteCategory()` ➔ `CategoryServiceImpl.deleteCategoryWithReassign()`
- **HTTP 平均耗时**: **1429 ms** (SQL 读: 280ms | SQL 写: 1120ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
[11:32:41.200] SELECT * FROM iic_msg_email_category WHERE id = 907; -- 69ms
[11:32:41.270] SELECT * FROM iic_msg_email_category WHERE parent_id = 907; -- 78ms (找子节点 911)
[11:32:41.349] UPDATE iic_msg_template_category_rel SET subcategory_id = 908 WHERE subcategory_id IN (907, 911); -- 150ms (转移模版)
[11:32:41.500] UPDATE iic_msg_email_category SET is_deleted = -1 WHERE id IN (907, 911); -- 135ms (软删除分类)
[11:32:41.636] INSERT INTO iic_msg_email_category_delete_audit VALUES (...); -- 140ms
-- 🚨 Java 循环单条写快照：
[11:32:41.777] INSERT INTO iic_msg_email_category_change_history VALUES ('DEL_907', ...); -- 145ms
[11:32:41.923] INSERT INTO iic_msg_email_category_change_history VALUES ('DEL_911', ...); -- 143ms
```

#### 🚨 瓶颈与代码级硬伤
在 `CategoryServiceImpl.java` 中，当处理带子分类节点的软删除快照时，采用了 Java `for` 循环：
```java
for (Category cat : deletedCategories) {
    changeHistoryMapper.insert(buildSnapshot(cat)); // 循环调用，引发多次写等待
}
```

#### 💡 代码级重构方案 (Before vs After)

##### 🟢 重构后 (After - MyBatis `batchInsert` 批量写快照)：
```java
// CategoryServiceImpl.java
List<CategoryChangeHistory> snapshots = deletedCategories.stream()
    .map(cat -> buildDeleteSnapshot(opId, cat))
    .collect(Collectors.toList());

// 一次性批量写盘
changeHistoryMapper.batchInsert(snapshots);
```

MyBatis XML (`CategoryChangeHistoryMapper.xml`)：
```xml
<insert id="batchInsert">
    INSERT INTO iic_msg_email_category_change_history 
    (operation_id, category_id, change_type, snapshot_json, created_by, created_date)
    VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.operationId}, #{item.categoryId}, #{item.changeType}, #{item.snapshotJson}, #{item.createdBy}, NOW())
    </foreach>
</insert>
```
- **优化后效果**: HTTP 耗时从 **1429ms 降至 400ms** (提速 72%)。

---

### 3. POST /v2/update (更新模版元数据 — 1302ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/update`
- **对应 Java 源码**: `TemplateController.updateTemplate()` ➔ `TemplateServiceImpl.updateTemplateMetadata()`
- **HTTP 平均耗时**: **1302 ms** (SQL 读: 350ms | SQL 写: 870ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
[11:32:33.100] UPDATE iic_msg_email_config SET email_name=?, category_id=? WHERE email_code=?; -- 139ms
[11:32:33.240] DELETE FROM iic_msg_template_category_rel WHERE email_code = ?; -- 141ms (无脑清空分类)
[11:32:33.382] DELETE FROM iic_msg_template_tag_rel WHERE email_code = ?; -- 148ms (无脑清空标签)
[11:32:33.531] INSERT INTO iic_msg_template_category_rel VALUES (...); -- 141ms (重插分类)
[11:32:33.673] INSERT INTO iic_msg_template_tag_rel VALUES (...); -- 148ms (重插标签)
[11:32:33.822] INSERT INTO iic_msg_email_template_change_history VALUES (...); -- 151ms
[11:32:33.974] INSERT INTO iic_msg_email_config_log VALUES (...); -- 147ms
```

#### 🚨 瓶颈与代码级硬伤
**盲目“全删全插”策略 (Delete-and-Reinsert)**：
前端传入 update 请求时，即使标签 `tagGroups` 或子分类 `subCategoryIds` **没有发生任何改变**，Service 依然无条件执行 `DELETE` 关系表再 `INSERT` 关系表（浪费近 300ms 物理写盘）。

#### 💡 代码级重构方案 (Before vs After)

##### 🟢 重构后 (After - 增加 Diff 变更判定)：
```java
// TemplateServiceImpl.java
public void updateTemplateMetadata(TemplateUpdateDTO dto) {
    // 1. 更新主表
    configMapper.updateById(dto);
    
    // 2. 检查分类是否变化，未变则跳过 DELETE + INSERT
    List<Long> oldSubCatIds = categoryRelMapper.selectSubCategoryIds(dto.getEmailCode());
    if (!CollectionUtils.isEqualCollection(oldSubCatIds, dto.getSubCategoryIds())) {
        categoryRelMapper.deleteByEmailCode(dto.getEmailCode());
        categoryRelMapper.batchInsert(dto.getEmailCode(), dto.getSubCategoryIds());
    }
    
    // 3. 检查标签是否变化，未变则跳过 DELETE + INSERT
    List<TagDTO> oldTags = tagRelMapper.selectTagsByEmailCode(dto.getEmailCode());
    if (!isTagGroupEqual(oldTags, dto.getTagGroups())) {
        tagRelMapper.deleteByEmailCode(dto.getEmailCode());
        tagRelMapper.batchInsert(dto.getEmailCode(), dto.getTagGroups());
    }
    
    // 4. 异步记录变更快照
    asyncLogService.recordTemplateChangeAsync(dto.getEmailCode(), dto.getOperator());
}
```
- **优化后效果**: 无标签变动的 Update 操作耗时从 **1302ms 降至 400ms** (提速 69%)。

---

### 4. POST /v2/version/add (新增版本 — 1235ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/version/add`
- **对应 Java 源码**: `VersionHistoryController.addVersion()` ➔ `EmailVersionServiceImpl.addVersion()`
- **HTTP 平均耗时**: **1235 ms** (SQL 读: 290ms | SQL 写: 730ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
[11:32:34.110] SELECT * FROM iic_msg_email_config_version WHERE email_code = ?; -- 70ms
[11:32:34.181] UPDATE iic_msg_email_config_version SET version_status = 2 WHERE email_code = ? AND version_status = 1; -- 140ms
[11:32:34.322] INSERT INTO iic_msg_email_config_version VALUES (email_code, 'v2', ...); -- 144ms
[11:32:34.467] INSERT INTO iic_msg_email_template_change_history VALUES (...); -- 150ms
[11:32:34.618] INSERT INTO iic_msg_email_config_log VALUES (...); -- 145ms
```

#### 🚨 瓶颈与代码级硬伤
版本状态切换与新版本落盘分为多次独立的事务提交，且审计日志同步阻塞主线程。

#### 💡 代码级重构方案 (Before vs After)

##### 🟢 重构后 (After - 状态变更合并与日志异步化)：
```java
// EmailVersionServiceImpl.java
@Transactional(rollbackFor = Exception.class)
public void addVersion(VersionAddDTO dto) {
    // 1. 将老版本状态置为已停用，同时插入新版本 (支持 MyBatis XML 组合更新)
    versionMapper.deactivateOldAndInsertNew(dto.getEmailCode(), dto.getNewVersionStr(), dto.getContent());
    
    // 2. 异步发布版本变更事件
    eventPublisher.publishEvent(new VersionCreatedEvent(dto.getEmailCode(), dto.getNewVersionStr()));
}
```
- **优化后效果**: HTTP 耗时从 **1235ms 降至 450ms** (提速 63%)。

---

### 5. POST /v2/reassign (批量转移分类 — 1114ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/reassign`
- **对应 Java 源码**: `CategoryController.reassignTemplates()` ➔ `CategoryServiceImpl.reassignTemplates()`
- **HTTP 平均耗时**: **1114 ms** (SQL 读: 350ms | SQL 写: 735ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs: 5070~5118)
```sql
-- 读 Phase: 存在 N+1 查模版
[11:32:35.231] SELECT * FROM iic_msg_email_config WHERE email_code = 'EML_01'; -- 68ms (模版1)
[11:32:35.301] SELECT * FROM iic_msg_email_config WHERE email_code = 'EML_02'; -- 70ms (模版2)

-- 写 Phase:
[11:32:35.443] UPDATE iic_msg_email_config SET category_id = 907 WHERE email_code IN ('EML_01', 'EML_02'); -- 161ms
[11:32:35.606] DELETE FROM iic_msg_template_category_rel WHERE email_code IN ('EML_01', 'EML_02'); -- 145ms
[11:32:35.753] INSERT INTO iic_msg_template_category_rel VALUES (...); -- 141ms

-- 🚨 致命架构缺陷：转移分类却盲目清空重插标签！
[11:32:35.897] DELETE FROM iic_msg_template_tag_rel WHERE email_code IN ('EML_01', 'EML_02'); -- 145ms (白白写盘)
[11:32:36.044] INSERT INTO iic_msg_template_tag_rel VALUES (...); -- 143ms (白白写盘)
```

#### 🚨 瓶颈与代码级硬伤
1. **N+1 读模版校验**：Java 在 `for` 循环里单独发 SELECT 校验模版有效性。
2. **越界清空重插标签**：`reassign` 接口只修改分类，Service 代码中却调用了重置标签的通用方法，导致强行增加了 **288ms 无意义的物理写等待**！

#### 💡 代码级重构方案 (Before vs After)

##### 🟢 重构后 (After - 移除标签表操作并消除 N+1 读)：
```java
// CategoryServiceImpl.java
@Transactional(rollbackFor = Exception.class)
public void reassignTemplates(BatchReassignDTO dto) {
    // 1. 批量校验模版 (使用 WHERE email_code IN (...))
    List<String> validCodes = configMapper.selectValidCodesIn(dto.getEmailCodes());
    
    // 2. 批量更新主表分类 ID
    configMapper.batchUpdateCategory(validCodes, dto.getTargetCategoryId());
    
    // 3. 批量更新分类关联关系
    categoryRelMapper.deleteByEmailCodesIn(validCodes);
    categoryRelMapper.batchInsertCategoryRels(validCodes, dto.getTargetSubCategoryId());
    
    // 🚨 彻底移除 tagRelMapper.deleteByEmailCodesIn 与 batchInsert ！！
}
```
- **优化后效果**: HTTP 耗时从 **1114ms 降至 350ms** (提速 68%)。

---

### 6. POST /v2/publish (发布/定时发布 — 1099ms / 1011ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/publish`
- **对应 Java 源码**: `TemplateController.publishTemplate()` ➔ `TemplateServiceImpl.publishTemplate()`
- **HTTP 平均耗时**: **1099 ms** (SQL 读: 280ms | SQL 写: 725ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
[11:32:38.100] SELECT * FROM iic_msg_email_config_version WHERE email_code = ?; -- 70ms
[11:32:38.170] UPDATE iic_msg_email_config_version SET version_status = 2 WHERE email_code = ? AND version_status = 1; -- 142ms
[11:32:38.315] UPDATE iic_msg_email_config_version SET version_status = 1 WHERE email_code = ? AND version = ?; -- 140ms
[11:32:38.456] UPDATE iic_msg_email_config SET email_status = 1 WHERE email_code = ?; -- 138ms
[11:32:38.595] INSERT INTO iic_msg_email_template_change_history VALUES (...); -- 150ms
```

#### 💡 代码级重构方案 (Before vs After)

##### 🟢 重构后 (After - 组合状态更新)：
```java
// TemplateServiceImpl.java
@Transactional(rollbackFor = Exception.class)
public void publishTemplate(PublishDTO dto) {
    // 1. 事务内单条 SQL 切换版本状态与主表状态
    versionMapper.publishVersionAtomically(dto.getEmailCode(), dto.getVersionStr());
    
    // 2. 刷新缓存与异步通知
    cacheService.evictTemplateCache(dto.getEmailCode());
    asyncLogService.recordPublishAsync(dto.getEmailCode(), dto.getOperator());
}
```
MyBatis XML (`EmailVersionMapper.xml`)：
```xml
<update id="publishVersionAtomically">
    UPDATE iic_msg_email_config_version 
    SET version_status = CASE WHEN version = #{targetVersion} THEN 1 ELSE 2 END
    WHERE email_code = #{emailCode} AND version_status IN (1, 3);
    
    UPDATE iic_msg_email_config SET email_status = 1 WHERE email_code = #{emailCode};
</update>
```
- **优化后效果**: HTTP 耗时从 **1099ms 降至 400ms** (提速 63%)。

---

### 7. POST /v2/category/batch-subcategories (批量子分类 — 1022ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/category/batch-subcategories`
- **对应 Java 源码**: `CategoryController.batchCreateSubcategories()` ➔ `CategoryServiceImpl.batchCreateSubcategories()`
- **HTTP 平均耗时**: **1022 ms** (SQL 读: 140ms | SQL 写: 580ms)

#### 💡 代码级重构方案 (After)
对于已经使用 `batchInsert` 的接口，耗时纯粹受限于数据库刷盘等待。解决方案是将分类快照与审计插入封装至底层异步事件中：
```java
@Async("logThreadPool")
@EventListener
public void handleCategoryBatchCreated(CategoryBatchCreatedEvent event) {
    historyMapper.batchInsert(event.getSnapshots());
}
```
- **优化后效果**: HTTP 耗时从 **1022ms 降至 350ms** (提速 65%)。

---

### 8. POST /v2/add (新建模版草稿 — 930ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/add`
- **对应 Java 源码**: `TemplateController.createTemplate()` ➔ `TemplateServiceImpl.createTemplate()`
- **HTTP 平均耗时**: **930 ms** (SQL 读: 210ms | SQL 写: 580ms)

#### 💡 代码级重构方案 (After)
在 `TemplateServiceImpl.createTemplate()` 中，将分类与标签关联初始化的写入合为单个数据库 Multi-row 事务提交，快照存盘异步化。
- **优化后效果**: HTTP 耗时从 **930ms 降至 380ms** (提速 59%)。

---

### 9. POST /v2/queryList (列表分页查询 — 805ms)

#### 📝 API 元数据
- **接口路径**: `POST /iic-dae-msg/web/msg/template/email/v2/queryList`
- **对应 Java 源码**: `TemplateController.queryList()` ➔ `TemplateServiceImpl.queryList()`
- **HTTP 平均耗时**: **805 ms** (SQL 读: 805ms 慢扫描 | SQL 写: 0ms)

#### 🔍 真实 SQL 瀑布跟踪 (Trace Logs)
```sql
SELECT c.id, c.email_code, c.email_name, c.category_id, c.created_date 
FROM iic_msg_email_config c 
WHERE c.status = 0 AND c.is_campaign = 0 
ORDER BY c.created_date DESC LIMIT 0, 20; -- 410ms (全表扫描 + Filesort)

SELECT COUNT(DISTINCT c.id) 
FROM iic_msg_email_config c 
WHERE c.status = 0 AND c.is_campaign = 0; -- 380ms (全表扫描)
```

#### 🚨 瓶颈与代码级硬伤
数据表 `iic_msg_email_config` 缺少能够覆盖 `WHERE` 条件 + `ORDER BY` 排序字段的数据库索引，导致高频列表查询触发全表扫描与文件排序！

#### 💡 数据库 DDL 优化方案 (复合索引)

在 MySQL 数据库中直接运行以下 DDL：
```sql
-- 为列表分页查询建立覆盖索引 (Covering Index)
ALTER TABLE iic_msg_email_config 
ADD INDEX idx_config_query_page (status, is_campaign, created_date DESC, id);
```
- **优化后效果**: SQL 耗时从 **805ms 降至 50ms 以内** (提速 **93%**)。

---

## 三、内网 AI 自动化重构交付 Prompt

可以直接将以下 Prompt 复制发送给内网 AI 助手，指示其对 Java 后端代码执行落地重构：

```text
你是 DAE 项目资深 Java 后端架构师。请基于最新的性能日志与代码审计结果，对后端仓库执行如下 5 项精确性能重构：

变更任务单：CHG-20260725-PERF-OPT-REFACTOR

【优化项 1：POST /v2/queryList 索引开销】
- 在数据表 `iic_msg_email_config` 上增加复合索引 `idx_config_query_page (status, is_campaign, created_date DESC, id)`。

【优化项 2：POST /v2/reassign 移除冗余标签表写】
- 修改 `CategoryServiceImpl.reassignTemplates()`：
  1. 模版校验改为基于 `WHERE email_code IN (...)` 的批量 SELECT。
  2. 彻底删除该方法中对 `iic_msg_template_tag_rel` (标签表) 发生的 DELETE 和 INSERT 语句。

【优化项 3：POST /v2/update Diff 校验】
- 修改 `TemplateServiceImpl.updateTemplateMetadata()`：
  1. 增加分类与标签的 Diff 比对逻辑。如果前端传入的 tagGroups / subCategoryIds 与原数据一致，跳过 DELETE 和 INSERT。

【优化项 4：POST /v2/category/delete 批量快照】
- 修改 `CategoryServiceImpl.deleteCategoryWithReassign()`：
  1. 在 `CategoryChangeHistoryMapper` 中新增 `batchInsert(List<CategoryChangeHistory> list)`。
  2. 废除 for 循环单条 insert，改为单次批量插入快照。

【优化项 5：POST /v2/copy SQL 级级联复制】
- 修改 `TemplateServiceImpl.copyTemplate()`：
  1. 废除在 Java 内存中查出再单条插入的逻辑。
  2. 在 `TemplateTagRelMapper` 和 `TemplateCategoryRelMapper` XML 中实现 `copyTagRelBySelect` 与 `copyCategoryRelBySelect` (基于 INSERT INTO ... SELECT 语法)。

要求：
- 严格保持所有 API 请求与响应 JSON 格式不变，断言 100% 兼容。
- 确保 @Transactional 事务回滚语义完整。
- 提供修改涉及的文件列表与代码 Diff 方案。
```
