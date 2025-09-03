#!/bin/bash

# ==========================================
# SISTEMA DE RESPALDO DE PERSONALIZACIONES
# Version: 2.0
# Autor: Claude AI Assistant
# ==========================================

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Rutas
HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$HORILLA_DIR/horilla_data"
CUSTOM_DIR="$HORILLA_DIR/custom_patches"
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla/customizations"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Crear estructura de directorios
setup_dirs() {
    log "Creando estructura de directorios..."
    
    mkdir -p "$CUSTOM_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$HORILLA_DIR/custom_translations"
    mkdir -p "$HORILLA_DIR/custom_config"
    
    success "Estructura de directorios creada"
}

# Detectar archivos modificados
detect_modifications() {
    log "Detectando modificaciones en el código..."
    
    cd "$DATA_DIR"
    
    echo ""
    echo "===========================================" 
    echo "  ARCHIVOS MODIFICADOS DETECTADOS"
    echo "==========================================="
    
    # Archivos modificados
    MODIFIED_FILES=$(git diff --name-only)
    
    if [ -n "$MODIFIED_FILES" ]; then
        echo "📝 Archivos modificados:"
        echo "$MODIFIED_FILES" | while read file; do
            echo "   • $file"
        done
        echo ""
        
        # Crear respaldo de cada archivo modificado
        echo "$MODIFIED_FILES" | while read file; do
            if [ -f "$file" ]; then
                backup_file="$CUSTOM_DIR/${file//\//_}_custom_$TIMESTAMP.py"
                cp "$file" "$backup_file"
                log "Respaldo creado: $(basename $backup_file)"
            fi
        done
    else
        success "No se detectaron archivos modificados"
    fi
    
    # Archivos no rastreados (untracked)
    UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
    
    if [ -n "$UNTRACKED_FILES" ]; then
        echo "📁 Archivos nuevos (no rastreados):"
        echo "$UNTRACKED_FILES" | while read file; do
            echo "   • $file"
        done
        echo ""
        
        # Respaldar archivos no rastreados que no sean backups
        echo "$UNTRACKED_FILES" | while read file; do
            if [ -f "$file" ] && [[ ! "$file" =~ \.backup_ ]]; then
                backup_file="$CUSTOM_DIR/${file//\//_}_new_$TIMESTAMP.py"
                cp "$file" "$backup_file"
                log "Respaldo creado: $(basename $backup_file)"
            fi
        done
    fi
}

# Crear patches automáticos
create_patches() {
    log "Creando patches de diferencias..."
    
    cd "$DATA_DIR"
    
    MODIFIED_FILES=$(git diff --name-only)
    
    if [ -n "$MODIFIED_FILES" ]; then
        patch_file="$CUSTOM_DIR/modifications_$TIMESTAMP.patch"
        git diff > "$patch_file"
        
        success "Patch creado: $(basename $patch_file)"
        
        # Crear script de aplicación del patch
        apply_script="$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh"
        
        cat > "$apply_script" << EOF
#!/bin/bash
# Script generado automáticamente para aplicar modificaciones personalizadas
# Fecha: $(date)

echo "Aplicando modificaciones personalizadas..."

cd "$DATA_DIR"

# Aplicar patch
if patch --dry-run -p1 < "$patch_file" > /dev/null 2>&1; then
    patch -p1 < "$patch_file"
    echo "✅ Modificaciones aplicadas exitosamente"
else
    echo "❌ Error aplicando modificaciones - revisar manualmente"
    exit 1
fi
EOF
        
        chmod +x "$apply_script"
        success "Script de aplicación creado: $(basename $apply_script)"
    fi
}

# Respaldar configuraciones
backup_configs() {
    log "Respaldando configuraciones..."
    
    # .env
    if [ -f "$HORILLA_DIR/.env" ]; then
        cp "$HORILLA_DIR/.env" "$CUSTOM_DIR/env_$TIMESTAMP.backup"
        log "Respaldo de .env creado"
    fi
    
    # docker-compose.yml
    if [ -f "$HORILLA_DIR/docker-compose.yml" ]; then
        cp "$HORILLA_DIR/docker-compose.yml" "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup"
        log "Respaldo de docker-compose.yml creado"
    fi
    
    # Dockerfile
    if [ -f "$HORILLA_DIR/Dockerfile" ]; then
        cp "$HORILLA_DIR/Dockerfile" "$CUSTOM_DIR/Dockerfile_$TIMESTAMP.backup"
        log "Respaldo de Dockerfile creado"
    fi
    
    # Nginx config (si existe)
    nginx_config="/etc/nginx/sites-available/rh.vainillacr.com"
    if [ -f "$nginx_config" ]; then
        cp "$nginx_config" "$CUSTOM_DIR/nginx_rh_vainillacr_com_$TIMESTAMP.backup" 2>/dev/null || true
        log "Respaldo de configuración Nginx creado"
    fi
}

# Respaldar traducciones personalizadas
backup_translations() {
    log "Respaldando traducciones personalizadas..."
    
    if [ -d "$HORILLA_DIR/custom_translations" ]; then
        tar -czf "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz" -C "$HORILLA_DIR" custom_translations/
        log "Respaldo de traducciones creado"
    fi
}

