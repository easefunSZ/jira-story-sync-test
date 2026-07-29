import fs from "node:fs";
import path from "node:path";

const postmanDir = path.resolve(import.meta.dirname, "..");
const sourcePath = path.resolve(postmanDir, "..", "..", "postman", "LEAD-93-v2-full-run.postman_collection.json");
const outputPath = path.join(postmanDir, "LEAD-93-405-backend-ac.postman_collection.json");
const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function flatten(items) {
  return (items || []).flatMap(item => item.item ? flatten(item.item) : [item]);
}

function baseName(name) {
  return name.replace(/^\d+\s+/, "");
}

const sourceItems = new Map(flatten(source.item).map(item => [baseName(item.name), item]));
function requestFrom(name) {
  const item = sourceItems.get(name);
  if (!item) throw new Error(`Missing source request: ${name}`);
  return clone(item.request);
}

const envelope = [
  "let json;",
  "pm.test('HTTP status is 200', () => pm.response.to.have.status(200));",
  "pm.test('Response is JSON', () => { json = pm.response.json(); pm.expect(json).to.be.an('object'); });",
  "pm.test('IIC response envelope exists', () => { pm.expect(json).to.include.all.keys('requestId', 'responseCode', 'responseMessage', 'data'); });"
];

function success(extra = []) {
  return [...envelope,
    "pm.test('Business response is successful', () => pm.expect(json.responseCode).to.eql('00000000'));",
    "pm.test('Response time is below 10 seconds', () => pm.expect(pm.response.responseTime).to.be.below(10000));",
    ...extra
  ];
}

function fieldFailure(expectedFields) {
  const fields = JSON.stringify(expectedFields);
  return [...envelope,
    "pm.test('Business response is a field validation failure', () => pm.expect(json.responseCode).to.eql('00000006'));",
    "pm.test('All field errors are returned together', () => { pm.expect(json.data).to.be.an('object'); pm.expect(json.data.fieldErrors).to.be.an('array').and.not.empty; pm.expect(json.data.invalidFieldCount).to.eql(json.data.fieldErrors.length); });",
    `pm.test('Expected invalid fields are represented', () => { const actual = json.data.fieldErrors.map(item => String(item.field || '')); for (const expected of ${fields}) pm.expect(actual.some(field => field.includes(expected))).to.eql(true, 'Missing field error: ' + expected); });`,
    "pm.test('Field errors are displayable', () => json.data.fieldErrors.forEach(item => { pm.expect(item.code).to.be.a('string').and.not.empty; pm.expect(item.message).to.be.a('string').and.not.empty; }));"
  ];
}

function businessFailure(extra = []) {
  return [...envelope,
    "pm.test('Business response is rejected', () => pm.expect(json.responseCode).to.not.eql('00000000'));",
    "pm.test('Rejected command has no success payload', () => pm.expect(json.data === null || typeof json.data === 'object').to.eql(true);",
    ...extra
  ];
}

const writeGuard = [
  "if (pm.variables.get('enableWriteTests') !== 'true') { console.warn('Write request skipped. Set enableWriteTests=true.'); pm.execution.skipRequest(); }"
];
const permissionGuard = [
  "if (pm.variables.get('runPermissionTests') !== 'true' || !pm.variables.get('adviserAuthorization')) { console.warn('Permission request skipped. Set runPermissionTests=true and adviserAuthorization.'); pm.execution.skipRequest(); }"
];

function item(name, sourceName, body, tests, preRequest = [], options = {}) {
  const request = requestFrom(sourceName);
  if (body !== undefined) {
    let raw = typeof body === "string" ? body : JSON.stringify(body, null, 2);
    // Postman substitutes variables as text. Keep business email codes quoted, but
    // emit Category/Subcategory Long IDs and tag arrays as JSON values.
    raw = raw
      .replaceAll('"{{acTagGroupsJson}}"', '{{acTagGroupsJson}}')
      .replaceAll('"{{acMultiTagGroupsJson}}"', '{{acMultiTagGroupsJson}}')
      .replace(/"\{\{(ac(?:Source|Target|Unused|Recreated)CategoryId|acSourceSubcategoryId[12]|acTargetSubcategoryId[12])\}\}"/g, '{{$1}}');
    request.body = {
      mode: "raw",
      raw,
      options: {raw: {language: "json"}}
    };
  }
  if (options.headers) request.header = options.headers;
  const events = [];
  if (preRequest.length) events.push({listen: "prerequest", script: {type: "text/javascript", exec: preRequest}});
  events.push({listen: "test", script: {type: "text/javascript", exec: tests}});
  return {name, request, response: [], event: events};
}

