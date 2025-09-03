#!/bin/bash

# ==========================================
# HORILLA UPDATE INFO - Dry Run
# ==========================================

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "  HORILLA HRMS - INFORMACIÓN DE UPDATE"
echo -e "==========================================${NC}"

cd /nvme0n1-disk/clientes/vainilla/horilla/horilla_data

# Fetch latest
echo -e "${BLUE}Obteniendo información más reciente...${NC}"
git fetch origin

# Estado actual
echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "${YELLOW}ESTADO ACTUAL${NC}"
echo -e "${YELLOW}===========================================${NC}"

CURRENT_COMMIT=$(git rev-parse --short HEAD)
CURRENT_DATE=$(git log -1 --format="%ad" --date=short)
COMMITS_BEHIND=$(git rev-list --count HEAD..origin/1.0)

echo "📍 Commit actual: $CURRENT_COMMIT ($CURRENT_DATE)"
echo "🔄 Commits disponibles: $COMMITS_BEHIND"

if [ $COMMITS_BEHIND -eq 0 ]; then
    echo -e "${GREEN}✅ Tu instalación está actualizada${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️ Tu instalación está $COMMITS_BEHIND commits atrasada${NC}"
fi

# Últimas actualizaciones disponibles
echo ""
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}ACTUALIZACIONES DISPONIBLES (últimas 10)${NC}"
echo -e "${BLUE}===========================================${NC}"

git log --format="%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %s" --date=short -10 origin/1.0 | head -10

# Cambios importantes
echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "${YELLOW}CAMBIOS DESDE TU ÚLTIMA ACTUALIZACIÓN${NC}"
echo -e "${YELLOW}===========================================${NC}"

git log --oneline HEAD..origin/1.0 | head -15

# Archivos modificados localmente
echo ""
echo -e "${RED}===========================================${NC}"
echo -e "${RED}ARCHIVOS MODIFICADOS LOCALMENTE${NC}"
echo -e "${RED}===========================================${NC}"

if git diff --quiet && git diff --staged --quiet; then
    echo -e "${GREEN}✅ No hay modificaciones locales${NC}"
else
    echo -e "${YELLOW}⚠️ Tienes modificaciones locales que serán preservadas:${NC}"
    git status --porcelain | while read status file; do
        case "$status" in
            "M ") echo "  📝 Modificado: $file" ;;
            "A ") echo "  ➕ Agregado: $file" ;;
            "D ") echo "  ❌ Eliminado: $file" ;;
            "??") echo "  ❓ No rastreado: $file" ;;
        esac
    done
fi

# Recomendaciones
echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}RECOMENDACIONES${NC}"
echo -e "${GREEN}===========================================${NC}"

if [ $COMMITS_BEHIND -gt 0 ]; then
    echo "🔄 Para actualizar ejecuta:"
    echo "   ./scripts/update_horilla.sh"
    echo ""
    echo "⚠️ ANTES DE ACTUALIZAR:"
    echo "   ✅ Haz backup: ./scripts/backup-horilla.sh"
    echo "   ✅ Verifica que el sitio funcione: https://rh.vainillacr.com"
    echo "   ✅ Notifica a usuarios del mantenimiento"
    echo ""
    
    # Estimar importancia
    CRITICAL_FIXES=$(git log --oneline HEAD..origin/1.0 | grep -c "\[FIX\]" || echo "0")
    SECURITY_UPDATES=$(git log --oneline HEAD..origin/1.0 | grep -ci "security\|xss\|vulnerability" || echo "0")
    
    if [ $SECURITY_UPDATES -gt 0 ]; then
        echo -e "${RED}🔒 IMPORTANTE: Se detectaron $SECURITY_UPDATES actualizaciones de seguridad${NC}"
        echo -e "${RED}   Recomendado actualizar lo antes posible${NC}"
    elif [ $CRITICAL_FIXES -gt 3 ]; then
        echo -e "${YELLOW}🐛 Se detectaron $CRITICAL_FIXES correcciones importantes${NC}"
        echo -e "${YELLOW}   Recomendado actualizar pronto${NC}"
    else
        echo -e "${GREEN}📈 Actualizaciones principalmente de mejoras${NC}"
        echo -e "${GREEN}   Puedes actualizar cuando sea conveniente${NC}"
    fi
fi

echo ""
echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}INFORMACIÓN DEL SISTEMA${NC}"
echo -e "${BLUE}===========================================${NC}"

cd /nvme0n1-disk/clientes/vainilla/horilla

echo "🐳 Estado de contenedores:"
docker-compose ps horilla-vainilla postgres-horilla-vainilla 2>/dev/null | grep -E "(horilla|postgres)" || echo "   ❌ Error obteniendo estado"

echo ""
echo "💾 Uso de disco:"
echo "   App: $(du -sh . 2>/dev/null | cut -f1)"
echo "   DB: $(du -sh /nvme1n1-disk/databases/vainilla/postgres-horilla/ 2>/dev/null | cut -f1 || echo 'N/A')"

echo ""
echo "🌐 Acceso:"
echo "   Local: http://localhost:8010"
echo "   Público: https://rh.vainillacr.com"

echo ""
echo -e "${BLUE}Para más información: ./scripts/status.sh${NC}"
