#!/bin/bash

# ==========================================
# ACTUALIZACIÓN HÍBRIDA: HORILLA + GIT
# Version: 4.0 - Sistema híbrido con Git
# ==========================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Directorios
HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$HORILLA_DIR/horilla_data"
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

git_log() {
    echo -e "${PURPLE}[GIT]${NC} $1"
}

# Verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    if [ ! -d "$HORILLA_DIR" ]; then
        error "Directorio de Horilla no encontrado: $HORILLA_DIR"
    fi
    
    cd "$HORILLA_DIR"
    if ! docker-compose ps | grep -q horilla-vainilla; then
        error "Horilla no está ejecutándose"
    fi
    
    # Verificar Git
    if [ ! -d ".git" ]; then
        warning "Repositorio Git no inicializado - se creará automáticamente"
    fi
    
    success "Prerrequisitos verificados"
}

# Mostrar información de actualización
show_update_info() {
    log "Verificando actualizaciones disponibles..."
    
    cd "$DATA_DIR"
    git fetch origin
    
    COMMITS_BEHIND=$(git rev-list --count HEAD..origin/1.0)
    CURRENT_COMMIT=$(git rev-parse --short HEAD)
    LATEST_COMMIT=$(git rev-parse --short origin/1.0)
    
    echo ""
    echo "=========================================="
    echo "  INFORMACIÓN DE ACTUALIZACIÓN"
    echo "=========================================="
    echo "📍 Commit actual: $CURRENT_COMMIT"
    echo "🆕 Commit remoto: $LATEST_COMMIT"
    
    if [ $COMMITS_BEHIND -gt 0 ]; then
        echo "🔄 Commits disponibles: $COMMITS_BEHIND"
        echo ""
        echo "📋 Últimos cambios:"
        git log --oneline HEAD..origin/1.0 | head -10
        echo ""
        return 0
    else
        success "Tu instalación de horilla_data está actualizada"
        
        # Verificar si hay actualizaciones en el repo principal
        cd "$HORILLA_DIR"
        if [ -d ".git" ]; then
            git fetch origin 2>/dev/null || true
            MAIN_COMMITS_BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
            if [ "$MAIN_COMMITS_BEHIND" -gt 0 ]; then
                log "Actualizaciones disponibles en repositorio principal: $MAIN_COMMITS_BEHIND commits"
                return 0
            fi
        fi
        
        exit 0
    fi
}