const tagGroups = "{{acTagGroupsJson}}";
const multiTagGroups = "{{acMultiTagGroupsJson}}";
const activeTemplateBody = {
  moduleCode: "COMMUNICATION", moduleCodeName: "Communications", scenarioCode: "TEMPLATE_LIBRARY",
  emailName: "{{acActiveTemplateName}}", description: "LEAD-93/405 backend AC active template",
  title: "LEAD-93/405 active subject", editMode: "HTML", emailContent: "{{acEmailContent}}",
  textContent: "LEAD-93/405 active body", fileKeys: "", emailContentKey: "{{acEmailContentKey}}",
  isDraft: "2", effectiveWay: 0, effectiveFrom: null, effectiveUntil: null, thumbnailKey: null,
  channelMap: {}, isCustomBranding: "0", categoryId: "{{acSourceCategoryId}}",
  subCategoryIds: ["{{acSourceSubcategoryId1}}"], tagGroups
};
const draftTemplateBody = {
  moduleCode: "COMMUNICATION", moduleCodeName: "Communications", scenarioCode: "TEMPLATE_LIBRARY",
  emailName: "{{acDraftTemplateName}}", description: null, title: null, editMode: "HTML",
  emailContent: "{{acEmailContent}}", textContent: null, fileKeys: "", emailContentKey: "{{acEmailContentKey}}",
  isDraft: "1", effectiveWay: 1, effectiveFrom: "{{acFutureEffectiveFrom}}", effectiveUntil: null,
  thumbnailKey: null, channelMap: {}, isCustomBranding: "0", categoryId: null, subCategoryIds: [], tagGroups: []
};

const preflight = [
  item("01 NEW-06 Tag taxonomy: four mandatory groups and multi-select data", "Preflight - Tag Taxonomy and Select Valid Tags", undefined, success([
    "pm.test('Exactly four mandatory groups are available', () => { const expected = ['CONTENT_TYPE','TRIGGER','LIFECYCLE_STAGE','FINANCIAL_NEED']; const groups = json.data.filter(group => Number(group.isMandatory) === 1); pm.expect(groups.map(group => group.groupCode)).to.have.members(expected); pm.expect(groups).to.have.lengthOf(4); });",
    "pm.test('At least one group supports multiple values', () => pm.expect(json.data.some(group => (group.tagValues || []).length >= 2)).to.eql(true));",
    "const required = json.data.filter(group => Number(group.isMandatory) === 1); const selected = required.map(group => ({groupCode: group.groupCode, tagCodes: [(group.tagValues || [])[0].tagCode]})); pm.environment.set('acTagGroupsJson', JSON.stringify(selected)); const multiGroup = required.find(group => (group.tagValues || []).length >= 2); const multi = required.map(group => ({groupCode: group.groupCode, tagCodes: group.groupCode === multiGroup.groupCode ? group.tagValues.slice(0, 2).map(value => value.tagCode) : [group.tagValues[0].tagCode]})); pm.environment.set('acMultiTagGroupsJson', JSON.stringify(multi)); pm.environment.set('acMultiTagGroupCode', multiGroup.groupCode);"
  ])),
  item("02 NEW-01 Category tree: active two-level taxonomy", "Preflight - Category Tree and Initialise Run", undefined, success([
    "pm.test('Tree contains only valid levels', () => { const roots = json.data || []; roots.forEach(root => { pm.expect(Number(root.parentId)).to.eql(0); (root.children || []).forEach(child => pm.expect(Number(child.parentId)).to.eql(Number(root.id))); }); });"
  ])),
  item("03 EX-01 Published list accepts Email-only filter", "Initial Published List", {isCampaign: 0, querySort: 0, keyWords: "", pageNum: 1, pageSize: 20}, success()),
  item("04 EX-02 Draft list accepts Draft status", "Initial Draft Admin List", {keyWords: "", templateStatus: 0, pageNum: 1, pageSize: 20}, success())
];

