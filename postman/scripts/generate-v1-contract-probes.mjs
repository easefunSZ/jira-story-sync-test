import fs from "node:fs";
import path from "node:path";
import {randomUUID} from "node:crypto";

const postmanDir = path.resolve(import.meta.dirname, "..");
const output = path.join(postmanDir, "LEAD-93-v1-contract-probes.postman_collection.json");
const basePath = "/iic-dae-msg/web/msg/template/email/v1";

const headers = [
  {key: "authorization", value: "{{authorization}}", type: "text"},
  {key: "x-apigw-api-id", value: "{{xApigwApiId}}", type: "text"},
  {key: "language", value: "{{language}}", type: "text"},
  {key: "requestid", value: "{{$guid}}", type: "text"},
  {key: "Accept", value: "application/json", type: "text"},
  {key: "Content-Type", value: "application/json", type: "text"}
];

const commonTests = [
  "pm.test('HTTP status is 200', function () { pm.response.to.have.status(200); });",
  "const json = pm.response.json();",
  "pm.test('IIC response envelope exists', function () { ['requestId','responseCode','responseMessage','data'].forEach(key => pm.expect(json).to.have.property(key)); });",
  "pm.test('Business response is successful', function () { pm.expect(json.responseCode).to.eql('00000000'); });",
  "pm.test('Response time is below 10 seconds', function () { pm.expect(pm.response.responseTime).to.be.below(10000); });"
];

function request(name, endpoint, body, tests = []) {
  return {
    name,
    request: {
      method: "POST",
      header: headers,
      url: `{{baseUrl}}{{gatewayPrefix}}${basePath}${endpoint}`,
      body: {mode: "raw", raw: JSON.stringify(body, null, 2), options: {raw: {language: "json"}}}
    },
    response: [],
    event: [{listen: "test", script: {type: "text/javascript", exec: [...commonTests, ...tests]}}]
  };
}

function templateList(name, body, tests = []) {
  return request(name, "/templateList", body, [
    "pm.test('Template list page exists', function () { pm.expect(json.data).to.be.an('object'); pm.expect(json.data.dataList).to.be.an('array'); });",
    ...tests
  ]);
}

function pageProbe(name, endpoint, body, expectedPage, resultLabel) {
  return request(name, endpoint, body, [
    `pm.test('${resultLabel}', function () { pm.expect(json.data.pageNo).to.eql(${expectedPage}); });`
  ]);
}