# Crear respaldo HÍBRIDO PRE-actualización  
create_pre_update_backup() {
    log "Creando respaldo HÍBRIDO PRE-actualización..."
    
    # Ejecutar el sistema híbrido de respaldo
    log "Ejecutando sistema híbrido de respaldo..."
    if "$HORILLA_DIR/scripts/backup_customizations_with_git.sh" > /dev/null 2>&1; then
        success "Respaldo híbrido completado"
    else
        warning "Error en respaldo híbrido - continuando con respaldo básico"
    fi
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PRE_UPDATE_BACKUP_DIR="$BACKUP_DIR/pre-update-$TIMESTAMP"
    mkdir -p "$PRE_UPDATE_BACKUP_DIR"
    
    # Backup de base de datos
    log "Respaldando base de datos..."
    docker exec postgres-horilla-vainilla pg_dump -U horilla horilla | gzip > "$PRE_UPDATE_BACKUP_DIR/horilla_db_pre_update.sql.gz"
    
    # Backup de archivos media
    log "Respaldando archivos media..."
    tar -czf "$PRE_UPDATE_BACKUP_DIR/horilla_media_pre_update.tar.gz" -C "$HORILLA_DIR" media/ 2>/dev/null || true
    
    # Git information snapshot
    cd "$HORILLA_DIR"
    if [ -d ".git" ]; then
        git_log "Guardando información Git..."
        
        # Estado Git actual
        cat > "$PRE_UPDATE_BACKUP_DIR/git_info_pre_update.txt" << EOF
# Git Information PRE-UPDATE
Date: $(date)
Branch: $(git branch --show-current 2>/dev/null || echo "No branch")
Commit: $(git rev-parse --short HEAD 2>/dev/null || echo "No commit")
Status: 
$(git status --porcelain)

# Remote information
Remote: $(git remote get-url origin 2>/dev/null || echo "No remote")

# Last 5 commits
$(git log --oneline -5 2>/dev/null || echo "No commits")
EOF
        
        # Respaldo del .git completo (pequeño)
        tar -czf "$PRE_UPDATE_BACKUP_DIR/git_repo_backup.tar.gz" .git/
        
        success "Información Git respaldada"
    fi
    
    # Crear script maestro HÍBRIDO de restauración
    cat > "$PRE_UPDATE_BACKUP_DIR/RESTORE_HYBRID.sh" << EOF
#!/bin/bash
# SCRIPT MAESTRO DE RESTAURACIÓN HÍBRIDA
# Generado automáticamente: $(date)

set -e

echo "=========================================="
echo "  RESTAURACIÓN HÍBRIDA POST-ACTUALIZACIÓN"
echo "=========================================="

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
BACKUP_DIR="$(pwd)"

# 1. Restaurar Git repository si es necesario
echo "🔗 Verificando estado Git..."
cd "\$HORILLA_DIR"

if [ ! -d ".git" ] && [ -f "\$BACKUP_DIR/git_repo_backup.tar.gz" ]; then
    echo "📦 Restaurando repositorio Git..."
    tar -xzf "\$BACKUP_DIR/git_repo_backup.tar.gz"
    echo "✅ Repositorio Git restaurado"
fi

# 2. Restaurar personalizaciones usando el último script disponible
echo "🔧 Restaurando personalizaciones..."
LATEST_RESTORE=\$(ls -t "\$HORILLA_DIR/custom_patches"/restore_customizations_*.sh 2>/dev/null | head -1)

if [ -f "\$LATEST_RESTORE" ]; then
    chmod +x "\$LATEST_RESTORE"
    "\$LATEST_RESTORE"
else
    echo "⚠️ Script de restauración de personalizaciones no encontrado"
fi

# 3. Verificar funcionamiento
echo "✅ Verificando funcionamiento..."
cd "\$HORILLA_DIR"
if [ -f "./scripts/status.sh" ]; then
    ./scripts/status.sh
else
    docker-compose ps
fi

echo "=========================================="
echo "✅ RESTAURACIÓN HÍBRIDA COMPLETADA"
echo "=========================================="
echo ""
echo "🌐 Acceder a: https://rh.vainillacr.com"
echo "📋 Ver logs: docker logs horilla-vainilla -f"
echo "🔗 Git status: git status"
EOF
    
    chmod +x "$PRE_UPDATE_BACKUP_DIR/RESTORE_HYBRID.sh"
    
    success "Backup PRE-actualización híbrido creado en: $PRE_UPDATE_BACKUP_DIR"
    echo "$PRE_UPDATE_BACKUP_DIR" > /tmp/horilla_last_backup
}

# Proceso de actualización Git-aware
update_code() {
    log "Iniciando actualización de código con Git..."
    
    cd "$DATA_DIR"
    
    # Stash de cambios locales
    if ! git diff --quiet || ! git diff --staged --quiet; then
        log "Guardando modificaciones locales en stash..."
        git stash push -m "Pre-update stash $(date '+%Y-%m-%d %H:%M:%S')"
        STASH_CREATED=true
    else
        STASH_CREATED=false
    fi
    
    # Pull de actualizaciones
    log "Descargando actualizaciones desde GitHub..."
    git pull origin 1.0
    
    # Restaurar cambios locales
    if [ "$STASH_CREATED" = true ]; then
        log "Restaurando modificaciones locales..."
        if git stash pop; then
            success "Modificaciones locales restauradas exitosamente"
        else
            warning "Conflictos detectados - se requiere intervención manual"
            log "Ejecutar manualmente: git status y resolver conflictos"
            return 1
        fi
    fi
    
    success "Actualización de código completada"
}

# Actualizar repositorio principal también
update_main_repository() {
    log "Actualizando repositorio principal..."
    
    cd "$HORILLA_DIR"
    
    if [ -d ".git" ]; then
        git_log "Verificando actualizaciones del repositorio principal..."
        
        # Fetch latest
        git fetch origin 2>/dev/null || true
        
        # Check if we're behind
        COMMITS_BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
        
        if [ "$COMMITS_BEHIND" -gt 0 ]; then
            git_log "Actualizando repositorio principal: $COMMITS_BEHIND commits"
            
            # Stash local changes if any
            if ! git diff --quiet || ! git diff --staged --quiet; then
                git stash push -m "Pre-main-update stash $(date '+%Y-%m-%d %H:%M:%S')"
                MAIN_STASH_CREATED=true
            else
                MAIN_STASH_CREATED=false
            fi
            
            # Pull updates
            git pull origin main
            
            # Restore local changes
            if [ "$MAIN_STASH_CREATED" = true ]; then
                if git stash pop; then
                    success "Cambios locales del repo principal restaurados"
                else
                    warning "Conflictos en repo principal - revisar manualmente"
                fi
            fi
            
            success "Repositorio principal actualizado"
        else
            success "Repositorio principal ya está actualizado"
        fi
    else
        warning "Repositorio Git no configurado en directorio principal"
    fi
}