const categorySetup = [
  item("05 NEW-02 rejects blank Category name", "Create Source Category", {categoryName: "", description: null, parentId: 0}, fieldFailure(["categoryName"]), writeGuard),
  item("06 NEW-02 creates Source Category", "Create Source Category", {categoryName: "{{acSourceCategoryName}}", description: "Source category for AC regression", parentId: 0}, success([
    "pm.test('Source Category ID is numeric', () => pm.expect(json.data.id).to.be.a('number'));",
    "pm.environment.set('acSourceCategoryId', String(json.data.id));"
  ]), writeGuard),
  item("07 NEW-02 creates Target Category", "Create Target Category", {categoryName: "{{acTargetCategoryName}}", description: "Target category for AC regression", parentId: 0}, success([
    "pm.environment.set('acTargetCategoryId', String(json.data.id));"
  ]), writeGuard),
  item("08 NEW-02 creates Unused Category", "Create Unused Category", {categoryName: "{{acUnusedCategoryName}}", description: null, parentId: 0}, success([
    "pm.environment.set('acUnusedCategoryId', String(json.data.id));"
  ]), writeGuard),
  item("09 NEW-02 rejects duplicate active Category name", "Create Source Category", {categoryName: "{{acSourceCategoryName}}", description: null, parentId: 0}, businessFailure(), writeGuard),
  item("10 NEW-08 rejects more than five Subcategories atomically", "Batch Create Source Subcategories", {parentId: "{{acSourceCategoryId}}", subcategories: [{name: "{{acTooManyPrefix}}1"},{name: "{{acTooManyPrefix}}2"},{name: "{{acTooManyPrefix}}3"},{name: "{{acTooManyPrefix}}4"},{name: "{{acTooManyPrefix}}5"},{name: "{{acTooManyPrefix}}6"}]}, fieldFailure(["subcategories"]), writeGuard),
  item("11 NEW-08 rejects invalid batch without partial create", "Batch Create Source Subcategories", {parentId: "{{acSourceCategoryId}}", subcategories: [{name: "{{acInvalidBatchName}}"},{name: ""}]}, fieldFailure(["subcategories[1].name"]), writeGuard),
  item("12 NEW-08 creates two Source Subcategories", "Batch Create Source Subcategories", {parentId: "{{acSourceCategoryId}}", subcategories: [{name: "{{acSourceSubcategoryName1}}", description: "Source one"},{name: "{{acSourceSubcategoryName2}}", description: "Source two"}]}, success([
    "pm.test('Two Subcategories are returned in request order', () => pm.expect(json.data).to.be.an('array').with.lengthOf(2));",
    "pm.environment.set('acSourceSubcategoryId1', String(json.data[0].id)); pm.environment.set('acSourceSubcategoryId2', String(json.data[1].id));"
  ]), writeGuard),
  item("13 NEW-08 creates Target Subcategories", "Batch Create Target Subcategory", {parentId: "{{acTargetCategoryId}}", subcategories: [{name: "{{acTargetSubcategoryName1}}", description: "Target one"}, {name: "{{acTargetSubcategoryName2}}", description: "Target two"}]}, success([
    "pm.test('Two Target Subcategories are returned', () => pm.expect(json.data).to.be.an('array').with.lengthOf(2));",
    "pm.environment.set('acTargetSubcategoryId1', String(json.data[0].id)); pm.environment.set('acTargetSubcategoryId2', String(json.data[1].id));"
  ]), writeGuard),
  item("14 NEW-03 updates Category name and description", "Update Source Category", {categoryId: "{{acSourceCategoryId}}", categoryName: "{{acSourceCategoryUpdatedName}}", description: "Updated source category description"}, success(), writeGuard),
  item("15 NEW-05 persists complete Source Subcategory order", "Save Complete Root Category Order", [{categoryId: "{{acSourceSubcategoryId2}}", sortOrder: 1}, {categoryId: "{{acSourceSubcategoryId1}}", sortOrder: 2}], success(), writeGuard),
  item("16 NEW-12 soft-deletes unreferenced Category", "Delete Unreferenced Category", {sourceCategoryId: "{{acUnusedCategoryId}}"}, success(), writeGuard)
];

