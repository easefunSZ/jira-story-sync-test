# Feature - LEAD-5: Batch Lead Ingestion-Segment Agnostic

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-5` |
| **Type** | `Feature` |
| **Status** | `Ready for Deployment` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Fix` |

## 📖 Original Description
Feature Goal
Enable automated ingestion of MADM manual lead files into the standard lead pipeline with real-time processing removing the need for incident logging and BAU manual processing.
Context
Lead data is fed into the pipeline either via API or manually.  Manual uploads will always be required for creation of new opportunities.The current manual source is MADM, these data files are created by the internal PF customer analytics team
Problem Statement
Data files are batched in chunks, to manage the throughput constraints and loaded on a directory as and when, by the internal PF customer analytics team.Once these files are picked and processed, by the Operations bau team, it follows the existing validation and allocation pattern.
The BAU team requires an incident to be logged in order to process these files. 
IG end users ( Campaign Manager and Campaign Administrator)and the Internal PF customer analytics team, have no insight to the success or failure of these uploads. 
Moving Forward
This feature requires that manual uploads are automatically ingested into the normal pattern used for automated uploads.Should not require a user to log an incident to process. The BAU operation team should not have to pick up the files to process and load into IG.                                                                                                                                            The process should be real time.The upload should be able to handle files that have in excess of 50k records.
The campaign manager, the campaign administrator and the PF customer analytics team need to be notified of a successful or failed upload, via email.


## 📖 Linked Stories (关联的故事需求)
- **[LEAD-149](stories/LEAD-149_Create_Demo_Scenarios_for_showcase.md)**: Create Demo Scenario's for showcase *(状态: 已完成 | 故事点数: 3)*
- **[LEAD-87](stories/LEAD-87_Batch_campaign_upload_in_IG_one_error_wont_stop_whole_batch.md)**: Batch campaign upload in IG — one error won't stop whole batch *(状态: Ready for Deployment | 故事点数: 5)*
- **[LEAD-67](stories/LEAD-67_Email_Notification_for_File_Failures.md)**: Email Notification  for File Failures *(状态: Ready for Deployment | 故事点数: 3)*
- **[LEAD-54](stories/LEAD-54_Successfailure_data_for_reporting.md)**: Success/failure data for reporting *(状态: Ready for Deployment | 故事点数: 3)*
- **[LEAD-53](stories/LEAD-53_Near_real_time_processing.md)**: Near real time processing *(状态: Ready for Deployment | 故事点数: 5)*
- **[LEAD-52](stories/LEAD-52_Support_large_files.md)**: Support large files *(状态: Ready for Deployment | 故事点数: 3)*
- **[LEAD-51](stories/LEAD-51_Automated_ingestion_of_manual_files.md)**: Automated ingestion of manual files *(状态: Ready for Deployment | 故事点数: 5)*
- **[LEAD-50](stories/LEAD-50_Use_existing_validation_processing_rules.md)**: Use existing validation & processing rules *(状态: Ready for Deployment | 故事点数: 3)*

---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
实现 MADM 手动批量上传线索文件的自动化、实时处理，免去人工运维介入。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：DAE 前端大文件上传模块与 Matillion ETL 的数据清洗配合，对错误线索进行记录级捕获。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：前端分片上传（AWS S3 Multipart Upload），Matillion 执行分批（Batch 1000）写入 SQS。对于校验失败的单条记录需要上报失败列表，并提供 Record-level failure visibility 报表，防止整批数据阻塞。
- **复杂度评估**：**高 (High)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
