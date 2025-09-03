#!/bin/bash

# ==========================================
# SISTEMA HÍBRIDO: RESPALDO + GIT
# Version: 3.0 - Combina patches + commits Git
# Autor: Claude AI Assistant
# ==========================================

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
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

git_log() {
    echo -e "${PURPLE}[GIT]${NC} $1"
}

# Configurar Git si es necesario
setup_git() {
    log "Configurando Git..."
    
    cd "$HORILLA_DIR"
    
    # Inicializar repositorio si no existe
    if [ ! -d ".git" ]; then
        git_log "Inicializando repositorio Git..."
        git init
        
        # Configurar usuario si no está configurado
        if ! git config user.name > /dev/null 2>&1; then
            git config user.name "Vainilla CR - Horilla HRMS"
            git config user.email "marlon@vainillacr.com"
            git_log "Usuario Git configurado"
        fi
        
        # Crear .gitignore apropiado
        create_gitignore
        
        # Configurar horilla_data como submodule (futuro)
        setup_horilla_submodule
    fi
    
    success "Git configurado correctamente"
}

create_gitignore() {
    git_log "Creando .gitignore optimizado..."
    
    cat > "$HORILLA_DIR/.gitignore" << 'EOF'
# ==========================================
# HORILLA HRMS - VAINILLA CR
# .gitignore optimizado para personalizaciones
# ==========================================

# Horilla Data (es submodule)
horilla_data/

# Environment Variables (sensitive)
.env
.env.local
.env.*.local

# Database 
*.sql
*.sql.gz  
*.dump
postgres-data/

# Media and Uploads
media/
staticfiles/
static/uploads/

# Python
*.pyc
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
*.egg-info/

# Docker
docker-compose.override.yml

# Backups automáticos (ya están en /sdb-disk/)
*.backup_*
*.bak
backups/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
*.tmp

# SSL Certificates (sensitive)
*.pem
*.key
*.crt
*.csr

# Custom translations backup (redundante)
custom_translations/backup/

# OS
Thumbs.db
.DS_Store

# ==========================================
# INCLUIR EXPLÍCITAMENTE (importantes)
# ==========================================

# Personalizaciones (CRÍTICAS)
!custom_patches/
!custom_patches/**
!custom_translations/
!custom_translations/**
!scripts/
!scripts/**

# Configuraciones (IMPORTANTES)
!docker-compose.yml
!Dockerfile
!requirements-custom.txt

# Documentación (ÚTIL)
!*.md
!docs/
!docs/**
EOF
    
    success ".gitignore creado"
}

setup_horilla_submodule() {
    git_log "Preparando configuración para horilla_data submodule..."
    
    # Crear archivo de instrucciones para futuro
    cat > "$HORILLA_DIR/SETUP_SUBMODULE.md" << 'EOF'
# 🔗 Configurar Horilla como Submodule

## Para convertir horilla_data en submodule (futuro):

```bash
# 1. Respaldar horilla_data actual
mv horilla_data horilla_data_backup

# 2. Agregar como submodule
git submodule add https://github.com/horilla-opensource/horilla.git horilla_data

# 3. Restaurar configuraciones locales
cp horilla_data_backup/entrypoint.sh horilla_data/ 2>/dev/null || true
cp -r horilla_data_backup/staticfiles horilla_data/ 2>/dev/null || true

# 4. Commit cambios
git add .gitmodules horilla_data
git commit -m "Convert horilla_data to submodule"

# 5. Para actualizaciones futuras
git submodule update --remote --merge
```

**Beneficios:**
- ✅ Separación clara código oficial vs personalizado
- ✅ Updates más limpios
- ✅ Control de versión granular
EOF
    
    success "Instrucciones submodule preparadas"
}

# Crear estructura de directorios
setup_dirs() {
    log "Creando estructura de directorios..."
    
    mkdir -p "$CUSTOM_DIR"
    mkdir -p "$BACKUP_DIR" 
    mkdir -p "$HORILLA_DIR/custom_translations"
    mkdir -p "$HORILLA_DIR/custom_config"
    mkdir -p "$HORILLA_DIR/docs"
    
    success "Estructura de directorios creada"
}

# Detectar archivos modificados (IGUAL QUE ANTES)
detect_modifications() {
    log "Detectando modificaciones en el código..."
    
    cd "$DATA_DIR"
    
    echo ""
    echo "===========================================" 
    echo "  ARCHIVOS MODIFICADOS DETECTADOS"
    echo "==========================================="
    
    # Archivos modificados
    MODIFIED_FILES=$(git diff --name-only)
    UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
    
    if [ -n "$MODIFIED_FILES" ]; then
        echo "📝 Archivos modificados:"
        echo "$MODIFIED_FILES" | while read file; do
            echo "   • $file"
            if [ -f "$file" ]; then
                backup_file="$CUSTOM_DIR/${file//\//_}_custom_$TIMESTAMP.py"
                cp "$file" "$backup_file"
                log "Respaldo creado: $(basename $backup_file)"
            fi
        done
        echo ""
        HAS_CHANGES=true
    else
        success "No se detectaron archivos modificados en horilla_data"
        HAS_CHANGES=false
    fi
    
    if [ -n "$UNTRACKED_FILES" ]; then
        echo "📁 Archivos nuevos (no rastreados):"
        echo "$UNTRACKED_FILES" | while read file; do
            echo "   • $file"
            if [ -f "$file" ] && [[ ! "$file" =~ \.backup_ ]]; then
                backup_file="$CUSTOM_DIR/${file//\//_}_new_$TIMESTAMP.py"
                cp "$file" "$backup_file"
                log "Respaldo creado: $(basename $backup_file)"
            fi
        done
        HAS_CHANGES=true
    fi
    
    # Exportar variable para uso en funciones posteriores
    export HAS_CHANGES
}

# Crear patches automáticos (IGUAL QUE ANTES)
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

# Respaldar configuraciones (IGUAL QUE ANTES)
backup_configs() {
    log "Respaldando configuraciones..."
    
    cd "$HORILLA_DIR"
    
    # .env
    if [ -f ".env" ]; then
        cp ".env" "$CUSTOM_DIR/env_$TIMESTAMP.backup"
        log "Respaldo de .env creado"
    fi
    
    # docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        cp "docker-compose.yml" "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup"
        log "Respaldo de docker-compose.yml creado"
    fi
    
    # Dockerfile
    if [ -f "Dockerfile" ]; then
        cp "Dockerfile" "$CUSTOM_DIR/Dockerfile_$TIMESTAMP.backup"
        log "Respaldo de Dockerfile creado"
    fi
    
    # Nginx config (si existe)
    nginx_config="/etc/nginx/sites-available/rh.vainillacr.com"
    if [ -f "$nginx_config" ]; then
        sudo cp "$nginx_config" "$CUSTOM_DIR/nginx_rh_vainillacr_com_$TIMESTAMP.backup" 2>/dev/null || true
        log "Respaldo de configuración Nginx creado"
    fi
}

# Respaldar traducciones personalizadas (IGUAL QUE ANTES)  
backup_translations() {
    log "Respaldando traducciones personalizadas..."
    
    if [ -d "$HORILLA_DIR/custom_translations" ]; then
        tar -czf "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz" -C "$HORILLA_DIR" custom_translations/
        log "Respaldo de traducciones creado"
    fi
}

# NUEVA FUNCIÓN: Commit Git de personalizaciones
commit_to_git() {
    git_log "Iniciando proceso Git..."
    
    cd "$HORILLA_DIR"
    
    # Verificar si hay cambios para commitear
    if ! git diff --quiet || ! git diff --staged --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        
        git_log "Detectados cambios para Git..."
        
        # Agregar archivos importantes al staging
        git_log "Agregando archivos al staging..."
        
        # Personalizaciones críticas
        git add custom_patches/ 2>/dev/null || true
        git add custom_translations/ 2>/dev/null || true  
        git add scripts/ 2>/dev/null || true
        
        # Configuraciones importantes (pero no .env por seguridad)
        git add docker-compose.yml 2>/dev/null || true
        git add Dockerfile 2>/dev/null || true
        
        # Documentación
        git add *.md 2>/dev/null || true
        git add docs/ 2>/dev/null || true
        
        # Verificar que hay algo en staging
        if git diff --staged --quiet; then
            warning "No hay cambios relevantes para commitear"
            return 0
        fi
        
        # Crear mensaje de commit descriptivo
        COMMIT_MSG="🔧 Backup personalizaciones $(date '+%Y-%m-%d %H:%M:%S')

📋 Cambios incluidos:
"
        
        # Agregar detalles de archivos modificados
        STAGED_FILES=$(git diff --staged --name-only)
        if [ -n "$STAGED_FILES" ]; then
            COMMIT_MSG="$COMMIT_MSG
📁 Archivos modificados:
$(echo "$STAGED_FILES" | sed 's/^/- /')"
        fi
        
        # Agregar información de horilla_data si hay cambios
        if [ "$HAS_CHANGES" = "true" ]; then
            COMMIT_MSG="$COMMIT_MSG

🔨 Modificaciones código Horilla:
- Patches creados en custom_patches/
- Scripts de restauración generados
- Respaldos en /sdb-disk/backups/"
        fi
        
        COMMIT_MSG="$COMMIT_MSG

⚡ Respaldo automático ID: $TIMESTAMP
🔧 Sistema: Horilla HRMS - Vainilla CR"
        
        # Hacer el commit
        git_log "Creando commit..."
        git commit -m "$COMMIT_MSG"
        
        # Mostrar información del commit
        COMMIT_HASH=$(git rev-parse --short HEAD)
        success "Git commit creado: $COMMIT_HASH"
        
        # Mostrar resumen del commit
        echo ""
        echo "=========================================="
        echo "  📝 COMMIT CREADO EXITOSAMENTE"
        echo "=========================================="
        echo "🔗 Hash: $COMMIT_HASH"
        echo "📅 Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "📁 Archivos incluidos:"
        echo "$STAGED_FILES" | sed 's/^/   • /'
        echo ""
        
        # Información sobre repositorio remoto
        if git remote -v | grep -q origin; then
            REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "No configurado")
            echo "🔗 Remoto: $REMOTE_URL"
            
            echo ""
            warning "Para sincronizar con repositorio remoto:"
            echo "   git push origin main"
            echo ""
        else
            echo ""
            warning "No hay repositorio remoto configurado."
            echo "   Para configurar GitHub/GitLab:"
            echo "   git remote add origin https://github.com/tu-usuario/horilla-vainilla.git"
            echo "   git push -u origin main"
            echo ""
        fi
        
    else
        success "No hay cambios nuevos para commitear"
    fi
}

# Crear script de restauración (MEJORADO)
create_restore_script() {
    log "Creando script de restauración..."
    
    restore_script="$CUSTOM_DIR/restore_customizations_$TIMESTAMP.sh"
    
    cat > "$restore_script" << EOF
#!/bin/bash
# Script de restauración de personalizaciones
# Generado automáticamente el $(date)
# Git commit: $(cd "$HORILLA_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "No disponible")

set -e

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="\$HORILLA_DIR/horilla_data"
CUSTOM_DIR="\$HORILLA_DIR/custom_patches"

echo "=========================================="
echo "  RESTAURANDO PERSONALIZACIONES"
echo "=========================================="
echo "🔧 Respaldo ID: $TIMESTAMP"
echo "📅 Creado: $(date)"
echo ""

# Restaurar configuraciones
echo "📋 Restaurando configuraciones..."
if [ -f "$CUSTOM_DIR/env_$TIMESTAMP.backup" ]; then
    cp "$CUSTOM_DIR/env_$TIMESTAMP.backup" "\$HORILLA_DIR/.env"
    echo "✅ .env restaurado"
fi

if [ -f "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup" ]; then
    cp "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup" "\$HORILLA_DIR/docker-compose.yml"
    echo "✅ docker-compose.yml restaurado"
fi

# Restaurar traducciones
echo "🌍 Restaurando traducciones..."
if [ -f "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz" ]; then
    cd "\$HORILLA_DIR"
    tar -xzf "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz"
    echo "✅ Traducciones restauradas"
fi

# Aplicar modificaciones de código
echo "🔨 Aplicando modificaciones de código..."
if [ -f "$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh" ]; then
    chmod +x "$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh"
    "\$CUSTOM_DIR/apply_patch_$TIMESTAMP.sh"
fi

# Aplicar traducciones personalizadas
echo "🇨🇷 Aplicando traducciones Costa Rica..."
if [ -f "\$HORILLA_DIR/custom_translations/apply_translations.py" ]; then
    cd "\$HORILLA_DIR"
    python3 custom_translations/apply_translations.py
    echo "✅ Traducciones Costa Rica aplicadas"
fi

# Reiniciar servicios
echo "🔄 Reiniciando servicios..."
cd "\$HORILLA_DIR"
docker-compose restart

echo ""
echo "=========================================="
echo "✅ RESTAURACIÓN COMPLETADA"
echo "=========================================="
echo "🌐 Verificar: https://rh.vainillacr.com"
echo "📋 Logs: docker logs horilla-vainilla -f"
echo "🔧 Status: ./scripts/status.sh"
EOF
    
    chmod +x "$restore_script"
    success "Script de restauración mejorado creado: $(basename $restore_script)"
}

# Documentar cambios (MEJORADO CON INFO GIT)
document_changes() {
    log "Documentando cambios..."
    
    doc_file="$CUSTOM_DIR/CUSTOMIZATIONS_$TIMESTAMP.md"
    
    # Obtener información Git
    cd "$HORILLA_DIR"
    CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "No disponible")
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "No disponible")
    
    cat > "$doc_file" << EOF
# 📋 PERSONALIZACIONES HORILLA - $(date)

## 📊 Información General

- **🕒 Timestamp**: $TIMESTAMP
- **📅 Fecha**: $(date)
- **🔗 Git Commit**: $CURRENT_COMMIT
- **🌿 Git Branch**: $CURRENT_BRANCH
- **🏢 Cliente**: Vainilla CR
- **⚙️ Sistema**: Horilla HRMS

## 🔍 Resumen de Cambios

### Archivos Modificados en horilla_data:
$(cd "$DATA_DIR" && git diff --name-only 2>/dev/null | sed 's/^/- /' || echo "Ninguno")

### Archivos Nuevos en horilla_data:
$(cd "$DATA_DIR" && git ls-files --others --exclude-standard 2>/dev/null | grep -v "\.backup_" | sed 's/^/- /' || echo "Ninguno")

### Personalizaciones en Repositorio Principal:
$(cd "$HORILLA_DIR" && git diff --staged --name-only 2>/dev/null | sed 's/^/- /' || echo "Ninguno")

## 🛠️ Detalles de Modificaciones

### 1. Archivos de Código (horilla_data)
EOF
    
    # Agregar detalles de cada archivo modificado
    cd "$DATA_DIR"
    MODIFIED_FILES=$(git diff --name-only 2>/dev/null || true)
    if [ -n "$MODIFIED_FILES" ]; then
        echo "$MODIFIED_FILES" | while read file; do
            if [ -f "$file" ]; then
                echo "" >> "$doc_file"
                echo "#### $file" >> "$doc_file"
                echo '```diff' >> "$doc_file"
                git diff "$file" 2>/dev/null | head -30 >> "$doc_file" || echo "Error obteniendo diff" >> "$doc_file"
                echo '```' >> "$doc_file"
            fi
        done
    else
        echo "No hay modificaciones en horilla_data" >> "$doc_file"
    fi
    
    cat >> "$doc_file" << EOF

### 2. Configuraciones Docker

$([ -f "$CUSTOM_DIR/docker-compose_$TIMESTAMP.backup" ] && echo "✅ docker-compose.yml respaldado" || echo "❌ No modificado")
$([ -f "$CUSTOM_DIR/Dockerfile_$TIMESTAMP.backup" ] && echo "✅ Dockerfile respaldado" || echo "❌ No modificado")  
$([ -f "$CUSTOM_DIR/env_$TIMESTAMP.backup" ] && echo "✅ .env respaldado" || echo "❌ No modificado")

### 3. Traducciones Personalizadas

$([ -f "$CUSTOM_DIR/custom_translations_$TIMESTAMP.tar.gz" ] && echo "✅ Traducciones Costa Rica respaldadas" || echo "❌ No modificadas")

## 📁 Archivos de Respaldo Creados

- **Patches**: \`custom_patches/modifications_$TIMESTAMP.patch\`
- **Script restauración**: \`custom_patches/restore_customizations_$TIMESTAMP.sh\`
- **Traducciones**: \`custom_patches/custom_translations_$TIMESTAMP.tar.gz\`
- **Configuraciones**: \`custom_patches/*_$TIMESTAMP.backup\`
- **Git Commit**: $CURRENT_COMMIT

## 🔄 Proceso de Restauración

### Después de actualización de Horilla:
\`\`\`bash
./custom_patches/restore_customizations_$TIMESTAMP.sh
\`\`\`

### Rollback completo (si es necesario):
\`\`\`bash
# Volver al commit anterior
git reset --hard HEAD~1

# O usar respaldo específico
./custom_patches/restore_customizations_$TIMESTAMP.sh
\`\`\`

## 📊 Git Information

- **Repository**: $(cd "$HORILLA_DIR" && git remote get-url origin 2>/dev/null || echo "Local repository")
- **Branch**: $CURRENT_BRANCH
- **Commit**: $CURRENT_COMMIT
- **Status**: $(cd "$HORILLA_DIR" && git status --porcelain | wc -l) archivos modificados

## ⚠️ Notas Importantes

- ✅ **Sistema híbrido**: Combina patches + Git commits
- ✅ **Doble respaldo**: Local (/sdb-disk/) + Git history
- ✅ **Restauración automática**: Scripts listos para usar
- ✅ **Compatible actualizaciones**: Preserva personalizaciones
- ⚠️ **Archivo .env**: No incluido en Git por seguridad

## 📞 Contacto

- **Sistema**: Horilla HRMS
- **Cliente**: Vainilla CR  
- **Fecha**: $(date)
- **Respaldo**: $TIMESTAMP
- **Git**: $CURRENT_COMMIT
EOF
    
    success "Documentación completa creada: $(basename $doc_file)"
}

# Crear respaldo completo en disco de backup (IGUAL QUE ANTES)
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

# Función principal MEJORADA
main() {
    echo ""
    echo "=========================================="
    echo "  SISTEMA HÍBRIDO: RESPALDO + GIT"
    echo "=========================================="
    echo "🔧 Patches automáticos + Git commits"
    echo "📅 $(date)"
    echo ""
    
    setup_dirs
    setup_git
    detect_modifications
    create_patches
    backup_configs
    backup_translations
    create_restore_script
    document_changes
    create_full_backup
    
    # NUEVO: Commit a Git
    commit_to_git
    
    echo ""
    echo "=========================================="
    echo "✅ RESPALDO HÍBRIDO COMPLETADO"
    echo "=========================================="
    echo ""
    echo "📁 **Respaldos locales:**"
    echo "   📂 Patches: $CUSTOM_DIR"
    echo "   💾 Completo: $BACKUP_DIR/customizations_$TIMESTAMP.tar.gz"
    echo "   📋 Docs: $CUSTOM_DIR/CUSTOMIZATIONS_$TIMESTAMP.md"
    echo ""
    echo "🔗 **Git commits:**"
    cd "$HORILLA_DIR"
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "No disponible")
    echo "   🔗 Hash: $COMMIT_HASH"
    echo "   🌿 Branch: $(git branch --show-current 2>/dev/null || echo "No disponible")"
    echo ""
    echo "🚀 **Para usar:**"
    echo "   🔄 Restaurar: ./custom_patches/restore_customizations_$TIMESTAMP.sh"
    echo "   📊 Estado Git: git status"
    echo "   📋 Log Git: git log --oneline -5"
    echo ""
    
    if git remote -v | grep -q origin; then
        echo "☁️ **Sincronizar con remoto:**"
        echo "   git push origin $(git branch --show-current 2>/dev/null || echo "main")"
    else
        echo "⚙️ **Configurar repositorio remoto:**"
        echo "   git remote add origin https://github.com/tu-usuario/horilla-vainilla.git"
        echo "   git push -u origin main"
    fi
    echo ""
}

# Ejecutar función principal
main "$@"
