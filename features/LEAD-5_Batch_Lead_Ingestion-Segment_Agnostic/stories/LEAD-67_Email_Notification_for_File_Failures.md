# Story - LEAD-67: Email Notification  for File Failures

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-67` |
| **Type** | `故事` |
| **Status** | `Ready for Deployment` |
| **Story Points** | `3` |
| **Parent Feature/Epic** | `LEAD-5` |
| **Labels** | `release-scope-breach` |
| **Components** | `Leads Fix` |

## 📖 Original Description
As a Analytics team, I need to receive an alert when a lead file fails ingestion so that I can investigate the root cause and coordinate with my team  to correct and resubmit the file.


## 🎯 Acceptance Criteria (验收标准)
* Email Format & Recipients (the recipient is different from the Everlytics recipient)
Item
Question
Example / Options
Sender (From)
What address should the email send from?
e.g., noreply-leads@oldmutual.com or a shared mailbox, please confirm
Subject template
Should we define it, or do you have a standard?
e.g., [ALERT] Lead File Ingestion Failed – {filename} – {timestamp}
Body template
Any formatting requirements beyond the AC-specified fields?
Plain text / HTML / branded template?
Recipients
Who receives the alert?
Waseem Davids & Michele-Joy Hoffman can be cc on the email to the DATA team. Team  mailbox (Configurable list (multiple people),
File Failure Detection
* * * Given a lead file ingestion process is executed
When the ingestion fails at any stage (e.g. file receipt)
Then the failure must be detected and classified by the ingestion framework.
* Alert Triggering
* * * Given a lead file ingestion failure is detected ( 3 times)
When the failure is confirmed
Then an alert（email) must be automatically triggered without manual intervention.
( as there is an hourly retry to ingest the file - after each attempt:
* * Log failure reason; Keep file in “Pending Retry” state. Alert must only be triggered after (final retry failed) 3rd time
Status: “Ingestion failed – manual intervention required
* Alert(Email) Delivery Channel
* * Given the alert is triggered
Then it must be delivered through the configured notification channel(s), such as:
* Email
* Alert Content
* * Given an alert is sent
Then it must include at minimum:
* * * * File name and unique file identifier
Source system name(Manual MADM Files )
Error message and/or error code
Date and time of failure
* Recovery Support
* * * Given the source system resubmits a corrected lead file
When ingestion succeeds
Then no failure alert is triggered, and the successful ingestion is logged.
Add Acceptance Criteria


## 📋 Definition of Ready (DOR) Checklist
# Default checklist
---DOR_US
* [done] FA: INVEST user story with AC
* [done] FA/QE: test data as needed
* [done] Data: business rules
* [done] Data data source established
* [open] Data: documentation pipelines and data flows
* [skipped] API: tech discovery done
* [skipped] API: documentation and payload provisioning
* [skipped] API: test data provisioned
* [skipped] OC: documentation and payload provisioning
* [skipped] OC: contract if no API exists
* [skipped] OC: table readiness for data integration
* [skipped] OC: UI design

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-67_Email_Notification_for_File_Failures_comments.md)**

