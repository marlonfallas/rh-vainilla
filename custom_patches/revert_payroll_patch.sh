#!/bin/bash
# Script para revertir el parche de payroll

ORIGINAL_FILE="/nvme0n1-disk/clientes/vainilla/horilla/horilla_data/payroll/forms/component_forms.py"
BACKUP_DIR=$(dirname $ORIGINAL_FILE)

echo "🔄 Buscando backups disponibles..."
ls -la $BACKUP_DIR/*.backup_* 2>/dev/null

if [ $? -eq 0 ]; then
    echo "Selecciona el backup a restaurar (copia el nombre completo):"
    read -p "Nombre del archivo: " BACKUP_FILE
    
    if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        cp "$BACKUP_DIR/$BACKUP_FILE" "$ORIGINAL_FILE"
        echo "✅ Archivo restaurado desde $BACKUP_FILE"
    else
        echo "❌ Archivo no encontrado"
    fi
else
    echo "❌ No se encontraron backups"
fi
