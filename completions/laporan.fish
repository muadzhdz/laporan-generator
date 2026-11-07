complete -c laporan -f
complete -c ./laporan -f

set -l commands mcp build pdf docx init import preset stats audit citations doctor bundle setup sync-hosts uninstall check test view watch clean help
set -l presets standard skripsi-4433 ui-skripsi itb-ta ugm-skripsi its-skripsi unpad-skripsi ub-skripsi undip-skripsi unair-skripsi ipb-ppki telkom-ta jurnal-uajy jurnal-standar
set -l preset_actions list scan show diff validate apply

complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "mcp" -d "Jalankan MCP Server untuk AI Agent"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "build" -d "Kompilasi PDF dan DOCX sekaligus"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "pdf" -d "Kompilasi dokumen PDF via Typst"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "docx" -d "Kompilasi dokumen Word (.docx)"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "init" -d "Inisialisasi template dokumen"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "import" -d "Konversi berkas eksternal ke Markdown"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "preset" -d "Kelola preset format kampus"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "stats" -d "Analisis statistik dokumen"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "audit" -d "Audit forensik stylometri AI"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "citations" -d "Verifikasi sitasi via Crossref API"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "doctor" -d "Audit integritas berkas"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "bundle" -d "Kemas arsip zip rilis"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "setup" -d "Pasang dependensi sistem"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "sync-hosts" -d "Sinkronkan skill AI agent"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "uninstall" -d "Hapus skill AI agent"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "check" -d "Audit dependensi sistem"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "test" -d "Jalankan test suite"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "view" -d "Buka Laporan.pdf"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "watch" -d "Auto-rebuild saat berkas disimpan"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "clean" -d "Bersihkan berkas sementara"
complete -c laporan -n "not __fish_seen_subcommand_from $commands" -a "help" -d "Tampilkan bantuan"

complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "list" -d "Daftar preset"
complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "show" -d "Detail preset"
complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "apply" -d "Terapkan preset"
complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "diff" -d "Bandingkan preset"
complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "validate" -d "Validasi skema"
complete -c laporan -n "__fish_seen_subcommand_from preset; and not __fish_seen_subcommand_from $preset_actions" -a "scan" -d "Pindai pedoman PDF"

complete -c laporan -n "__fish_seen_subcommand_from preset; and __fish_seen_subcommand_from show apply diff validate" -a "$presets"
complete -c laporan -n "__fish_seen_subcommand_from citations" -a "verify" -d "Verifikasi DOI via Crossref API"
