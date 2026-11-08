"use strict";

const fs = require("fs");
const path = require("path");
const readline = require("readline");
const https = require("https");
const { spawn } = require("child_process");
const { initProject } = require("./init");

const VERSION = "4.0.0";
const PACKAGE_ROOT = path.join(__dirname, "..");

const PROCESS_OUTPUT_LIMIT = 256 * 1024;
const PROCESS_TIMEOUT_MS = 120 * 1000;
const BUILD_TIMEOUT_MS = 10 * 60 * 1000;
const HTTP_TIMEOUT_MS = 15 * 1000;
const HTTP_BODY_LIMIT = 2 * 1024 * 1024;

function getPresetNames() {
  return fs.readdirSync(path.join(PACKAGE_ROOT, "presets"))
    .filter((file) => file.endsWith(".yml"))
    .map((file) => file.slice(0, -4))
    .sort();
}

const PRESET_NAMES = getPresetNames();

function normalizePresetName(value) {
  const name = String(value || "").replace(/\.ya?ml$/i, "");
  if (!PRESET_NAMES.includes(name)) {
    throw new Error("Unknown preset. Choose one of: " + PRESET_NAMES.join(", "));
  }
  return name;
}

function resolveWithinDirectory(directory, value, label) {
  const root = fs.realpathSync(path.resolve(directory));
  const resolved = path.resolve(root, value);
  const relative = path.relative(root, resolved);
  if (relative === ".." || relative.startsWith(".." + path.sep) || path.isAbsolute(relative)) {
    throw new Error(label + " must stay inside the document directory");
  }
  let current = root;
  for (const segment of relative.split(path.sep).filter(Boolean)) {
    current = path.join(current, segment);
    try {
      if (fs.lstatSync(current).isSymbolicLink()) {
        throw new Error(label + " must not pass through symbolic links");
      }
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
  }
  return resolved;
}

function appendLimited(current, chunk) {
  const next = current + chunk.toString("utf8");
  return next.length > PROCESS_OUTPUT_LIMIT ? next.slice(-PROCESS_OUTPUT_LIMIT) : next;
}

function runProcess(command, args, options = {}) {
  return new Promise((resolve) => {
    let stdout = "";
    let stderr = "";
    let timedOut = false;
    let settled = false;
    let killTimer;
    const timeoutMs = options.timeoutMs || PROCESS_TIMEOUT_MS;
    const child = spawn(command, args, {
      cwd: options.cwd,
      env: options.env || process.env,
      windowsHide: true,
      stdio: ["ignore", "pipe", "pipe"]
    });

    const finish = (result) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      if (killTimer) clearTimeout(killTimer);
      resolve({ stdout, stderr, ...result });
    };

    child.stdout.on("data", (chunk) => { stdout = appendLimited(stdout, chunk); });
    child.stderr.on("data", (chunk) => { stderr = appendLimited(stderr, chunk); });
    child.once("error", (error) => finish({ status: null, error }));
    child.once("close", (code, signal) => finish({
      status: timedOut ? 124 : (code === null ? 1 : code),
      signal,
      timedOut
    }));

    const timer = setTimeout(() => {
      timedOut = true;
      child.kill();
      killTimer = setTimeout(() => child.kill("SIGKILL"), 2000);
      if (killTimer.unref) killTimer.unref();
    }, timeoutMs);
    if (timer.unref) timer.unref();
  });
}

async function runPython(args, options = {}) {
  const first = process.platform === "win32" ? "python" : "python3";
  const alternate = first === "python" ? "python3" : "python";
  const result = await runProcess(first, args, options);
  if (result.error && result.error.code === "ENOENT") {
    return runProcess(alternate, args, options);
  }
  return result;
}

function requireSuccess(result, operation) {
  if (result.error) {
    throw new Error(operation + " could not start: " + result.error.message);
  }
  if (result.timedOut) {
    throw new Error(operation + " timed out");
  }
  if (result.status !== 0) {
    const details = (result.stderr || result.stdout || "").trim();
    throw new Error(operation + " failed (exit " + result.status + ")" + (details ? ": " + details.slice(-4000) : ""));
  }
  return result;
}