const templateAndMetadata = [
  item("17 EX-05 Draft rejects missing Template Name", "Create Temporary V1 Active", {...draftTemplateBody, emailName: "{{acInvalidDraftName}}"}, fieldFailure(["emailName"]), writeGuard),
  item("18 EX-05 creates lenient V1 Draft without Metadata", "Create Temporary V1 Active", draftTemplateBody, success([
    "pm.test('V1 Draft identifiers are returned', () => { pm.expect(json.data.emailCode).to.be.a('string').and.not.empty; pm.expect(json.data.version).to.eql('V1'); });",
    "pm.environment.set('acDraftEmailCode', String(json.data.emailCode));"
  ]), writeGuard),
  item("19 EX-02 returns created Draft", "Initial Draft Admin List", {keyWords: "{{acDraftTemplateName}}", templateStatus: 0, pageNum: 1, pageSize: 20}, success([
    "pm.test('Draft appears in Draft list', () => pm.expect((json.data.dataList || []).some(row => String(row.emailCode) === pm.environment.get('acDraftEmailCode'))).to.eql(true));"
  ])),
  item("20 EX-05 Publish returns every mandatory field error and rolls back", "Create Temporary V1 Active", {...draftTemplateBody, emailName: "{{acInvalidPublishName}}", title: null, emailContent: "", emailContentKey: "", textContent: "", isDraft: "2", effectiveWay: 0, categoryId: null, subCategoryIds: [], tagGroups: [{groupCode: "CONTENT_TYPE", tagCodes: []},{groupCode: "TRIGGER", tagCodes: []},{groupCode: "LIFECYCLE_STAGE", tagCodes: []},{groupCode: "FINANCIAL_NEED", tagCodes: []}]}, fieldFailure(["title", "categoryId", "subCategoryIds", "tagGroups", "emailContent"]), writeGuard),
  item("21 EX-05 creates valid V1 Active with full Metadata", "Create Temporary V1 Active", activeTemplateBody, success([
    "pm.test('V1 Active is created', () => { pm.expect(json.data.emailCode).to.be.a('string').and.not.empty; pm.expect(json.data.version).to.eql('V1'); });",
    "pm.environment.set('acActiveEmailCode', String(json.data.emailCode));"
  ]), writeGuard),
  item("22 EX-03 returns active Template and current Metadata", "Verify EX-06 Metadata Persistence by Detail", {emailCode: "{{acActiveEmailCode}}", version: "V1"}, success([
    "pm.test('Detail returns current Category Metadata', () => pm.expect(json.data).to.be.an('object'));"
  ])),
  item("23 EX-01 filters Published Template by Category, Subcategory and Tags", "Search Published Temporary Template", {isCampaign: 0, querySort: 0, keyWords: "{{acActiveTemplateName}}", categoryId: "{{acSourceCategoryId}}", subCategoryIds: ["{{acSourceSubcategoryId1}}"], tagGroups, pageNum: 1, pageSize: 20}, success([
    "pm.test('Published search returns the active Template', () => pm.expect((json.data.dataList || []).some(row => String(row.emailCode) === pm.environment.get('acActiveEmailCode'))).to.eql(true));"
  ])),
  item("24 EX-06 reassigns Published Template Metadata without Version transition", "Update Template Metadata", {emailCode: "{{acActiveEmailCode}}", emailName: "{{acActiveTemplateName}}", description: "Metadata reassigned to target", channelMap: {EMAIL: "Email"}, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}"], tagGroups: multiTagGroups}, success(), writeGuard),
  item("25 EX-13 confirms V1 remains Active after Metadata change", "Get V1 Version Detail", {emailCode: "{{acActiveEmailCode}}", version: "V1"}, success([
    "pm.test('Version state remains Active', () => pm.expect(Number(json.data.versionStatus)).to.eql(1));"
  ])),
  item("26 EX-03 confirms replaced Category/Subcategory/Tag relations", "Verify EX-06 Metadata Persistence by Detail", {emailCode: "{{acActiveEmailCode}}", version: "V1"}, success([
    "pm.test('Detail uses target Category', () => pm.expect(String(json.data.categoryId)).to.eql(pm.environment.get('acTargetCategoryId')));",
    "pm.test('Detail retains multi-select Tag group', () => { const map = json.data.tagMap || {}; const selected = map[pm.environment.get('acMultiTagGroupCode')] || []; pm.expect(selected.length).to.be.at.least(2); });"
  ])),
  item("27 EX-06 changes only Subcategories within the same Category", "Update Template Metadata", {emailCode: "{{acActiveEmailCode}}", emailName: "{{acActiveTemplateName}}", description: "Subcategory-only change", channelMap: {EMAIL: "Email"}, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}", "{{acTargetSubcategoryId2}}"], tagGroups: multiTagGroups}, success(), writeGuard),
  item("28 EX-03 confirms multiple current Subcategories", "Verify EX-06 Metadata Persistence by Detail", {emailCode: "{{acActiveEmailCode}}", version: "V1"}, success([
    "pm.test('Detail contains both target Subcategories', () => { const selected = (json.data.subCategoryIds || []).map(String); pm.expect(selected).to.include(pm.environment.get('acTargetSubcategoryId1')); pm.expect(selected).to.include(pm.environment.get('acTargetSubcategoryId2')); });"
  ])),
  item("29 EX-06 rejects Subcategory outside selected Category", "Update Template Metadata", {emailCode: "{{acActiveEmailCode}}", emailName: "{{acActiveTemplateName}}", description: "invalid category-subcategory combination", channelMap: {}, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acSourceSubcategoryId1}}"], tagGroups: multiTagGroups}, fieldFailure(["subCategoryIds"]), writeGuard),
  item("30 EX-06 rejects free-text or unknown Tag value", "Update Template Metadata", {emailCode: "{{acActiveEmailCode}}", emailName: "{{acActiveTemplateName}}", description: "invalid tag test", channelMap: {}, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}"], tagGroups: [{groupCode: "CONTENT_TYPE", tagCodes: ["UNKNOWN_TAG_VALUE"]},{groupCode: "TRIGGER", tagCodes: []},{groupCode: "LIFECYCLE_STAGE", tagCodes: []},{groupCode: "FINANCIAL_NEED", tagCodes: []}]}, fieldFailure(["tagGroups"]), writeGuard),
  item("31 EX-01 finds Published Template by assigned Tag", "Search Published Temporary Template", {isCampaign: 0, querySort: 0, keyWords: "", categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}"], tagGroups: multiTagGroups, pageNum: 1, pageSize: 20}, success([
    "pm.test('Tag filter returns the reclassified active Template', () => pm.expect((json.data.dataList || []).some(row => String(row.emailCode) === pm.environment.get('acActiveEmailCode'))).to.eql(true));"
  ]))
];

const copyAndLifecycle = [
  item("32 NEW-10 creates independent Copy and Create V1 Draft", "Copy and Create Independent Draft", {sourceEmailCode: "{{acActiveEmailCode}}", sourceVersion: "V1", moduleCode: "COMMUNICATION", moduleCodeName: "Communications", scenarioCode: "TEMPLATE_LIBRARY", emailName: "{{acCopyTemplateName}}", description: "Independent copy", channelMap: {}, isCustomBranding: "0", title: "Copied subject", editMode: "HTML", emailContent: "{{acEmailContent}}", emailContentKey: "{{acEmailContentKey}}", textContent: "Copied body", fileKeys: "", thumbnailKey: null, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}"], tagGroups: multiTagGroups}, success([
    "pm.test('Copy has a distinct ID and V1 Draft', () => { pm.expect(String(json.data.emailCode)).to.not.eql(pm.environment.get('acActiveEmailCode')); pm.expect(json.data.version).to.eql('V1'); pm.expect(Number(json.data.versionStatus)).to.eql(3); });",
    "pm.environment.set('acCopyEmailCode', String(json.data.emailCode));"
  ]), writeGuard),
  item("33 EX-10 saves Copy working Draft without changing source", "Update V2 Working Draft Content", {emailCode: "{{acCopyEmailCode}}", version: "V1", moduleCode: "COMMUNICATION", scenarioCode: "TEMPLATE_LIBRARY", title: "Copied subject updated", editMode: "HTML", emailContent: "{{acEmailContent}}", textContent: "Copied body updated", fileKeys: "", emailContentKey: "{{acEmailContentKey}}", thumbnailKey: null, isCustomBranding: "0", isDraft: "1"}, success(), writeGuard),
  item("34 EX-04 confirms original Published Template remains readable", "Verify Published V1 Detail", {emailCode: "{{acActiveEmailCode}}"}, success()),
  item("35 EX-07 deactivates the original only when explicitly requested", "Deactivate Temporary Template", {emailCode: "{{acActiveEmailCode}}", emailStatus: 0}, success(), writeGuard),
  item("36 EX-04 hides explicitly deactivated Template", "Verify Published V1 Detail", {emailCode: "{{acActiveEmailCode}}"}, businessFailure()),
  item("37 EX-07 reactivates the original Template", "Deactivate Temporary Template", {emailCode: "{{acActiveEmailCode}}", emailStatus: 1}, success(), writeGuard),
  item("38 EX-04 confirms reactivated original remains readable", "Verify Published V1 Detail", {emailCode: "{{acActiveEmailCode}}"}, success()),
  item("39 EX-08 discards Copy working Template by soft delete", "Cleanup - Delete Copied Template", {emailCode: "{{acCopyEmailCode}}"}, success(), writeGuard),
  item("40 EX-03 rejects discarded Copy Template", "Verify Copied Draft Detail", {emailCode: "{{acCopyEmailCode}}", version: "V1"}, businessFailure()),
  item("41 EX-09 creates V2 Draft from Active", "Create Draft for Scheduled Delete", {emailCode: "{{acActiveEmailCode}}", moduleCode: "COMMUNICATION", scenarioCode: "TEMPLATE_LIBRARY", title: "V2 draft", editMode: "HTML", emailContent: "{{acEmailContent}}", textContent: "V2 draft body", fileKeys: "", emailContentKey: "{{acEmailContentKey}}", thumbnailKey: null, isCustomBranding: "0", effectiveWay: 0, effectiveFrom: null, effectiveUntil: null, isDraft: "1"}, success([
    "pm.environment.set('acV2Version', String(json.data.version));"
  ]), writeGuard),
  item("42 EX-10 schedules existing V2 Draft", "Schedule V2 with Dynamic Future Time", {emailCode: "{{acActiveEmailCode}}", version: "{{acV2Version}}", moduleCode: "COMMUNICATION", scenarioCode: "TEMPLATE_LIBRARY", title: "V2 scheduled", editMode: "HTML", emailContent: "{{acEmailContent}}", textContent: "V2 scheduled body", fileKeys: "", emailContentKey: "{{acEmailContentKey}}", thumbnailKey: null, isCustomBranding: "0", effectiveWay: 1, effectiveFrom: "{{acFutureEffectiveFrom}}", effectiveUntil: null, isDraft: "2"}, success(), writeGuard),
  item("43 EX-10 cancels Schedule back to same V2 Draft", "Cancel Schedule via EX-10", {emailCode: "{{acActiveEmailCode}}", version: "{{acV2Version}}", moduleCode: "COMMUNICATION", scenarioCode: "TEMPLATE_LIBRARY", title: "V2 scheduled", editMode: "HTML", emailContent: "{{acEmailContent}}", textContent: "V2 scheduled body", fileKeys: "", emailContentKey: "{{acEmailContentKey}}", thumbnailKey: null, isDraft: "1"}, success(), writeGuard),
  item("44 EX-13 confirms cancelled V2 is Draft", "Verify V2 Draft Retains Schedule Time", {emailCode: "{{acActiveEmailCode}}", version: "{{acV2Version}}"}, success([
    "pm.test('Cancelled Version is Draft', () => pm.expect(Number(json.data.versionStatus)).to.eql(3));"
  ])),
  item("45 EX-10 publishes V2 and expires V1", "Publish V2 Now", {emailCode: "{{acActiveEmailCode}}", version: "{{acV2Version}}", moduleCode: "COMMUNICATION", scenarioCode: "TEMPLATE_LIBRARY", title: "V2 published", editMode: "HTML", emailContent: "{{acEmailContent}}", textContent: "V2 published body", fileKeys: "", emailContentKey: "{{acEmailContentKey}}", thumbnailKey: null, isCustomBranding: "0", effectiveWay: 0, effectiveFrom: null, effectiveUntil: null, isDraft: "2"}, success(), writeGuard),
  item("46 EX-14 shows V2 Active and V1 Expired history", "Get Version History", {emailCode: "{{acActiveEmailCode}}", pageNum: 1, pageSize: 20, isAsc: false}, success([
    "pm.test('Version history contains both V1 and V2', () => { const rows = json.data.dataList || json.data || []; pm.expect(rows.map(row => row.version)).to.include('V1'); pm.expect(rows.map(row => row.version)).to.include(pm.environment.get('acV2Version')); });"
  ]))
];

