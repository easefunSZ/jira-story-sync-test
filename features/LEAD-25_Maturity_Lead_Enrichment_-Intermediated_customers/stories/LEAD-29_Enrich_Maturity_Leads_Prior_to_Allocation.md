# Story - LEAD-29: Enrich Maturity Leads Prior to Allocation

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-29` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-25` |
| **Labels** | `none` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Lead Processing Owner
I want maturity campaign leads to be enriched with maturity-related information before allocation
So that relevant campaign information is available for allocation, prioritisation, and adviser engagement
Rules
* * * Rule: CAMPAIGN_TYPE = MATURITY
Rule: Enrichment must execute in pre-allocation pipeline stage
Rule: Enrichment failure must not block lead ingestion (non-blocking fallback)
Data Elements
* * * * Campaign ID
Campaign Type
Retention Note
Maturity Date


## 🎯 Acceptance Criteria (验收标准)
AC1.1 – Maturity Lead Identification
Given a lead is received from a maturity campaign source
When lead processing begins
Then the system must identify the lead as a maturity campaign lead.   "isMaturity": "true”
AC1.2 – Enrichment Before Allocation
Given a lead has been identified as a maturity campaign lead
When enrichment processing occurs
Then the system must enrich the lead before allocation takes place.
 "productName; maturityDate";maturityValue
AC1.3 – Retention Note Enrichment
Given a maturity campaign lead contain thesxe fields in  the source data
When enrichment is completed
Then the fields must be stored against the lead record.
AC1.4 – Non-Maturity Campaigns
Given a lead does not belong to a maturity campaign ("isMaturity": "false”
When enrichment processing occurs
Then maturity-specific enrichment must not be applied.
AC1.5  – Audit enrichment
Given maturity information is added to a lead
When enrichment completes
Then an audit record must be created showing the enrichment date, source and outcome.


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 *暂无评审与讨论历史评论*