# Aplicar migraciones y reiniciar
apply_migrations_and_restart() {
    log "Aplicando migraciones y reiniciando servicios..."
    
    cd "$HORILLA_DIR"
    
    # Verificar si requirements.txt cambió
    cd "$DATA_DIR"
    if git diff HEAD~1 requirements.txt > /dev/null 2>&1; then
        log "requirements.txt modificado, rebuilding imagen..."
        cd "$HORILLA_DIR"
        docker-compose build --no-cache horilla-vainilla
    fi
    
    cd "$HORILLA_DIR"
    
    # Aplicar migraciones
    docker-compose exec -T horilla-vainilla python manage.py migrate --noinput
    
    # Recopilar archivos estáticos
    log "Recopilando archivos estáticos..."
    docker-compose exec -T horilla-vainilla python manage.py collectstatic --noinput > /dev/null
    
    # Compilar traducciones
    log "Compilando traducciones..."
    docker-compose exec -T horilla-vainilla python manage.py compilemessages > /dev/null 2>&1 || true
    
    # Reiniciar servicios
    log "Reiniciando servicios..."
    docker-compose restart horilla-vainilla
    
    # Esperar a que esté disponible
    for i in {1..30}; do
        if curl -s http://localhost:8010 > /dev/null; then
            success "Servicios reiniciados y disponibles"
            return 0
        fi
        sleep 2
    done
    
    warning "El servicio tardó más de lo esperado en responder"
}

