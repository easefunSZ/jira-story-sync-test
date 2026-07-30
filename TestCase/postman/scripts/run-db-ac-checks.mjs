import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";

const RESULT_MARKER_START = "__LEAD93_DB_RESULT__";
const RESULT_MARKER_END = "__LEAD93_DB_RESULT_END__";
const PYMYSQL_RUNNER = String.raw`import base64
import json
import sys

def emit(value):
    encoded = base64.b64encode(json.dumps(value, ensure_ascii=False, default=str).encode("utf-8")).decode("ascii")
    print("${RESULT_MARKER_START}" + encoded + "${RESULT_MARKER_END}")


try:
    import pymysql
    payload = json.load(sys.stdin)
    connection = pymysql.connect(
        host=payload["host"],
        port=int(payload["port"]),
        user=payload["user"],
        password=payload["password"],
        database=payload["database"],
        charset="utf8mb4",
        autocommit=True,
    )
    checks = []
    statement_results = []
    with connection.cursor() as cursor:
        for statement in payload["statements"]:
            cursor.execute(statement)
            if not cursor.description:
                statement_results.append({"sql": statement, "columns": [], "rows": []})
                continue
            columns = [column[0] for column in cursor.description]
            rows = [dict(zip(columns, row)) for row in cursor.fetchall()]
            statement_results.append({"sql": statement, "columns": columns, "rows": rows})
            for row in rows:
                if {"check_id", "result", "evidence"}.issubset(row):
                    checks.append({"checkId": str(row["check_id"]), "result": str(row["result"]), "evidence": str(row["evidence"])})
    connection.close()
    emit({"checks": checks, "statements": statement_results})
except Exception as error:
    emit({"error": str(error)})
`;

function parseArgs(args) {
  const options = {};
  for (let index = 0; index < args.length; index += 2) {
    const key = args[index];
    const value = args[index + 1];
    if (!key?.startsWith("--") || value === undefined) {
      throw new Error("Usage: node run-db-ac-checks.mjs --environment <runtime.json> --template <assertions.sql> --checkpoint <name> --output <result.json>");
    }
    options[key.slice(2)] = value;
  }
  return options;
}

