#!/bin/bash
# Script de restauración de personalizaciones
# Generado automáticamente el Wed Sep  3 23:20:01 UTC 2025
# Git commit: 34fb73c

set -e

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$HORILLA_DIR/horilla_data"
CUSTOM_DIR="$HORILLA_DIR/custom_patches"

echo "=========================================="
echo "  RESTAURANDO PERSONALIZACIONES"
echo "=========================================="
echo "🔧 Respaldo ID: 20250903_232001"
echo "📅 Creado: Wed Sep  3 23:20:01 UTC 2025"
echo ""

# Restaurar configuraciones
echo "📋 Restaurando configuraciones..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/env_20250903_232001.backup" ]; then
    cp "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/env_20250903_232001.backup" "$HORILLA_DIR/.env"
    echo "✅ .env restaurado"
fi

if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/docker-compose_20250903_232001.backup" ]; then
    cp "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/docker-compose_20250903_232001.backup" "$HORILLA_DIR/docker-compose.yml"
    echo "✅ docker-compose.yml restaurado"
fi

# Restaurar traducciones
echo "🌍 Restaurando traducciones..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/custom_translations_20250903_232001.tar.gz" ]; then
    cd "$HORILLA_DIR"
    tar -xzf "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/custom_translations_20250903_232001.tar.gz"
    echo "✅ Traducciones restauradas"
fi

# Aplicar modificaciones de código
echo "🔨 Aplicando modificaciones de código..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/apply_patch_20250903_232001.sh" ]; then
    chmod +x "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/apply_patch_20250903_232001.sh"
    "$CUSTOM_DIR/apply_patch_20250903_232001.sh"
fi

# Aplicar traducciones personalizadas
echo "🇨🇷 Aplicando traducciones Costa Rica..."
if [ -f "$HORILLA_DIR/custom_translations/apply_translations.py" ]; then
    cd "$HORILLA_DIR"
    python3 custom_translations/apply_translations.py
    echo "✅ Traducciones Costa Rica aplicadas"
fi

# Reiniciar servicios
echo "🔄 Reiniciando servicios..."
cd "$HORILLA_DIR"
docker-compose restart

echo ""
echo "=========================================="
echo "✅ RESTAURACIÓN COMPLETADA"
echo "=========================================="
echo "🌐 Verificar: https://rh.vainillacr.com"
echo "📋 Logs: docker logs horilla-vainilla -f"
echo "🔧 Status: ./scripts/status.sh"
