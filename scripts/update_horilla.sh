#!/bin/bash

# ==========================================
# SCRIPT DE ACTUALIZACIÓN HORILLA HRMS
# Versión: 2.0
# Actualizado: $(date +%Y-%m-%d)
# ==========================================

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
HORILLA_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$HORILLA_DIR/horilla_data"
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"

# Funciones
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Verificar prerrequisitos
check_prerequisites() {
    log "Verificando prerrequisitos..."
    
    if [ ! -d "$HORILLA_DIR" ]; then
        error "Directorio de Horilla no encontrado: $HORILLA_DIR"
    fi
    
    if [ ! -d "$DATA_DIR" ]; then
        error "Directorio de datos no encontrado: $DATA_DIR"
    fi
    
    cd "$HORILLA_DIR"
    if ! docker-compose ps | grep -q horilla-vainilla; then
        error "Horilla no está ejecutándose"
    fi
    
    success "Prerrequisitos verificados"
}

# Backup completo antes de actualizar
create_backup() {
    log "Creando backup completo antes de la actualización..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    UPDATE_BACKUP_DIR="$BACKUP_DIR/pre-update-$TIMESTAMP"
    mkdir -p "$UPDATE_BACKUP_DIR"
    
    # Backup de base de datos
    log "Respaldando base de datos..."
    docker exec postgres-horilla-vainilla pg_dump -U horilla horilla | gzip > "$UPDATE_BACKUP_DIR/horilla_db_pre_update.sql.gz"
    
    # Backup de archivos media
    log "Respaldando archivos media..."
    tar -czf "$UPDATE_BACKUP_DIR/horilla_media_pre_update.tar.gz" -C "$HORILLA_DIR" media/
    
    # Backup de configuración
    log "Respaldando configuración..."
    cp "$HORILLA_DIR/.env" "$UPDATE_BACKUP_DIR/"
    
    # Backup de código personalizado (con cambios)
    log "Respaldando código con modificaciones..."
    cd "$DATA_DIR"
    tar -czf "$UPDATE_BACKUP_DIR/horilla_data_with_changes.tar.gz" .
    
    success "Backup completo creado en: $UPDATE_BACKUP_DIR"
    echo "$UPDATE_BACKUP_DIR" > /tmp/horilla_last_backup
}

# Mostrar información de la actualización
show_update_info() {
    log "Información de la actualización disponible:"
    
    cd "$DATA_DIR"
    
    echo ""
    echo "=========================================="
    echo "ESTADO ACTUAL DEL REPOSITORIO"
    echo "=========================================="
    
    CURRENT_COMMIT=$(git rev-parse HEAD)
    LATEST_COMMIT=$(git rev-parse origin/1.0)
    COMMITS_BEHIND=$(git rev-list --count HEAD..origin/1.0)
    
    echo "Commit actual: $CURRENT_COMMIT"
    echo "Último commit disponible: $LATEST_COMMIT"
    echo "Commits pendientes: $COMMITS_BEHIND"
    echo ""
    
    echo "=========================================="
    echo "MODIFICACIONES LOCALES DETECTADAS"
    echo "=========================================="
    git status --porcelain
    echo ""
    
    echo "=========================================="
    echo "NUEVAS FUNCIONALIDADES/FIXES DISPONIBLES"
    echo "=========================================="
    git log --oneline --graph HEAD..origin/1.0 | head -15
    echo ""
    
    if [ $COMMITS_BEHIND -gt 0 ]; then
        warning "Tu instalación está $COMMITS_BEHIND commits atrasada"
        log "Últimos cambios disponibles:"
        git log --format="  %ad - %s" --date=short HEAD..origin/1.0 | head -10
    else
        success "Tu instalación está actualizada"
        return 1
    fi
}

# Stash de cambios locales
stash_local_changes() {
    log "Guardando cambios locales..."
    
    cd "$DATA_DIR"
    
    # Crear stash con nombre descriptivo
    STASH_MESSAGE="Cambios locales antes de update $(date '+%Y-%m-%d %H:%M:%S')"
    
    if git diff --quiet && git diff --staged --quiet; then
        log "No hay cambios locales para guardar"
        return 0
    fi
    
    git stash push -m "$STASH_MESSAGE"
    success "Cambios locales guardados en stash"
    
    # Mostrar archivos en stash
    log "Archivos guardados:"
    git stash show --name-only stash@{0} | sed 's/^/  - /'
}

# Actualizar código
update_code() {
    log "Actualizando código desde GitHub..."
    
    cd "$DATA_DIR"
    
    # Pull de cambios
    git pull origin 1.0
    
    success "Código actualizado exitosamente"
}

