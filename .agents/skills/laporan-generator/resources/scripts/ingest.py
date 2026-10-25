#!/usr/bin/env python3
"""
scripts/ingest.py - Universal Document Ingestion for Laporan Generator (v3.0.0)
Converts incoming .docx, .pdf, .pptx, and .xlsx into clean Markdown chapters.

Uses Microsoft MarkItDown when available, with a zero-dependency standard-library
fallback for .docx and plain text.
"""

import sys
import os
import argparse
import zipfile
import xml.etree.ElementTree as ET

def extract_docx_fallback(file_path):
    """
    Standard-library fallback parser for .docx files when markitdown is not installed.
    Extracts headings, paragraphs, and lists directly from word/document.xml.
    """
    ns = {
        'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    }
    lines = []
    
    with zipfile.ZipFile(file_path, 'r') as z:
        if 'word/document.xml' not in z.namelist():
            raise ValueError(f"Invalid DOCX structure: {file_path}")
        
        xml_content = z.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        for p in root.iter(f"{{{ns['w']}}}p"):
            # Check paragraph style (Headings)
            pStyle = p.find(f".//{{{ns['w']}}}pStyle")
            style_val = pStyle.get(f"{{{ns['w']}}}val", "") if pStyle is not None else ""
            
            # Extract text
            texts = [node.text for node in p.iter(f"{{{ns['w']}}}t") if node.text]
            p_text = "".join(texts).strip()
            
            if not p_text:
                continue
                
            # Classify headings
            if style_val.lower().startswith('heading1') or style_val == 'Heading1':
                lines.append(f"\n# {p_text}\n")
            elif style_val.lower().startswith('heading2') or style_val == 'Heading2':
                lines.append(f"\n## {p_text}\n")
            elif style_val.lower().startswith('heading3') or style_val == 'Heading3':
                lines.append(f"\n### {p_text}\n")
            else:
                lines.append(f"{p_text}\n")
                
    return "\n".join(lines).strip() + "\n"

def convert_document(file_path):
    """
    Converts a document to Markdown.
    Attempts Microsoft MarkItDown first; falls back gracefully if unavailable.
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
        
    ext = os.path.splitext(file_path)[1].lower()
    
    # 1. Try Microsoft MarkItDown if installed
    try:
        from markitdown import MarkItDown
        md = MarkItDown()
        result = md.convert(file_path)
        if result and result.text_content:
            return result.text_content
    except ImportError:
        pass
    except Exception as e:
        sys.stderr.write(f"[WARNING] MarkItDown error: {e}. Attempting fallback parser...\n")

    # 2. Native Fallbacks
    if ext == '.docx':
        return extract_docx_fallback(file_path)
    elif ext in ['.txt', '.md']:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    else:
        raise RuntimeError(
            f"Format '{ext}' requires Microsoft MarkItDown.\n"
            f"Install it with: pip install markitdown\n"
            f"Supported formats with MarkItDown: .pdf, .docx, .pptx, .xlsx, images, audio."
        )

def main():
    parser = argparse.ArgumentParser(
        description="Convert DOCX, PDF, PPTX, or XLSX to Markdown for Laporan Generator (v3.0.0)"
    )
    parser.add_argument("input_file", help="Path to input document (.docx, .pdf, .pptx, .xlsx, .txt)")
    parser.add_argument("-o", "--output", help="Output Markdown file path (prints to stdout if omitted)")
    parser.add_argument("--append", action="store_true", help="Append to output file instead of overwriting")
    
    args = parser.parse_args()
    
    try:
        markdown_content = convert_document(args.input_file)
        
        if args.output:
            out_dir = os.path.dirname(args.output)
            if out_dir and not os.path.exists(out_dir):
                os.makedirs(out_dir, exist_ok=True)
                
            mode = "a" if args.append else "w"
            with open(args.output, mode, encoding="utf-8") as f:
                f.write(markdown_content)
            print(f"✔ Successfully converted '{args.input_file}' -> '{args.output}'")
        else:
            sys.stdout.write(markdown_content)
    except Exception as err:
        sys.stderr.write(f"[ERROR] Ingestion failed: {err}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
