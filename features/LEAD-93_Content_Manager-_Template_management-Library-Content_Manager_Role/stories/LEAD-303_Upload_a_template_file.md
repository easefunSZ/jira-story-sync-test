# Story - LEAD-303: Upload a template file

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-303` |
| **Type** | `故事` |
| **Status** | `待办` |
| **Story Points** | `5` |
| **Parent Feature/Epic** | `LEAD-93` |
| **Labels** | `none` |
| **Components** | `none` |

## 📖 Original Description
I want to upload an existing file when creating a template
So that I can reuse pre‑created content instead of building it from scratch
The Content Manager can choose to upload an existing file as the primary content for a template via the Create Template screen. Uploading a file is an alternative to creating content manually and follows the same  lifecycle as created templates.
Only one file may be uploaded per template.


## 🎯 Acceptance Criteria (验收标准)
AC1: Upload Option Availability
Given the Content Manager is on the Create Template screen
When the Content Manager selects the “Upload Template” option
Then the system displays a file upload component
And the manual content‑creation fields are hidden or disabled
And the Content Manager can switch back to “Create Template” with confirmation (uploaded file will be discarded)
AC2: Supported File Types & Validation
Given the Content Manager uploads a file
When the file format is not supported
Then the system displays an error message and prevents upload
Supported file types (by extension):
* * * * * PDF → .pdf
Text → .txt
Video → .mp4
Audio → .mp3
HTML → .html, .htm
Additional Rules:
* * Maximum file size: 10MB
Only one file allowed per template
Error message:
“Unsupported file type. Please upload a PDF, TXT, MP4, MP3, or HTML file.”
AC3: Successful Upload & Storage
Given a supported file is uploaded
Then the system:
* * * Stores the file in secure object storage
Retains:
* * * Original file name
File size
File type
Links the uploaded file to the template record
And the uploaded file is displayed with:
* * File name
File type
AC4: Save Draft with Uploaded File
Given an uploaded file is present
When the Content Manager clicks Save Draft
Then:
* * * * A template record is created (if not already created)
Status is set to Draft
File upload is optional for Save Draft
The draft is visible to Content Managers 
AC5: Submit Uploaded Template for Review
Given the Content Manager has:
* * Uploaded a valid file
Completed all required metadata fields (Title, Description, Format, Category)
When the Content Manager clicks Submit 
Then:
* * * * The system validates that a file is attached
Status changes to In Review
The approval workflow is initiated
The template remains hidden from Advisers until approved
AC6: Replace or Remove Uploaded File
Given a file has been uploaded
When the Content Manager chooses to replace the file
Then:
* * The previous file is removed and replaced
The new file is validated and stored
When the Content Manager removes the file
Then:
* * The file is deleted from the template
Submission is blocked until a new file is uploaded
AC7: Error Handling
* * If file upload fails:
* * An error message is displayed
The user remains on the Create Template screen
If the user navigates away with an uploaded file and unsaved changes:
* A confirmation dialog is displayed
AC8: Permissions & Visibility
* * * Only users with Content Manager permissions can upload files
Uploaded templates:
* Are visible to Advisers only after submission
Advisers cannot access the raw uploaded file unless explicitly enabled downstream



## 📋 Definition of Ready (DOR) Checklist
*未明确配置 DOR Checklist*

💬 **[View Comments & Discussions (查看评审与讨论历史)](LEAD-303_Upload_a_template_file_comments.md)**

