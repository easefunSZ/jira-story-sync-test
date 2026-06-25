# Story - LEAD-51: Automated ingestion of manual files

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-51` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-5` |
| **Labels** | `DOR_US` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As the Leads Data Pipeline
I want to automatically detect and ingest manual  files placed in the agreed ingestion location
So that manual uploads flow through the same pipeline pattern without BAU needing to pick them up.
Success
* * * AC1.1 When a  file is placed in the ingestion location, the pipeline automatically detects it (no manual trigger).
AC1.2 The pipeline starts processing without any BAU operational action (no manual pickup).
AC1.3 Each file is assigned a unique processing identifier (e.g., upload/job ID) for tracking.
Failure
AC1.4: File not detected
If a manual  file is placed in the ingestion location and the pipeline fails to detect it, then the system must not start any processing and the file must remain in the location for retry（3） or reprocessing.
AC1.5 : File Detected but Processing Fails to Start
If a manual file is successfully detected in the ingestion location, but the pipeline fails to initiate processing, then the system must:
* * * * * * * Mark the file as Processing Failed
Write the file failure record to the Exception Table
Capture and store the failure reason / error details
Trigger notification to Liezel Pienaar data team 
Ensure the file is not processed partially or left in an unknown state.
Failure scenarios:
This includes the following cases:
* * * The file is detected but processing does not start.
The file is detected and processing is initiated but fails before completion.
The file is detected but is not picked up by the processing job due to internal pipeline errors .


## 🎯 Acceptance Criteria (验收标准)
*未明确配置 Acceptance Criteria*

## 📋 Definition of Ready (DOR) Checklist
# DOR_US
* [skipped] S/Arch: enabler work identified and systems integration designed
* [done] S/Arch: solution design
* [done] Data: business rules
* [done] Data data source established
* [done] Data: documentation pipelines and data flows
* [done] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design
* [done] FA: INVEST user story with AC
* [done] FA/QE: test data as needed

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-51_Automated_ingestion_of_manual_files_comments.md)**

