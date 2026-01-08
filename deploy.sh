#!/bin/bash

# 1. Pastikan user memasukkan pesan commit
if [ -z "$1" ]; then
  echo "❌ Error: Harap masukkan pesan commit!"
  echo "Contoh: ./deploy.sh 'Update warna header'"
  exit 1
fi

echo "=== 🚀 MULAI PROSES DEPLOY OTOMATIS ==="

# 2. Add & Commit ke Git dulu (Supaya dapat ID Commit terbaru)
git add .
git commit -m "$1"

# 3. Ambil ID Commit (7 karakter)
TAG=$(git rev-parse --short HEAD)
REGISTRY="100.118.31.124:2612"  # Ganti dengan IP:PORT Anda
IMAGE="web-kantor"

echo "🏷️  Versi Terdeteksi: $TAG"

# 4. Build Image (Pakai TAG tadi)
echo "🍳 Sedang Memasak Image (ARM64)..."
docker build --platform linux/arm64 -t $REGISTRY/$IMAGE:$TAG .

# 5. Push ke Gudang Pi
echo "🚚 Sedang Mengirim ke Gudang..."
docker push $REGISTRY/$IMAGE:$TAG

# 6. Push Code ke GitHub (Memicu Jenkins)
echo "octocat: Memicu Jenkins..."
git push origin main

echo "=== ✅ SELESAI! Check Jenkins Dashboard ==="