const reassignmentAndDelete = [
  item("47 NEW-11 batch reassigns active Template to Source Category", "Batch Reassign Both Templates to Target Category", {templates: [{emailCode: "{{acActiveEmailCode}}", categoryId: "{{acSourceCategoryId}}", subCategoryIds: ["{{acSourceSubcategoryId1}}"], tagGroups: multiTagGroups}]}, success(), writeGuard),
  item("48 NEW-12 soft-deletes unreferenced Subcategory without deleting parent", "Delete Unreferenced Category", {sourceCategoryId: "{{acSourceSubcategoryId2}}"}, success(), writeGuard),
  item("49 NEW-01 confirms Source Category remains after leaf deletion", "Preflight - Category Tree and Initialise Run", undefined, success([
    "pm.test('Source Category remains after its unused Subcategory is deleted', () => pm.expect((json.data || []).map(node => node.categoryName)).to.include(pm.environment.get('acSourceCategoryUpdatedName')));"
  ])),
  item("50 NEW-12 first delete request reports referenced Source Category", "Check Referenced Source Category Impact", {sourceCategoryId: "{{acSourceCategoryId}}"}, success([
    "pm.test('Referenced source requires reassignment', () => { pm.expect(json.data.reassignRequired).to.eql(true); pm.expect(Number(json.data.affectedTemplateCount)).to.be.at.least(1); });"
  ]), writeGuard),
  item("51 NEW-12 reassigns references and soft-deletes Source Category", "Reassign References and Delete Source Category", {sourceCategoryId: "{{acSourceCategoryId}}", targetCategoryId: "{{acTargetCategoryId}}", targetSubcategoryIds: ["{{acTargetSubcategoryId1}}"]}, success(), writeGuard),
  item("52 EX-03 confirms Template moved to Target after Category deletion", "Verify EX-06 Metadata Persistence by Detail", {emailCode: "{{acActiveEmailCode}}", version: "{{acV2Version}}"}, success([
    "pm.test('Current Template Category is Target', () => pm.expect(String(json.data.categoryId)).to.eql(pm.environment.get('acTargetCategoryId')));"
  ])),
  item("53 NEW-01 hides deleted Source Category", "Preflight - Category Tree and Initialise Run", undefined, success([
    "pm.test('Deleted Source is absent from tree', () => { const names = (json.data || []).map(node => node.categoryName); pm.expect(names).to.not.include(pm.environment.get('acSourceCategoryUpdatedName')); });"
  ])),
  item("54 NEW-02 permits reusing a soft-deleted Category name", "Create Source Category", {categoryName: "{{acSourceCategoryUpdatedName}}", description: "Recreated after soft delete", parentId: 0}, success([
    "pm.environment.set('acRecreatedCategoryId', String(json.data.id));"
  ]), writeGuard)
];

