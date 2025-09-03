#!/bin/bash

# ==========================================
# VERIFICADOR DE CONFLICTOS PRE-UPDATE
# ==========================================

cd /nvme0n1-disk/clientes/vainilla/horilla/horilla_data

echo "=========================================="
echo "  VERIFICACIÓN DE CONFLICTOS POTENCIALES  "
echo "=========================================="

# Archivos modificados localmente
MODIFIED_FILES=$(git diff --name-only)

if [ -z "$MODIFIED_FILES" ]; then
    echo "✅ No hay archivos modificados localmente"
    exit 0
fi

echo "📋 Archivos modificados localmente:"
echo "$MODIFIED_FILES" | while read file; do
    echo "  📝 $file"
done

echo ""
echo "🔍 Verificando conflictos potenciales con actualizaciones..."

# Verificar si los archivos modificados también han cambiado upstream
for file in $MODIFIED_FILES; do
    if git diff origin/1.0...HEAD --name-only | grep -q "^$file$"; then
        echo "⚠️ POSIBLE CONFLICTO: $file"
        echo "   - Modificado localmente"
        echo "   - También modificado en actualizaciones"
        echo "   - Requerirá merge manual"
        
        echo ""
        echo "   Cambios locales en $file:"
        git diff HEAD "$file" | head -10 | sed 's/^/     /'
        
        echo ""
        echo "   Cambios upstream en $file:"
        git diff HEAD..origin/1.0 "$file" | head -10 | sed 's/^/     /'
        echo ""
    else
        echo "✅ Sin conflicto: $file"
        echo "   - Solo modificado localmente"
    fi
done

echo ""
echo "🔧 RECOMENDACIONES:"
echo "1. Haz backup antes de actualizar"
echo "2. Revisa los cambios mostrados arriba"
echo "3. Si hay conflictos, prepárate para resolver manualmente"
