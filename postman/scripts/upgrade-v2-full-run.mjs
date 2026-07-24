import fs from "node:fs";
import path from "node:path";

const postmanDir = path.resolve(import.meta.dirname, "..");
const collectionPath = path.join(postmanDir, "LEAD-93-v2-full-run.postman_collection.json");
const collection = JSON.parse(fs.readFileSync(collectionPath, "utf8"));

// Requests that can run without IDs created by this test run. They always run first.
const independentNames = [
  "Load Channel List",
  "Initial Published List",
  "Initial Draft Admin List",
  "Preflight - Category Tree and Initialise Run",
  "Preflight - Tag Taxonomy and Select Valid Tags"
];

// Ordered lifecycle. Keep every producer before requests that consume its runtime IDs.
const workflowNames = [
  "Create Source Category",
  "Create Target Category",
  "Create Unused Category",
  "Update Source Category",
  "Batch Create Source Subcategories",
  "Batch Create Target Subcategory",
  "Save Complete Root Category Order",
  "Delete Unreferenced Category",
  "Create Temporary V1 Draft",
  "Update Template Metadata",
  "Verify V1 Draft Detail",
  "Verify Draft Admin List",
  "Update V1 Draft Content",
  "Publish V1 Now",
  "Verify Published V1 Detail",
  "Search Published Temporary Template",
  "Update Template Master Fields",
  "Deactivate Temporary Template",
  "Reactivate Temporary Template",
  "Get Max Version",
  "Get V1 Version Detail",
  "Get Version History",
  "Copy and Create Independent Draft",
  "Verify Copied Draft Detail",
  "Add Target Version V2",
  "Verify V2 Version Detail",
  "Create V3 Working Draft",
  "Update V3 Working Draft",
  "Schedule V3 with Dynamic Future Time",
  "Cancel Schedule by Save Draft",
  "Publish V3 Now",
  "Create V4 Draft for Discard",
  "Discard V4 Draft",
  "Batch Reassign Both Templates to Target Category",
  "Move Primary Template Back to Source Metadata",
  "Check Referenced Source Category Impact",
  "Reassign References and Delete Source Category"
];

// Cleanup is protected: configured skip rules are ignored for these requests.
const cleanupNames = [
  "Cleanup - Delete Copied Template",
  "Cleanup - Delete Primary Template",
  "Verify Temporary Templates Removed",
  "Cleanup Fallback - Delete Unused Category if Needed",
  "Cleanup Fallback - Delete Source Category if Needed",
  "Cleanup - Delete Target Category",
  "Final Verification - No Temporary Categories Remain"
];

// Optional persistent skips. Use exact base names from the lists above; never add cleanup names.
// Prefer Environment variables skipRequestNames/skipSteps for temporary Dev limitations.
const skippedNames = [
  "Load Channel List"
];

function flatten(items) {
  return items.flatMap(item => item.item ? flatten(item.item) : [item]);
}

function baseName(name) {
  return name.replace(/^\d+\s+/, "");
}

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function normalizeItem(item) {
  const normalized = deepClone(item);
  for (const event of normalized.event || []) {
    if (!event.script?.exec) continue;
    event.script.exec = event.script.exec.map(line =>
      line.replaceAll("pm.collectionVariables", "pm.environment")
    );
  }
  return normalized;
}

const groups = [independentNames, workflowNames, cleanupNames];
const configuredNames = groups.flat();
const duplicateNames = configuredNames.filter((name, index) => configuredNames.indexOf(name) !== index);
if (duplicateNames.length) {
  throw new Error(`Duplicate v2 orchestration names: ${[...new Set(duplicateNames)].join(", ")}`);
}

const existingItems = flatten(collection.item);
const byName = new Map();
for (const item of existingItems) {
  const name = baseName(item.name);
  if (byName.has(name)) throw new Error(`Duplicate v2 request base name: ${name}`);
  byName.set(name, item);
}

const missingNames = configuredNames.filter(name => !byName.has(name));
const unconfiguredNames = [...byName.keys()].filter(name => !configuredNames.includes(name));
if (missingNames.length || unconfiguredNames.length) {
  throw new Error([
    missingNames.length ? `Missing requests: ${missingNames.join(", ")}` : "",
    unconfiguredNames.length ? `Unconfigured requests: ${unconfiguredNames.join(", ")}` : ""
  ].filter(Boolean).join("; "));
}

