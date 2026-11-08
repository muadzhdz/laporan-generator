#!/usr/bin/env python3

import argparse
import glob
import json
import math
import os
import re
import sys

CLICHE_PATTERNS_ID = [
    r"\bkrusial\b",
    r"\bkomprehensif\b",
    r"\bmenyeluruh\b",
    r"\blanskap\b",
    r"\bmemainkan peran penting\b",
    r"\bperan krusial\b",
    r"\bselaras dengan\b",
    r"\bdalam era\b",
    r"\btak terbantahkan\b",
    r"\bpatut dicatat\b",
    r"\bsecara signifikan\b",
    r"\bmenyoroti pentingnya\b",
    r"\btitik balik penting\b",
    r"\bsecara mendalam\b",
    r"\btidak dapat dipungkiri\b",
]

CLICHE_PATTERNS_EN = [
    r"\bcrucial\b",
    r"\bcomprehensive\b",
    r"\blandscape\b",
    r"\btestament\b",
    r"\bpivotal\b",
    r"\bdelve\b",
    r"\btapestry\b",
    r"\bbeacon\b",
    r"\bfurthermore\b",
    r"\bmoreover\b",
    r"\bit is important to note\b",
    r"\bplays a crucial role\b",
    r"\bseamlessly\b",
    r"\bin today's\b",
]

FORMULAIC_STARTERS = [
    r"^selain itu\b",
    r"^namun demikian\b",
    r"^oleh karena itu\b",
    r"^di sisi lain\b",
    r"^dengan demikian\b",
    r"^sehubungan dengan itu\b",
    r"^dalam hal ini\b",
    r"^furthermore\b",
    r"^moreover\b",
    r"^in addition\b",
    r"^however\b",
    r"^consequently\b",
]

ABBREVIATIONS = (
    "dr.", "prof.", "ir.", "h.", "s.pd.", "m.pd.", "s.t.", "m.t.", "s.kom.", "m.kom.",
    "dll.", "dsb.", "dst.", "ttg.", "hal.", "no.", "vol.", "al.", "etc.", "e.g.", "i.e."
)

