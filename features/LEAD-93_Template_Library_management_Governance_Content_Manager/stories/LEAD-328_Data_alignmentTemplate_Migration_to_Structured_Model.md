# Story - LEAD-328: Data alignment/Template Migration to Structured Model

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-328` |
| **Type** | `故事` |
| **Status** | `Analysis` |
| **Story Points** | `none` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
As a Content Manager,
I want existing templates to be moved into the new structured category model,
So that all templates are organised consistently and are easy to find and manage.
Background
There are currently 79 published templates in the system. These templates were created under the old flat-list structure with inconsistent naming conventions. As part of the Template Library restructuring (LEAD-93), all existing templates need to be migrated into the new structured model that includes:
* * Category & Subcategory — as defined in LEAD-301 (Assign & Edit Category & Subcategory)
Tags — as defined in LEAD-300 (Select/Assign and Edit Tags), covering Content Type, Trigger Event, Lifecycle Stage, Financial Need
The mapping rules have been provided in the following attachments on LEAD-93:
* * * Final_Template_Tag_Mapping_Business_Review v1.0.xlsx— template-level mapping of category, subcategory, and tags
Category Framework v2.0.xlsx - full category/subcategory structure with proposed template names and descriptions
Tag_Taxonomy_with_Descriptions.xlsx - tag taxonomy definitions
Prerequisites / Dependencies:
* * LEAD-301 (Assign & Edit Category & Subcategory) — Category/Subcategory data model must be implemented and seeded before migration can run
LEAD-300 (Select/Assign and Edit Tags) — Tag taxonomy and assignment functionality must be implemented before tags can be applied
Migration Data Summary
Based on Category Framework v2.0.xlsx, the 79 templates will be migrated into the following structure:
Category
Subcategories
approx. qty
Client Engagement
Advice Reviews, Contact & Follow-up, Financial Education & Insights, Life Events & Support, Personal Milestones, Rewards, Seasonal & Celebration, Service Availability & Notices, Welcome & Onboarding
~25
Protection
Business Protection, Disability, Funeral, Life Cover, Severe Illness
~20
Retirement
Financial Education & Insights, RA, Retirement Income, Retirement Planning
~10
Savings & Investments
Education Planning, Investments, Savings, TFSA
~8
Lending
Home Loans
~3
Duplicate / Outdated templates to deactivate: Templates with no proposed name or description marked as NaN in the mapping spreadsheet are candidates for deactivation. Confirm with Cisca before execution.


## 🎯 Acceptance Criteria (验收标准)
AC1: Pre-Migration Audit & Classification
Given the Content Manager has the approved mapping spreadsheet (Final_Template_Tag_Mapping_Business_Review v 1.0.xlsx),
Then all 79 existing published templates must be classified into one of the following actions:
* * * Retain — template is active, relevant, and will be migrated with full metadata
Deactivate (Duplicate) — template is a duplicate of another; deactivate to Draft and annotate which template it duplicates
Deactivate (Outdated) — template is no longer relevant; deactivate to Draft and annotate reason
And the classification must be reviewed and approved by the Content Manager (Cisca) before migration execution begins.
AC2: Category & Subcategory Assignment
Given a template is classified as Retain,
When the migration is executed,
Then:
* * * The template must be assigned the correct Category as specified in the mapping spreadsheet
The template must be assigned the correct Subcategory as specified in the mapping spreadsheet
No template classified as Retain may have an empty Category or Subcategory after migration
AC3: Tag Assignment
Given a template is classified as Retain,
When the migration is executed,
Then the following tags must be assigned per the mapping spreadsheet:
* * * * Content Type (e.g., Email, Toolkit, Campaign, Infographic)
Trigger Event (e.g., Client Event, Adviser Activity, Business Event, Seasonal Event)
Lifecycle Stage (if specified in the mapping)---transfer allowing to be null?
Financial Need (e.g., Protect, Grow Wealth, Save, Plan Retirement — may be multi-value) ---transfer allowing to be null?
And all four required tag groups must have at least one value assigned (per LEAD-300 validation rules).
AC4: Template Renaming
Given the mapping spreadsheet provides a Proposed Template Name for a template,
When the migration is executed,
Then:
* * The template title must be updated to the proposed name
If the proposed name is blank (NaN), the existing template name is retained unchanged
AC5: Duplicate Template Handling
Given a template is classified as Deactivate (Duplicate),
When the migration is executed,
Then:
* * * * The template status must be changed from Published → Draft (deactivated)
The template description must be annotated with: "[DEACTIVATED — Duplicate of: {primary template name}] — Deactivated during migration on {date}"
The template must not be permanently deleted
The primary (retained) version must be clearly identified in the migration report
AC6: Outdated Template Handling
Given a template is classified as Deactivate (Outdated),
When the migration is executed,
Then:
* * * The template status must be changed from Published → Draft (deactivated)
The template description must be annotated with: "[DEACTIVATED — Outdated: {reason}] — Deactivated during migration on {date}"
The template must not be permanently deleted
AC7: Post-Migration Data Integrity Verification
Given the migration has been executed,
Then the following checks must pass:
* * * * * * Total template count (Retained + Deactivated) = original 79 — no templates lost or orphaned
Every Retained template has a valid Category, Subcategory, and all four required tag groups populated
Every Deactivated template is in Draft status with the correct annotation
No template exists without a Category assignment (no orphaned templates)
Retained templates are visible and correctly positioned in the Template Library under their assigned Category and Subcategory
Deactivated templates are not visible to Advisers
AC8: Migration Summary Report （offline）
Given the migration is complete and verified,
Then a migration summary report must be produced containing:
* * * * * * * Total templates before migration: 79
Templates retained: count + list
Templates deactivated (duplicate): count + list (with primary template reference)
Templates deactivated (outdated): count + list (with reason)
Templates renamed: count + list (old name → new name)
Operator: who performed the migration
Date: when the migration was executed
And the report must be reviewed and signed off by the om BA(Cisca) as confirmation that the migration is complete and correct.


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-328_Data_alignmentTemplate_Migration_to_Structured_Model_comments.md)**