const invalidSkips = skippedNames.filter(name => !configuredNames.includes(name));
const cleanupSkips = skippedNames.filter(name => cleanupNames.includes(name));
if (invalidSkips.length) throw new Error(`Unknown configured skips: ${invalidSkips.join(", ")}`);
if (cleanupSkips.length) throw new Error(`Cleanup requests cannot be skipped: ${cleanupSkips.join(", ")}`);

let sequence = 1;
function buildGroup(names) {
  return names.map(name => {
    const item = normalizeItem(byName.get(name));
    item.name = `${String(sequence++).padStart(2, "0")} ${name}`;
    return item;
  });
}

const independentItems = buildGroup(independentNames);
const workflowItems = buildGroup(workflowNames);
const cleanupItems = buildGroup(cleanupNames);

collection.info.name = "LEAD-93 v2 Contract - Configurable Fail-Fast Lifecycle Run";
collection.info.description = "Configuration-driven v2 regression. Independent requests run first, the dependency workflow runs in explicit order, and Cleanup is protected from skip rules.";
collection.item = [
  {
    name: "01 Independent Queries",
    description: "Requests with no test-run ID dependency. They execute before data creation.",
    item: independentItems
  },
  {
    name: "02 Dependency Workflow",
    description: "Explicit ordered lifecycle. The runner stops at the first failed request or assertion.",
    item: workflowItems
  },
  {
    name: "99 Cleanup",
    description: "Protected cleanup and final verification. Skip configuration is ignored for this folder.",
    item: cleanupItems
  }
];

collection.event = [{
  listen: "prerequest",
  script: {
    type: "text/javascript",
    exec: [
      "if (!pm.variables.get('authorization')) { pm.request.headers.remove('authorization'); }",
      "if (!pm.variables.get('xApigwApiId')) { pm.request.headers.remove('x-apigw-api-id'); }",
      "const requestBaseName = pm.info.requestName.replace(/^\\d+\\s+/, '');",
      "const requestStepMatch = pm.info.requestName.match(/^(\\d+)/);",
      "const requestStep = requestStepMatch ? requestStepMatch[1] : '';",
      "const splitConfig = value => String(value || '').split(',').map(item => item.trim()).filter(Boolean);",
      "let configuredSkips = [];",
      "let protectedCleanup = [];",
      "try { configuredSkips = JSON.parse(pm.variables.get('configuredSkipRequestNamesJson') || '[]'); } catch (error) { throw new Error('configuredSkipRequestNamesJson is invalid JSON'); }",
      "try { protectedCleanup = JSON.parse(pm.variables.get('cleanupRequestNamesJson') || '[]'); } catch (error) { throw new Error('cleanupRequestNamesJson is invalid JSON'); }",
      "const skippedRequestNames = new Set([...configuredSkips, ...splitConfig(pm.variables.get('skipRequestNames'))]);",
      "const skippedSteps = new Set(splitConfig(pm.variables.get('skipSteps')).map(step => step.padStart(2, '0')));",
      "const skipRequested = skippedRequestNames.has(requestBaseName) || skippedSteps.has(requestStep);",
      "if (skipRequested && protectedCleanup.includes(requestBaseName)) { console.warn(`Ignored skip rule for protected Cleanup request: ${pm.info.requestName}`); }",
      "if (skipRequested && !protectedCleanup.includes(requestBaseName)) { console.warn(`Skipped by v2 orchestration configuration: ${pm.info.requestName}`); pm.execution.skipRequest(); }"
    ]
  }
}];

const variables = new Map((collection.variable || []).map(variable => [variable.key, variable]));
function setVariable(key, value, type = "string") {
  variables.set(key, {...(variables.get(key) || {}), key, value, type});
}
setVariable("configuredSkipRequestNamesJson", JSON.stringify(skippedNames));
setVariable("cleanupRequestNamesJson", JSON.stringify(cleanupNames));
setVariable("skipRequestNames", "");
setVariable("skipSteps", "");
collection.variable = [...variables.values()];

const runtimeScripts = flatten(collection.item).flatMap(item =>
  (item.event || []).flatMap(event => event.script?.exec || [])
);
if (runtimeScripts.some(line => line.includes("pm.collectionVariables"))) {
  throw new Error("Runtime state still uses collection variables");
}

fs.writeFileSync(collectionPath, `${JSON.stringify(collection, null, 2)}\n`);
console.log(`Upgraded ${collectionPath}`);
console.log(`Groups: ${independentItems.length} independent, ${workflowItems.length} sequential, ${cleanupItems.length} cleanup; configured skips: ${skippedNames.length}`);
