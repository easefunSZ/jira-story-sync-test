# LEAD-93 / 405 / 406 / 407 / 308 后端 AC 验证入口

## 运行

使用与现有 LEAD-93/405 包相同的环境文件和数据库配置：

```bash
cd Lead-93/TestCase/postman
./run-lead93-405-406-407-308-ac-with-db.sh local-dev-LEAD-93-405-backend-ac.postman_environment.json
```

环境文件继续使用 `baseUrl`、`gatewayPrefix`、`authorization`、`xApigwApiId`、`language` 和既有数据库配置。不要在 Git 中保存 Token 或数据库密码。

## 执行内容

1. 原样调用 `run-lead93-lead405-ac-with-db.sh`，得到 LEAD-93/405 的逐条 Story、场景、步骤、API、DB checkpoint 和 Cleanup 证据。
2. 使用同一运行时 Environment 执行编号 `101--108` 的 LEAD-308/407 Adviser 读接口：Category Tree、Tag Taxonomy、Published List、Search、Filter、Published Detail 和 Preview Context。
3. 输出三个入口：LEAD-93/405 详细 AC 报告、LEAD-308/407 阶段 Debug、跨五个 Feature 的总览报告。

## 结果语义

- API 或 DB 实测失败：保留请求、响应和 SQL 证据，继续执行无依赖检查。
- 前置测试数据未建立：只跳过依赖步骤并写明原因。
- `OPEN`：Jira 已有需求但 API Contract 尚未冻结，不能用猜测的请求替代。
- `N/A UI`：页面交互/视觉行为，转前端测试，不计为后端通过。

当前不能由该脚本真实判定的 AC：LEAD-296 删除/停用最终语义、LEAD-328 迁移执行入口和 mapping、LEAD-318 排序定义、LEAD-321 Email/Campaign activation Contract，以及所有纯 UI AC。完整原因和补齐条件见 [主测试流程](LEAD-93_405_406_407_308_AC_Master_Test_Plan_CN.md)。

## 远程数据库执行

当 Mac/本机无法直连测试 MySQL 时，使用同一套 API 测试和远程只读 DB checkpoint：

```bash
cd Lead-93/TestCase/postman
./run-lead93-405-406-407-308-ac-with-remote-db.sh \
  local-dev-LEAD-93-405-backend-ac.postman_environment.json \
  remote-db-test.env
```

`remote-db-test.env` 从 [模板](postman/remote-db-test.env.example) 复制并填写：`REMOTE_BASH_WS`、`REMOTE_DB_PROPERTIES_PATH` 和可选超时。数据库密码只保留在远程运行服务所使用的 properties 文件中；脚本不会写入或复制密码。

## LEAD-406 / 308 / 407 快速只读回归

不希望运行 LEAD-93/405 写入和数据库检查时，执行：

```bash
cd Lead-93/TestCase/postman
./run-lead308-406-407-read-contract.sh local-dev-LEAD-93-405-backend-ac.postman_environment.json
```

它只使用系统中已有的 Adviser 可见 Published Template，不创建、更新或删除任何数据，也不连接数据库。执行完成后输出 Newman Debug HTML 和 Summary JSON。
