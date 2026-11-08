"use strict";

const { spawn } = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const assert = require("assert");
const { runProcess, httpsGet, TOOLS } = require("../lib/mcp");

async function runMcpTest() {
  console.log("Starting MCP Server automated test...");
  const serverPath = path.join(__dirname, "../bin/mcp-server.js");
  const proc = spawn("node", [serverPath], {
    stdio: ["pipe", "pipe", "pipe"]
  });
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "laporan-mcp-test-"));
  const testProject = path.join(tempRoot, "project");
  process.on("exit", () => {
    proc.kill();
    fs.rmSync(tempRoot, { recursive: true, force: true });
  });

  let buffer = "";
  const responses = [];

  proc.stdout.on("data", (chunk) => {
    buffer += chunk.toString("utf8");
    const lines = buffer.split("\n");
    buffer = lines.pop(); // keep remainder
    for (const line of lines) {
      if (line.trim()) {
        try {
          responses.push(JSON.parse(line.trim()));
        } catch (e) {
          console.error("Failed to parse line:", line);
        }
      }
    }
  });

  proc.stderr.on("data", (data) => {
    process.stderr.write("  [MCP Server Log] " + data);
  });

  function send(msg) {
    proc.stdin.write(JSON.stringify(msg) + "\n");
  }

  async function waitForResponse(id, timeoutMs = 7000) {
    const start = Date.now();
    while (Date.now() - start < timeoutMs) {
      const idx = responses.findIndex((r) => r.id === id);
      if (idx !== -1) {
        return responses.splice(idx, 1)[0];
      }
      await new Promise((r) => setTimeout(r, 50));
    }
    throw new Error("Timeout waiting for response to id: " + id);
  }

  send({
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: { name: "test-client", version: "1.0.0" }
    }
  });
  const initRes = await waitForResponse(1);
  assert.strictEqual(initRes.jsonrpc, "2.0");
  assert.ok(initRes.result.serverInfo);
  assert.strictEqual(initRes.result.serverInfo.name, "laporan-generator");
  console.log("  ✔ [OK] initialize response valid");

  send({
    jsonrpc: "2.0",
    id: 2,
    method: "tools/list",
    params: {}
  });
  const listRes = await waitForResponse(2);
  assert.ok(Array.isArray(listRes.result.tools));
  const toolNames = listRes.result.tools.map((t) => t.name);
  assert.deepStrictEqual(toolNames, TOOLS.map((tool) => tool.name));
  const initTool = listRes.result.tools.find((tool) => tool.name === "laporan_init");
  const expectedPresets = fs.readdirSync(path.join(__dirname, "../presets"))
    .filter((file) => file.endsWith(".yml"))
    .map((file) => file.slice(0, -4))
    .sort();
  assert.deepStrictEqual(initTool.inputSchema.properties.preset.enum, expectedPresets);
  assert.ok(expectedPresets.includes("jurnal-uajy"));
  assert.ok(expectedPresets.includes("jurnal-standar"));
  console.log("  ✔ [OK] tools/list returns all " + toolNames.length + " tools and current preset schema");

  send({
    jsonrpc: "2.0",
    id: 3,
    method: "tools/call",
    params: {
      name: "laporan_presets",
      arguments: { action: "list" }
    }
  });
  const presetsRes = await waitForResponse(3);
  assert.ok(presetsRes.result.content);
  const parsedPresets = JSON.parse(presetsRes.result.content[0].text);
  assert.ok(Array.isArray(parsedPresets.presets));
  assert.ok(parsedPresets.presets.length >= 6);
  console.log("  ✔ [OK] laporan_presets returned " + parsedPresets.presets.length + " presets");

  send({
    jsonrpc: "2.0",
    id: 4,
    method: "tools/call",
    params: {
      name: "laporan_presets",
      arguments: { action: "get", preset_name: "itb-ta" }
    }
  });
  const getPresetRes = await waitForResponse(4);
  assert.ok(getPresetRes.result.content[0].text.includes("itb"));
  console.log("  ✔ [OK] laporan_presets get itb-ta valid");

  send({
    jsonrpc: "2.0",
    id: 12,
    method: "tools/call",
    params: {
      name: "laporan_presets",
      arguments: { action: "get", preset_name: "../../README" }
    }
  });
  const traversalRes = await waitForResponse(12);
  assert.strictEqual(traversalRes.result.isError, true);
  assert.match(traversalRes.result.content[0].text, /Unknown preset/);
  console.log("  ✔ [OK] preset lookup rejects path traversal");

  send({
    jsonrpc: "2.0",
    id: 5,
    method: "tools/call",
    params: {
      name: "laporan_stats",
      arguments: { target_dir: path.join(__dirname, "..") }
    }
  });
  const statsRes = await waitForResponse(5);
  const statsData = JSON.parse(statsRes.result.content[0].text);
  assert.ok(statsData.total_words > 0);
  console.log("  ✔ [OK] laporan_stats returned total_words: " + statsData.total_words);

  send({
    jsonrpc: "2.0",
    id: 6,
    method: "tools/call",
    params: {
      name: "laporan_doctor",
      arguments: { target_dir: path.join(__dirname, "..") }
    }
  });
  const doctorRes = await waitForResponse(6);
  const doctorData = JSON.parse(doctorRes.result.content[0].text);
  assert.ok(doctorData.status);
  assert.ok(doctorData.dependencies);
  console.log("  ✔ [OK] laporan_doctor returned status: " + doctorData.status);

  send({
    jsonrpc: "2.0",
    id: 7,
    method: "tools/call",
    params: {
      name: "laporan_citations",
      arguments: { action: "validate", target_dir: path.join(__dirname, "..") }
    }
  });
  const citeRes = await waitForResponse(7);
  const citeData = JSON.parse(citeRes.result.content[0].text);
  assert.strictEqual(citeData.valid, true);
  assert.ok(citeData.totalEntries > 0);
  console.log("  ✔ [OK] laporan_citations validate returned " + citeData.totalEntries + " bib entries");

  send({
    jsonrpc: "2.0",
    id: 8,
    method: "resources/list",
    params: {}
  });
  const resList = await waitForResponse(8);
  assert.ok(Array.isArray(resList.result.resources));
  assert.ok(resList.result.resources.length >= 4);
  console.log("  ✔ [OK] resources/list returned " + resList.result.resources.length + " resources");

  send({
    jsonrpc: "2.0",
    id: 9,
    method: "resources/read",
    params: { uri: "laporan://presets/all" }
  });
  const resRead = await waitForResponse(9);
  assert.ok(resRead.result.contents);
  const presetsJson = JSON.parse(resRead.result.contents[0].text);
  assert.ok(presetsJson.presets.length >= 10);
  console.log("  ✔ [OK] resources/read laporan://presets/all returned " + presetsJson.presets.length + " presets");

  send({
    jsonrpc: "2.0",
    id: 19,
    method: "resources/read",
    params: { uri: "laporan://docs/preset-sources" }
  });
  const presetSourcesRes = await waitForResponse(19);
  assert.match(presetSourcesRes.result.contents[0].text, /Status pemetaan nilai preset/);
  assert.match(presetSourcesRes.result.contents[0].text, /ipb-ppki/);
  console.log("  ✔ [OK] resources/read preset sources returned scope and verification status");

  send({
    jsonrpc: "2.0",
    id: 13,
    method: "resources/read",
    params: { uri: "laporan://presets/../../README" }
  });
  const unsafeResourceRes = await waitForResponse(13);
  assert.strictEqual(unsafeResourceRes.error.code, -32602);
  console.log("  ✔ [OK] preset resources reject path traversal");

  send({
    jsonrpc: "2.0",
    id: 10,
    method: "prompts/list",
    params: {}
  });
  const promptList = await waitForResponse(10);
  assert.ok(Array.isArray(promptList.result.prompts));
  console.log("  ✔ [OK] prompts/list returned " + promptList.result.prompts.length + " prompts");

  send({
    jsonrpc: "2.0",
    id: 11,
    method: "prompts/get",
    params: { name: "academic_interview" }
  });
  const promptGet = await waitForResponse(11);
  assert.ok(promptGet.result.messages);
  console.log("  ✔ [OK] prompts/get academic_interview returned valid prompt");

  const failedProcess = await runProcess("laporan-command-that-does-not-exist", []);
  assert.ok(failedProcess.error);
  const nonzeroProcess = await runProcess(process.execPath, ["-e", "process.exit(7)"]);
  assert.strictEqual(nonzeroProcess.status, 7);
  const timedOutProcess = await runProcess(process.execPath, ["-e", "setTimeout(() => {}, 5000)"], { timeoutMs: 100 });
  assert.strictEqual(timedOutProcess.timedOut, true);
  assert.strictEqual(timedOutProcess.status, 124);
  await assert.rejects(httpsGet("http://127.0.0.1"), /Only HTTPS requests are allowed/);
  console.log("  ✔ [OK] subprocess missing-command, exit-code, and timeout cases");

  send({
    jsonrpc: "2.0",
    id: 14,
    method: "tools/call",
    params: {
      name: "laporan_init",
      arguments: { target_dir: testProject, preset: "standard" }
    }
  });
  const initProjectRes = await waitForResponse(14);
  assert.strictEqual(JSON.parse(initProjectRes.result.content[0].text).success, true);

  send({
    jsonrpc: "2.0",
    id: 15,
    method: "tools/call",
    params: {
      name: "laporan_build",
      arguments: { target_dir: testProject, format: "all" }
    }
  });
  const buildRes = await waitForResponse(15, 180000);
  const buildData = JSON.parse(buildRes.result.content[0].text);
  assert.strictEqual(buildData.status, "SUCCESS");
  assert.strictEqual(buildData.pdfGenerated, true);
  assert.strictEqual(buildData.docxGenerated, true);

  send({
    jsonrpc: "2.0",
    id: 16,
    method: "tools/call",
    params: {
      name: "laporan_import",
      arguments: {
        source_file: path.join(testProject, "Laporan.docx"),
        target_dir: testProject,
        target_file: "chapters/imported.md"
      }
    }
  });
  const importRes = await waitForResponse(16);
  assert.strictEqual(importRes.result.isError, undefined, JSON.stringify(importRes.result));
  assert.ok(fs.existsSync(path.join(testProject, "chapters/imported.md")));

  const outsideImport = path.join(tempRoot, "outside.md");
  const symlinkImport = path.join(testProject, "chapters/outside.md");
  try {
    fs.symlinkSync(outsideImport, symlinkImport);
    send({
      jsonrpc: "2.0",
      id: 18,
      method: "tools/call",
      params: {
        name: "laporan_import",
        arguments: {
          source_file: path.join(testProject, "Laporan.docx"),
          target_dir: testProject,
          target_file: "chapters/outside.md"
        }
      }
    });
    const symlinkRes = await waitForResponse(18);
    assert.strictEqual(symlinkRes.result.isError, true);
    assert.match(symlinkRes.result.content[0].text, /symbolic links/);
    assert.strictEqual(fs.existsSync(outsideImport), false);
    console.log("  ✔ [OK] import destination rejects symlink escape");
  } catch (error) {
    if (error.code !== "EPERM" && error.code !== "EACCES" && error.code !== "ENOSYS") throw error;
    console.log("  - [SKIP] symlink protection test unsupported on this platform");
  } finally {
    try { fs.unlinkSync(symlinkImport); } catch (_) {}
  }

  send({
    jsonrpc: "2.0",
    id: 17,
    method: "tools/call",
    params: {
      name: "laporan_audit",
      arguments: { target_dir: testProject }
    }
  });
  const auditRes = await waitForResponse(17);
  assert.ok(JSON.parse(auditRes.result.content[0].text).summary);

  send({
    jsonrpc: "2.0",
    id: 18,
    method: "tools/call",
    params: {
      name: "laporan_verify_citations",
      arguments: { bib_file: path.join(testProject, "references.bib"), offline: true }
    }
  });
  const verifyRes = await waitForResponse(18);
  assert.ok(JSON.parse(verifyRes.result.content[0].text).total_entries >= 0);
  console.log("  ✔ [OK] MCP init, PDF/DOCX build, import, audit, and offline citation verification");

  proc.kill();
  console.log("\nAll MCP integration tests PASSED successfully!");
}

runMcpTest().catch((err) => {
  console.error("Test failed:", err);
  process.exit(1);
});
