import fs from "node:fs";
import path from "node:path";

const RESULT_MARKER_START = "__LEAD93_REMOTE_DB_RESULT__";
const RESULT_MARKER_END = "__LEAD93_REMOTE_DB_RESULT_END__";
const REMOTE_PYTHON = String.raw`import base64
import json
import sys
from pathlib import Path
from urllib.parse import urlparse

import pymysql


def load_properties(path):
    values = {}
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        if line.startswith("spring.datasource.") and "=" in line:
            key, value = line.split("=", 1)
            values[key] = value
    return values


def emit(result):
    payload = base64.b64encode(json.dumps(result, ensure_ascii=False, default=str).encode("utf-8")).decode("ascii")
    print("${RESULT_MARKER_START}" + payload + "${RESULT_MARKER_END}")


try:
    payload_path, properties_path = sys.argv[1:3]
    payload = json.loads(Path(payload_path).read_text(encoding="utf-8"))
    properties = load_properties(properties_path)
    jdbc_url = properties["spring.datasource.url"].removeprefix("jdbc:")
    parsed = urlparse(jdbc_url)
    connection = pymysql.connect(
        host=parsed.hostname,
        port=parsed.port or 3306,
        user=properties["spring.datasource.username"],
        password=properties["spring.datasource.password"],
        database=parsed.path.lstrip("/"),
        charset="utf8mb4",
        autocommit=True,
    )
    checks = []
    statement_results = []
    with connection.cursor() as cursor:
        # The test schema uses utf8mb4_0900_ai_ci. Align string literals and
        # session variables before comparing them with table columns.
        cursor.execute("SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci")
        for statement in payload["statements"]:
            cursor.execute(statement)
            if not cursor.description:
                statement_results.append({"sql": statement, "columns": [], "rows": []})
                continue
            columns = [column[0] for column in cursor.description]
            rows = cursor.fetchall()
            statement_results.append({
                "sql": statement,
                "columns": columns,
                "rows": [dict(zip(columns, row)) for row in rows]
            })
            for row in rows:
                if len(row) < 3:
                    raise RuntimeError("Unexpected database assertion row")
                checks.append({"checkId": str(row[0]), "result": str(row[1]), "evidence": str(row[2])})
    connection.close()
    if not checks or any(check["result"] not in ("PASS", "FAIL") for check in checks):
        raise RuntimeError("Unexpected database assertion output")
    failed = [check for check in checks if check["result"] == "FAIL"]
    emit({"generatedAt": payload["generatedAt"], "checkpoint": payload["checkpoint"], "status": "FAIL" if failed else "PASS", "checks": checks, "statements": statement_results})
except Exception as error:
    emit({"generatedAt": None, "status": "FAIL", "error": str(error), "checks": []})
`;

function parseArgs(args) {
  const options = {};
  for (let index = 0; index < args.length; index += 2) {
    const key = args[index];
    const value = args[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error("Usage: node run-db-ac-checks-via-remote-terminal.mjs --environment <runtime.json> --template <assertions.sql> --checkpoint <name> --output <result.json>");
    }
    options[key.slice(2)] = value;
  }
  return options;
}

