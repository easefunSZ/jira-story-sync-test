import fs from "node:fs";

const [input, output, environmentFile] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: node sanitize-htmlextra-report.mjs <input.html> <output.html> [environment.json]");
  process.exit(2);
}

const environment = environmentFile
  ? JSON.parse(fs.readFileSync(environmentFile, "utf8"))
  : {values: []};
const values = Object.fromEntries((environment.values ?? []).map(item => [item.key, String(item.value ?? "")]));
let html = fs.readFileSync(input, "utf8");

const replacements = [
  [values.authorization, "[REDACTED_AUTHORIZATION]"],
  [values.xApigwApiId, "[REDACTED_API_ID]"],
  [`${values.baseUrl}${values.gatewayPrefix}`, "{{baseUrl}}{{gatewayPrefix}}"],
  [values.baseUrl, "{{baseUrl}}"]
].filter(([value]) => value);

for (const [value, replacement] of replacements) {
  html = html.split(value).join(replacement);
  html = html.split(value.replaceAll("&", "&amp;")).join(replacement);
}

// htmlextra may render resolved query values even when headers and bodies are hidden.
for (const key of ["emailCode", "recipientId", "clientId", "accountNumber"]) {
  const queryValue = new RegExp(`(${key})(?:=|&#x3D;)[^&<"'\\s]+`, "gi");
  html = html.replace(queryValue, `$1&#x3D;[REDACTED]`);
}

fs.writeFileSync(output, html);
console.log(`Generated sanitized HTML report: ${output}`);