# Aplicar cambios locales de vuelta
restore_local_changes() {
    log "Restaurando cambios locales..."
    
    cd "$DATA_DIR"
    
    # Verificar si hay stash
    if git stash list | grep -q "WIP on"; then
        log "Aplicando cambios desde stash..."
        
        # Aplicar stash
        if git stash pop; then
            success "Cambios locales restaurados exitosamente"
        else
            warning "Conflictos detectados al restaurar cambios locales"
            log "Archivos con conflictos:"
            git status --porcelain | grep "^UU" | sed 's/^UU /  - /'
            
            echo ""
            warning "ACCIÓN REQUERIDA:"
            echo "1. Resuelve los conflictos manualmente"
            echo "2. Ejecuta: git add <archivo_resuelto>"
            echo "3. Continúa con el proceso de actualización"
            return 1
        fi
    else
        log "No hay cambios locales para restaurar"
    fi
}

# Actualizar dependencias
update_dependencies() {
    log "Verificando actualizaciones de dependencias..."
    
    cd "$HORILLA_DIR"
    
    # Rebuild de imagen si requirements.txt cambió
    if git diff HEAD~1 "$DATA_DIR/requirements.txt" > /dev/null 2>&1; then
        log "requirements.txt modificado, rebuilding imagen..."
        docker-compose build --no-cache horilla-vainilla
    else
        log "No hay cambios en dependencias"
    fi
}

# Aplicar migraciones de base de datos
apply_migrations() {
    log "Aplicando migraciones de base de datos..."
    
    cd "$HORILLA_DIR"
    
    # Verificar que el contenedor esté ejecutándose
    if ! docker-compose ps horilla-vainilla | grep -q "Up"; then
        log "Iniciando contenedor de Horilla..."
        docker-compose up -d
        sleep 10
    fi
    
    # Aplicar migraciones
    docker-compose exec -T horilla-vainilla python manage.py migrate --noinput
    
    # Recopilar archivos estáticos
    log "Recopilando archivos estáticos..."
    docker-compose exec -T horilla-vainilla python manage.py collectstatic --noinput
    
    # Compilar traducciones
    log "Compilando traducciones..."
    docker-compose exec -T horilla-vainilla python manage.py compilemessages || true
    
    success "Migraciones aplicadas exitosamente"
}

# Reiniciar servicios
restart_services() {
    log "Reiniciando servicios de Horilla..."
    
    cd "$HORILLA_DIR"
    docker-compose restart horilla-vainilla
    
    # Esperar a que el servicio esté listo
    log "Esperando a que el servicio esté disponible..."
    for i in {1..30}; do
        if curl -s http://localhost:8010 > /dev/null; then
            success "Servicio reiniciado y disponible"
            return 0
        fi
        sleep 2
    done
    
    warning "El servicio tardó más de lo esperado en responder"
}

# Verificar funcionamiento
verify_update() {
    log "Verificando el funcionamiento después de la actualización..."
    
    cd "$HORILLA_DIR"
    
    # Verificar contenedores
    if docker-compose ps horilla-vainilla | grep -q "Up"; then
        success "✅ Contenedor funcionando"
    else
        error "❌ Contenedor no está funcionando"
    fi
    
    # Verificar base de datos
    if docker exec postgres-horilla-vainilla pg_isready -U horilla > /dev/null 2>&1; then
        success "✅ Base de datos accesible"
    else
        error "❌ Base de datos no accesible"
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
    
    success "Verificación completada"
}

# Cleanup
cleanup() {
    log "Limpiando archivos temporales..."
    
    # Limpiar imágenes Docker no utilizadas
    docker system prune -f > /dev/null 2>&1 || true
    
    success "Cleanup completado"
}

# Función principal
main() {
    echo ""
    echo "=========================================="
    echo "  HORILLA HRMS - ACTUALIZACIÓN SEGURA"
    echo "=========================================="
    echo ""
    
    # Verificar si hay actualizaciones disponibles
    cd "$DATA_DIR"
    git fetch origin
    
    if ! show_update_info; then
        success "Ya tienes la versión más reciente de Horilla"
        exit 0
    fi
    
    echo ""
    echo "=========================================="
    echo "INICIANDO PROCESO DE ACTUALIZACIÓN"
    echo "=========================================="
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
    
    # Ejecutar pasos de actualización
    check_prerequisites
    create_backup
    stash_local_changes
    update_code
    
    if ! restore_local_changes; then
        error "Por favor resuelve los conflictos y ejecuta el script nuevamente"
    fi
    
    update_dependencies
    apply_migrations
    restart_services
    verify_update
    cleanup
    
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
        log "💾 Backup creado en: $BACKUP_LOCATION"
    fi
    
    echo ""
}

# Manejo de errores
trap 'error "Script interrumpido. Verifica el estado del sistema."' INT TERM

# Ejecutar función principal
main "$@"