function sqlString(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function sqlNumber(value, name) {
  if (!/^\d+$/.test(String(value ?? ""))) throw new Error(`Runtime variable ${name} must be a numeric Category ID, received: ${value ?? "(empty)"}`);
  return String(value);
}

function runtimeValues(file) {
  const environment = JSON.parse(fs.readFileSync(file, "utf8"));
  return Object.fromEntries((environment.values ?? []).map(item => [item.key, item.value]));
}

function checkpointSql(template, checkpoint) {
  const markers = [...template.matchAll(/^-- CHECKPOINT:\s*([a-z_]+)\s*$/gm)];
  const current = markers.find(marker => marker[1] === checkpoint);
  if (!current) throw new Error(`Unknown database checkpoint: ${checkpoint}`);
  const start = current.index + current[0].length;
  const next = markers.find(marker => marker.index > current.index);
  return template.slice(start, next?.index).trim();
}

function statements(sql) {
  return sql.split(/;\s*(?:\r?\n|$)/).map(value => value.trim()).filter(Boolean);
}

function shellQuote(value) {
  return `'${String(value).replaceAll("'", "'\\''")}'`;
}

function stripTerminalControl(value) {
  return value.replace(/\u001B\][^\u0007]*(?:\u0007|\u001B\\)/g, "").replace(/\u001B\[[0-?]*[ -/]*[@-~]/g, "");
}

async function executeRemote(command, timeoutMs) {
  const endpoint = process.env.REMOTE_BASH_WS ?? "ws://127.0.0.1:7681/ws";
  return await new Promise((resolve, reject) => {
    const socket = new WebSocket(endpoint);
    let transcript = "";
    const timeout = setTimeout(() => {
      socket.close();
      reject(new Error(`Remote Bash timed out after ${timeoutMs}ms`));
    }, timeoutMs);
    socket.onopen = () => socket.send(`${command}\n`);
    socket.onmessage = event => {
      transcript += event.data;
      const normalized = stripTerminalControl(transcript).replace(/[\r\n]/g, "");
      const match = normalized.match(new RegExp(`${RESULT_MARKER_START}([A-Za-z0-9+/=]+)${RESULT_MARKER_END}`));
      if (!match) return;
      clearTimeout(timeout);
      socket.close();
      try {
        resolve(JSON.parse(Buffer.from(match[1], "base64").toString("utf8")));
      } catch (error) {
        reject(new Error(`Remote Bash returned an unreadable database result: ${error.message}`));
      }
    };
    socket.onerror = () => {
      clearTimeout(timeout);
      reject(new Error(`Cannot connect to remote Bash at ${endpoint}`));
    };
  });
}

const requiredByCheckpoint = {
  template_metadata: ["acActiveEmailCode", "acDraftEmailCode", "acSourceCategoryId", "acTargetCategoryId", "acInvalidPublishName", "acInvalidBatchName"],
  copy: ["acActiveEmailCode", "acCopyEmailCode"],
  lifecycle: ["acActiveEmailCode", "acV2Version"],
  reassignment: ["acActiveEmailCode", "acDraftEmailCode", "acSourceCategoryId", "acTargetCategoryId", "acTargetSubcategoryId1", "acTargetSubcategoryId2", "acRecreatedCategoryId"],
  cleanup: ["acActiveEmailCode", "acDraftEmailCode", "acCopyEmailCode", "acTargetCategoryId", "acRecreatedCategoryId"]
};

let outputPath;
try {
  const {environment, template, checkpoint, output} = parseArgs(process.argv.slice(2));
  outputPath = output;
  if (!environment || !template || !checkpoint || !output) throw new Error("Missing required option");
  if (!requiredByCheckpoint[checkpoint]) throw new Error(`Unsupported checkpoint: ${checkpoint}`);
  if (!fs.existsSync(environment)) throw new Error(`Runtime environment not found: ${environment}`);
  if (!fs.existsSync(template)) throw new Error(`SQL assertion template not found: ${template}`);
  const remoteProperties = process.env.REMOTE_DB_PROPERTIES_PATH;
  if (!remoteProperties) throw new Error("Set REMOTE_DB_PROPERTIES_PATH to the remote application-*.properties file used by the running service");

  const values = runtimeValues(environment);
  const missing = requiredByCheckpoint[checkpoint].filter(key => values[key] === undefined || values[key] === "");
  if (missing.length) throw new Error(`Missing Newman runtime variables for ${checkpoint}: ${missing.join(", ")}`);
  const selectedSql = checkpointSql(fs.readFileSync(template, "utf8"), checkpoint);
  if (/^\s*(?:INSERT|UPDATE|DELETE|ALTER|CREATE|DROP|TRUNCATE)\b/im.test(selectedSql)) throw new Error("Database assertion template contains a write statement");

  const variableSql = [
    `SET @active_email_code = ${sqlString(values.acActiveEmailCode ?? "")};`,
    `SET @draft_email_code = ${sqlString(values.acDraftEmailCode ?? "")};`,
    `SET @copy_email_code = ${sqlString(values.acCopyEmailCode ?? "")};`,
    `SET @source_category_id = ${sqlNumber(values.acSourceCategoryId ?? "0", "acSourceCategoryId")};`,
    `SET @target_category_id = ${sqlNumber(values.acTargetCategoryId ?? "0", "acTargetCategoryId")};`,
    `SET @target_subcategory_id_1 = ${sqlNumber(values.acTargetSubcategoryId1 ?? "0", "acTargetSubcategoryId1")};`,
    `SET @target_subcategory_id_2 = ${sqlNumber(values.acTargetSubcategoryId2 ?? "0", "acTargetSubcategoryId2")};`,
    `SET @recreated_category_id = ${sqlNumber(values.acRecreatedCategoryId ?? "0", "acRecreatedCategoryId")};`,
    `SET @v2_version = ${sqlString(values.acV2Version ?? "")};`,
    `SET @invalid_publish_name = ${sqlString(values.acInvalidPublishName ?? "")};`,
    `SET @invalid_batch_name = ${sqlString(values.acInvalidBatchName ?? "")};`
  ];
  const payload = {generatedAt: new Date().toISOString(), checkpoint, statements: [...variableSql, ...statements(selectedSql)]};
  const nonce = `${Date.now()}-${process.pid}`;
  const scriptPath = `/tmp/lead93-remote-db-${nonce}.py`;
  const payloadPath = `/tmp/lead93-remote-db-${nonce}.json`;
  const command = [
    `printf %s ${shellQuote(Buffer.from(REMOTE_PYTHON, "utf8").toString("base64"))} | base64 -d > ${shellQuote(scriptPath)}`,
    `printf %s ${shellQuote(Buffer.from(JSON.stringify(payload), "utf8").toString("base64"))} | base64 -d > ${shellQuote(payloadPath)}`,
    `python ${shellQuote(scriptPath)} ${shellQuote(payloadPath)} ${shellQuote(remoteProperties)}`,
    `rm -f ${shellQuote(scriptPath)} ${shellQuote(payloadPath)}`
  ].join("\n");
  const result = await executeRemote(command, Number(process.env.REMOTE_DB_TIMEOUT_MS ?? 30000));
  fs.mkdirSync(path.dirname(output), {recursive: true});
  fs.writeFileSync(output, `${JSON.stringify(result, null, 2)}\n`);
  console.log(`Remote database checkpoint ${checkpoint}: ${result.status}`);
  process.exit(result.status === "PASS" ? 0 : 1);
} catch (error) {
  if (outputPath) {
    fs.mkdirSync(path.dirname(outputPath), {recursive: true});
    fs.writeFileSync(outputPath, `${JSON.stringify({generatedAt: new Date().toISOString(), status: "FAIL", error: error.message, checks: []}, null, 2)}\n`);
  }
  console.error(`Remote database assertion failed: ${error.message}`);
  process.exit(2);
}