const permissions = [
  item("55 Permission: Adviser cannot create Category", "Create Source Category", {categoryName: "{{acPermissionCategoryName}}", description: null, parentId: 0}, businessFailure(), [...writeGuard, ...permissionGuard], {
    headers: requestFrom("Create Source Category").header.map(header => header.key.toLowerCase() === "authorization" ? {...header, value: "{{adviserAuthorization}}"} : header)
  }),
  item("56 Permission: Adviser cannot create Template", "Create Temporary V1 Active", activeTemplateBody, businessFailure(), [...writeGuard, ...permissionGuard], {
    headers: requestFrom("Create Temporary V1 Active").header.map(header => header.key.toLowerCase() === "authorization" ? {...header, value: "{{adviserAuthorization}}"} : header)
  }),
  item("57 Permission: Adviser cannot update Template Metadata or Tags", "Update Template Metadata", {emailCode: "{{acActiveEmailCode}}", emailName: "{{acActiveTemplateName}}", description: "Adviser permission check", channelMap: {EMAIL: "Email"}, categoryId: "{{acTargetCategoryId}}", subCategoryIds: ["{{acTargetSubcategoryId1}}"], tagGroups: multiTagGroups}, businessFailure(), [...writeGuard, ...permissionGuard], {
    headers: requestFrom("Update Template Metadata").header.map(header => header.key.toLowerCase() === "authorization" ? {...header, value: "{{adviserAuthorization}}"} : header)
  })
];

