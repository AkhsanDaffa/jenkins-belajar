#!/bin/bash

echo "🔎 Memulai Quality Control..."

# 1. Cek keberadaan file
if [ -f "index.html" ]; then
    echo "✅ File index.html ditemukan."
else
    echo "❌ ERROR: index.html hilang!"
    exit 1 # Kode 1 artinya GAGAL
fi

# 2. Cek isi konten wajib (Validasi)
# Kita cari kata "Jawara" atau "DOCTYPE" di dalam file
if grep -q "Jawara" index.html; then
    echo "✅ Konten valid: Kata 'Jawara' ditemukan."
else
    echo "❌ ERROR: Konten tidak valid! Tidak ada kata 'Jawara'."
    exit 1
fi

echo "🎉 Quality Control LULUS! Siap dideploy."
exit 0