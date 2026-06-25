# Story - LEAD-68: Record Level:  Failure Visibility ( business)

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-68` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `2` |
| **Parent Feature/Epic** | `LEAD-6` |
| **Labels** | `none` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Campaign Team
I want to see detailed failure reasons for each rejected/failed record with a failure reason 
So that I can log an incident or  fix issues and re-upload corrected data
Record Failures are already saved to an IG table, “Exceptions”. All record failures must write to this table, to ensure that it can be used for reporting. For future, the PFMI team need to craete a report in Powerbi, to provide a view of the data in the existing table.


## 🎯 Acceptance Criteria (验收标准)
Identification of Failed Records
* * * Given a busines validation is performed
When individual records fail validation 
Then each failed or rejected record must be clearly identified as failed.
2. Record‑Level Failure Reason
* * Given a record is rejected
Then the system must display a specific failure reason for that individual record.
3. Field‑Level Detail
* * Given a failure is caused by an invalid field
Then the failure details must include:
* * The field name
The reason for failure (e.g. missing, invalid format, invalid value)
4. Access and Visibility
* * Given records are rejected
Then the Campaign Team must be able to view failure reasons via a  Powerbi  report. ( or if an extract of table can be provided in in the interim)
5. Support Incident Logging
* * Given a Campaign Team member needs to log an incident
Then the failure details must be sufficient to include in an incident ticket without requiring further technical investigation.
6.Re‑upload of Corrected Records
* * * Given rejected records have been corrected
When the corrected data is re‑uploaded
Then the system must re‑process only the corrected records.


## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-68_Record_Level_Failure_Visibility_business_comments.md)**