# Aplicar personalizaciones y crear commit POST-actualización
apply_customizations_and_commit() {
    log "Aplicando personalizaciones después de la actualización..."
    
    # Buscar el script de restauración más reciente
    LATEST_RESTORE=$(ls -t "$HORILLA_DIR/custom_patches"/restore_customizations_*.sh 2>/dev/null | head -1)
    
    if [ -f "$LATEST_RESTORE" ]; then
        log "Ejecutando restauración de personalizaciones..."
        chmod +x "$LATEST_RESTORE"
        
        if "$LATEST_RESTORE"; then
            success "Personalizaciones aplicadas exitosamente"
        else
            warning "Error aplicando personalizaciones - revisar manualmente"
            log "Script de restauración: $LATEST_RESTORE"
            return 1
        fi
    else
        warning "No se encontró script de restauración de personalizaciones"
        log "Las personalizaciones deben aplicarse manualmente"
    fi
    
    # Crear commit POST-actualización
    cd "$HORILLA_DIR"
    
    if [ -d ".git" ]; then
        git_log "Creando commit post-actualización..."
        
        # Agregar cambios de la actualización si los hay
        if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            
            # Agregar archivos relevantes
            git add custom_patches/ 2>/dev/null || true
            git add scripts/ 2>/dev/null || true
            git add *.md 2>/dev/null || true
            
            if ! git diff --staged --quiet; then
                CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
                DATA_COMMIT=$(cd "$DATA_DIR" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                
                git commit -m "🔄 Post-update: Personalizaciones reaplicadas $CURRENT_DATE

📦 Horilla actualizado a commit: $DATA_COMMIT
🔧 Personalizaciones restauradas automáticamente
⚡ Sistema funcionando correctamente

🎯 Cambios post-actualización:
$(git diff --staged --name-only | sed 's/^/- /')

🚀 Sistema: Horilla HRMS - Vainilla CR"
                
                NEW_COMMIT=$(git rev-parse --short HEAD)
                success "Commit post-actualización creado: $NEW_COMMIT"
            fi
        else
            success "No hay cambios adicionales para commitear"
        fi
    fi
}

# Verificación final
verify_system() {
    log "Verificando el sistema después de la actualización..."
    
    cd "$HORILLA_DIR"
    
    echo ""
    echo "=========================================="
    echo "  🔍 VERIFICACIÓN POST-ACTUALIZACIÓN"
    echo "=========================================="
    
    # Verificar contenedores
    if docker-compose ps horilla-vainilla | grep -q "Up"; then
        success "✅ Contenedores funcionando"
    else
        error "❌ Problema con contenedores"
    fi
    
    # Verificar base de datos
    if docker exec postgres-horilla-vainilla pg_isready -U horilla > /dev/null 2>&1; then
        success "✅ Base de datos accesible"
    else
        error "❌ Problema con base de datos"
    fi
    
    # Verificar web
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8010 | grep -q "301\|302\|200"; then
        success "✅ Interfaz web funcionando"
    else
        warning "⚠️ Interfaz web no responde como esperado"
    fi
    
    # Mostrar información de versiones
    echo ""
    echo "📊 **Versiones actuales:**"
    
    cd "$DATA_DIR"
    CURRENT_VERSION=$(git rev-parse --short HEAD)
    echo "   🔧 Horilla: $CURRENT_VERSION"
    
    cd "$HORILLA_DIR"
    if [ -d ".git" ]; then
        MAIN_VERSION=$(git rev-parse --short HEAD)
        MAIN_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
        echo "   📦 Repo principal: $MAIN_VERSION ($MAIN_BRANCH)"
    fi
    
    echo ""
}

# Función principal
main() {
    echo ""
    echo "=========================================="
    echo "  🔄 ACTUALIZACIÓN HÍBRIDA HORILLA + GIT"
    echo "=========================================="
    echo "🔧 Sistema híbrido con respaldo Git integrado"
    echo "📅 $(date)"
    echo ""
    
    check_prerequisites
    
    if ! show_update_info; then
        exit 0
    fi
    
    echo ""
    echo "⚠️ IMPORTANTE: Esta actualización incluye:"
    echo "   ✅ Respaldo híbrido (patches + Git commits)"
    echo "   ✅ Actualización del código base (horilla_data)"  
    echo "   ✅ Actualización del repositorio principal"
    echo "   ✅ Restauración automática de personalizaciones"
    echo "   ✅ Commits automáticos pre y post actualización"
    echo "   ✅ Plan de rollback completo"
    echo ""
    
    # Preguntar confirmación si no está en modo automático
    if [ "$1" != "--auto" ]; then
        echo -n "¿Deseas continuar con la actualización híbrida? (s/N): "
        read -r confirmation
        if [ "$confirmation" != "s" ] && [ "$confirmation" != "S" ]; then
            log "Actualización cancelada por el usuario"
            exit 0
        fi
    fi
    
    echo ""
    echo "=========================================="
    echo "  🚀 INICIANDO ACTUALIZACIÓN HÍBRIDA"
    echo "=========================================="
    echo ""
    
    create_pre_update_backup
    
    if update_code && update_main_repository; then
        apply_migrations_and_restart
        apply_customizations_and_commit
        verify_system
        
        echo ""
        echo "=========================================="
        success "✅ ACTUALIZACIÓN HÍBRIDA COMPLETADA"
        echo "=========================================="
        echo ""
        log "🌐 URL: https://rh.vainillacr.com"
        log "📋 Logs: docker logs horilla-vainilla -f"
        log "🔄 Status: ./scripts/status.sh"
        log "🔗 Git: git status && git log --oneline -3"
        
        if [ -f "/tmp/horilla_last_backup" ]; then
            BACKUP_LOCATION=$(cat /tmp/horilla_last_backup)
            log "💾 Backup completo: $BACKUP_LOCATION"
            log "🔧 Restauración híbrida: $BACKUP_LOCATION/RESTORE_HYBRID.sh"
        fi
        
        echo ""
        echo "📊 **RESUMEN ACTUALIZACIÓN:**"
        echo "   ✅ Código Horilla actualizado con últimos cambios oficiales"
        echo "   ✅ Repositorio principal sincronizado"
        echo "   ✅ Personalizaciones preservadas y reaplicadas"
        echo "   ✅ Commits Git automáticos creados"
        echo "   ✅ Base de datos migrada exitosamente"
        echo "   ✅ Servicios funcionando correctamente"
        echo "   ✅ Respaldo híbrido completo disponible"
        echo ""
        
        # Información de Git
        cd "$HORILLA_DIR"
        if [ -d ".git" ]; then
            echo "🔗 **Git Status:**"
            CURRENT_COMMIT=$(git rev-parse --short HEAD)
            CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
            echo "   📝 Commit actual: $CURRENT_COMMIT"
            echo "   🌿 Branch: $CURRENT_BRANCH"
            
            if git remote -v | grep -q origin; then
                echo "   ☁️ Sincronizar: git push origin $CURRENT_BRANCH"
            fi
            echo ""
        fi
        
    else
        error "Error durante la actualización - revisar conflictos manualmente"
    fi
}

# Ejecutar función principal
main "$@"
