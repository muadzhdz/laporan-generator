"use strict";

const fs = require("fs");
const path = require("path");
const readline = require("readline");
const https = require("https");
const { spawnSync } = require("child_process");
const { initProject } = require("./init");

const VERSION = "2.8.0";
const PACKAGE_ROOT = path.join(__dirname, "..");

function getPythonCommand() {
  if (process.platform === "win32") {
    const testPy = spawnSync("python", ["--version"], { stdio: "ignore" });
    if (testPy.status === 0) return "python";
    const testPy3 = spawnSync("python3", ["--version"], { stdio: "ignore" });
    if (testPy3.status === 0) return "python3";
    return "python";
  }
  const testPy3 = spawnSync("python3", ["--version"], { stdio: "ignore" });
  if (testPy3.status === 0) return "python3";
  return "python";
}

function httpsGet(url, options = {}, maxRedirects = 5) {
  return new Promise((resolve, reject) => {
    if (maxRedirects < 0) return reject(new Error("Too many HTTP redirects"));
    const u = new URL(url);
    const reqOpts = {
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: Object.assign({
        "User-Agent": "LaporanGenerator/" + VERSION + " (academic-document-engine; mailto:support@example.com)"
      }, options.headers || {})
    };

    https.get(reqOpts, (res) => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location) {
        return resolve(httpsGet(res.headers.location, options, maxRedirects - 1));
      }
      let body = "";
      res.on("data", (chunk) => { body += chunk; });
      res.on("end", () => {
        resolve({ statusCode: res.statusCode, headers: res.headers, body });
      });
    }).on("error", reject);
  });
}

const TOOLS = [
  {
    name: "laporan_init",
    description: "Initialize a new academic report, thesis (skripsi/TA), internship report (PKL), or scientific paper workspace with university presets (UI, ITB, UGM, ITS, Unpad, standard, skripsi-4433).",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Target directory where the project will be initialized. Defaults to current directory."
        },
        preset: {
          type: "string",
          enum: ["standard", "skripsi-4433", "itb-ta", "ui-skripsi", "ugm-skripsi", "its-skripsi", "unpad-skripsi"],
          description: "Campus preset defining margins (e.g. 4-4-3-3), fonts, line-spacing, and heading rules."
        },
        title: {
          type: "string",
          description: "Document title (will be formatted as inverted pyramid on cover)."
        },
        author_name: {
          type: "string",
          description: "Full name of the author/student."
        },
        author_id: {
          type: "string",
          description: "Student ID or NIM."
        },
        institution: {
          type: "string",
          description: "University or institution name."
        },
        faculty: {
          type: "string",
          description: "Faculty name."
        },
        department: {
          type: "string",
          description: "Study program or department."
        },
        year: {
          type: "string",
          description: "Academic year (e.g. 2026)."
        },
        daftar_gambar: {
          type: "boolean",
          description: "Whether to include Daftar Gambar (List of Figures). Default is false."
        },
        daftar_tabel: {
          type: "boolean",
          description: "Whether to include Daftar Tabel (List of Tables). Default is false."
        },
        force: {
          type: "boolean",
          description: "Whether to overwrite existing files if already present."
        }
      }
    }
  },
  {
    name: "laporan_doctor",
    description: "Audit document health and integrity: verify system dependencies (Pandoc, Typst, Python), missing citation keys in references.bib, broken local figure paths, manual heading violations, and math notation.",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Target directory containing the document. Defaults to current directory."
        }
      }
    }
  },
  {
    name: "laporan_stats",
    description: "Compute comprehensive document metrics: word count, character count, estimated page count (A4 1.5 spacing), reading duration, chapter breakdown, headings, equations, and citation counts.",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Target directory containing the document. Defaults to current directory."
        }
      }
    }
  },
  {
    name: "laporan_presets",
    description: "List all supported university presets or get detailed layout specifications (margins in cm, fonts, line spacing, heading formats) for a specific university preset.",
    inputSchema: {
      type: "object",
      properties: {
        action: {
          type: "string",
          enum: ["list", "get"],
          default: "list",
          description: "Action to perform: list all presets, or get details of a specific preset."
        },
        preset_name: {
          type: "string",
          description: "Preset name (e.g. standard, skripsi-4433, ui-skripsi, itb-ta, ugm-skripsi, its-skripsi, unpad-skripsi) when action is get."
        }
      }
    }
  },
  {
    name: "laporan_citations",
    description: "Search academic citations via Crossref API or validate and inspect citations in references.bib. Can fetch official BibTeX entries by DOI or title and append them to references.bib without manual scraping.",
    inputSchema: {
      type: "object",
      properties: {
        action: {
          type: "string",
          enum: ["search_doi", "get_bibtex", "add_citation", "validate"],
          description: "Action: search_doi (query Crossref for papers), get_bibtex (fetch official BibTeX by DOI), add_citation (append BibTeX to references.bib), or validate (check integrity)."
        },
        query: {
          type: "string",
          description: "Search query (title, author, keyword) for searching Crossref."
        },
        doi: {
          type: "string",
          description: "DOI string (e.g. 10.1145/3377811.3380327 or https://doi.org/...) to fetch BibTeX."
        },
        bibtex: {
          type: "string",
          description: "Raw BibTeX entry to append when action is add_citation."
        },
        target_dir: {
          type: "string",
          description: "Target directory of the project. Defaults to current directory."
        }
      },
      required: ["action"]
    }
  },
  {
    name: "laporan_build",
    description: "Compile the academic document into publication-grade PDF (via Typst) and standard Microsoft Word DOCX with Roman/Arabic dual page numbering.",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Document directory. Defaults to current directory."
        },
        format: {
          type: "string",
          enum: ["all", "pdf", "docx"],
          default: "all",
          description: "Target format to build: all (both PDF and DOCX), pdf, or docx."
        }
      }
    }
  }
];