const cleanup = [
  item("58 Cleanup: delete lenient Draft Template", "Cleanup - Delete Primary Template", {emailCode: "{{acDraftEmailCode}}"}, success(), writeGuard),
  item("59 Cleanup: delete primary Template", "Cleanup - Delete Primary Template", {emailCode: "{{acActiveEmailCode}}"}, success(), writeGuard),
  item("60 Cleanup: delete recreated Category", "Cleanup Fallback - Delete Source Category if Needed", {sourceCategoryId: "{{acRecreatedCategoryId}}"}, success(), writeGuard),
  item("61 Cleanup: delete Target Category cascade", "Cleanup - Delete Target Category", {sourceCategoryId: "{{acTargetCategoryId}}"}, success(), writeGuard),
  item("62 NEW-01 confirms no temporary Categories remain", "Final Verification - No Temporary Categories Remain", undefined, success([
    "pm.test('No temporary root Categories remain', () => { const names = (json.data || []).map(node => node.categoryName || ''); ['acSourceCategoryUpdatedName','acTargetCategoryName','acUnusedCategoryName'].forEach(key => pm.expect(names).to.not.include(pm.environment.get(key))); });"
  ]))
];

let sequence = 1;
function numbered(items) {
  return items.map(entry => ({...entry, name: `${String(sequence++).padStart(2, "0")} ${baseName(entry.name)}`}));
}

