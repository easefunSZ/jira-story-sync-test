# Feature - LEAD-265: Maturity Leads_ AI conversation guide

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-265` |
| **Type** | `Feature` |
| **Status** | `Refinement` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Context
English
简体中文（更自然、口语化）
Once a maturity lead has been accepted and opened in My Leads, the adviser should be able to click a clearly labelled guide and view contextual conversation prompts.
当顾问在线索被接受并进入“我的线索”详情页后，可以点击一个清晰标识的引导入口，查看结合上下文生成的对话提示。
The purpose is to support the adviser in starting or handling the conversation, not to provide a script or financial advice.
它的目的只是帮助顾问更好地开场或推进沟通，而不是提供固定话术，更不是财务建议。
This feature depends on the maturity data already being available on the lead.
该功能依赖于线索上已经具备成熟度相关数据。
Feature Goal
English
简体中文（更自然、口语化）
Provide advisers with an embedded, contextual AI conversation guide for maturity leads, so they can start stronger, more relevant conversations without the AI giving advice or replacing the advice process.
为成熟度线索提供一个嵌入式、结合上下文的 AI 对话引导，帮助顾问更自然地开启更有针对性的沟通，同时确保 AI 不提供建议，也不替代正式的建议流程。
Channel Scope
English
简体中文（更自然、口语化）
Applies to PF channels: PFA, AFD, DFA.
适用于 PF 渠道：PFA、AFD、DFA。
Explicitly excludes OMiD.
明确不包含 OMiD 渠道。
Access and Interaction Pattern
English
简体中文（更自然、口语化）
The guide is available only after the adviser accepts a maturity lead and opens the lead detail page in My Leads.
该引导只会在线索被顾问接受、并且进入“我的线索”详情页后才可使用。
The guide is accessed through a clearly labelled tooltip / inline panel trigger so the adviser understands its purpose immediately.
顾问通过一个有清晰标签的 tooltip / 行内面板入口来打开该引导，一眼就能知道它的用途。
The interaction should stay on the same page and must not open a new window, full chat experience, or modal pop-up.
整个交互必须留在当前页面内，不能打开新页面、完整聊天窗口或模态弹窗。
What AI must do
English
简体中文（更自然、口语化）
The AI may use only the information made available on the lead, for example client name/title, age, gender reference, maturity date, and maturity value.
AI 只能使用线索上已经提供的信息，例如客户姓名/称谓、年龄、性别称呼、到期日期和到期金额。
The AI should point out contextual indicators such as time sensitivity (for example, funds becoming available soon) and value significance (for example, a meaningful or significant amount).
AI 需要点出关键上下文信号，例如时间敏感性（比如资金很快就会到位）以及金额的重要性（比如这是一笔对客户有意义、金额较大的资金）。
The output should provide optional conversational approaches and open-ended prompts that help the adviser explore customer needs.
输出内容应提供可选的沟通切入方式，以及帮助顾问了解客户需求的开放式提问提示。
 What the AI must NOT do
English
简体中文（更自然、口语化）
The AI must never make recommendations, suggest products, make financial decisions, or replace any formal advice process.
AI 绝不能做产品推荐、给出财务建议、替客户做决定，或替代任何正式的建议流程。
The wording must remain guidance-oriented and should never read like an instruction script the adviser must follow word for word.
文案必须保持“沟通引导”的语气，不能写成顾问必须逐字照读的固定脚本。
Guardrails and Labelling
English
简体中文（更自然、口语化）
A mandatory disclaimer must be visible: ‘This is a guidance tool to support conversations and is not a script or financial advice.’
页面上必须清楚显示免责声明：‘本工具仅用于支持沟通引导，不是固定话术，也不构成任何财务建议。’
The tooltip label should clearly tell the adviser what it is for, for example ‘AI Conversation Guide’ or ‘Conversation Guide’.
tooltip 的标签要让顾问一看就知道用途，例如‘AI Conversation Guide’或‘Conversation Guide（对话引导）’。
Example Output style
English
简体中文（更自然、口语化）
Example guide: This policy is due to mature within the next month, with funds becoming available soon. The maturity value of approximately R120,000 represents a meaningful amount for Mrs AB Sample. Suggested conversational approach: acknowledge the upcoming maturity, explore how the customer is thinking about these funds, and use open-ended questions to understand needs and priorities.
示例引导：这张保单将在未来一个月内到期，资金很快就会释放。约 R120,000 的到期金额，对 AB Sample 女士来说是一笔很有分量的资金。建议的沟通方式是：先确认客户是否了解即将到期的时间点，再了解她目前对这笔资金有哪些想法，并通过开放式提问进一步理解她当前的需求和优先事项。
Demo Requirements
English
简体中文（更自然、口语化）
Demo 1: Open a maturity lead in My Leads and show the clearly labelled AI guide trigger.
演示 1：打开“我的线索”中的一条成熟度线索，展示带清晰标签的 AI 引导入口。
Demo 2: Click the trigger and show the inline expandable panel on the same page.
演示 2：点击入口后，在当前页面内展开 AI 引导面板。
Demo 3: Confirm that the generated content highlights timing and value but does not provide advice or recommendations.
演示 3：确认生成内容会强调时间点和金额重要性，但不会给出建议或推荐。
Demo 4: Confirm the disclaimer is visible.
演示 4：确认免责声明清晰可见。
Scope Boundary Summary
English
简体中文（口语化业务表达）
What this feature accepts
本功能验收关注点
Relevant maturity-led conversation guidance is available, contextual, compliant, clearly labelled, and delivered inside the adviser experience.
成熟度线索相关的对话引导能够在顾问使用场景中提供，内容贴合上下文、符合合规要求、标签清晰，并内嵌在顾问操作体验中。
What this feature does not accept
本功能不包含
Detailed prompt rules, UI micro-behaviour, generation thresholds, post-conversation summarisation, or story-level acceptance checks.
不包含详细提示词规则、界面微交互规则、生成阈值、会后总结能力，或用户故事层级的验收项。


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-229](stories/LEAD-229_Audit_reporting_of_AI_Usage_conversation_guide.md)**: Audit & reporting of  AI Usage ( conversation guide) *(状态: 正在进行)*
- **[LEAD-207](stories/LEAD-207_Enforce_AI_Compliance_Disclaimer.md)**: Enforce AI Compliance & Disclaimer *(状态: 待办)*
- **[LEAD-177](stories/LEAD-177_AI_Conversation_Guide_Expandable_Panel.md)**: AI Conversation Guide (Expandable Panel) *(状态: 待办)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
结合线索富化的意图数据，为成熟度线索的顾问展示由 AI 推导的开场白（Opening Pitch）引导。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：前端顾问展业页面，AI 对话建议浮窗卡片展示。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：前端组件基于 `lead_enrichment_data` 中的 intension 段进行渲染转换，以对话气泡形式提供标准话术指导。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
