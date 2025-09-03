#!/bin/bash

# Script para verificar actualizaciones disponibles de Horilla HRMS
# Solo muestra información, no aplica cambios

set -e

DATA_DIR="/nvme0n1-disk/clientes/vainilla/horilla/horilla_data"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   HORILLA - VERIFICACIÓN DE UPDATES${NC}"
echo -e "${BLUE}=========================================${NC}"

cd $DATA_DIR

# Información actual
echo -e "${GREEN}📍 VERSIÓN ACTUAL:${NC}"
CURRENT_COMMIT=$(git rev-parse --short HEAD)
CURRENT_DATE=$(git show --format="%cd" --date=short -s HEAD)
CURRENT_MSG=$(git show --format="%s" -s HEAD)
echo "   Commit: $CURRENT_COMMIT"
echo "   Fecha:  $CURRENT_DATE"
echo "   Desc:   $CURRENT_MSG"
echo ""

# Fetch latest
echo -e "${YELLOW}📡 Consultando GitHub...${NC}"
git fetch origin -q

# Verificar updates disponibles
UPDATES_COUNT=$(git rev-list --count HEAD..origin/1.0)
LATEST_COMMIT=$(git rev-parse --short origin/1.0)
LATEST_DATE=$(git show --format="%cd" --date=short -s origin/1.0)

echo -e "${GREEN}📍 ÚLTIMA VERSIÓN DISPONIBLE:${NC}"
echo "   Commit: $LATEST_COMMIT"
echo "   Fecha:  $LATEST_DATE"
echo ""

if [ "$UPDATES_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}🆕 ACTUALIZACIONES DISPONIBLES: $UPDATES_COUNT commits${NC}"
    echo ""
    echo -e "${GREEN}📋 LISTA DE ACTUALIZACIONES:${NC}"
    git log --oneline --color=always HEAD..origin/1.0 | nl -w2 -s'. '
    echo ""
    
    # Mostrar archivos que cambiarán
    CHANGED_FILES=$(git diff --name-only HEAD origin/1.0 | wc -l)
    echo -e "${GREEN}📁 ARCHIVOS QUE SERÁN MODIFICADOS: $CHANGED_FILES${NC}"
    
    # Mostrar algunos archivos importantes
    echo -e "${BLUE}Archivos principales:${NC}"
    git diff --name-only HEAD origin/1.0 | grep -E '\.(py|html|js|css)$' | head -10 | sed 's/^/   • /'
    if [ $(git diff --name-only HEAD origin/1.0 | wc -l) -gt 10 ]; then
        echo "   • ... y $((CHANGED_FILES - 10)) archivos más"
    fi
    echo ""
    
    # Mostrar tipos de cambios
    echo -e "${GREEN}📊 TIPOS DE ACTUALIZACIONES:${NC}"
    FIXES=$(git log HEAD..origin/1.0 --oneline | grep -c '\[FIX\]' || echo 0)
    UPDATES=$(git log HEAD..origin/1.0 --oneline | grep -c '\[UPDT\]' || echo 0)
    FEATURES=$(git log HEAD..origin/1.0 --oneline | grep -c '\[FEAT\]' || echo 0)
    REMOVES=$(git log HEAD..origin/1.0 --oneline | grep -c '\[RMV\]' || echo 0)
    
    echo "   🔧 Fixes:          $FIXES"
    echo "   🔄 Updates:        $UPDATES"
    echo "   🆕 Features:       $FEATURES"
    echo "   🗑️  Removes:        $REMOVES"
    echo ""
    
    # Verificar modificaciones locales
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}⚠️  MODIFICACIONES LOCALES DETECTADAS:${NC}"
        git status --short | sed 's/^/   /'
        echo ""
        echo -e "${YELLOW}💡 Estas modificaciones se preservarán durante la actualización${NC}"
    else
        echo -e "${GREEN}✅ No hay modificaciones locales pendientes${NC}"
    fi
    echo ""
    
    # Comando para actualizar
    echo -e "${GREEN}🚀 PARA APLICAR ESTAS ACTUALIZACIONES:${NC}"
    echo "   ./scripts/update-horilla.sh"
    echo ""
    
    # Mostrar releases si hay tags nuevos
    LATEST_TAG=$(git describe --tags origin/1.0 2>/dev/null || echo "No tags")
    CURRENT_TAG=$(git describe --tags HEAD 2>/dev/null || echo "No tags")
    
    if [ "$LATEST_TAG" != "$CURRENT_TAG" ] && [ "$LATEST_TAG" != "No tags" ]; then
        echo -e "${BLUE}🏷️  NUEVA VERSIÓN DISPONIBLE: $LATEST_TAG${NC}"
        echo ""
    fi
    
else
    echo -e "${GREEN}✅ TU INSTALACIÓN ESTÁ ACTUALIZADA${NC}"
    echo ""
    echo -e "${BLUE}📅 Última verificación: $(date)${NC}"
fi

# Información adicional
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}ℹ️  INFORMACIÓN ADICIONAL:${NC}"
echo ""
echo -e "${BLUE}📁 Directorio:${NC} $DATA_DIR"
echo -e "${BLUE}🌐 URL:${NC} https://rh.vainillacr.com"
echo -e "${BLUE}📊 Estado:${NC} $(docker ps --format '{{.Status}}' --filter name=horilla-vainilla)"
echo ""
echo -e "${BLUE}🛠️  COMANDOS ÚTILES:${NC}"
echo "   ./scripts/status.sh           - Ver estado completo"
echo "   ./scripts/backup-horilla.sh   - Crear backup"
echo "   ./scripts/update-horilla.sh   - Aplicar actualizaciones"
echo ""
echo -e "${BLUE}=========================================${NC}"
