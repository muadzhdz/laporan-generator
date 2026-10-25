"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const { removeRecursiveSync, parseJsonc } = require("./uninstall");

function copyRecursiveSync(src, dest) {
  if (!fs.existsSync(src)) return;
  const stats = fs.statSync(src);
  if (stats.isDirectory()) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach((childItemName) => {
      copyRecursiveSync(path.join(src, childItemName), path.join(dest, childItemName));
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

function syncInternalResources(packageRoot) {
  const skillRoot = path.join(packageRoot, ".agents/skills/laporan-generator");
  const resDir = path.join(skillRoot, "resources");
  const skillScriptsDir = path.join(skillRoot, "scripts");
  const skillRefsDir = path.join(skillRoot, "references");
  const resScriptsDir = path.join(resDir, "scripts");
  const resPresetsDir = path.join(resDir, "presets");
  const resChaptersDir = path.join(resDir, "chapters");

  fs.mkdirSync(resDir, { recursive: true });
  fs.mkdirSync(skillScriptsDir, { recursive: true });
  fs.mkdirSync(skillRefsDir, { recursive: true });
  fs.mkdirSync(resScriptsDir, { recursive: true });
  fs.mkdirSync(resPresetsDir, { recursive: true });
  fs.mkdirSync(resChaptersDir, { recursive: true });

  // 1. Sync scripts from root scripts/
  const srcScripts = path.join(packageRoot, "scripts");
  if (fs.existsSync(srcScripts)) {
    for (const f of fs.readdirSync(srcScripts)) {
      if (f.startsWith("__pycache__") || f.endsWith(".pyc")) continue;
      const srcFile = path.join(srcScripts, f);
      copyRecursiveSync(srcFile, path.join(skillScriptsDir, f));
      copyRecursiveSync(srcFile, path.join(resScriptsDir, f));
    }
  }

  // Also sync CLI and build scripts to skillScriptsDir
  for (const s of ["build.sh", "build-docx.sh", "laporan", "laporan.ps1"]) {
    const srcS = path.join(packageRoot, s);
    if (fs.existsSync(srcS)) {
      fs.copyFileSync(srcS, path.join(skillScriptsDir, s));
    }
  }

  // 2. Sync docs/ to .agents/skills/laporan-generator/references/
  const srcDocs = path.join(packageRoot, "docs");
  if (fs.existsSync(srcDocs)) {
    copyRecursiveSync(srcDocs, skillRefsDir);
  }

  // 3. Sync presets from root presets/
  const srcPresets = path.join(packageRoot, "presets");
  if (fs.existsSync(srcPresets)) {
    copyRecursiveSync(srcPresets, resPresetsDir);
  }

  // 4. Sync chapters from templates/default/chapters or root chapters/
  const srcChapters = fs.existsSync(path.join(packageRoot, "templates/default/chapters"))
    ? path.join(packageRoot, "templates/default/chapters")
    : path.join(packageRoot, "chapters");
  if (fs.existsSync(srcChapters)) {
    copyRecursiveSync(srcChapters, resChaptersDir);
  }

  // 5. Sync template files
  const templateFiles = [
    "template.typ",
    "reference.docx",
    "docx.lua",
    "references.bib",
    "apa.csl",
    "metadata.yml",
    "cover.md",
    "logo.jpg"
  ];

  const tplDir = path.join(packageRoot, "templates/default");
  for (const tf of templateFiles) {
    const src = fs.existsSync(path.join(tplDir, tf))
      ? path.join(tplDir, tf)
      : path.join(packageRoot, tf);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, path.join(resDir, tf));
    }
  }

  // Also sync toolchain files
  for (const s of ["Makefile", "build.sh", "build-docx.sh", "laporan", "laporan.ps1"]) {
    const srcS = path.join(packageRoot, s);
    if (fs.existsSync(srcS)) {
      fs.copyFileSync(srcS, path.join(resDir, s));
    }
  }
}

function registerMcpServers(packageRoot, home) {
  const mcpBin = path.join(packageRoot, "bin/mcp-server.js");

  // 1. Antigravity MCP (~/.gemini/config/mcp_config.json)
  const agyMcpPath = path.join(home, ".gemini/config/mcp_config.json");
  try {
    let agyConfig = { mcpServers: {} };
    if (fs.existsSync(agyMcpPath)) {
      try {
        agyConfig = JSON.parse(fs.readFileSync(agyMcpPath, "utf8"));
      } catch (_) {
        agyConfig = { mcpServers: {} };
      }
    }
    if (!agyConfig.mcpServers) agyConfig.mcpServers = {};
    agyConfig.mcpServers["laporan"] = {
      command: "node",
      args: [mcpBin],
      disabled: false
    };
    fs.mkdirSync(path.dirname(agyMcpPath), { recursive: true });
    fs.writeFileSync(agyMcpPath, JSON.stringify(agyConfig, null, 2), "utf8");
    console.log("  ✔ [ANTIGRAVITY MCP] Registered server \"laporan\" -> ~/.gemini/config/mcp_config.json");
  } catch (err) {
    console.log("  ✖ [ANTIGRAVITY MCP SKIP] " + err.message);
  }

  // 2. Claude Desktop & Claude Code (~/.config/Claude/claude_desktop_config.json, ~/.claude.json)
  const claudePaths = [
    path.join(home, ".config/Claude/claude_desktop_config.json"),
    path.join(home, ".claude.json")
  ];
  for (const cPath of claudePaths) {
    try {
      let conf = { mcpServers: {} };
      if (fs.existsSync(cPath)) {
        try {
          conf = JSON.parse(fs.readFileSync(cPath, "utf8"));
        } catch (_) {}
      }
      if (!conf.mcpServers) conf.mcpServers = {};
      conf.mcpServers["laporan"] = {
        command: "node",
        args: [mcpBin]
      };
      fs.mkdirSync(path.dirname(cPath), { recursive: true });
      fs.writeFileSync(cPath, JSON.stringify(conf, null, 2), "utf8");
      console.log("  ✔ [CLAUDE MCP] Registered server \"laporan\" -> " + cPath);
    } catch (_) {}
  }

  // 3. OpenCode (~/.config/opencode/opencode.jsonc)
  const opencodeConfigPath = path.join(home, ".config/opencode/opencode.jsonc");
  if (fs.existsSync(opencodeConfigPath)) {
    try {
      const raw = fs.readFileSync(opencodeConfigPath, "utf8");
      const opencodeConfig = parseJsonc(raw);
      if (!opencodeConfig.mcpServers) opencodeConfig.mcpServers = {};
      opencodeConfig.mcpServers["laporan"] = {
        command: "node",
        args: [mcpBin]
      };
      fs.writeFileSync(opencodeConfigPath, JSON.stringify(opencodeConfig, null, 2), "utf8");
      console.log("  ✔ [OPENCODE MCP] Registered MCP server \"laporan\" -> ~/.config/opencode/opencode.jsonc");
    } catch (_) {}
  }
}

function run(argv = []) {
  const home = os.homedir();
  const packageRoot = path.join(__dirname, "..");
  const skillGeneratorSource = path.join(packageRoot, ".agents/skills/laporan-generator");
  const workflowSource = path.join(packageRoot, ".agents/workflows/laporan-generator.md");

  console.log("\n==========================================================");
  console.log("   LAPORAN GENERATOR - AI AGENT SKILLS & MCP SYNC         ");
  console.log("==========================================================\n");

  // Step 0: Sinkronisasi berkas internal sebelum distribusi
  syncInternalResources(packageRoot);
  console.log("  ✔ [INTERNAL SYNC] Root scripts & templates synced to .agents/skills/laporan-generator");

  // Bersihkan alias lama/duplikat laporan agar tidak dobel dengan laporan-generator
  const legacyDuplicates = [
    path.join(home, ".agents/skills/laporan"),
    path.join(home, ".gemini/config/skills/laporan"),
    path.join(home, ".claude/skills/laporan"),
    path.join(home, ".grok/skills/laporan"),
    path.join(home, ".config/opencode/skills/laporan"),
    path.join(process.cwd(), ".agents/skills/laporan"),
    path.join(home, ".kiro/agents/laporan.json"),
    path.join(home, ".agents/workflows/laporan.md"),
    path.join(process.cwd(), ".agents/workflows/laporan.md"),
    path.join(home, ".claude/commands/laporan.md")
  ];
  for (const legacy of legacyDuplicates) {
    if (fs.existsSync(legacy)) {
      removeRecursiveSync(legacy);
    }
  }

  const targets = [
    {
      name: "Global Agents (~/.agents/skills/)",
      skillsDir: path.join(home, ".agents/skills")
    },
    {
      name: "Antigravity CLI (~/.gemini/config/skills/)",
      skillsDir: path.join(home, ".gemini/config/skills")
    },
    {
      name: "Claude Code (~/.claude/skills/)",
      skillsDir: path.join(home, ".claude/skills")
    },
    {
      name: "Grok CLI (~/.grok/skills/)",
      skillsDir: path.join(home, ".grok/skills")
    },
    {
      name: "OpenCode (~/.config/opencode/skills/)",
      skillsDir: path.join(home, ".config/opencode/skills")
    },
    {
      name: "Local Project Workspace (.agents/skills/)",
      skillsDir: path.join(process.cwd(), ".agents/skills")
    }
  ];

  let installedCount = 0;

  for (const target of targets) {
    try {
      const destGen = path.join(target.skillsDir, "laporan-generator");
      copyRecursiveSync(skillGeneratorSource, destGen);
      console.log(`  ✔ [INSTALLED] ${target.name} (with full templates & resources)`);
      installedCount++;
    } catch (err) {
      console.log(`  ✖ [SKIP] ${target.name}: ${err.message}`);
    }
  }

  // Daftarkan Slash Command ke OpenCode (~/.config/opencode/opencode.jsonc)
  const opencodeConfigPath = path.join(home, ".config/opencode/opencode.jsonc");
  try {
    let opencodeConfig = {};
    if (fs.existsSync(opencodeConfigPath)) {
      const raw = fs.readFileSync(opencodeConfigPath, "utf8");
      try {
        opencodeConfig = parseJsonc(raw);
      } catch (_) {
        opencodeConfig = {};
      }
    }
    opencodeConfig["$schema"] = "https://opencode.ai/config.json";
    if (!opencodeConfig.command) {
      opencodeConfig.command = {};
    }
    delete opencodeConfig.command["laporan"];

    opencodeConfig.command["laporan-generator"] = {
      description: "Universal Academic Report & Thesis Generator",
      template: "Gunakan skill laporan-generator untuk membuat atau mengompilasi dokumen laporan/skripsi akademik: $ARGUMENTS"
    };

    if (!opencodeConfig.skills) {
      opencodeConfig.skills = {};
    }
    const skillPaths = new Set(opencodeConfig.skills.paths || []);
    skillPaths.add(path.join(home, ".agents/skills"));
    skillPaths.add(path.join(home, ".config/opencode/skills"));
    opencodeConfig.skills.paths = Array.from(skillPaths);

    const opencodeDir = path.dirname(opencodeConfigPath);
    if (!fs.existsSync(opencodeDir)) {
      fs.mkdirSync(opencodeDir, { recursive: true });
    }
    fs.writeFileSync(opencodeConfigPath, JSON.stringify(opencodeConfig, null, 2), "utf8");
    console.log("  ✔ [OPENCODE] Registered /laporan-generator command -> ~/.config/opencode/opencode.jsonc");
  } catch (err) {
    console.log("  ✖ [OPENCODE SKIP] " + err.message);
  }

  // Daftarkan Custom Agent ke Kiro CLI (~/.kiro/agents/laporan-generator.json)
  const kiroAgentsDir = path.join(home, ".kiro/agents");
  try {
    if (!fs.existsSync(kiroAgentsDir)) {
      fs.mkdirSync(kiroAgentsDir, { recursive: true });
    }
    const kiroPrompt = [
      "You are an expert academic writing assistant powered by Laporan Generator and Native MCP Tools.",
      "",
      "CRITICAL INSTRUCTION: DO NOT write raw Typst code from scratch or create standalone .typ files (such as laporan.typ). DO NOT import @preview/ieee or external packages.",
      "",
      "Always follow the Modular Markdown Architecture:",
      "1. Scaffolding: Use MCP tool laporan_init or run npx laporan-generator init.",
      "2. Metadata: Edit metadata.yml to set title, author, institution, faculty, department, year, and campus preset (standard, skripsi-4433, itb-ta, ui-skripsi, ugm-skripsi, its-skripsi, unpad-skripsi).",
      "3. Content: Write chapters in pure standard Markdown inside chapters/ (bab1-pendahuluan.md, bab2-tinjauan-pustaka.md, bab3-metodologi.md, bab4-hasil-dan-pembahasan.md, bab5-penutup.md).",
      "4. Citations: Use MCP tool laporan_citations to search DOIs on Crossref, add BibTeX entries to references.bib, and cite in Markdown using [@citekey].",
      "5. Audit: Use MCP tool laporan_doctor to audit document health.",
      "6. Compilation: Use MCP tool laporan_build or run ./laporan build to compile both PDF and Word DOCX simultaneously."
    ].join("\n");

    const kiroConfig = {
      name: "laporan-generator",
      description: "Universal Academic Report & Thesis Generator with Native MCP Tools",
      prompt: kiroPrompt,
      tools: ["read", "write", "shell", "grep", "glob"],
      allowedTools: ["read", "write", "shell", "grep", "glob"]
    };
    fs.writeFileSync(
      path.join(kiroAgentsDir, "laporan-generator.json"),
      JSON.stringify(kiroConfig, null, 2),
      "utf8"
    );
    console.log("  ✔ [KIRO AGENT] Registered agent: \"laporan-generator\" -> ~/.kiro/agents/");
  } catch (err) {
    console.log("  ✖ [KIRO SKIP] " + err.message);
  }

  // Daftarkan Slash Commands / Workflows
  const workflowDestinations = [
    path.join(home, ".agents/workflows"),
    path.join(process.cwd(), ".agents/workflows"),
    path.join(home, ".claude/commands")
  ];

  for (const wDir of workflowDestinations) {
    try {
      if (!fs.existsSync(wDir)) {
        fs.mkdirSync(wDir, { recursive: true });
      }
      fs.copyFileSync(workflowSource, path.join(wDir, "laporan-generator.md"));
      console.log(`  ✔ [SLASH COMMAND] /laporan-generator -> ${wDir}`);
    } catch (_) {}
  }

  // Registrasi Native MCP Server
  registerMcpServers(packageRoot, home);

  console.log("\n==========================================================");
  console.log("✨ Sukses! Skill dan MCP server /laporan-generator berhasil disinkronkan.");
  console.log("Seluruh AI Agent (Antigravity, Claude, OpenCode, Kiro) kini siap digunakan!");
  console.log("==========================================================\n");
}

module.exports = { run, syncInternalResources };