const items = [
  templateList("01 Seed and Baseline", {pageNum: 1, pageSize: 5, keyWords: ""}, [
    "pm.test('Baseline contains a reusable template', function () { pm.expect(json.data.dataList.length).to.be.above(0); });",
    "if (json.data.dataList.length) { pm.environment.set('probeEmailCode', String(json.data.dataList[0].emailCode)); }",
    "pm.environment.set('baselineTotal', String(json.data.totalCount));"
  ]),
  templateList("02 templateStatus=1", {pageNum: 1, pageSize: 5, keyWords: "", templateStatus: "1"}),
  templateList("03 templateStatus=3", {pageNum: 1, pageSize: 5, keyWords: "", templateStatus: "3"}),
  templateList("04 Invalid Channel Filter", {pageNum: 1, pageSize: 5, keyWords: "", channelList: ["__NO_SUCH_CHANNEL__"]}, [
    "pm.test('Invalid channel returns no records', function () { pm.expect(json.data.totalCount).to.eql(0); });"
  ]),
  templateList("05 Inactive Filter", {pageNum: 1, pageSize: 20, keyWords: "", emailStatusList: ["0"]}, [
    "pm.test('Inactive filter only returns emailStatus 0', function () { json.data.dataList.forEach(item => pm.expect(item.emailStatus).to.eql(0)); });"
  ]),
  templateList("06 Active Filter", {pageNum: 1, pageSize: 20, keyWords: "", emailStatusList: ["1"]}, [
    "pm.test('Active filter only returns emailStatus 1', function () { json.data.dataList.forEach(item => pm.expect(item.emailStatus).to.eql(1)); });"
  ]),
  templateList("07 Impossible Keyword", {pageNum: 1, pageSize: 5, keyWords: "__LEAD93_NO_MATCH__"}, [
    "pm.test('Impossible keyword returns no records', function () { pm.expect(json.data.totalCount).to.eql(0); });"
  ]),
  templateList("08 updatedDate ASC", {pageNum: 1, pageSize: 5, keyWords: "", sortField: "updatedDate", isAsc: true}, [
    "if (json.data.dataList.length) { pm.environment.set('ascFirstUpdatedDate', String(json.data.dataList[0].updatedDate)); }"
  ]),
  templateList("09 updatedDate DESC", {pageNum: 1, pageSize: 5, keyWords: "", sortField: "updatedDate", isAsc: false}, [
    "pm.test('ASC and DESC select different first rows when data permits', function () { if (json.data.totalCount > 1) pm.expect(String(json.data.dataList[0].updatedDate)).not.to.eql(pm.environment.get('ascFirstUpdatedDate')); });"
  ]),
  pageProbe("10 templateList pageNum=2", "/templateList", {pageNum: 2, pageSize: 1, keyWords: ""}, 2, "pageNum binds to requested page"),
  pageProbe("11 templateList pageNo=2", "/templateList", {pageNo: 2, pageSize: 1, keyWords: ""}, 1, "pageNo is ignored and defaults to page 1"),
  pageProbe("12 queryList pageNum=2", "/queryList", {pageNum: 2, pageSize: 1, emailName: "", isCampaign: 0}, 2, "queryList accepts pageNum"),
  pageProbe("13 queryList pageNo=2", "/queryList", {pageNo: 2, pageSize: 1, emailName: "", isCampaign: 0}, 1, "queryList ignores pageNo"),
  pageProbe("14 recipientList pageNum=2", "/recipientList", {pageNum: 2, pageSize: 1, keyWords: ""}, 2, "recipientList accepts pageNum"),
  pageProbe("15 recipientList pageNo=2", "/recipientList", {pageNo: 2, pageSize: 1, keyWords: ""}, 1, "recipientList ignores pageNo"),
  {
    name: "16 Get Next Version",
    request: {
      method: "GET",
      header: headers.filter(header => header.key !== "Content-Type"),
      url: `{{baseUrl}}{{gatewayPrefix}}${basePath}/version/getNextVersion?emailCode={{probeEmailCode}}`
    },
    response: [],
    event: [{listen: "test", script: {type: "text/javascript", exec: [
      ...commonTests,
      "pm.test('Next version uses Vn format', function () { pm.expect(json.data).to.be.a('string').and.match(/^V\\d+$/); });"
    ]}}]
  }
];

const collection = {
  info: {
    _postman_id: randomUUID(),
    name: "LEAD-93 v1 QA Contract Difference Probes",
    description: "Read-only A/B probes for pagination binding, templateList filters and getNextVersion. No template data is created or modified.",
    schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  event: [{
    listen: "prerequest",
    script: {
      type: "text/javascript",
      exec: [
        "if (!pm.variables.get('authorization')) { pm.request.headers.remove('authorization'); }",
        "if (!pm.variables.get('xApigwApiId')) { pm.request.headers.remove('x-apigw-api-id'); }"
      ]
    }
  }],
  item: items,
  variable: [
    {key: "baseUrl", value: "http://localhost:31093", type: "string"},
    {key: "gatewayPrefix", value: "", type: "string"},
    {key: "authorization", value: "", type: "string"},
    {key: "xApigwApiId", value: "", type: "string"},
    {key: "language", value: "en-US", type: "string"},
    {key: "probeEmailCode", value: "", type: "string"},
    {key: "baselineTotal", value: "", type: "string"},
    {key: "ascFirstUpdatedDate", value: "", type: "string"}
  ]
};

fs.writeFileSync(output, `${JSON.stringify(collection, null, 2)}\n`);
console.log(`Generated ${output}`);
