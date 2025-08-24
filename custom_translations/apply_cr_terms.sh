#!/bin/bash

# Términos específicos para Costa Rica
echo "Aplicando términos de Costa Rica..."

# Archivo de traducciones
PO_FILE="/nvme0n1-disk/clientes/vainilla/horilla/horilla_data/horilla/locale/es/LC_MESSAGES/django.po"

# Hacer backup
cp $PO_FILE ${PO_FILE}.backup.$(date +%Y%m%d)

# Función para reemplazar términos
replace_term() {
    local original="$1"
    local new="$2"
    sed -i "s/msgid \"$original\"/msgid \"$original\"\nmsgstr \"$new\"/" $PO_FILE
}

# Aplicar términos locales
# (Aquí puedes agregar más términos específicos)

echo "✅ Términos aplicados"
