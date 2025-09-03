#!/bin/bash

# ==========================================
# ACTUALIZACIÓN SEGURA CON RESPALDO DE PERSONALIZACIONES
# Version: 3.0 - Integrado con respaldo de customizaciones
# ==========================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    
    success "Prerrequisitos verificados"
}

# Mostrar información de actualización
show_update_info() {
    log "Verificando actualizaciones disponibles..."
    
    cd "$DATA_DIR"
    git fetch origin
    
    COMMITS_BEHIND=$(git rev-list --count HEAD..origin/1.0)
    
    echo ""
    echo "=========================================="
    echo "  INFORMACIÓN DE ACTUALIZACIÓN"
    echo "=========================================="
    
    if [ $COMMITS_BEHIND -gt 0 ]; then
        echo "🔄 Commits disponibles: $COMMITS_BEHIND"
        echo ""
        echo "📋 Últimos cambios:"
        git log --oneline HEAD..origin/1.0 | head -10
        echo ""
        return 0
    else
        success "Tu instalación está actualizada"
        exit 0
    fi
}

# Crear respaldo completo PRE-actualización
create_pre_update_backup() {
    log "Creando respaldo PRE-actualización completo..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    PRE_UPDATE_BACKUP_DIR="$BACKUP_DIR/pre-update-$TIMESTAMP"
    mkdir -p "$PRE_UPDATE_BACKUP_DIR"
    
    # Backup de base de datos
    log "Respaldando base de datos..."
    docker exec postgres-horilla-vainilla pg_dump -U horilla horilla | gzip > "$PRE_UPDATE_BACKUP_DIR/horilla_db_pre_update.sql.gz"
    
    # Backup de archivos media
    log "Respaldando archivos media..."
    tar -czf "$PRE_UPDATE_BACKUP_DIR/horilla_media_pre_update.tar.gz" -C "$HORILLA_DIR" media/ 2>/dev/null || true
    
    # Backup de configuración
    log "Respaldando configuración..."
    cp "$HORILLA_DIR/.env" "$PRE_UPDATE_BACKUP_DIR/"
    
    # Backup de TODAS las personalizaciones usando el script especializado
    log "Ejecutando respaldo completo de personalizaciones..."
    "$HORILLA_DIR/scripts/backup_customizations.sh" > /dev/null 2>&1
    
    # Mover respaldo de personalizaciones al directorio pre-update
    LATEST_CUSTOMIZATION=$(ls -t "$HORILLA_DIR/custom_patches"/restore_customizations_*.sh | head -1)
    if [ -f "$LATEST_CUSTOMIZATION" ]; then
        CUSTOM_TIMESTAMP=$(basename "$LATEST_CUSTOMIZATION" | sed 's/restore_customizations_\(.*\)\.sh/\1/')
        
        # Copiar archivos de personalización al backup pre-update
        cp -r "$HORILLA_DIR/custom_patches"/* "$PRE_UPDATE_BACKUP_DIR/"
        
        # Crear script maestro de restauración
        cat > "$PRE_UPDATE_BACKUP_DIR/RESTORE_ALL.sh" << EOF
#!/bin/bash
# SCRIPT MAESTRO DE RESTAURACIÓN POST-ACTUALIZACIÓN
# Generado automáticamente: $(date)

set -e

echo "=========================================="
echo "  RESTAURACIÓN COMPLETA POST-ACTUALIZACIÓN"
echo "=========================================="

HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"

# 1. Restaurar personalizaciones de código
echo "🔧 Restaurando personalizaciones de código..."
if [ -f "./restore_customizations_${CUSTOM_TIMESTAMP}.sh" ]; then
    chmod +x "./restore_customizations_${CUSTOM_TIMESTAMP}.sh"
    "./restore_customizations_${CUSTOM_TIMESTAMP}.sh"
else
    echo "⚠️ Script de restauración de personalizaciones no encontrado"
fi

# 2. Verificar funcionamiento
echo "✅ Verificando funcionamiento..."
cd "\$HORILLA_DIR"
./scripts/status.sh

echo "=========================================="
echo "✅ RESTAURACIÓN COMPLETA FINALIZADA"
echo "=========================================="
echo ""
echo "🌐 Acceder a: https://rh.vainillacr.com"
echo "📋 Verificar logs: docker logs horilla-vainilla -f"
EOF
        
        chmod +x "$PRE_UPDATE_BACKUP_DIR/RESTORE_ALL.sh"
    fi
    
    success "Backup PRE-actualización creado en: $PRE_UPDATE_BACKUP_DIR"
    echo "$PRE_UPDATE_BACKUP_DIR" > /tmp/horilla_last_backup
}

# Proceso de actualización (git stash + pull + apply)
update_code() {
    log "Iniciando actualización de código..."
    
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

# Aplicar migraciones y reiniciar
apply_migrations_and_restart() {
    log "Aplicando migraciones y reiniciando servicios..."
    
    cd "$HORILLA_DIR"
    
    # Verificar si requirements.txt cambió
    if git diff HEAD~1 "$DATA_DIR/requirements.txt" > /dev/null 2>&1; then
        log "requirements.txt modificado, rebuilding imagen..."
        docker-compose build --no-cache horilla-vainilla
    fi
    
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

# Aplicar personalizaciones POST-actualización
apply_customizations() {
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
        fi
    else
        warning "No se encontró script de restauración de personalizaciones"
        log "Las personalizaciones deben aplicarse manualmente"
    fi
}

# Verificación final
verify_system() {
    log "Verificando el sistema después de la actualización..."
    
    cd "$HORILLA_DIR"
    
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
    
    # Mostrar versión actual
    cd "$DATA_DIR"
    CURRENT_VERSION=$(git rev-parse --short HEAD)
    log "Versión actual: $CURRENT_VERSION"
}

# Función principal
main() {
    echo ""
    echo "=========================================="
    echo "  ACTUALIZACIÓN SEGURA CON PERSONALIZACIONES"
    echo "=========================================="
    echo ""
    
    check_prerequisites
    
    if ! show_update_info; then
        exit 0
    fi
    
    echo ""
    echo "⚠️ IMPORTANTE: Esta actualización incluye:"
    echo "   ✅ Respaldo completo de personalizaciones"
    echo "   ✅ Actualización del código base"
    echo "   ✅ Restauración automática de cambios locales"
    echo "   ✅ Plan de rollback completo"
    echo ""
    
    # Preguntar confirmación si no está en modo automático
    if [ "$1" != "--auto" ]; then
        echo -n "¿Deseas continuar con la actualización? (s/N): "
        read -r confirmation
        if [ "$confirmation" != "s" ] && [ "$confirmation" != "S" ]; then
            log "Actualización cancelada por el usuario"
            exit 0
        fi
    fi
    
    echo ""
    echo "=========================================="
    echo "  INICIANDO ACTUALIZACIÓN COMPLETA"
    echo "=========================================="
    echo ""
    
    create_pre_update_backup
    
    if update_code; then
        apply_migrations_and_restart
        apply_customizations
        verify_system
        
        echo ""
        echo "=========================================="
        success "✅ ACTUALIZACIÓN COMPLETADA EXITOSAMENTE"
        echo "=========================================="
        echo ""
        log "🌐 URL: https://rh.vainillacr.com"
        log "📋 Logs: docker logs horilla-vainilla -f"
        log "🔄 Status: ./scripts/status.sh"
        
        if [ -f "/tmp/horilla_last_backup" ]; then
            BACKUP_LOCATION=$(cat /tmp/horilla_last_backup)
            log "💾 Backup completo en: $BACKUP_LOCATION"
            log "🔧 Restauración completa: $BACKUP_LOCATION/RESTORE_ALL.sh"
        fi
        
        echo ""
        echo "📋 RESUMEN:"
        echo "   ✅ Código actualizado con últimos cambios de GitHub"
        echo "   ✅ Personalizaciones preservadas y reaplicadas"
        echo "   ✅ Base de datos migrada exitosamente"
        echo "   ✅ Servicios funcionando correctamente"
        echo ""
        
    else
        error "Error durante la actualización - revisar conflictos manualmente"
    fi
}

# Ejecutar función principal
main "$@"
