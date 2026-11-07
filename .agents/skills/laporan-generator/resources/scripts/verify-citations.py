#!/usr/bin/env python3

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

USER_AGENT = "LaporanGenerator/3.1.0 (https://github.com/muadzhdz/laporan-generator; mailto:contact@muadz.dev)"

def load_cache(cache_path):
    if os.path.isfile(cache_path):
        try:
            with open(cache_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_cache(cache_path, cache_data):
    try:
        os.makedirs(os.path.dirname(cache_path), exist_ok=True)
        with open(cache_path, "w", encoding="utf-8") as f:
            json.dump(cache_data, f, indent=2)
    except Exception:
        pass

def parse_bib_file(bib_path):
    entries = []
    with open(bib_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()
    raw_entries = re.split(r"@([a-zA-Z]+)\s*\{", content)
    for i in range(1, len(raw_entries), 2):
        entry_type = raw_entries[i].strip().lower()
        body = raw_entries[i + 1] if i + 1 < len(raw_entries) else ""
        lines = body.split("\n")
        first_line = lines[0].strip()
        key_match = re.match(r"([^,]+),", first_line)
        if not key_match:
            continue
        citation_key = key_match.group(1).strip()
        doi_match = re.search(r"\bdoi\s*=\s*[\"{]([^\",}]+)[\"}]", body, re.IGNORECASE)
        doi = doi_match.group(1).strip() if doi_match else None
        title_match = re.search(r"\btitle\s*=\s*[\"{]([^\",}]+)[\"}]", body, re.IGNORECASE)
        title = title_match.group(1).strip() if title_match else ""
        year_match = re.search(r"\byear\s*=\s*[\"{]?([0-9]{4})[\"}]?", body, re.IGNORECASE)
        year = year_match.group(1).strip() if year_match else ""
        author_match = re.search(r"\bauthor\s*=\s*[\"{]([^\",}]+)[\"}]", body, re.IGNORECASE)
        author = author_match.group(1).strip() if author_match else ""
        entries.append({
            "key": citation_key,
            "type": entry_type,
            "doi": doi,
            "title": title,
            "year": year,
            "author": author,
        })
    return entries

def clean_doi(doi):
    doi = doi.strip()
    doi = re.sub(r"^https?://(dx\.)?doi\.org/", "", doi)
    return urllib.parse.quote(doi, safe="/")

def check_doi_crossref(doi, cache):
    cleaned = clean_doi(doi)
    if cleaned in cache:
        return cache[cleaned]
    url = f"https://api.crossref.org/works/{cleaned}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=5) as response:
            if response.status == 200:
                data = json.loads(response.read().decode("utf-8"))
                item = data.get("message", {})
                cr_title = item.get("title", [""])[0] if item.get("title") else ""
                res = {
                    "valid": True,
                    "status_code": 200,
                    "crossref_title": cr_title,
                    "publisher": item.get("publisher", ""),
                }
                cache[cleaned] = res
                return res
    except urllib.error.HTTPError as e:
        res = {"valid": False, "status_code": e.code, "error": f"HTTP {e.code}"}
        cache[cleaned] = res
        return res
    except Exception as e:
        return {"valid": False, "status_code": 0, "error": str(e)}

def find_bib_file(custom_path=None):
    if custom_path and os.path.isfile(custom_path):
        return custom_path
    candidates = [
        "references.bib",
        "templates/default/references.bib",
        os.path.join(os.path.dirname(__file__), "..", "templates", "default", "references.bib"),
    ]
    for c in candidates:
        if os.path.isfile(c):
            return os.path.abspath(c)
    return None

def main():
    parser = argparse.ArgumentParser(description="CrossRef DOI Citation Verifier")
    parser.add_argument("--bib", default=None, help="Path ke berkas references.bib")
    parser.add_argument("--json", action="store_true", help="Keluarkan hasil dalam format JSON terstruktur")
    parser.add_argument("--cache", default=".cache/doi_cache.json", help="Path berkas cache DOI")
    parser.add_argument("--offline", action="store_true", help="Hanya gunakan cache lokal tanpa request jaringan")
    args = parser.parse_args()

    bib_path = find_bib_file(args.bib)
    if not bib_path:
        if args.json:
            print(json.dumps({"error": "Berkas references.bib tidak ditemukan"}))
        else:
            print("Berkas references.bib tidak ditemukan.")
        sys.exit(1)

    cache = load_cache(args.cache)
    entries = parse_bib_file(bib_path)

    verified_count = 0
    failed_count = 0
    non_doi_count = 0
    results = []

    for entry in entries:
        doi = entry.get("doi")
        if not doi:
            non_doi_count += 1
            results.append({
                "key": entry["key"],
                "has_doi": False,
                "valid": True,
                "type": entry["type"],
                "title": entry["title"],
                "note": "Primary non-DOI document",
            })
            continue
        if args.offline:
            cleaned = clean_doi(doi)
            cached = cache.get(cleaned)
            if cached and cached.get("valid"):
                verified_count += 1
                results.append({"key": entry["key"], "doi": doi, "has_doi": True, "valid": True, "cached": True})
            else:
                results.append({"key": entry["key"], "doi": doi, "has_doi": True, "valid": None, "note": "Offline unverified"})
            continue
        check = check_doi_crossref(doi, cache)
        if check.get("valid"):
            verified_count += 1
            results.append({
                "key": entry["key"],
                "doi": doi,
                "has_doi": True,
                "valid": True,
                "crossref_title": check.get("crossref_title", ""),
                "publisher": check.get("publisher", ""),
            })
        else:
            failed_count += 1
            results.append({
                "key": entry["key"],
                "doi": doi,
                "has_doi": True,
                "valid": False,
                "status_code": check.get("status_code"),
                "error": check.get("error", "Unknown error"),
            })

    save_cache(args.cache, cache)

    if args.json:
        payload = {
            "bib_path": bib_path,
            "total_entries": len(entries),
            "verified_dois": verified_count,
            "failed_dois": failed_count,
            "non_doi_entries": non_doi_count,
            "status": "HEALTHY" if failed_count == 0 else "DEGRADED",
            "results": results,
        }
        print(json.dumps(payload, indent=2))
        sys.exit(1 if failed_count > 0 else 0)

    print("=" * 70)
    print("           LAPORAN GENERATOR - CITATION DOI VERIFIER")
    print("=" * 70)
    print(f"Berkas BibTeX: {os.path.relpath(bib_path)}")
    print(f"Total Entri  : {len(entries)} (DOI: {verified_count + failed_count}, Non-DOI: {non_doi_count})")
    print("-" * 70)
    for r in results:
        k = r["key"]
        if not r.get("has_doi"):
            print(f"[~] {k:24} | PRIMARY DOC (Non-DOI: Buku / Regulasi / Prosiding)")
        elif r.get("valid"):
            print(f"[+] {k:24} | VERIFIED HTTP 200 OK | DOI: {r.get('doi')}")
        else:
            print(f"[-] {k:24} | INVALID / HALLUCINATED | {r.get('error')} | DOI: {r.get('doi')}")
    print("-" * 70)
    if failed_count == 0:
        print(f"HASIL: 100% SITASI DOI TERVERIFIKASI REAL ({verified_count} DOI lolos, 0 halusinasi)")
    else:
        print(f"HASIL: PERINGATAN! Ditemukan {failed_count} DOI tidak valid / fiktif.")
    print("=" * 70)
    sys.exit(1 if failed_count > 0 else 0)

if __name__ == "__main__":
    main()
