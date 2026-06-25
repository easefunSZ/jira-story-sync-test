# Feature - LEAD-190: Content Manager-Supporting video file uploads

## 📋 Jira Metadata
| Field | Value |
| :--- | :--- |
| **Jira Key** | `LEAD-190` |
| **Type** | `Feature` |
| **Status** | `打开` |
| **Parent Epic** | `LEAD-34` |
| **Labels** | `DOR_FEAT` |
| **Components** | `Leads Additions` |

## 📖 Original Description
Adding templates and or marketing material in video formats for advisers to use


---

### 💡 AI 深度技术分析与卡点评估

#### 1. 核心功能目标 (Business Goal)
在模板和营销库中支持视频文件格式的上传与顾问消费。

#### 2. 业务边界与核心场景 (Scope & Boundaries)
- **业务范围**：大视频文件上传及流媒体加速，控制视频格式（MP4/MOV）与大小安全。
- **输入数据**：依赖前置校验合格后流入的 Standard Payload 数据结构。
- **输出流向**：记录结果审计入库、下发 SQS 或进行页面渲染。

#### 3. 技术方案设计与难点评估 (Technical Design & Complexity)
- **技术实现**：前端基于 S3 Multipart Upload 开启断点续传；后端整合 AWS S3 与 CloudFront CDN 进行视频安全防毒扫描与高并发流媒体分发。
- **复杂度评估**：**中 (Medium)**。主要考量高并发去重加锁、大文件批处理时的 JVM 内存分配，以及多系统对接时的时延控制。
