#compdef laporan ./laporan

_laporan() {
    local -a commands
    commands=(
        'mcp:Jalankan Model Context Protocol (MCP) Server'
        'build:Kompilasi PDF dan DOCX sekaligus'
        'pdf:Kompilasi dokumen PDF via Typst'
        'docx:Kompilasi dokumen Word (.docx)'
        'init:Wizard inisialisasi dokumen'
        'import:Konversi berkas eksternal ke Markdown'
        'preset:Kelola preset format kampus'
        'stats:Analisis statistik kata dan halaman'
        'audit:Audit forensik stylometri dan anti-AI-slop'
        'citations:Kelola dan verifikasi keabsahan sitasi'
        'doctor:Audit integritas berkas dan dependensi'
        'bundle:Kemas berkas menjadi arsip zip rilis'
        'setup:Pasang dependensi sistem otomatis'
        'sync-hosts:Sinkronkan skill AI agent ke Antigravity/Claude'
        'uninstall:Hapus integrasi skill dari sistem'
        'check:Audit dependensi sistem'
        'test:Jalankan test suite'
        'view:Buka Laporan.pdf di viewer'
        'watch:Pantau berkas dan auto-rebuild'
        'clean:Bersihkan berkas sementara'
        'help:Tampilkan panduan bantuan'
    )

    local -a presets
    presets=(
        'standard:Standar Modern (2-3-2.5-2.5)'
        'skripsi-4433:Standar Skripsi Nasional (4-4-3-3)'
        'ui-skripsi:Universitas Indonesia'
        'itb-ta:Institut Teknologi Bandung'
        'ugm-skripsi:Universitas Gadjah Mada'
        'its-skripsi:Institut Teknologi Sepuluh Nopember'
        'unpad-skripsi:Universitas Padjadjaran'
        'ub-skripsi:Universitas Brawijaya'
        'undip-skripsi:Universitas Diponegoro'
        'unair-skripsi:Universitas Airlangga'
        'ipb-ppki:IPB University (Pedoman PPKI)'
        'telkom-ta:Telkom University'
        'jurnal-uajy:Univ. Atma Jaya Yogyakarta (JBI IEEE)'
        'jurnal-standar:Standar Jurnal Nasional SINTA'
    )

    _arguments -C \
        '1: :->command' \
        '*:: :->args'

    case $state in
        command)
            _describe -t commands 'perintah laporan' commands
            ;;
        args)
            case $words[1] in
                preset)
                    local -a preset_actions
                    preset_actions=(
                        'list:Lihat semua preset kampus'
                        'show:Lihat rincian konfigurasi preset'
                        'apply:Terapkan preset ke metadata.yml'
                        'diff:Bandingkan preset'
                        'validate:Validasi skema preset'
                        'scan:Pindai buku pedoman PDF'
                    )
                    if (( CURRENT == 2 )); then
                        _describe -t preset_actions 'aksi preset' preset_actions
                    elif (( CURRENT >= 3 )); then
                        case $words[2] in
                            show|apply|diff|validate)
                                _describe -t presets 'preset kampus' presets
                                ;;
                            scan)
                                _files -g '*.pdf'
                                ;;
                        esac
                    fi
                    ;;
                citations)
                    if (( CURRENT == 2 )); then
                        local -a cite_actions
                        cite_actions=('verify:Verifikasi keabsahan DOI secara real-time via Crossref')
                        _describe -t cite_actions 'aksi sitasi' cite_actions
                    fi
                    ;;
                import|ingest)
                    _files
                    ;;
            esac
            ;;
    esac
}

_laporan "$@"
