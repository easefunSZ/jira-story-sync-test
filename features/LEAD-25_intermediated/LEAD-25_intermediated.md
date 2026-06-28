# Feature - LEAD-25: Maturity Lead Enrichment -Intermediated customers

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-25` |
| **Type** | `Feature` |
| **Status** | `Refinement` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
1. Context
English
简体中文（更自然、口语化）
Maturity campaigns are already being run and presented to advisers as leads.
目前已经在运行成熟度营销活动，并且这些活动会以线索的形式分配给顾问。
Today, the information shown in IG does not include maturity details, which limits the adviser’s ability to understand the opportunity and have a stronger conversation.
目前 IG 页面上没有展示成熟度相关信息，所以顾问很难快速判断这条线索的价值，也不利于开展更有针对性的沟通。
This feature focuses on data enrichment and UX surfacing only. It does not include AI conversation guidance.
这个功能只聚焦在数据补充和页面展示，不包含 AI 对话引导能力。
Feature Goal
English
简体中文（更自然、口语化）
Ensure maturity campaign leads are enriched with clear maturity information and surfaced at the right points in the adviser journey, so advisers can recognise these leads early and open them with the right context.
确保成熟度营销线索在顾问旅程的关键节点上补充并展示清晰的到期信息，让顾问能更早识别这类线索，并在打开线索时马上看到需要的背景信息。
Scope
English
简体中文（更自然、口语化）
Applicable Scope
适用范围
Applies to PF channels: PFA, AFD, DFA.
适用于 PF 渠道：PFA、AFD、DFA。
Explicitly excludes OMiD.
明确不包含 OMiD 渠道。
Applies only to intermediated customers.
仅适用于“有中介服务关系”的客户。
An intermediated customer is defined as a lead record where a PSI is present and matches the PSI on the customer record, or where the lead record is updated with the PSI on record.
“有中介服务关系”的客户定义为：线索记录中存在 PSI，并且该 PSI 与客户主数据中的 PSI 一致，或线索记录已被更新为与客户记录中的 PSI 保持一致。
Explicitly excludes lead records where a PSI code is present but does not match the PSI on the customer record.
明确排除：线索记录中存在 PSI 编码，但该 PSI 与客户主数据中的 PSI 不一致的情况。
English
简体中文（更自然、口语化）
Stage 1 – Leads Pool (pre-allocation): show a new column called Campaign Information.
阶段 1——线索池（分配前）：新增一个字段，名称为 Campaign Information（活动信息）。
For maturity campaigns only, the Campaign Information column is populated with the value from the field Retention Note.
只有当线索属于成熟度营销活动时，Campaign Information 字段才显示 Retention Note 的值。
For non-maturity campaigns, the Campaign Information column remains blank and should not show irrelevant text.
如果不是成熟度营销活动，Campaign Information 字段保持空白，不显示任何无关内容。
Stage 2 – My Leads / Lead Detail (post-allocation): once the adviser accepts a maturity lead and opens it, the screen displays Policy Type, Maturity Date, and Maturity Value.
阶段 2——我的线索 / 线索详情（分配后）：当顾问接受一条成熟度线索并打开详情页后，页面展示 Policy Type、Maturity Date 和 Maturity Value。
The maturity fields appear only for maturity campaigns and are not shown for other campaign types.
这些到期字段只对成熟度营销活动显示，其他活动类型不展示。
UX Behaviour
English
简体中文（更自然、口语化）
Leads Pool: add Campaign Information as a new visible column in the grid.
在线索池列表中新增 Campaign Information 这一列。
Lead Detail: display Policy Type, Maturity Date, and Maturity Value within the opened maturity lead.
在线索详情页中，对成熟度线索展示 Policy Type、Maturity Date 和 Maturity Value。
Dynamic behaviour: do not show blank maturity fields on non-maturity campaigns.
动态展示规则：对于非成熟度活动，不显示空白的到期字段。
The design should minimise clutter and fit into the existing platform layout.
设计上要尽量减少页面拥挤感，并且要贴合现有平台布局。
Data/ Payload requirements
English
简体中文（更自然、口语化）
Required field for Leads Pool: Retention Note.
线索池展示所需字段：Retention Note。
Required fields for Lead Detail: Policy Type, Maturity Date, Maturity Value.
线索详情展示所需字段：Policy Type、Maturity Date、Maturity Value。
OC must provide the standard payload formatting requirements and the required fields, as the current file format was built for CSI.
由于当前文件格式是按 CSI 的要求设计的，因此 OC 需要提供新的标准 payload 格式要求以及必填字段定义。


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-266](stories/LEAD-266.md)**: Demo Requirements *(状态: 待办 | 故事点数: 3)*
- **[LEAD-208](stories/LEAD-208.md)**: Master rule matrix *(状态: 正在进行 | 故事点数: 3)*
- **[LEAD-176](stories/LEAD-176.md)**: Controlled Display of Campaign Information in Leads Pool *(状态: Analysis | 故事点数: 3)*
- **[LEAD-175](stories/LEAD-175.md)**: Maturity Lead Visibility in My Leads ( after acceptance) *(状态: Analysis | 故事点数: 3)*
- **[LEAD-66](stories/LEAD-66.md)**: Conditional Display of Maturity Features *(状态: Analysis | 故事点数: 3)*
- **[LEAD-32](stories/LEAD-32.md)**: Audit & Reporting of Enrichment Outcomes *(状态: Analysis | 故事点数: 3)*
- **[LEAD-29](stories/LEAD-29.md)**: Enrich Maturity Leads Prior to Allocation *(状态: Analysis | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
对成熟度线索（Maturity Leads）进行特别富化，将保单到期等关键属性呈现给理财顾问。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：提取到期时间、预期退保金额等特有属性，并在前端卡片为顾问专门呈现成熟度信息看板。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：解析 `UnifiedLeadDTO` 的 `maturityDetails` 属性包，将其序列化并映射至 DAE 客户详情的独立展示层。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
