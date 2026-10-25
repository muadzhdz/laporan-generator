.PHONY: build clean lint-deps watch docx html crossref test docker-build init view reference-docx

build:
	./build.sh

init:
	@git config core.hooksPath .githooks
	@echo "[OK] Git pre-commit hook berhasil diaktifkan!"

view:
	@if [ -f Laporan.pdf ]; then \
		command -v xdg-open >/dev/null 2>&1 && xdg-open Laporan.pdf || open Laporan.pdf || echo "Laporan.pdf ada di: $(shell pwd)/Laporan.pdf"; \
	else \
		echo "ERROR: Laporan.pdf belum dibuat. Jalankan 'make build' terlebih dahulu."; \
		exit 1; \
	fi

clean:
	rm -f Laporan.pdf Laporan.docx Laporan.html
	rm -rf tmp/

lint-deps:
	@echo "Checking dependencies..."
	@command -v pandoc >/dev/null 2>&1 || { echo "ERROR: pandoc not found"; exit 1; }
	@command -v typst >/dev/null 2>&1 || { echo "ERROR: typst not found"; exit 1; }
	@command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || { echo "ERROR: ImageMagick (magick/convert) not found"; exit 1; }
	@echo "All dependencies OK."

watch:
	@command -v inotifywait >/dev/null 2>&1 || { echo "ERROR: inotifywait not found. Install inotify-tools."; exit 1; }
	@echo "Watching for changes... (Ctrl+C to stop)"
	@while true; do \
		inotifywait -r -e modify -e create -e delete . \
			--exclude '(Laporan\.pdf|tmp/|\.git/|\.pdf)' 2>/dev/null; \
		./build.sh; \
	done

docx:
	./build-docx.sh


reference-docx:
	@command -v pandoc >/dev/null 2>&1 || { echo "ERROR: pandoc not found"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 not found"; exit 1; }
	@mkdir -p tmp
	pandoc --print-default-data-file reference.docx > tmp/ref-default.docx
	python3 scripts/make-reference-docx.py tmp/ref-default.docx templates/default/reference.docx
	@rm -f tmp/ref-default.docx

html:
	@SRC_DIR="."; \
	if [ ! -d "$$SRC_DIR/chapters" ] && [ -d "templates/default/chapters" ]; then \
		SRC_DIR="templates/default"; \
	fi; \
	if [ ! -d "$$SRC_DIR/chapters" ]; then \
		echo "ERROR: Direktori chapters/ tidak ditemukan."; \
		exit 1; \
	fi; \
	PRESET=$$(grep -E '^[[:space:]]*(preset|margin_preset):' "$$SRC_DIR/metadata.yml" 2>/dev/null | head -n 1 | cut -d: -f2- | tr -d '\"'\''\r\n '); \
	PRESET_FILE=""; \
	if [ -n "$$PRESET" ] && [ -f "presets/$${PRESET}.yml" ]; then \
		PRESET_FILE="--metadata-file=presets/$${PRESET}.yml"; \
	elif [ -f "presets/standard.yml" ]; then \
		PRESET_FILE="--metadata-file=presets/standard.yml"; \
	fi; \
	pandoc "$$SRC_DIR"/chapters/bab*.md \
		$$PRESET_FILE \
		--metadata-file="$$SRC_DIR/metadata.yml" \
		--citeproc --bibliography="$$SRC_DIR/references.bib" \
		--csl="$$SRC_DIR/apa.csl" \
		--metadata=reference-section-title="DAFTAR PUSTAKA" \
		--top-level-division=chapter \
		--standalone --toc \
		-o Laporan.html 2>&1

crossref:
	@command -v pandoc-crossref >/dev/null 2>&1 || { \
		echo "ERROR: pandoc-crossref not found."; \
		echo "Install: https://github.com/lierdakil/pandoc-crossref"; \
		exit 1; \
	}
	CITEPROC_OPTS="--filter pandoc-crossref" ./build.sh

test:
	./test.sh

docker-build:
	docker compose build

docker-run:
	docker compose run --rm laporan-generator

docker-watch:
	docker compose run --rm watch
