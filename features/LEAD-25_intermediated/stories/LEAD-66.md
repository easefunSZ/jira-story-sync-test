# Story - LEAD-66: Conditional Display of Maturity Features

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-66` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-25` |
| **Labels** | `none` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a system,
I want to show maturity features only for valid maturity campaign leads
So that irrelevant leads are not impacted.



## 🎯 Acceptance Criteria (验收标准)
* * * * * AC1: Maturity fields and AI features only appear for maturity campaign leads.
AC2: Non-maturity leads do not display any maturity UI or AI components.
AC3: Missing maturity data results in no UI rendering (no placeholders).
AC4: Feature is limited to supported channels (PFA, AFD, DFA only)
* * * .Maturity UI and AI features:
Are rendered only for PFA, AFD, DFA
Are explicitly suppressed for all other channels, even if maturity data exists
AC5: Maturity qualification logic
* A lead is considered a maturity campaign lead only when:
* * * * Campaign ID  approved maturity campaign list OR
isMaturity = true AND
maturityDate is populated and in the future or within the defined window
Camapign status is active


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

