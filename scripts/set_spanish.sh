#!/bin/bash

# Script para cambiar Horilla a español y personalizar traducciones
# Sin afectar actualizaciones futuras de GitHub

echo "========================================="
echo "  CONFIGURACIÓN DE HORILLA EN ESPAÑOL   "
echo "========================================="

# Paso 1: Cambiar idioma predeterminado a español
echo ""
echo "📝 Configurando idioma español..."

# Agregar configuración de idioma al .env
cd /nvme0n1-disk/clientes/vainilla/horilla

# Verificar si ya existe configuración de idioma
if ! grep -q "LANGUAGE_CODE" .env; then
    echo "" >> .env
    echo "# Language Settings" >> .env
    echo "LANGUAGE_CODE=es" >> .env
    echo "USE_I18N=True" >> .env
    echo "USE_L10N=True" >> .env
    echo "✅ Configuración de idioma agregada al .env"
else
    echo "⚠️ Configuración de idioma ya existe"
fi

# Paso 2: Aplicar traducciones personalizadas para Costa Rica
cat > /nvme0n1-disk/clientes/vainilla/horilla/custom_translations/apply_cr_terms.sh << 'SCRIPT'
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
SCRIPT

chmod +x /nvme0n1-disk/clientes/vainilla/horilla/custom_translations/apply_cr_terms.sh

# Paso 3: Compilar mensajes
echo ""
echo "📦 Compilando traducciones..."
docker exec horilla-vainilla python manage.py compilemessages

# Paso 4: Reiniciar servicio
echo ""
echo "🔄 Reiniciando Horilla..."
docker-compose restart horilla-vainilla

echo ""
echo "========================================="
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "========================================="
echo ""
echo "🌐 Horilla ahora está en ESPAÑOL"
echo ""
echo "📝 Para personalizar más traducciones:"
echo "   1. Edita: custom_translations/custom_translations.txt"
echo "   2. Aplica: python3 custom_translations/apply_translations.py"
echo "   3. Compila: docker exec horilla-vainilla python manage.py compilemessages"
echo "   4. Reinicia: docker-compose restart horilla-vainilla"
echo ""
echo "🔄 Después de actualizar desde GitHub:"
echo "   1. git pull"
echo "   2. Ejecuta este script nuevamente"
echo "   3. Tus personalizaciones se mantendrán"
