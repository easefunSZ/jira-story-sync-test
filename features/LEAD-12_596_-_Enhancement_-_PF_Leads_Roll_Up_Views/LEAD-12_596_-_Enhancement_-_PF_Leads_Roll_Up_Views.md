# Feature - LEAD-12:  596 - Enhancement - PF Leads Roll Up Views

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-12` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `None` |
| **Labels** | `DOR_FEAT, Wayne's-world` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Segment Scope - PF all distirbution channels 
Rolled-up view for leads tracking for BC, SM, AM, RM, PGM per panel/Team - this shows leads activity per panel/team
rolled-up view for leads tracking for BC, SM, AM, RM, PGM per panel/Team - this shows leads activity per panel/team. The new number should include all IG management users (up to Channel Head) and should include a summary view of my teams activities, so that I can track progress on a practice level.  For MFC, an additional Category for leads, is added on the Practice Metrics Dashboard.  
Notes: 
solution design required 
Data work required 
API work required 
UX design required 


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-118](stories/LEAD-118_As_a_manager_PF_I_want_to_filter_the_leads_information_of_my_team_by_a_period_count_and_so_that_I_can_track_the_teams_contribution.md)**: As a manager (PF)  I want to filter the leads information of my team by a period, count and %, so that I can track the team's contribution *(状态: 待办)*
- **[LEAD-113](stories/LEAD-113_CLONE_-_As_a_PF_Channel_Head_or_PF_secretary_I_want_to_apply_additional_filters_to_the_leads_information_of_my_team_so_that_I_can_track_the_teams_contribution_on_a_hierarchy_level.md)**: CLONE - As a PF Channel Head (or PF secretary), I want to apply additional filters to the leads information of my team, so that I can track the team’s contribution on a hierarchy level *(状态: 待办)*
- **[LEAD-108](stories/LEAD-108_CLONE_-_As_a_PF_Business_Manager_I_want_to_apply_additional_filters_to_the_leads_information_of_my_team_so_that_I_can_track_the_teams_contribution_on_a_hierarchy_level.md)**: CLONE - As a PF Business Manager I want to apply additional filters to the leads information of my team, so that I can track the team’s contribution on a hierarchy level *(状态: 待办)*
- **[LEAD-103](stories/LEAD-103_CLONE_-_As_a_PF_regional_Manager_I_want_to_apply_additional_filters_to_the_leads_information_of_my_team_so_that_I_can_track_the_teams_contribution_on_a_hierarchy_level.md)**: CLONE - As a PF regional Manager , I want to apply additional filters to the leads information of my team, so that I can track the team’s contribution on a hierarchy level *(状态: 待办)*
- **[LEAD-101](stories/LEAD-101_CLONE_-_As_a_PF_manager_I_want_a_summary_view_of_my_teams_leads_in_the_various_status_so_that_I_can_track_the_teams_progress.md)**: CLONE - As a PF manager  I want a summary view of my team’s leads in the various status, so that I can track the team's progress *(状态: 待办)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
为 BC、SM、AM、RM、PGM 各管理层级提供分级的 Panel/Team 线索转化率汇总看板（Roll-up Views）。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：销售管理层的决策分析，支持不同层级的权限控制与数据穿透。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：后端开发基于 `lead_record` 分配历史的聚合查询 API，使用 ClickHouse 或数据库只读副本（Replica）进行轻量级定时计算，避免对主业务库造成统计压力。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
