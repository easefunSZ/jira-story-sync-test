import fs from "node:fs";

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error("Usage: node prepare-newman-runtime-environment.mjs <source-environment.json> <runtime-environment.json>");
  process.exit(2);
}

const environment = JSON.parse(fs.readFileSync(input, "utf8"));
environment.values ??= [];

function setValue(key, value) {
  const existing = environment.values.find(item => item.key === key);
  if (existing) {
    existing.value = value;
    existing.enabled = true;
    return;
  }
  environment.values.push({key, value, enabled: true});
}

setValue("enableWriteTests", "true");
fs.writeFileSync(output, `${JSON.stringify(environment, null, 2)}\n`);
console.log(`Prepared private Newman runtime environment: ${output}`);