function httpsGet(url, options = {}, maxRedirects = 5) {
  return new Promise((resolve, reject) => {
    if (maxRedirects < 0) return reject(new Error("Too many HTTP redirects"));
    let u;
    try {
      u = new URL(url);
    } catch (error) {
      reject(error);
      return;
    }
    if (u.protocol !== "https:") {
      reject(new Error("Only HTTPS requests are allowed"));
      return;
    }
    const reqOpts = {
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: Object.assign({
        "User-Agent": "LaporanGenerator/" + VERSION + " (academic-document-engine; mailto:support@example.com)"
      }, options.headers || {})
    };

    const req = https.get(reqOpts, (res) => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location) {
        res.resume();
        let redirectUrl;
        try {
          redirectUrl = new URL(res.headers.location, u).toString();
        } catch (error) {
          reject(error);
          return;
        }
        return resolve(httpsGet(redirectUrl, options, maxRedirects - 1));
      }
      let body = "";
      let size = 0;
      res.on("data", (chunk) => {
        size += chunk.length;
        if (size > HTTP_BODY_LIMIT) {
          req.destroy(new Error("HTTP response exceeds 2 MB limit"));
          return;
        }
        body += chunk;
      });
      res.on("end", () => {
        resolve({ statusCode: res.statusCode, headers: res.headers, body });
      });
    });
    const timeout = setTimeout(() => req.destroy(new Error("HTTPS request timed out after 15 seconds")), HTTP_TIMEOUT_MS);
    if (timeout.unref) timeout.unref();
    req.once("close", () => clearTimeout(timeout));
    req.setTimeout(HTTP_TIMEOUT_MS, () => req.destroy(new Error("HTTPS request timed out after 15 seconds")));
    req.on("error", reject);
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
          enum: PRESET_NAMES,
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
    description: "Search Crossref metadata or inspect citations in references.bib. Retrieve BibTeX metadata for a DOI and append it to references.bib; verify source details and relevance independently.",
    inputSchema: {
      type: "object",
      properties: {
        action: {
          type: "string",
          enum: ["search_doi", "get_bibtex", "add_citation", "validate"],
          description: "Action: search_doi (query Crossref for papers), get_bibtex (retrieve DOI metadata as BibTeX), add_citation (append BibTeX to references.bib), or validate (check local structure)."
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
  },
  {
    name: "laporan_import",
    description: "Convert an external document (.docx, .pdf, .pptx, .xlsx, .txt) into clean Markdown for use in chapters/ using Microsoft MarkItDown.",
    inputSchema: {
      type: "object",
      properties: {
        source_file: {
          type: "string",
          description: "Path to the input document (.docx, .pdf, .pptx, .xlsx, .txt)."
        },
        target_file: {
          type: "string",
          description: "Optional destination Markdown path (e.g. chapters/bab1-pendahuluan.md). If omitted, returns converted content in response."
        },
        target_dir: {
          type: "string",
          description: "Document directory. Relative source and destination paths use this directory; defaults to the current directory."
        }
      },
      required: ["source_file"]
    }
  },
  {
    name: "laporan_audit",
    description: "Analyze writing-pattern heuristics such as sentence-length variation, lexical diversity, repeated phrases, and formulaic starters. Results are not an AI-authorship detector or proof of authorship.",
    inputSchema: {
      type: "object",
      properties: {
        target_dir: {
          type: "string",
          description: "Target directory or Markdown file to audit. Defaults to current directory."
        },
        strict: {
          type: "boolean",
          description: "When true, returns failure status if the heuristic pattern score exceeds 15. This score does not estimate whether a person or AI wrote the text."
        }
      }
    }
  },
  {
    name: "laporan_verify_citations",
    description: "Check DOI reachability and metadata against Crossref. A resolvable DOI does not by itself confirm that a citation is accurate or relevant.",
    inputSchema: {
      type: "object",
      properties: {
        bib_file: {
          type: "string",
          description: "Path to references.bib. Defaults to auto-detecting references.bib."
        },
        offline: {
          type: "boolean",
          description: "When true, checks local cache without outbound network requests."
        }
      }
    }
  }
];

const RESOURCES = [
  {
    uri: "laporan://presets/all",
    name: "Campus Presets Directory",
    description: "Complete list of university format presets supported by Laporan Generator.",
    mimeType: "application/json"
  },
  {
    uri: "laporan://docs/campus-guide",
    name: "Campus Preset Usage Guide",
    description: "How to use the starter presets and check local academic requirements.",
    mimeType: "text/markdown"
  },
  {
    uri: "laporan://docs/preset-sources",
    name: "Preset Sources and Scope",
    description: "Source links, institutional scope, and verification status for each preset.",
    mimeType: "text/markdown"
  },
  {
    uri: "laporan://docs/metadata-schema",
    name: "Metadata Configuration Schema",
    description: "Full YAML metadata.yml configuration schema documentation.",
    mimeType: "text/markdown"
  }
];

const PROMPTS = [
  {
    name: "academic_interview",
    description: "Interactive questionnaire for discovering a user's academic document requirements.",
    arguments: [
      {
        name: "document_type",
        description: "Type of document (skripsi, tesis, makalah, pkl)",
        required: false
      }
    ]
  },
  {
    name: "puebi_compliance_audit",
    description: "Audit checklist for Indonesian academic language (PUEBI), citations, and formatting standards.",
    arguments: []
  }
];

async function handleToolCall(name, args = {}) {
  const targetDir = args.target_dir ? path.resolve(args.target_dir) : process.cwd();

  switch (name) {
    case "laporan_init": {
      if (args.preset) normalizePresetName(args.preset);
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
      const proc = requireSuccess(await runPython([script, targetDir, "--json"], { timeoutMs: PROCESS_TIMEOUT_MS }), "Doctor");
      const output = proc.stdout.trim();
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
      const proc = requireSuccess(await runPython([script, targetDir, "--json"], { timeoutMs: PROCESS_TIMEOUT_MS }), "Stats");
      const output = proc.stdout.trim();
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
        const presetName = normalizePresetName(args.preset_name);
        if (!presetName) {
          throw new Error("Missing preset_name argument for action get");
        }
        const filePath = path.join(presetsDir, presetName + ".yml");
        if (!fs.existsSync(filePath)) {
          throw new Error("Preset '" + presetName + "' not found in " + presetsDir);
        }
        const content = fs.readFileSync(filePath, "utf8");
        return {
          content: [{ type: "text", text: content }]
        };
      }
      if (action !== "list") throw new Error("Unknown preset action: " + action);

      const presets = PRESET_NAMES.map((name) => {
        const f = name + ".yml";
        const full = path.join(presetsDir, f);
        const raw = fs.readFileSync(full, "utf8");
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

      if (action !== "search_doi" && action !== "get_bibtex" && action !== "add_citation" && action !== "validate") {
        throw new Error("Unknown citation action: " + action);
      }

      if (action === "validate") {
        let bibFile = path.join(targetDir, "references.bib");
        if (!fs.existsSync(bibFile) && fs.existsSync(path.join(targetDir, "templates/default/references.bib"))) {
          bibFile = path.join(targetDir, "templates/default/references.bib");
        }
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
      if (!["all", "pdf", "docx"].includes(format)) {
        throw new Error("Unknown build format: " + format);
      }
      const isWin = process.platform === "win32";
      const results = [];

      if (isWin) {
        const ps = path.join(PACKAGE_ROOT, "laporan.ps1");
        const commands = format === "all" ? ["pdf", "docx"] : [format];
        for (const command of commands) {
          results.push(requireSuccess(await runProcess("powershell", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps, command], {
            cwd: targetDir,
            timeoutMs: BUILD_TIMEOUT_MS
          }), "Build " + command.toUpperCase()));
        }
      } else {
        const scriptPdf = path.join(PACKAGE_ROOT, "build.sh");
        const scriptDocx = path.join(PACKAGE_ROOT, "build-docx.sh");
        const commands = format === "all" ? ["pdf", "docx"] : [format];
        for (const command of commands) {
          const script = command === "pdf" ? scriptPdf : scriptDocx;
          results.push(requireSuccess(await runProcess("bash", [script, targetDir], {
            cwd: targetDir,
            timeoutMs: BUILD_TIMEOUT_MS
          }), "Build " + command.toUpperCase()));
        }
      }

      const proc = {
        status: 0,
        stdout: results.map((result) => result.stdout).join("\n"),
        stderr: results.map((result) => result.stderr).join("\n")
      };

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

    case "laporan_import": {
      const src = args.source_file;
      if (!src) throw new Error("source_file argument is required");
      const ingestScript = path.join(PACKAGE_ROOT, "scripts", "ingest.py");
      const cmdArgs = [ingestScript, src];
      if (args.target_file) {
        cmdArgs.push("-o", resolveWithinDirectory(targetDir, args.target_file, "target_file"));
      }
      const proc = requireSuccess(await runPython(cmdArgs, { cwd: targetDir, timeoutMs: PROCESS_TIMEOUT_MS }), "Document import");
      return {
        content: [
          {
            type: "text",
            text: args.target_file
              ? `Successfully converted '${src}' into '${args.target_file}'`
              : proc.stdout
          }
        ]
      };
    }

    case "laporan_audit": {
      const script = path.join(PACKAGE_ROOT, "scripts", "audit-forensics.py");
      const cmdArgs = [script, targetDir, "--json"];
      if (args.strict) cmdArgs.push("--strict");
      const proc = requireSuccess(await runPython(cmdArgs, { timeoutMs: PROCESS_TIMEOUT_MS }), "Stylometry audit");
      const outputText = proc.stdout || proc.stderr || "{}";
      return {
        content: [{ type: "text", text: outputText }]
      };
    }

    case "laporan_verify_citations": {
      const script = path.join(PACKAGE_ROOT, "scripts", "verify-citations.py");
      const cmdArgs = [script, "--json"];
      if (args.bib_file) cmdArgs.push("--bib", args.bib_file);
      if (args.offline) cmdArgs.push("--offline");
      const proc = requireSuccess(await runPython(cmdArgs, { timeoutMs: PROCESS_TIMEOUT_MS }), "Citation verification");
      const outputText = proc.stdout || proc.stderr || "{}";
      return {
        content: [{ type: "text", text: outputText }]
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
              tools: {},
              resources: {},
              prompts: {}
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

        case "resources/list":
          sendResponse(id, {
            resources: RESOURCES
          });
          break;

        case "resources/read": {
          const uri = params && params.uri ? params.uri : "";
          if (uri === "laporan://presets/all") {
            const presetsDir = path.join(PACKAGE_ROOT, "presets");
            let files = [];
            if (fs.existsSync(presetsDir)) {
              files = fs.readdirSync(presetsDir).filter(f => f.endsWith(".yml")).map(f => f.replace(".yml", ""));
            }
            sendResponse(id, {
              contents: [{ uri, mimeType: "application/json", text: JSON.stringify({ presets: files }, null, 2) }]
            });
          } else if (uri.startsWith("laporan://presets/")) {
            const presetId = uri.replace("laporan://presets/", "");
            let safePresetId;
            try {
              safePresetId = normalizePresetName(presetId);
            } catch (error) {
              sendError(id, -32602, error.message);
              break;
            }
            const pFile = path.join(PACKAGE_ROOT, "presets", safePresetId + ".yml");
            if (fs.existsSync(pFile)) {
              sendResponse(id, {
                contents: [{ uri, mimeType: "text/yaml", text: fs.readFileSync(pFile, "utf8") }]
              });
            } else {
              sendError(id, -32602, "Preset not found: " + presetId);
            }
          } else if (uri === "laporan://docs/campus-guide") {
            const docFile = path.join(PACKAGE_ROOT, "docs/campus-guide.md");
            sendResponse(id, {
              contents: [{ uri, mimeType: "text/markdown", text: fs.existsSync(docFile) ? fs.readFileSync(docFile, "utf8") : "" }]
            });
          } else if (uri === "laporan://docs/preset-sources") {
            const docFile = path.join(PACKAGE_ROOT, "docs/preset-sources.md");
            sendResponse(id, {
              contents: [{ uri, mimeType: "text/markdown", text: fs.existsSync(docFile) ? fs.readFileSync(docFile, "utf8") : "" }]
            });
          } else if (uri === "laporan://docs/metadata-schema") {
            const docFile = path.join(PACKAGE_ROOT, "docs/metadata-schema.md");
            sendResponse(id, {
              contents: [{ uri, mimeType: "text/markdown", text: fs.existsSync(docFile) ? fs.readFileSync(docFile, "utf8") : "" }]
            });
          } else {
            sendError(id, -32602, "Unknown resource URI: " + uri);
          }
          break;
        }

        case "prompts/list":
          sendResponse(id, {
            prompts: PROMPTS
          });
          break;

        case "prompts/get": {
          const promptName = params && params.name ? params.name : "";
          if (promptName === "academic_interview") {
            sendResponse(id, {
              description: "Guided interview for structuring academic documents.",
              messages: [
                {
                  role: "user",
                  content: {
                    type: "text",
                    text: "Pandu saya menentukan struktur laporan/skripsi akademik (kampus, fakultas, jenis dokumen, dan kebutuhan halaman depan seperti Abstrak atau Lembar Pengesahan)."
                  }
                }
              ]
            });
          } else if (promptName === "puebi_compliance_audit") {
            sendResponse(id, {
              description: "Review academic report against PUEBI and scientific publication standards.",
              messages: [
                {
                  role: "user",
                  content: {
                    type: "text",
                    text: "Audit naskah bab-bab laporan ini terhadap kepatuhan PUEBI, kelengkapan sitasi (@citekey), kejelasan tabel/gambar, dan konsistensi penomoran bab."
                  }
                }
              ]
            });
          } else {
            sendError(id, -32602, "Unknown prompt: " + promptName);
          }
          break;
        }

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

module.exports = { start, handleToolCall, TOOLS, VERSION, runProcess, httpsGet };
