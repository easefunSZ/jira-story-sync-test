import fs from "node:fs";
import path from "node:path";

const postmanDir = path.resolve(import.meta.dirname, "..");
const adviserSourcePath = path.resolve(postmanDir, "..", "..", "..", "Lead-308", "postman", "LEAD-308-v2-contract.postman_collection.json");
const v2SourcePath = path.resolve(postmanDir, "..", "..", "postman", "LEAD-93-v2-full-run.postman_collection.json");
const outputPath = path.join(postmanDir, "LEAD-308-406-407-read-contract.postman_collection.json");

function clone(value) { return JSON.parse(JSON.stringify(value)); }
function flatten(items) { return (items ?? []).flatMap(item => item.item ? flatten(item.item) : [item]); }

const suite = clone(JSON.parse(fs.readFileSync(adviserSourcePath, "utf8")));
const v2Items = new Map(flatten(JSON.parse(fs.readFileSync(v2SourcePath, "utf8")).item).map(item => [item.name, item]));
const adviserNames = [
  "NEW-01 Category Tree - Adviser Navigation",
  "NEW-06 Tag Taxonomy - Four Mandatory Groups",
  "EX-01 Published List - Email Adviser Cards",
  "EX-01 Search - Template Name Title Description or Tag Name",
  "EX-01 Category and Subcategory Filter",
  "EX-01 Tag Filter - Same Group OR Cross Group AND Contract",
  "EX-04 已发布详情（含 Metadata） - Resolve Current Active",
  "EX-04 Preview Context - Body and Metadata Only"
];
const numbers = new Map(adviserNames.map((name, index) => [name, 101 + index]));
for (const item of flatten(suite.item)) {
  const number = numbers.get(item.name);
  if (!number) throw new Error(`Unexpected Adviser source request: ${item.name}`);
  item.name = `${number} ${item.name}`;
}

const commonTests = [
  "pm.test('HTTP status is 200', () => pm.response.to.have.status(200));",
  "let json; pm.test('Response is JSON', () => { json = pm.response.json(); pm.expect(json).to.be.an('object'); });",
  "pm.test('IIC response envelope exists', () => pm.expect(json).to.include.all.keys('requestId', 'responseCode', 'responseMessage', 'data'));",
  "pm.test('Business response is successful', () => pm.expect(json.responseCode).to.eql('00000000'));",
  "pm.test('Response time is below 10 seconds', () => pm.expect(pm.response.responseTime).to.be.below(10000));"
];
function event(listen, exec) { return {listen, script: {type: "text/javascript", exec}}; }
function versionRequest(name, sourceName, body, tests) {
  const source = v2Items.get(sourceName);
  if (!source) throw new Error(`Missing v2 source request: ${sourceName}`);
  const item = clone(source);
  item.name = name;
  item.request.body.raw = JSON.stringify(body, null, 2);
  item.event = [
    event("prerequest", ["if (!pm.collectionVariables.get('emailCode')) { console.warn('Skipped: Published List did not supply emailCode.'); pm.execution.skipRequest(); }"]),
    event("test", tests)
  ];
  return item;
}

const versionFolder = {
  name: "04 LEAD-406 Version Read APIs",
  item: [
    {
      name: "109 EX-12 Get Maximum Version for selected Published Template",
      request: {
        method: "GET",
        header: clone(v2Items.get("22 Get V1 Version Detail").request.header),
        url: "{{baseUrl}}{{gatewayPrefix}}/iic-dae-msg/web/msg/template/email/v2/version/getMaxVersion?emailCode={{emailCode}}"
      },
      response: [],
      event: [
        event("prerequest", ["if (!pm.collectionVariables.get('emailCode')) { console.warn('Skipped: Published List did not supply emailCode.'); pm.execution.skipRequest(); }"]),
        event("test", [...commonTests,
          "pm.test('Maximum Version is returned for the selected Template', () => { pm.expect(String(json.data.emailCode)).to.eql(String(pm.collectionVariables.get('emailCode'))); pm.expect(json.data.version).to.match(/^V\\d+$/); });",
          "pm.collectionVariables.set('readVersion', String(json.data.version));"
        ])
      ]
    },
    versionRequest("110 EX-13 Read selected maximum Version detail", "22 Get V1 Version Detail", {emailCode: "{{emailCode}}", version: "{{readVersion}}"}, [...commonTests,
      "pm.test('Requested Version Detail is returned', () => pm.expect(String(json.data.version)).to.eql(String(pm.collectionVariables.get('readVersion')));"
    ]),
    versionRequest("111 EX-14 Read Version History", "23 Get Version History", {emailCode: "{{emailCode}}", pageNum: 1, pageSize: 20, isAsc: false}, [...commonTests,
      "pm.test('Version History contains the selected maximum Version', () => { pm.expect(json.data.dataList).to.be.an('array'); pm.expect(json.data.dataList.some(item => String(item.version) === String(pm.collectionVariables.get('readVersion')))).to.eql(true); });"
    ])
  ]
};

suite.item.push(versionFolder);
suite.info.name = "LEAD-308 / LEAD-406 / LEAD-407 Read-only Contract Verification";
suite.info.description = "Standalone, non-destructive verification. It uses an existing Adviser-visible Published template and does not create, update, delete or run database checks.";
fs.writeFileSync(outputPath, `${JSON.stringify(suite, null, 2)}\n`);
console.log(`Generated ${outputPath}`);