const collection = {
  info: {
    _postman_id: "22c9dd93-820a-4fb8-834d-f5a50e692405",
    name: "LEAD-93 + LEAD-405 Backend AC Regression",
    description: "Backend-only acceptance suite generated from current Jira Story AC and the Web v2 API Contract. It intentionally excludes UI-only AC such as navigation, dialog rendering, drag gesture and WYSIWYG toolbar visuals.",
    schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  variable: [
    {key: "baseUrl", value: "", type: "string"}, {key: "gatewayPrefix", value: "", type: "string"},
    {key: "authorization", value: "", type: "string"}, {key: "adviserAuthorization", value: "", type: "string"},
    {key: "xApigwApiId", value: "", type: "string"}, {key: "language", value: "en-US", type: "string"},
    {key: "enableWriteTests", value: "false", type: "string"}, {key: "runPermissionTests", value: "false", type: "string"},
    {key: "aesSecretKey", value: "1234567890123456", type: "string"}
  ],
  event: [{listen: "prerequest", script: {type: "text/javascript", exec: [
    "if (!pm.variables.get('authorization')) pm.request.headers.remove('authorization');",
    "if (!pm.variables.get('xApigwApiId')) pm.request.headers.remove('x-apigw-api-id');",
    "const now = Date.now();",
    "if (!pm.environment.get('acRunId')) { const runId = `AC_${now}`; pm.environment.set('acRunId', runId); pm.environment.set('acSourceCategoryName', `LEAD93 AC Source ${runId}`); pm.environment.set('acSourceCategoryUpdatedName', `LEAD93 AC Source Updated ${runId}`); pm.environment.set('acTargetCategoryName', `LEAD93 AC Target ${runId}`); pm.environment.set('acUnusedCategoryName', `LEAD93 AC Unused ${runId}`); pm.environment.set('acSourceSubcategoryName1', `LEAD93 AC Source One ${runId}`); pm.environment.set('acSourceSubcategoryName2', `LEAD93 AC Source Two ${runId}`); pm.environment.set('acTargetSubcategoryName1', `LEAD93 AC Target One ${runId}`); pm.environment.set('acTargetSubcategoryName2', `LEAD93 AC Target Two ${runId}`); pm.environment.set('acTooManyPrefix', `LEAD93 AC TooMany ${runId} `); pm.environment.set('acInvalidBatchName', `LEAD93 AC InvalidBatch ${runId}`); pm.environment.set('acDraftTemplateName', `LEAD93 AC Draft ${runId}`); pm.environment.set('acActiveTemplateName', `LEAD93 AC Active ${runId}`); pm.environment.set('acCopyTemplateName', `LEAD93 AC Copy ${runId}`); pm.environment.set('acInvalidDraftName', ''); pm.environment.set('acInvalidPublishName', `LEAD93 AC Invalid Publish ${runId}`); pm.environment.set('acPermissionCategoryName', `LEAD93 AC Permission ${runId}`); const future = new Date(Date.now() + 48 * 60 * 60 * 1000).toISOString().slice(0, 19).replace('T', ' '); pm.environment.set('acFutureEffectiveFrom', future); }",
    "if (!pm.environment.get('acEmailContent')) { const baseUrl = String(pm.variables.get('baseUrl') || ''); const key = String(pm.variables.get('aesSecretKey') || '1234567890123456').padEnd(16, '0').slice(0, 16); if (baseUrl.includes('localhost') || baseUrl.includes('127.0.0.1')) { pm.environment.set('acEmailContent', 'MOCK_AES_CONTENT'); pm.environment.set('acEmailContentKey', key); } else { const CryptoJS = require('crypto-js'); const parsedKey = CryptoJS.enc.Utf8.parse(key); const cipher = CryptoJS.AES.encrypt('<p>LEAD-93/405 backend AC content</p>', parsedKey, {mode: CryptoJS.mode.ECB, padding: CryptoJS.pad.Pkcs7}).toString(); pm.environment.set('acEmailContent', cipher); pm.environment.set('acEmailContentKey', key); } }"
  ]}}],
  item: [
    {name: "01 Preflight and Read APIs", item: numbered(preflight)},
    {name: "02 Category and Subcategory APIs", item: numbered(categorySetup)},
    {name: "03 Template Create, Validation and Metadata APIs", item: numbered(templateAndMetadata)},
    {name: "04A Copy Independence APIs", item: numbered(copyAndLifecycle.slice(0, 7))},
    {name: "04B Version Lifecycle APIs", item: numbered(copyAndLifecycle.slice(7))},
    {name: "05 Reassignment, Delete and Permission APIs", item: numbered([...reassignmentAndDelete, ...permissions])},
    {name: "99 Cleanup", item: numbered(cleanup)}
  ]
};

fs.writeFileSync(outputPath, `${JSON.stringify(collection, null, 2)}\n`);
console.log(`Generated ${outputPath}`);
console.log(`Requests: ${flatten(collection.item).length}`);
