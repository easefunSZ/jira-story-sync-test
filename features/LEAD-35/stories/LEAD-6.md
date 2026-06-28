# Story - LEAD-6: Enhance ingestion of  lead data

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-6` |
| **Type** | `Feature` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-35` |
| **Labels** | `DOR_FEAT, release-scope-breach` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Statement
All lead sources (starting with Everlytic as the initial implementation) must support ingestion of both intermediated and un-intermediated leads into the Integreat pipeline, with full and transparent visibility of ingestion outcomes (success or failure).
Context
This enhancement ensures that all incoming lead data feeds, regardless of origin, are consistently processed through the Integreat ingestion pipeline and are capable of handling both:
* * Intermediated leads 
Un-intermediated leads 
Each inbound feed must provide explicit file-level ingestion status, indicating whether the upload and processing was successful or failed.
Current Behaviour (Everlytic)
* * * Everlytic currently supports PSI structure in payloads
When PSI data is not present, it is passed as null or empty:
* * PSI.SalesCode = ""
PSI.digitalId = null
However, un-intermediated Everlytic leads are not currently being ingested into the Integreat lead pipeline, resulting in data loss and incomplete coverage.
Required Behaviour
The system must:
* * * * Accept both intermediated and un-intermediated leads from all sources
Ensure all valid leads are processed through the Integreat ingestion pipeline
Provide clear ingestion outcome visibility at file/feed level:
* * Successful ingestion
Full failure
Ensure PSI-null leads are still valid and processed where appropriate (based on routing rules)
Key Impacts
* * * Everlytic un-intermediated leads are currently excluded and must be included in the pipeline
PSI = null must be treated as a valid state, not a rejection condition
Ingestion pipeline must not assume PSI presence is mandatory for processing
Future Considerations
Although initial implementation focuses on Everlytic, the solution must be designed as source-agnostic and extensible, supporting future onboarding of new source feeds.
All future sources must inherit the same capability to expose:
* * * Ingestion success/failure status
Record-level processing outcomes (where applicable)
Standardised error reporting structure


## 🎯 Acceptance Criteria (验收标准)
* * * * * All lead data sources (including Everylytic), where it is identified as either intermediated or un-intermediated, must be fed through to the IG lead pipeline. (Future sources should not require bespoke handling)
Success/Failure report data to indicate success of upload. (Success / failure of a file upload)(Success /failure/ of a lead )
Feed of success /failure to existing leads tracker. (Build of reports out of scope.)
Notification to Campaign Team/data team of File failure
Handling of failure 


## 📋 Definition of Ready (DOR) Checklist
​# Default checklist
​--- DOR_FEAT
​* [done] Feature goal
​* [done] 5 - 7 stories
​* [done] Acceptance criteria
​* [done] OC input
​* [done] Arch Solution design
​* [skipped] UX journey map

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-6_comments.md)**