# Crear script de restauración
create_restore_script() {
    log "Creando script de restauración..."
    
    restore_script="$CUSTOM_DIR/restore_customizations_$TIMESTAMP.sh"
    
    cat > "$restore_script" << EOF
#!/bin/bash
# Script de restauración de personalizaciones
# Generado automáticamente el $(date)

set -e

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="\$HORILLA_DIR/horilla_data"
CUSTOM_DIR="\$HORILLA_DIR/custom_patches"

echo "=========================================="
echo "  RESTAURANDO PERSONALIZACIONES"
echo "=========================================="

# Restaurar configuraciones
echo "Restaurando configuraciones..."
if [ -f "$CUSTOM_DIR/env_$TIMESTAMP.backup" ]; then
    cp "$CUSTOM_DIR/env_$TIMESTAMP.backup" "\$HORILLA_DIR/.env"
    echo "✅ .env restaurado"
fi

if [ -f "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup" ]; then
    cp "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup" "\$HORILLA_DIR/docker-compose.yml"
    echo "✅ docker-compose.yml restaurado"
fi

# Restaurar traducciones
echo "Restaurando traducciones..."
if [ -f "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz" ]; then
    cd "\$HORILLA_DIR"
    tar -xzf "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz"
    echo "✅ Traducciones restauradas"
fi

# Aplicar modificaciones de código
echo "Aplicando modificaciones de código..."
if [ -f "$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh" ]; then
    chmod +x "$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh"
    "\$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh"
fi

# Reiniciar servicios
echo "Reiniciando servicios..."
cd "\$HORILLA_DIR"
docker-compose restart

echo "=========================================="
echo "✅ RESTAURACIÓN COMPLETADA"
echo "=========================================="
EOF
    
    chmod +x "$restore_script"
    success "Script de restauración creado: $(basename $restore_script)"
}

# Documentar cambios
document_changes() {
    log "Documentando cambios..."
    
    doc_file="$CUSTOM_DIR/CUSTOMIZATIONS_$TIMESTAMP.md"
    
    cat > "$doc_file" << EOF
# 📋 PERSONALIZACIONES HORILLA - $(date)

## 🔍 Resumen de Cambios

### Archivos Modificados:
$(cd "$DATA_DIR" && git diff --name-only | sed 's/^/- /')

### Archivos Nuevos:
$(cd "$DATA_DIR" && git ls-files --others --exclude-standard | grep -v "\.backup_" | sed 's/^/- /' || echo "Ninguno")

## 🛠️ Detalles de Modificaciones

### 1. Archivos de Código
EOF
    
    # Agregar detalles de cada archivo modificado
    cd "$DATA_DIR"
    git diff --name-only | while read file; do
        if [ -f "$file" ]; then
            echo "" >> "$doc_file"
            echo "#### $file" >> "$doc_file"
            echo '```diff' >> "$doc_file"
            git diff "$file" | head -30 >> "$doc_file"
            echo '```' >> "$doc_file"
        fi
    done
    
    cat >> "$doc_file" << EOF

## 📁 Archivos de Respaldo Creados

- Configuraciones: \`custom_patches/\`
- Patches: \`custom_patches/modifications_$TIMESTAMP.patch\`
- Script de restauración: \`custom_patches/restore_customizations_$TIMESTAMP.sh\`
- Traducciones: \`custom_patches/custom_translations_$TIMESTAMP.tar.gz\`

## 🔄 Proceso de Restauración

1. Ejecutar después de actualización:
   \`\`\`bash
   ./custom_patches/restore_customizations_$TIMESTAMP.sh
   \`\`\`

2. Verificar funcionamiento:
   \`\`\`bash
   ./scripts/status.sh
   \`\`\`

## ⚠️ Notas Importantes

- Estas modificaciones son específicas para Vainilla CR
- Deben reaplicarse después de cada actualización de Horilla
- Los archivos de respaldo se mantienen para referencia histórica

## 📞 Contacto

- **Sistema**: Horilla HRMS
- **Cliente**: Vainilla CR
- **Fecha**: $(date)
- **Respaldo**: $TIMESTAMP
EOF
    
    success "Documentación creada: $(basename $doc_file)"
}

# Crear respaldo completo en disco de backup
create_full_backup() {
    log "Creando respaldo completo..."
    
    backup_full_dir="$BACKUP_DIR/customizations_$TIMESTAMP"
    mkdir -p "$backup_full_dir"
    
    # Copiar todo el directorio custom_patches
    cp -r "$CUSTOM_DIR"/* "$backup_full_dir/"
    
    # Crear tar.gz del respaldo
    cd "$BACKUP_DIR"
    tar -czf "customizations_$TIMESTAMP.tar.gz" "customizations_$TIMESTAMP/"
    
    success "Respaldo completo creado en: $backup_full_dir"
}

# Función principal
main() {
    echo ""
    echo "=========================================="
    echo "  RESPALDO DE PERSONALIZACIONES HORILLA"
    echo "=========================================="
    echo ""
    
    setup_dirs
    detect_modifications
    create_patches
    backup_configs
    backup_translations
    create_restore_script
    document_changes
    create_full_backup
    
    echo ""
    echo "=========================================="
    echo "✅ RESPALDO COMPLETADO EXITOSAMENTE"
    echo "=========================================="
    echo ""
    echo "📁 Ubicación: $CUSTOM_DIR"
    echo "💾 Respaldo completo: $BACKUP_DIR/customizations_$TIMESTAMP.tar.gz"
    echo "📋 Documentación: $CUSTOM_DIR/CUSTOMIZATIONS_$TIMESTAMP.md"
    echo "🔄 Restauración: $CUSTOM_DIR/restore_customizations_$TIMESTAMP.sh"
    echo ""
    echo "🚀 Para restaurar después de actualización:"
    echo "   ./custom_patches/restore_customizations_$TIMESTAMP.sh"
    echo ""
}

# Ejecutar función principal
main "$@"
