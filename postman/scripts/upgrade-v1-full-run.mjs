import fs from "node:fs";
import path from "node:path";

const postmanDir = path.resolve(import.meta.dirname, "..");
const collectionPath = path.join(postmanDir, "LEAD-93-v1-full-run.postman_collection.json");
const collection = JSON.parse(fs.readFileSync(collectionPath, "utf8"));

const independentNames = [
  "Channel List",
  "Query Object",
  "Recipient List",
  "Initial Published List"
];

const workflowNames = [
  "Create Temporary V1 Draft",
  "Verify Draft Detail",
  "Verify Draft Max Version",
  "Verify V1 Detail",
  "Verify Initial History",
  "Update Temporary Template",
  "Disable Temporary Template",
  "Re-enable Temporary Template",
  "Update V1 Draft Content",
  "Publish Temporary V1",
  "Verify Published Detail",
  "Search Published Test Template",
  "Add Target Version V2",
  "Verify V2 Is Maximum",
  "Verify Current Version Detail",
  "Verify V2 Active and V1 Expired",
  "Verify Active Version Delete Is Rejected"
];

function flatten(items) {
  return items.flatMap(item => item.item ? flatten(item.item) : [item]);
}

function baseName(name) {
  return name
    .replace(/^\d+\s+/, "")
    .replace(/^Cleanup\s+-\s+/, "Cleanup - ");
}

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function scripts(item) {
  return (item.event || []).flatMap(event => event.script?.exec || []);
}

function normalizeItem(item) {
  const normalized = deepClone(item);
  const request = normalized.request;
  if (typeof request.url === "string") {
    request.url = request.url.replace("{{baseUrl}}/dae/", "{{baseUrl}}{{gatewayPrefix}}/");
  } else if (request.url?.raw) {
    request.url.raw = request.url.raw.replace("{{baseUrl}}/dae/", "{{baseUrl}}{{gatewayPrefix}}/");
  }

  for (const header of request.header || []) {
    if (header.key.toLowerCase() === "requestid") header.value = "{{$guid}}";
  }

  for (const event of normalized.event || []) {
    if (!event.script?.exec) continue;
    event.script.exec = event.script.exec.map(line =>
      line.replaceAll("pm.collectionVariables", "pm.environment")
    );
  }
  return normalized;
}

function numbered(item, number, name) {
  const result = normalizeItem(item);
  result.name = `${String(number).padStart(2, "0")} ${name}`;
  return result;
}

const existing = flatten(collection.item);
const byName = new Map();
for (const item of existing) {
  const name = baseName(item.name);
  if (!byName.has(name)) byName.set(name, item);
}

function requiredItem(name) {
  const item = byName.get(name);
  if (!item) throw new Error(`Missing v1 full-run request: ${name}`);
  return item;
}

const independent = independentNames.map((name, index) =>
  numbered(requiredItem(name), index + 1, name)
);
const workflow = workflowNames.map((name, index) =>
  numbered(requiredItem(name), independent.length + index + 1, name)
);

const deleteTemplate = numbered(
  requiredItem("Cleanup - Delete Temporary Template"),
  independent.length + workflow.length + 1,
  "Cleanup - Delete Temporary Template"
);

for (const event of deleteTemplate.event || []) {
  if (event.listen !== "test" || !event.script?.exec) continue;
  event.script.exec = event.script.exec.filter(line => !line.includes("pm.environment.unset"));
}

const searchTemplate = requiredItem("Search Published Test Template");
const verifyRemoved = normalizeItem(searchTemplate);
verifyRemoved.name = `${String(independent.length + workflow.length + 2).padStart(2, "0")} Final Verification - Temporary Template Removed`;
verifyRemoved.request.description = "Verifies that the isolated v1 test Template is no longer returned after soft deletion.";
verifyRemoved.event = [{
  listen: "test",
  script: {
    type: "text/javascript",
    exec: [
      "pm.test('HTTP status is 200', function () { pm.response.to.have.status(200); });",
      "const json = pm.response.json();",
      "pm.test('v1 response envelope exists', function () { pm.expect(json).to.have.property('responseCode'); pm.expect(json).to.have.property('responseMessage'); });",
      "pm.test('Business response is successful', function () { pm.expect(json.responseCode).to.eql('00000000'); });",
      "const rows = Array.isArray(json.data?.dataList) ? json.data.dataList : [];",
      "pm.test('Deleted temporary Template is not returned', function () { pm.expect(rows.some(item => String(item.emailCode) === String(pm.environment.get('testEmailCode')))).to.eql(false); });",
      "pm.environment.unset('testEmailCode');",
      "pm.environment.unset('testEmailName');",
      "pm.environment.unset('activeVersion');",
      "pm.environment.unset('draftVersion');"
    ]
  }
}];

collection.info.name = "LEAD-93 v1 As-Is - Full Fail-Fast Lifecycle Run (17 Endpoints)";
collection.info.description = "Runs four independent v1 queries first, then an isolated Template lifecycle. The first request or assertion failure stops the dependency workflow; the runner subsequently executes only the Cleanup folder with exported runtime IDs.";
collection.event = [{
  listen: "prerequest",
  script: {
    type: "text/javascript",
    exec: [
      "if (!pm.variables.get('authorization')) { pm.request.headers.remove('authorization'); }",
      "if (!pm.variables.get('xApigwApiId')) { pm.request.headers.remove('x-apigw-api-id'); }"
    ]
  }
}];
collection.item = [
  {
    name: "01 Independent Queries",
    description: "Read-only requests with no dependency on test data. Run before any write operation.",
    item: independent
  },
  {
    name: "02 Dependency Workflow",
    description: "Creates one isolated Template and verifies the existing v1 Draft, Publish, Version and status lifecycle in strict order.",
    item: workflow
  },
  {
    name: "99 Cleanup",
    description: "Soft-deletes only the Template created by this run, then verifies that it is no longer returned.",
    item: [deleteTemplate, verifyRemoved]
  }
];

const variables = new Map((collection.variable || []).map(variable => [variable.key, variable]));
const defaults = [
  {key: "baseUrl", value: "http://localhost:8086", type: "string"},
  {key: "gatewayPrefix", value: "", type: "string"},
  {key: "authorization", value: "", type: "string"},
  {key: "xApigwApiId", value: "", type: "string"},
  {key: "language", value: "en-US", type: "string"},
  {key: "enableWriteTests", value: "true", type: "string"},
  {key: "testEmailName", value: "", type: "string"},
  {key: "testEmailCode", value: "", type: "string"},
  {key: "activeVersion", value: "V1", type: "string"},
  {key: "draftVersion", value: "V2", type: "string"}
];
collection.variable = defaults.map(variable => ({...variable, ...(variables.get(variable.key) || {})}));

const collectionVariableLines = flatten(collection.item).flatMap(scripts).filter(line => line.includes("pm.collectionVariables"));
if (collectionVariableLines.length) throw new Error("Runtime state still uses collection variables");

fs.writeFileSync(collectionPath, `${JSON.stringify(collection, null, 2)}\n`);
console.log(`Upgraded ${collectionPath}`);
