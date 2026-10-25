"use strict";

const { spawn } = require("child_process");
const path = require("path");
const assert = require("assert");

async function runMcpTest() {
  console.log("Starting MCP Server automated test...");
  const serverPath = path.join(__dirname, "../bin/mcp-server.js");
  const proc = spawn("node", [serverPath], {
    stdio: ["pipe", "pipe", "pipe"]
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
    // stderr is for logging
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

  // 1. Test initialize
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

  // 2. Test tools/list
  send({
    jsonrpc: "2.0",
    id: 2,
    method: "tools/list",
    params: {}
  });
  const listRes = await waitForResponse(2);
  assert.ok(Array.isArray(listRes.result.tools));
  const toolNames = listRes.result.tools.map((t) => t.name);
  assert.ok(toolNames.includes("laporan_init"));
  assert.ok(toolNames.includes("laporan_doctor"));
  assert.ok(toolNames.includes("laporan_stats"));
  assert.ok(toolNames.includes("laporan_presets"));
  assert.ok(toolNames.includes("laporan_citations"));
  assert.ok(toolNames.includes("laporan_build"));
  assert.ok(toolNames.includes("laporan_import"));
  console.log("  ✔ [OK] tools/list returns all 7 tools:", toolNames.join(", "));

  // 3. Test tools/call: laporan_presets (list)
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

  // 4. Test tools/call: laporan_presets (get)
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

  // 5. Test tools/call: laporan_stats
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

  // 6. Test tools/call: laporan_doctor
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

  // 7. Test tools/call: laporan_citations (validate)
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

  // 8. Test resources/list
  send({
    jsonrpc: "2.0",
    id: 8,
    method: "resources/list",
    params: {}
  });
  const resList = await waitForResponse(8);
  assert.ok(Array.isArray(resList.result.resources));
  assert.ok(resList.result.resources.length >= 3);
  console.log("  ✔ [OK] resources/list returned " + resList.result.resources.length + " resources");

  // 9. Test resources/read
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

  // 10. Test prompts/list & prompts/get
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

  proc.kill();
  console.log("\nAll MCP integration tests PASSED successfully!");
}

runMcpTest().catch((err) => {
  console.error("Test failed:", err);
  process.exit(1);
});