function sqlString(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function sqlNumber(value, name) {
  if (!/^\d+$/.test(String(value ?? ""))) {
    throw new Error(`Runtime variable ${name} must be a numeric Category ID, received: ${value ?? "(empty)"}`);
  }
  return String(value);
}

function runtimeValues(file) {
  const environment = JSON.parse(fs.readFileSync(file, "utf8"));
  return Object.fromEntries((environment.values ?? []).map(item => [item.key, item.value]));
}

function loadMysqlEnvFile() {
  const postmanDir = path.resolve(import.meta.dirname, "..");
  const envFile = process.env.MYSQL_ENV_FILE ?? [
    path.join(postmanDir, "mysql-test.env"),
    path.join(postmanDir, ".env")
  ].find(fs.existsSync);
  if (!envFile) return null;
  if (!fs.existsSync(envFile)) return null;
  for (const originalLine of fs.readFileSync(envFile, "utf8").split(/\r?\n/)) {
    const line = originalLine.trim();
    if (!line || line.startsWith("#")) continue;
    const match = line.match(/^([A-Z][A-Z0-9_]*)=(.*)$/);
    if (!match || !match[1].startsWith("MYSQL_")) continue;
    const [, key, rawValue] = match;
    let value = rawValue.trim();
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) value = value.slice(1, -1);
    if (process.env[key] === undefined) process.env[key] = value;
  }
  return envFile;
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

function pythonCommands() {
  if (process.env.PYTHON_COMMAND) return [{command: process.env.PYTHON_COMMAND, args: []}];
  return [
    {command: "python", args: []},
    {command: "python3", args: []},
    {command: "py", args: ["-3"]}
  ];
}

function runPyMySql(payload) {
  let lastMissingCommand;
  for (const candidate of pythonCommands()) {
    const execution = spawnSync(candidate.command, [...candidate.args, "-c", PYMYSQL_RUNNER], {
      input: JSON.stringify(payload),
      encoding: "utf8"
    });
    if (execution.error?.code === "ENOENT") {
      lastMissingCommand = candidate.command;
      continue;
    }
    if (execution.error) throw execution.error;
    const output = `${execution.stdout ?? ""}\n${execution.stderr ?? ""}`;
    const marker = output.match(new RegExp(`${RESULT_MARKER_START}([A-Za-z0-9+/=]+)${RESULT_MARKER_END}`));
    if (!marker) {
      throw new Error(`Python database fallback failed: ${output.trim() || `python exited ${execution.status}`}`);
    }
    const result = JSON.parse(Buffer.from(marker[1], "base64").toString("utf8"));
    if (result.error) throw new Error(`Python database fallback failed: ${result.error}`);
    return result;
  }
  throw new Error(`mysql command is unavailable and no Python executable was found (last tried: ${lastMissingCommand ?? "python"}). Install a MySQL client, or install Python with PyMySQL.`);
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
  const options = parseArgs(process.argv.slice(2));
  const {environment, template, checkpoint, output} = options;
  outputPath = output;
  if (!environment || !template || !checkpoint || !output) throw new Error("Missing required option");
  if (!requiredByCheckpoint[checkpoint]) throw new Error(`Unsupported checkpoint: ${checkpoint}`);
  if (!fs.existsSync(environment)) throw new Error(`Runtime environment not found: ${environment}`);
  if (!fs.existsSync(template)) throw new Error(`SQL assertion template not found: ${template}`);

  const values = runtimeValues(environment);
  loadMysqlEnvFile();
  const missing = requiredByCheckpoint[checkpoint].filter(key => values[key] === undefined || values[key] === "");
  if (missing.length) throw new Error(`Missing Newman runtime variables for ${checkpoint}: ${missing.join(", ")}`);

  const templateSql = fs.readFileSync(template, "utf8");
  const selectedSql = checkpointSql(templateSql, checkpoint);
  if (/^\s*(?:INSERT|UPDATE|DELETE|ALTER|CREATE|DROP|TRUNCATE)\b/im.test(selectedSql)) {
    throw new Error("Database assertion template contains a write statement");
  }

  const variablesSql = [
    "SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci;",
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
  const assertionStatements = statements(selectedSql);

  const mysqlArgs = [];
  if (process.env.MYSQL_DEFAULTS_FILE) {
    mysqlArgs.push(`--defaults-extra-file=${process.env.MYSQL_DEFAULTS_FILE}`);
  } else {
    const connectionKeys = ["MYSQL_HOST", "MYSQL_PORT", "MYSQL_USER", "MYSQL_DATABASE"];
    const missingConnection = connectionKeys.filter(key => !process.env[key]);
    if (missingConnection.length) {
      throw new Error(`Configure ${missingConnection.join(", ")} in TestCase/postman/mysql-test.env, MYSQL_ENV_FILE, or process environment`);
    }
    if (!process.env.MYSQL_PWD && process.env.MYSQL_ALLOW_EMPTY_PASSWORD !== "true") {
      throw new Error("Set MYSQL_PWD, or set MYSQL_ALLOW_EMPTY_PASSWORD=true only for a passwordless test account");
    }
    mysqlArgs.push(`--host=${process.env.MYSQL_HOST}`, `--port=${process.env.MYSQL_PORT}`, `--user=${process.env.MYSQL_USER}`, `--database=${process.env.MYSQL_DATABASE}`);
  }
  mysqlArgs.push("--batch", "--raw", "--skip-column-names", "--silent", "--default-character-set=utf8mb4");

  const mysqlExecution = spawnSync("mysql", mysqlArgs, {
    input: `${variablesSql.join("\n")}\n\n${selectedSql}\n`,
    encoding: "utf8",
    env: process.env
  });
  let checks;
  let statementResults;
  if (mysqlExecution.error?.code === "ENOENT") {
    if (process.env.MYSQL_DEFAULTS_FILE) {
      throw new Error("mysql command is unavailable. Python fallback requires MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_DATABASE and MYSQL_PWD instead of MYSQL_DEFAULTS_FILE.");
    }
    const pythonResult = runPyMySql({
      host: process.env.MYSQL_HOST,
      port: process.env.MYSQL_PORT,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PWD ?? "",
      database: process.env.MYSQL_DATABASE,
      statements: [...variablesSql, ...assertionStatements]
    });
    checks = pythonResult.checks ?? [];
    statementResults = pythonResult.statements ?? [];
    console.log("mysql command not found; database assertions executed through Python PyMySQL fallback.");
  } else {
    if (mysqlExecution.error) throw mysqlExecution.error;
    if (mysqlExecution.status !== 0) throw new Error(`mysql exited ${mysqlExecution.status}: ${(mysqlExecution.stderr || "").trim()}`);
    checks = mysqlExecution.stdout.trim().split("\n").filter(Boolean).map(line => {
      const [checkId, result, ...evidence] = line.split("\t");
      return {checkId, result, evidence: evidence.join("\t")};
    });
    statementResults = [
      ...variablesSql.map(sql => ({sql, columns: [], rows: []})),
      ...assertionStatements.map((sql, index) => ({
        sql,
        columns: ["check_id", "result", "evidence"],
        rows: checks[index] ? [checks[index]] : []
      }))
    ];
  }
  if (!checks.length || checks.some(check => !check.checkId || !["PASS", "FAIL"].includes(check.result))) {
    throw new Error(`Unexpected MySQL assertion output at ${checkpoint}`);
  }
  const failed = checks.filter(check => check.result === "FAIL");
  const result = {
    generatedAt: new Date().toISOString(),
    checkpoint,
    status: failed.length ? "FAIL" : "PASS",
    checks,
    statements: statementResults
  };
  fs.writeFileSync(output, `${JSON.stringify(result, null, 2)}\n`);
  console.log(`Database checkpoint ${checkpoint}: ${result.status} (${checks.length - failed.length}/${checks.length} checks passed)`);
  process.exit(failed.length ? 1 : 0);
} catch (error) {
  if (outputPath) {
    fs.writeFileSync(outputPath, `${JSON.stringify({generatedAt: new Date().toISOString(), status: "FAIL", error: error.message, checks: []}, null, 2)}\n`);
  }
  console.error(`Database assertion failed: ${error.message}`);
  process.exit(2);
}
