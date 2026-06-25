针对 **Lead-93**（Content Manager- Template management-Library）需求，我已阅读了 [as-is.md](file:///Users/qthitsz/DAE-workspace/om/Jira-conflunce-mcp-analazy/As-Is-DAE/as-is.md)，并结合系统中现有的数据库设计 SQL 文件 [iicseacrm.sql](file:///Users/qthitsz/DAE-workspace/om/Jira-conflunce-mcp-analazy/As-Is-DAE/iicseacrm.sql)，以及已采集的 QA 系统实际运行截图进行了全面调查。

以下是针对目前 QA 系统的实际现状、业务现状以及与 Lead-93 需求差距（Gap Analysis）的深度调查报告。

---

# 📋 Lead-93 需求：QA 系统实际现状调查报告

## 一、 QA 系统入口及凭证

根据 [as-is.md](file:///Users/qthitsz/DAE-workspace/om/Jira-conflunce-mcp-analazy/As-Is-DAE/as-is.md)，QA 系统的入口信息如下：

- **登录地址**：[https://secure.adviser.qa.oldmutual.co.za/iicSeaUmsWeb/index.html#/login](https://secure.adviser.qa.oldmutual.co.za/iicSeaUmsWeb/index.html#/login)
- **登录账号**：`OCQADAESuper` / `Password@01`
- **Lead-93 管理入口**：[https://secure.adviser.qa.oldmutual.co.za/iicSeaUmsWeb/index.html#/main/crm/templateLibrary/managerTemplateLibrary](https://secure.adviser.qa.oldmutual.co.za/iicSeaUmsWeb/index.html#/main/crm/templateLibrary/managerTemplateLibrary)

---

## 二、 目前 QA 系统实际状态调查结论（As-is 现状）

通过对系统截图及数据库结构的分析，目前 QA 系统中的“模板管理”呈现为**“扁平化的模板列表管理”**，尚未具备 Lead-93 所要求的“结构化树状文件夹分类体系”。

具体界面和系统逻辑表现如下：

### 1. 模板库首页（Monitor Template Library）

* **现状表现**：
  - 页面由 `Published`（已发布）、`Draft`（草稿）、`Usage Report`（使用报告）以及 `Default Branding`（默认品牌）四个 Tab 页组成。
  - 当前模板库主要是 **Email 模板**（页面上方有 `EMAIL` 过滤标签，但没有 SMS、视频等其他内容分类切换）。
  - 模板采用**扁平化列表**展示，包含：`Template Name`、`Channel`（渠道，如 Broker Distribution, Direct Sales 等）、`Number Of Uses`（被使用次数）、`Status`（状态：Active/Inactive）、`Created By`、`Created At`、`Modified By` 和 `Action`（包含停用 `X` 和删除 `垃圾桶` 图标）。
  - **核心缺失**：页面**无左侧或上方的文件夹树状层级导航栏**，所有模板混杂在同一个扁平列表中。

### 2. 创建模板流（Create Email Template）

* **现状表现**：
  - 采用 4 步向导式弹窗：`1. Template Info` ➔ `2. Template Creation` ➔ `3. Version Info` ➔ `4. Confirm`。
  - 第一步（Template Info）表单项包含：`Email Template Name*`、`Enable Custom Branding?*`、`Channel*`、`Description`。
  - **核心缺失**：创建时**没有关联分类/选择文件夹（Category/Folder）**的表单项。

### 3. 模板编辑与富文本支持

* **现状表现**：
  - 编辑页面（Edit Email Message）采用 3 步向导：`1. Template Creation` ➔ `2. Version Info` ➔ `3. Confirm`。
  - 支持 `Subject*` 和 `Email Content*` 编辑。内容编辑区提供了基础的预览和 `EDIT` 按钮。
  - 支持 **附件上传**（`UPLOAD FILES`，限制格式为 PDF, DOC, DOCX, JPEG, JPG, PNG，最大 2MB）。
  - 拥有 `OBJECT` 动态变量注入按钮（用于在富文本中插入系统占位变量）。
  - **核心缺失**：编辑区无法直接对模板挂载特定的“分类标签”。

### 4. 版本历史（Version History）

* **现状表现**：
  - 模板详情页分为 `Details` 和 `Version History` 两个 Tab。
  - `Version History` 下有列表，展示 `Version` (如 V1)、`Modified By`、`Modified At`、`Status` (如 Draft)、以及 Actions（包含 `+` 新建版本、`编辑` 和 `删除`）。
  - **核心缺失**：仅支持历史记录的查询，尚未实现“一键回滚/恢复历史版本并处理当前草稿冲突”的成熟业务逻辑。

### 5. 数据库设计现状（iicseacrm.sql）

* **现状表现**：
  - 数据库中仅包含扁平的模板关联表，例如 `iic_crm_campaign_template`（活动模板表），其字段包含 `template_code`、`template_name`、`category`（存为简单分类字符，而非外键树状 ID）、`status`、`type`、`sub_type` 等。
  - 存在 `iic_crm_campaign_template_material`（模板附件表）、`iic_crm_campaign_template_role`（模板角色关联表）。
  - **核心缺失**：**完全没有自关联的树形结构分类目录表**（如 `template_category` 或 `folder_hierarchy`），数据库层面还不支持多级目录管理。

---

## 三、 Lead-93 各个子故事实现程度对比（Gap Analysis）

我们将 Lead-93 下属的 13 个 Story 需求，与目前的 QA 系统现状进行逐一比对：

| 关联故事卡号       | 故事名称/核心需求                                                           | QA系统实现现状         | 差异与卡点评估（Gap）                                                                                                                                                              |
| :----------------- | :-------------------------------------------------------------------------- | :--------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LEAD-276** | **Folder/Category Structure Management**`<br>`(文件夹/分类结构管理) | ❌**未实现**     | 界面上完全无分类文件夹创建、重命名、删除及拖拽功能。数据库无分类树形表支持。                                                                                                       |
| **LEAD-293** | **Maintain Folder Hierarchy**`<br>`(维护文件夹多级层级)             | ❌**未实现**     | 缺乏父子级嵌套收缩的二层或多级树状目录表现，目前仍是扁平列表。                                                                                                                     |
| **LEAD-294** | **Re-order folders**`<br>`(文件夹重排序)                            | ❌**未实现**     | 无法对文件夹进行物理或逻辑排序。                                                                                                                                                   |
| **LEAD-295** | **Categorise template**`<br>`(模板归类/移动)                        | ❌**未实现**     | 无法将模板从“分类 A”拖拽或转移到“分类 B”。                                                                                                                                     |
| **LEAD-298** | **Validation and rules for folders**`<br>`(文件夹删除校验规则)      | ❌**未实现**     | 现有系统不涉及文件夹，因此“非空文件夹禁止删除”、“同级禁止重名”等规则完全不存在。                                                                                               |
| **LEAD-277** | **Adviser Template Library View**`<br>`(顾问只读模板库视图)         | ❌**未实现**     | 顾问端前台缺乏按分类树只读浏览、所见即所得预览及一键唤起发信的独立只读面板。                                                                                                       |
| **LEAD-299** | **Enforce role-based restriction**`<br>`(基于角色的分类访问限制)    | ⚠️**部分支持** | 数据库有扁平的 `template_role` 关联表，但因缺乏分类树，无法对“文件夹/目录”应用角色和渠道（PFA/MFC）隔离。                                                                      |
| **LEAD-278** | **Edit Template Content**`<br>`(在线编辑模板内容)                   | ⚠️**部分支持** | 支持通过向导弹窗和 `OBJECT` 变量注入进行基本修改，但缺乏针对非白名单变量的强正则拦截，以及清除外部 CSS 格式污染的功能。                                                          |
| **LEAD-279** | **Draft & Publish Workflow**`<br>`(草稿与发布隔离工作流)            | ⚠️**部分支持** | 实现了 Published 与 Draft 状态的基本状态隔离（Tab 隔离），但在**“在线版本运行中，直接在此基础上编辑并保存新草稿，且不影响在线版，等发布时再覆盖”**的高级并发隔离隔离上存在欠缺。 |
| **LEAD-280** | **Version History**`<br>`(模板历史版本记录)                         | ⚠️**部分支持** | UI 上已有版本列表展示，但暂不支持版本快速恢复/回滚以及恢复历史版本时覆盖当前未发布草稿的阻断二次确认提示。                                                                         |
| **LEAD-296** | **Search Templates**`<br>`(检索模板)                                | ⚠️**部分支持** | 仅支持基础的扁平列表关键字检索，无法支持在分类树目录、标签元数据下进行倒排索引模糊检索。                                                                                           |
| **LEAD-297** | **Support Multiple Content Types**`<br>`(支持多媒体及多种内容类型)  | ⚠️**部分支持** | 目前偏向 Email 格式，附件支持上传 PDF/图片等，但不支持 SMS 模板、纯视频（S3 存储与播放限制）以及音频模板。                                                                         |
| **LEAD-300** | **Bulk upload of templates**`<br>`(批量导入模板)                    | ❌**未实现**     | UI 层面无 Excel/CSV/ZIP 压缩包的批量导入入口，后端也缺乏对导入重名冲突的过滤或覆盖控制事务逻辑。                                                                                   |

---

## 四、 下一步建议与结论

1. **当前 QA 系统的阶段**：现有的 QA 系统上，仅开发完成了**第一阶段扁平模板发布与版本表象展示**，对于 Lead-93 的**核心特性（树状文件夹分类、移动分类、只读顾问树形展示、批量导入）**完全属于待开发状态。
2. **底层设计要点**：
   - 数据库需要在 `iicseacrm.sql` 的基础上，新建 `template_category` 目录表（自关联 `parent_category_id`），并在 `template_definition` 中增加 `draft_category_id` 与 `live_category_id` 来实现草稿和发布状态的物理隔离。
   - 前端控制台需要以 **qiankun 子应用** 的形式被集成进 DAE，引入树形拖拽（React + AntD Tree）来展示目录关系。
3. **后续行动**：
   - 如果您需要我针对以上缺失的业务模块开始编写代码或技术方案设计，由于涉及数据库及系统架构变动，在需要使用到外部 skill（如 `superpowers-plan` 来输出细化执行方案）或调用 Atlassian 关联 MCP 时，我会向您申请确认。

请问是否需要我输出新规设计的 `database_design_final.md` 或开始拟定具体的故事实现方案？
