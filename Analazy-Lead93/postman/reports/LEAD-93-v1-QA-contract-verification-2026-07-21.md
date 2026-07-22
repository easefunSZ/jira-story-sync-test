# LEAD-93 v1 QA Contract 验证报告

> 环境：QA（Host、认证信息和业务数据已脱敏）  
> 日期：2026-07-21  
> 工具：Newman + `newman-reporter-htmlextra`

## 1. 执行结果

| 测试组 | 请求 | 断言 | 失败 | 写操作 |
|---|---:|---:|---:|---|
| v1 完整生命周期 | 22 | 110 | 0 | 创建隔离 Template，结束时已软删除 |
| v1 Contract 差异探针 | 16 | 86 | 0 | 无，只读 |

完整生命周期验证了 Draft、Publish、Version Add、Active/Expired 切换、Active Version 删除拒绝和最终清理。差异探针验证了分页字段、Template Library Filter 和 `getNextVersion`。

## 2. 已确认契约

| 项目 | QA 结论 |
|---|---|
| 响应包络 | `requestId/responseCode/responseMessage/data` |
| 成功业务码 | `00000000` |
| 分页请求 | `pageNum/pageSize` |
| 分页响应 | `pageNo/pageSize/totalCount/totalPage/dataList` |
| `channelList` 列表项 | `channelCode/channelName` |
| `templateList` 更新字段 | `updatedBy/updatedDate` |
| Version History 更新字段 | `updatedBy/updatedDate` |
| 版本格式 | `V1/V2/...` |
| `getNextVersion` | Endpoint 存在，`data` 返回 `Vn` String |
| `version/add` | 成功时 `data=null`；需重新查询确认最终状态 |
| `version/update` | 返回 VO 外形，但字段可以全部为 null |
| v1 Version Detail | 不返回 Category/Subcategory/Tag |

## 3. 分页 A/B

| Endpoint | 发送 `pageNum=2` | 发送 `pageNo=2` |
|---|---|---|
| `templateList` | 响应 `pageNo=2` | 响应 `pageNo=1` |
| `queryList` | 响应 `pageNo=2` | 响应 `pageNo=1` |
| `recipientList` | 响应 `pageNo=2` | 响应 `pageNo=1` |

结论：`pageNo` 只属于响应字段，不能作为分页请求字段。

## 4. Template Library Filter

QA 对照请求确认以下字段会改变查询结果：

- `templateStatus`
- `channelList`
- `emailStatusList`
- `sortField`
- `isAsc`
- `keyWords`

无效 Channel 和不存在的关键字均返回 0 条；`emailStatusList=["0"]` 只返回 Inactive，`emailStatusList=["1"]` 只返回 Active；`updatedDate` 正序和倒序返回不同首条记录。

`templateStatus=1` 已确认会过滤结果；其他枚举值的完整业务含义仍应由现有常量或页面逻辑定义，不能仅凭记录数推断。

## 5. 未完成的行为验证

- 当前 QA 的 `queryList` 基线结果为 0 条，无法证明 `channelList/isCampaign/querySort` 的精确过滤行为。
- `update.isCampaign` 尚未通过“切换值后重新查询”证明实际落库。

## 6. 可执行材料

- [完整生命周期 Collection](../LEAD-93-v1-full-run.postman_collection.json)
- [差异探针 Collection](../LEAD-93-v1-contract-probes.postman_collection.json)
- [Newman 一键脚本](../run-v1-newman.sh)
- [完整生命周期 HTML](v1-full-run-2026-07-21_132810.html)
- [差异探针 HTML](v1-contract-probes-2026-07-21_132746.html)
- [完整生命周期脱敏 JSON](v1-full-run-2026-07-21_132810.summary.json)
- [差异探针脱敏 JSON](v1-contract-probes-2026-07-21_132746.summary.json)
