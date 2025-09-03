#!/bin/bash
# Script de restauración de personalizaciones
# Generado automáticamente el Wed Sep  3 23:16:30 UTC 2025

set -e

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$HORILLA_DIR/horilla_data"
CUSTOM_DIR="$HORILLA_DIR/custom_patches"

echo "=========================================="
echo "  RESTAURANDO PERSONALIZACIONES"
echo "=========================================="

# Restaurar configuraciones
echo "Restaurando configuraciones..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/env_20250903_231630.backup" ]; then
    cp "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/env_20250903_231630.backup" "$HORILLA_DIR/.env"
    echo "✅ .env restaurado"
fi

if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/docker-compose_20250903_231630.backup" ]; then
    cp "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/docker-compose_20250903_231630.backup" "$HORILLA_DIR/docker-compose.yml"
    echo "✅ docker-compose.yml restaurado"
fi

# Restaurar traducciones
echo "Restaurando traducciones..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/custom_translations_20250903_231630.tar.gz" ]; then
    cd "$HORILLA_DIR"
    tar -xzf "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/custom_translations_20250903_231630.tar.gz"
    echo "✅ Traducciones restauradas"
fi

# Aplicar modificaciones de código
echo "Aplicando modificaciones de código..."
if [ -f "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/apply_patch_20250903_231630.sh" ]; then
    chmod +x "/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/apply_patch_20250903_231630.sh"
    "$CUSTOM_DIR/apply_patch_20250903_231630.sh"
fi

# Reiniciar servicios
echo "Reiniciando servicios..."
cd "$HORILLA_DIR"
docker-compose restart

echo "=========================================="
echo "✅ RESTAURACIÓN COMPLETADA"
echo "=========================================="
