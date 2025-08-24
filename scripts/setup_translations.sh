#!/bin/bash
# Script para personalizar traducciones de Horilla
# Mantiene las personalizaciones separadas de los archivos originales

# Directorio base
BASE_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
LOCALE_DIR="$BASE_DIR/horilla_data/horilla/locale"
CUSTOM_DIR="$BASE_DIR/custom_translations"

# Crear directorio para traducciones personalizadas
mkdir -p $CUSTOM_DIR/es/LC_MESSAGES
mkdir -p $CUSTOM_DIR/backup

echo "==================================="
echo "  PERSONALIZACIÓN DE TRADUCCIONES  "
echo "==================================="

# Hacer backup del archivo original
if [ -f "$LOCALE_DIR/es/LC_MESSAGES/django.po" ]; then
    cp "$LOCALE_DIR/es/LC_MESSAGES/django.po" "$CUSTOM_DIR/backup/django.po.original.$(date +%Y%m%d)"
    echo "✅ Backup creado"
fi

# Crear archivo de traducciones personalizadas
cat > $CUSTOM_DIR/custom_translations.txt << 'EOF'
# TRADUCCIONES PERSONALIZADAS PARA VAINILLA
# ==========================================
# Formato: ORIGINAL|PERSONALIZADO

# Términos de RRHH
Allowance|Bonificación
Deduction|Deducción
Reimbursement|Reembolso
Leave|Vacaciones
Attendance|Asistencia
Payroll|Planilla
Employee|Colaborador
Shift|Turno
Department|Departamento
Badge ID|Código de Empleado

# Términos financieros
Basic Pay|Salario Base
Gross Pay|Salario Bruto
Net Pay|Salario Neto
Encashment|Liquidación
Loan|Préstamo
Advanced Salary|Adelanto de Salario

# Términos específicos de Costa Rica
Tax|Impuesto sobre la Renta
Insurance|CCSS
Overtime|Horas Extra
Bonus|Aguinaldo
Commission|Comisión

EOF

echo "✅ Archivo de traducciones personalizadas creado"

# Crear script de aplicación
cat > $CUSTOM_DIR/apply_translations.py << 'EOF'
#!/usr/bin/env python3
"""
Script para aplicar traducciones personalizadas a Horilla
Mantiene compatibilidad con actualizaciones de GitHub
"""

import os
import re
import shutil
from datetime import datetime

def apply_custom_translations():
    base_dir = "/nvme0n1-disk/clientes/vainilla/horilla"
    po_file = f"{base_dir}/horilla_data/horilla/locale/es/LC_MESSAGES/django.po"
    custom_file = f"{base_dir}/custom_translations/custom_translations.txt"
    
    # Leer traducciones personalizadas
    translations = {}
    with open(custom_file, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip() and not line.startswith('#') and '|' in line:
                original, custom = line.strip().split('|')
                translations[original] = custom
    
    # Hacer backup
    backup_file = f"{base_dir}/custom_translations/backup/django.po.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(po_file, backup_file)
    
    # Aplicar traducciones
    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for original, custom in translations.items():
        # Buscar y reemplazar en el archivo .po
        pattern = f'msgid "{original}"\\nmsgstr ".*?"'
        replacement = f'msgid "{original}"\\nmsgstr "{custom}"'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Guardar cambios
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Traducciones aplicadas: {len(translations)} términos")
    print(f"📁 Backup guardado en: {backup_file}")

if __name__ == "__main__":
    apply_custom_translations()
EOF

chmod +x $CUSTOM_DIR/apply_translations.py

echo ""
echo "✅ Sistema de traducciones personalizado creado"
echo ""
echo "📝 Para personalizar traducciones:"
echo "   1. Edita: $CUSTOM_DIR/custom_translations.txt"
echo "   2. Ejecuta: python3 $CUSTOM_DIR/apply_translations.py"
echo "   3. Reinicia: docker-compose restart horilla-vainilla"
echo ""
echo "🔄 Para restaurar después de actualización:"
echo "   1. git pull (actualiza el código)"
echo "   2. python3 $CUSTOM_DIR/apply_translations.py"
echo "   3. docker-compose restart horilla-vainilla"
