import fs from "node:fs";
import path from "node:path";

const testCasePostmanDir = path.resolve(import.meta.dirname, "..");
const sourcePath = path.resolve(testCasePostmanDir, "..", "..", "..", "Lead-308", "postman", "LEAD-308-v2-contract.postman_collection.json");
const outputPath = path.join(testCasePostmanDir, "LEAD-308-407-adviser-ac.postman_collection.json");
const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));

const numberedNames = [
  "NEW-01 Category Tree - Adviser Navigation",
  "NEW-06 Tag Taxonomy - Four Mandatory Groups",
  "EX-01 Published List - Email Adviser Cards",
  "EX-01 Search - Template Name Title Description or Tag Name",
  "EX-01 Category and Subcategory Filter",
  "EX-01 Tag Filter - Same Group OR Cross Group AND Contract",
  "EX-04 已发布详情（含 Metadata） - Resolve Current Active",
  "EX-04 Preview Context - Body and Metadata Only"
];

const lookup = new Map(numberedNames.map((name, index) => [name, 101 + index]));

function visit(items) {
  for (const item of items ?? []) {
    if (item.item) visit(item.item);
    else {
      const number = lookup.get(item.name);
      if (!number) throw new Error(`Unexpected LEAD-308 request name: ${item.name}`);
      item.name = `${number} ${item.name}`;
    }
  }
}

visit(source.item);
source.info.name = "LEAD-308 / LEAD-407 Adviser AC Verification";
source.info.description = "Generated from the frozen LEAD-308 v2 Contract collection. Numeric prefixes make the requests traceable in the shared Newman report pipeline.";
fs.writeFileSync(outputPath, `${JSON.stringify(source, null, 2)}\n`);
console.log(`Generated ${outputPath}`);