async function handleToolCall(name, args = {}) {
  const targetDir = args.target_dir ? path.resolve(args.target_dir) : process.cwd();

  switch (name) {
    case "laporan_init": {
      const res = initProject({
        targetDir,
        preset: args.preset,
        title: args.title,
        authorName: args.author_name,
        authorId: args.author_id,
        institution: args.institution,
        faculty: args.faculty,
        department: args.department,
        year: args.year,
        daftar_gambar: args.daftar_gambar,
        daftar_tabel: args.daftar_tabel,
        force: args.force,
        silent: true
      });
      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(res, null, 2)
          }
        ]
      };
    }

    case "laporan_doctor": {
      const script = path.join(PACKAGE_ROOT, "scripts/report-doctor.py");
      const py = getPythonCommand();
      const proc = spawnSync(py, [script, targetDir, "--json"], { encoding: "utf8" });
      let output = proc.stdout ? proc.stdout.trim() : "";
      try {
        const parsed = JSON.parse(output);
        return {
          content: [{ type: "text", text: JSON.stringify(parsed, null, 2) }]
        };
      } catch (_) {
        return {
          content: [{ type: "text", text: output || proc.stderr || "Doctor check executed" }]
        };
      }
    }

    case "laporan_stats": {
      const script = path.join(PACKAGE_ROOT, "scripts/report-stats.py");
      const py = getPythonCommand();
      const proc = spawnSync(py, [script, targetDir, "--json"], { encoding: "utf8" });
      let output = proc.stdout ? proc.stdout.trim() : "";
      try {
        const parsed = JSON.parse(output);
        return {
          content: [{ type: "text", text: JSON.stringify(parsed, null, 2) }]
        };
      } catch (_) {
        return {
          content: [{ type: "text", text: output || proc.stderr || "Stats check executed" }]
        };
      }
    }

    case "laporan_presets": {
      const presetsDir = path.join(PACKAGE_ROOT, "presets");
      const action = args.action || "list";

      if (action === "get") {
        const presetName = (args.preset_name || "").replace(/\.ya?ml$/, "");
        if (!presetName) {
          throw new Error("Missing preset_name argument for action get");
        }
        const filePath = path.join(presetsDir, presetName + ".yml");
        if (!fs.existsSync(filePath)) {
          throw new Error("Preset  + presetName +  not found in " + presetsDir);
        }
        const content = fs.readFileSync(filePath, "utf8");
        return {
          content: [{ type: "text", text: content }]
        };
      }

      // Action: list
      const files = fs.readdirSync(presetsDir).filter((f) => f.endsWith(".yml"));
      const presets = files.map((f) => {
        const full = path.join(presetsDir, f);
        const raw = fs.readFileSync(full, "utf8");
        const name = f.replace(/\.ya?ml$/, "");
        const descMatch = raw.match(/^description:\s*["']?(.*?)["']?$/m);
        return {
          preset: name,
          filename: f,
          description: descMatch ? descMatch[1] : name
        };
      });

      return {
        content: [{ type: "text", text: JSON.stringify({ presets }, null, 2) }]
      };
    }

    case "laporan_citations": {
      const action = args.action;

      if (action === "search_doi") {
        if (!args.query) throw new Error("Missing query for action search_doi");
        const queryUrl = "https://api.crossref.org/works?query=" + encodeURIComponent(args.query) + "&rows=5";
        const resp = await httpsGet(queryUrl);
        if (resp.statusCode !== 200) {
          throw new Error("Crossref API returned status " + resp.statusCode);
        }
        const data = JSON.parse(resp.body);
        const items = (data.message && data.message.items ? data.message.items : []).map((it) => {
          const authors = (it.author || []).map((a) => (a.given ? a.given + " " : "") + (a.family || "")).join(", ");
          const year = it.issued && it.issued["date-parts"] && it.issued["date-parts"][0] ? it.issued["date-parts"][0][0] : null;
          return {
            doi: it.DOI,
            title: it.title ? it.title[0] : "Untitled",
            authors: authors || "Unknown",
            year: year,
            container: it["container-title"] ? it["container-title"][0] : null,
            type: it.type
          };
        });
        return {
          content: [{ type: "text", text: JSON.stringify({ query: args.query, count: items.length, items }, null, 2) }]
        };
      }

      if (action === "get_bibtex") {
        let cleanDoi = (args.doi || "").trim();
        cleanDoi = cleanDoi.replace(/^https?:\/\/(dx\.)?doi\.org\//i, "");
        if (!cleanDoi) throw new Error("Missing doi parameter for action get_bibtex");
        const doiUrl = "https://doi.org/" + encodeURIComponent(cleanDoi);
        const resp = await httpsGet(doiUrl, {
          headers: {
            "Accept": "application/x-bibtex"
          }
        });
        if (resp.statusCode !== 200) {
          throw new Error("Failed to fetch BibTeX for DOI " + cleanDoi + ": HTTP " + resp.statusCode);
        }
        return {
          content: [{ type: "text", text: resp.body.trim() }]
        };
      }

      if (action === "add_citation") {
        let bibtex = (args.bibtex || "").trim();
        if (!bibtex && args.doi) {
          // Auto fetch if only DOI was provided
          let cleanDoi = args.doi.trim().replace(/^https?:\/\/(dx\.)?doi\.org\//i, "");
          const resp = await httpsGet("https://doi.org/" + encodeURIComponent(cleanDoi), {
            headers: { "Accept": "application/x-bibtex" }
          });
          if (resp.statusCode === 200) {
            bibtex = resp.body.trim();
          }
        }
        if (!bibtex) throw new Error("Missing bibtex entry or valid doi to add");
        const bibFile = path.join(targetDir, "references.bib");
        if (!fs.existsSync(bibFile)) {
          fs.writeFileSync(bibFile, bibtex + "\n", "utf8");
        } else {
          fs.appendFileSync(bibFile, "\n\n" + bibtex + "\n", "utf8");
        }

        // Extract cite key
        const keyMatch = bibtex.match(/@\w+\s*\{\s*([a-zA-Z0-9_:-]+)/);
        const citeKey = keyMatch ? keyMatch[1] : null;

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                status: "SUCCESS",
                message: "Citation appended to references.bib",
                citeKey: citeKey,
                markdownCitation: citeKey ? "[@" + citeKey + "]" : null
              }, null, 2)
            }
          ]
        };
      }

      if (action === "validate") {
        const bibFile = path.join(targetDir, "references.bib");
        if (!fs.existsSync(bibFile)) {
          return {
            content: [{ type: "text", text: JSON.stringify({ valid: false, error: "references.bib not found in " + targetDir }) }]
          };
        }
        const bibContent = fs.readFileSync(bibFile, "utf8");
        const keys = Array.from(bibContent.matchAll(/@\w+\s*\{\s*([a-zA-Z0-9_:-]+)/g)).map((m) => m[1]);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                valid: true,
                totalEntries: keys.length,
                keys: keys
              }, null, 2)
            }
          ]
        };
      }

      throw new Error("Unknown action: " + action);
    }

    case "laporan_build": {
      const format = args.format || "all";
      const isWin = process.platform === "win32";
      let proc;

      if (isWin) {
        const ps = path.join(PACKAGE_ROOT, "laporan.ps1");
        proc = spawnSync("powershell", ["-ExecutionPolicy", "Bypass", "-File", ps, "build"], {
          cwd: targetDir,
          encoding: "utf8"
        });
      } else {
        const script = path.join(PACKAGE_ROOT, "build.sh");
        if (format === "docx") {
          proc = spawnSync("make", ["docx"], { cwd: targetDir, encoding: "utf8" });
        } else if (format === "pdf") {
          proc = spawnSync("bash", [script], { cwd: targetDir, encoding: "utf8" });
        } else {
          // both
          const procPdf = spawnSync("bash", [script], { cwd: targetDir, encoding: "utf8" });
          const procDocx = spawnSync("make", ["docx"], { cwd: targetDir, encoding: "utf8" });
          proc = {
            status: (procPdf.status || 0) + (procDocx.status || 0),
            stdout: (procPdf.stdout || "") + "\n" + (procDocx.stdout || ""),
            stderr: (procPdf.stderr || "") + "\n" + (procDocx.stderr || "")
          };
        }
      }

      const pdfPath = path.join(targetDir, "Laporan.pdf");
      const docxPath = path.join(targetDir, "Laporan.docx");

      const res = {
        status: proc.status === 0 ? "SUCCESS" : "FAILED",
        exitCode: proc.status,
        pdfGenerated: fs.existsSync(pdfPath),
        pdfSize: fs.existsSync(pdfPath) ? fs.statSync(pdfPath).size : null,
        docxGenerated: fs.existsSync(docxPath),
        docxSize: fs.existsSync(docxPath) ? fs.statSync(docxPath).size : null,
        outputLogs: proc.stdout ? proc.stdout.slice(-1000) : "",
        errorLogs: proc.stderr ? proc.stderr.slice(-1000) : ""
      };

      return {
        content: [{ type: "text", text: JSON.stringify(res, null, 2) }]
      };
    }

    default:
      throw new Error("Unknown tool: " + name);
  }
}

