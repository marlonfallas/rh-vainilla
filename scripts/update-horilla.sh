#!/bin/bash

# Script de Actualización Segura de Horilla HRMS
# Mantiene personalizaciones locales mientras actualiza desde GitHub

set -e  # Exit on any error

PROJECT_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
DATA_DIR="$PROJECT_DIR/horilla_data"
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   HORILLA HRMS - ACTUALIZACIÓN SEGURA${NC}"
echo -e "${BLUE}=========================================${NC}"

# Function to print colored output
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Verificar que estamos en el directorio correcto
cd $PROJECT_DIR

# Paso 1: Crear backup completo antes de actualizar
log "📦 Creando backup completo antes de actualizar..."
./scripts/backup-horilla.sh

# Paso 2: Verificar estado del repositorio
log "🔍 Verificando estado del repositorio..."
cd $DATA_DIR

# Mostrar cambios locales
if [ -n "$(git status --porcelain)" ]; then
    warn "Se encontraron modificaciones locales:"
    git status --short
    echo ""
    warn "Estas modificaciones se guardarán en stash temporal"
fi

# Paso 3: Fetch latest changes
log "📥 Obteniendo últimas actualizaciones desde GitHub..."
git fetch origin

# Mostrar qué commits están disponibles
UPDATES_COUNT=$(git rev-list --count HEAD..origin/1.0)
if [ "$UPDATES_COUNT" -gt 0 ]; then
    log "📋 Se encontraron $UPDATES_COUNT actualizaciones disponibles:"
    echo ""
    git log --oneline --color=always HEAD..origin/1.0 | head -10
    echo ""
else
    log "✅ Tu instalación ya está actualizada"
    exit 0
fi

# Paso 4: Confirmar actualización
echo ""
read -p "¿Deseas aplicar estas actualizaciones? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "❌ Actualización cancelada por el usuario"
    exit 0
fi

# Paso 5: Stash local changes
log "💾 Guardando modificaciones locales..."
git stash push -m "Auto-stash before update $TIMESTAMP" || log "No hay cambios para stash"

# Paso 6: Pull updates
log "⬇️ Aplicando actualizaciones..."
git pull origin 1.0

# Paso 7: Apply local modifications back
log "🔧 Restaurando personalizaciones locales..."

# Aplicar stash si existe
if git stash list | grep -q "Auto-stash before update $TIMESTAMP"; then
    log "Aplicando cambios locales desde stash..."
    if ! git stash pop; then
        warn "Conflictos detectados al aplicar cambios locales"
        warn "Resuelve los conflictos manualmente y ejecuta: git add . && git stash drop"
        log "Archivos en conflicto:"
        git status --short
        echo ""
        warn "Por ahora continuaremos sin aplicar los cambios locales"
    fi
fi

# Paso 8: Rebuild containers
log "🏗️ Reconstruyendo contenedores Docker..."
cd $PROJECT_DIR
docker-compose build --no-cache horilla-vainilla

# Paso 9: Run database migrations
log "🗃️ Ejecutando migraciones de base de datos..."
docker-compose up -d postgres-horilla-vainilla
sleep 5  # Wait for DB to be ready
docker-compose run --rm horilla-vainilla python manage.py migrate

# Paso 10: Collect static files
log "📄 Recopilando archivos estáticos..."
docker-compose run --rm horilla-vainilla python manage.py collectstatic --noinput

# Paso 11: Compile translations
log "🌍 Compilando traducciones..."
docker-compose run --rm horilla-vainilla python manage.py compilemessages || warn "Error compilando traducciones, continuando..."

# Paso 12: Restart services
log "🔄 Reiniciando servicios..."
docker-compose up -d

# Wait for services to be ready
log "⏳ Esperando que los servicios estén listos..."
sleep 10

# Paso 13: Health check
log "🔍 Verificando estado de los servicios..."
if curl -s -f http://localhost:8010 > /dev/null; then
    log "✅ Horilla está respondiendo correctamente"
else
    error "❌ Horilla no está respondiendo - revisar logs:"
    docker-compose logs --tail=20 horilla-vainilla
fi

# Paso 14: Show update summary
log "📊 Resumen de actualización:"
CURRENT_COMMIT=$(git rev-parse --short HEAD)
PREVIOUS_COMMIT=$(git rev-parse --short HEAD~$UPDATES_COUNT)

echo ""
echo -e "${GREEN}✅ ACTUALIZACIÓN COMPLETADA${NC}"
echo -e "📅 Fecha: $(date)"
echo -e "📦 Commits aplicados: $UPDATES_COUNT"
echo -e "🔢 Versión anterior: $PREVIOUS_COMMIT"
echo -e "🔢 Versión actual: $CURRENT_COMMIT"
echo -e "🌐 URL: https://rh.vainillacr.com"
echo ""

log "📋 Para verificar el estado completo ejecuta:"
echo "   ./scripts/status.sh"
echo ""
log "🔄 En caso de problemas, puedes hacer rollback:"
echo "   git reset --hard $PREVIOUS_COMMIT"
echo "   docker-compose restart"

echo -e "${BLUE}=========================================${NC}"