def clean_markdown(text):
    text = re.sub(r"^---[\s\S]*?---", " ", text, flags=re.MULTILINE)
    text = re.sub(r"```[\s\S]*?```", " ", text)
    text = re.sub(r"`[^`]+`", " ", text)
    text = re.sub(r"\$\$[\s\S]*?\$\$", " ", text)
    text = re.sub(r"\$[^$]+\$", " ", text)
    text = re.sub(r"!\[.*?\]\(.*?\)", " ", text)
    text = re.sub(r"\[(.*?)\]\(.*?\)", r"\1", text)
    text = re.sub(r"^#{1,6}\s+.*$", " ", text, flags=re.MULTILINE)
    text = re.sub(r"<!--[\s\S]*?-->", " ", text)
    text = re.sub(r"^\+[-+]+\+$", " ", text, flags=re.MULTILINE)
    text = re.sub(r"^\|.*?\|$", " ", text, flags=re.MULTILINE)
    text = re.sub(r"^[-=_]{3,}\s*$", " ", text, flags=re.MULTILINE)
    text = re.sub(r"^(\s*[-*+]|\d+\.)\s+", " ", text, flags=re.MULTILINE)
    text = re.sub(r"\{#[^}]+\}", " ", text)
    text = re.sub(r"@[a-zA-Z0-9_:-]+", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def split_into_sentences(text):
    raw_parts = re.split(r"(?<=[.!?])\s+", text)
    sentences = []
    buffer = ""
    for part in raw_parts:
        part = part.strip()
        if not part:
            continue
        if buffer:
            buffer += " " + part
        else:
            buffer = part
        lower = buffer.lower()
        if any(lower.endswith(abbr) for abbr in ABBREVIATIONS):
            continue
        if len(buffer) > 1:
            sentences.append(buffer)
            buffer = ""
    if buffer:
        sentences.append(buffer)
    return sentences

def calculate_mattr(words, window_size=50):
    if len(words) < window_size:
        return len(set(words)) / max(1, len(words))
    ttr_sum = 0
    steps = len(words) - window_size + 1
    for i in range(steps):
        window = words[i:i + window_size]
        ttr_sum += len(set(window)) / window_size
    return ttr_sum / steps

def analyze_text(text):
    cleaned = clean_markdown(text)
    words = [w.lower() for w in re.findall(r"\b[a-zA-Z0-9_-]+\b", cleaned)]
    word_count = len(words)
    raw_sentences = split_into_sentences(cleaned)
    valid_sentences = []
    for s in raw_sentences:
        s_words = re.findall(r"\b[a-zA-Z0-9_-]+\b", s)
        if len(s_words) >= 3:
            valid_sentences.append((s, len(s_words)))
    sentence_count = len(valid_sentences)
    if sentence_count < 2 or word_count < 20:
        return {
            "status": "SKIPPED",
            "message": "Teks terlalu pendek untuk dianalisis forensik",
            "word_count": word_count,
            "sentence_count": sentence_count,
            "pattern_score": 0,
        }
    lengths = [cnt for _, cnt in valid_sentences]
    mean_len = sum(lengths) / sentence_count
    variance = sum((l - mean_len) ** 2 for l in lengths) / sentence_count
    std_dev = math.sqrt(variance)
    cv = std_dev / mean_len if mean_len > 0 else 0
    deltas = [abs(lengths[i] - lengths[i - 1]) for i in range(1, sentence_count)]
    mean_adj_delta = sum(deltas) / len(deltas) if deltas else 0
    mattr = calculate_mattr(words, window_size=min(50, word_count))
    cliches_found = []
    text_lower = cleaned.lower()
    for pat in CLICHE_PATTERNS_ID + CLICHE_PATTERNS_EN:
        matches = re.findall(pat, text_lower)
        if matches:
            cliches_found.append((pat.replace(r"\b", "").replace(r"\s+", " "), len(matches)))
    em_dash_count = len(re.findall(r"(?:[a-zA-Z0-9]\s*[—]\s*[a-zA-Z0-9]|[a-zA-Z0-9]\s+--\s+[a-zA-Z0-9])", cleaned))
    formulaic_count = 0
    for s, _ in valid_sentences:
        s_lower = s.strip().lower()
        if any(re.search(pat, s_lower) for pat in FORMULAIC_STARTERS):
            formulaic_count += 1
    penalty = 0
    if cv < 0.42:
        penalty += (0.42 - cv) * 80
    if mean_adj_delta < 12.0:
        penalty += (12.0 - mean_adj_delta) * 2.5
    if mattr < 0.70:
        penalty += (0.70 - mattr) * 50
    penalty += len(cliches_found) * 12
    if em_dash_count > (word_count / 300):
        penalty += (em_dash_count - (word_count / 300)) * 5
    if (formulaic_count / sentence_count) > 0.25:
        penalty += ((formulaic_count / sentence_count) - 0.25) * 60
    pattern_score = min(98, max(4, int(penalty)))
    verdict = "FEW PATTERN FLAGS" if pattern_score <= 15 else ("SOME PATTERN FLAGS" if pattern_score <= 40 else "MANY PATTERN FLAGS")
    return {
        "status": "AUDITED",
        "verdict": verdict,
        "pattern_score": pattern_score,
        "word_count": word_count,
        "sentence_count": sentence_count,
        "min_sentence_len": min(lengths),
        "max_sentence_len": max(lengths),
        "mean_sentence_len": round(mean_len, 2),
        "cv": round(cv, 3),
        "mean_adj_delta": round(mean_adj_delta, 2),
        "mattr": round(mattr, 3),
        "cliches_count": sum(cnt for _, cnt in cliches_found),
        "cliches_details": cliches_found,
        "em_dash_count": em_dash_count,
        "formulaic_starters_count": formulaic_count,
        "formulaic_ratio": round(formulaic_count / sentence_count, 3),
    }

def collect_files(target):
    if os.path.isfile(target):
        return [target]
    if os.path.isdir(target):
        files = []
        for ext in ("*.md", "*.markdown"):
            files.extend(glob.glob(os.path.join(target, "**", ext), recursive=True))
        return sorted(files)
    return sorted(glob.glob(target))

def main():
    parser = argparse.ArgumentParser(description="Heuristic Writing Pattern Audit")
    parser.add_argument("target", nargs="?", default=None, help="File atau direktori Markdown yang akan diaudit")
    parser.add_argument("--dir", dest="dir_target", default=None, help="Direktori Markdown yang akan diaudit")
    parser.add_argument("--all", action="store_true", help="Audit seluruh berkas Markdown di dalam repositori")
    parser.add_argument("--json", action="store_true", help="Keluarkan hasil dalam format JSON terstruktur")
    parser.add_argument("--strict", "--fail-on-ai", action="store_true", dest="strict", help="Gagal jika skor pola tulisan heuristik melebihi 15; bukan estimasi penggunaan AI")
    args = parser.parse_args()

    target_path = args.target if args.target is not None else args.dir_target
    if target_path is not None:
        if os.path.isdir(target_path):
            ch = os.path.join(target_path, "chapters")
            if os.path.isdir(ch):
                files = collect_files(ch)
                cov = os.path.join(target_path, "cover.md")
                if os.path.isfile(cov):
                    files.insert(0, cov)
            else:
                files = collect_files(target_path)
        else:
            files = collect_files(target_path)
    elif args.all:
        files = collect_files(".")
    else:
        if os.path.isdir("chapters"):
            files = collect_files("chapters")
            if os.path.isfile("cover.md"):
                files.insert(0, "cover.md")
        elif os.path.isdir("templates/default/chapters"):
            files = collect_files("templates/default/chapters")
            if os.path.isfile("templates/default/cover.md"):
                files.insert(0, "templates/default/cover.md")
        else:
            files = collect_files(".")

    if not files:
        if args.json:
            print(json.dumps({"error": "Tidak ada berkas Markdown yang ditemukan"}))
        else:
            print("Tidak ada berkas Markdown yang ditemukan untuk diaudit.")
        sys.exit(1)

    results = {}
    total_words = 0
    total_sentences = 0
    max_pattern_score = 0
    failed_strict = False

    for path in files:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()
        res = analyze_text(content)
        results[path] = res
        if res.get("status") == "AUDITED":
            total_words += res["word_count"]
            total_sentences += res["sentence_count"]
            max_pattern_score = max(max_pattern_score, res["pattern_score"])
            if args.strict and res["pattern_score"] > 15:
                failed_strict = True

    if args.json:
        output_payload = {
            "summary": {
                "total_files": len(files),
                "total_words": total_words,
                "total_sentences": total_sentences,
                "max_pattern_score": max_pattern_score,
                "score_interpretation": "Heuristic writing-pattern score; not an estimate of authorship or AI use.",
                "passed_strict": not failed_strict,
            },
            "files": results,
        }
        print(json.dumps(output_payload, indent=2))
        sys.exit(1 if failed_strict else 0)

    print("=" * 70)
    print("          LAPORAN GENERATOR - WRITING PATTERN AUDIT")
    print("=" * 70)
    for path, res in results.items():
        rel = os.path.relpath(path)
        if res.get("status") != "AUDITED":
            print(f"[-] {rel:32} | {res.get('message', 'SKIPPED')}")
            continue
        v = res["verdict"]
        p = res["pattern_score"]
        cv = res["cv"]
        delta = res["mean_adj_delta"]
        mattr = res["mattr"]
        cl = res["cliches_count"]
        print(f"[*] {rel:32} | {v:19} | PatternScore={p:2}/98 | CV={cv:0.3f} | Delta={delta:0.2f} | MATTR={mattr:0.3f} | Cliches={cl}")
        if res["cliches_details"]:
            for item, cnt in res["cliches_details"]:
                print(f"    ! Cliche found: '{item}' ({cnt}x)")

    print("-" * 70)
    status_msg = "PASSED (FEW PATTERN FLAGS)" if not failed_strict else "FAILED (PATTERN SCORE THRESHOLD EXCEEDED)"
    print(f"Rangkuman: {len(files)} berkas | {total_words} kata | Max pattern score: {max_pattern_score}/98 | Status: {status_msg}")
    print("Skor ini adalah heuristik pola tulisan, bukan probabilitas penggunaan AI atau bukti kepengarangan.")
    print("=" * 70)
    sys.exit(1 if failed_strict else 0)

if __name__ == "__main__":
    main()