function start() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
  });

  function sendResponse(id, result) {
    const payload = {
      jsonrpc: "2.0",
      id: id,
      result: result
    };
    process.stdout.write(JSON.stringify(payload) + "\n");
  }

  function sendError(id, code, message, data) {
    const payload = {
      jsonrpc: "2.0",
      id: id,
      error: {
        code: code,
        message: message,
        data: data
      }
    };
    process.stdout.write(JSON.stringify(payload) + "\n");
  }

  rl.on("line", async (line) => {
    line = line.trim();
    if (!line) return;

    let req;
    try {
      req = JSON.parse(line);
    } catch (e) {
      sendError(null, -32700, "Parse error: " + e.message);
      return;
    }

    const { id, method, params } = req;

    if (!id && method && method.startsWith("notifications/")) {
      return;
    }

    try {
      switch (method) {
        case "initialize":
          sendResponse(id, {
            protocolVersion: "2024-11-05",
            capabilities: {
              tools: {}
            },
            serverInfo: {
              name: "laporan-generator",
              version: VERSION
            }
          });
          break;

        case "ping":
          sendResponse(id, {});
          break;

        case "tools/list":
          sendResponse(id, {
            tools: TOOLS
          });
          break;

        case "tools/call": {
          if (!params || !params.name) {
            sendError(id, -32602, "Invalid params: missing tool name");
            return;
          }
          try {
            const toolResult = await handleToolCall(params.name, params.arguments || {});
            sendResponse(id, toolResult);
          } catch (err) {
            sendResponse(id, {
              isError: true,
              content: [
                {
                  type: "text",
                  text: "Tool execution failed: " + err.message
                }
              ]
            });
          }
          break;
        }

        default:
          sendError(id, -32601, "Method not found: " + method);
          break;
      }
    } catch (err) {
      sendError(id, -32603, "Internal error: " + err.message);
    }
  });

  process.stderr.write("Laporan Generator MCP Server v" + VERSION + " running on stdio\n");
}

module.exports = { start, handleToolCall, TOOLS, VERSION };
