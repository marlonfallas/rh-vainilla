#!/bin/bash

# ==========================================
# SCRIPT DE INTEGRACIÓN HORILLA MODULAR
# Version: 2.0 - Arquitectura evolutiva
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CUSTOMIZATIONS_DIR="$PROJECT_DIR/customizations"
HORILLA_DATA_DIR="$PROJECT_DIR/horilla_data"

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
    exit 1
}

section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

# Verificar arquitectura modular
check_modular_architecture() {
    log "Verificando arquitectura modular..."
    
    if [ ! -d "$CUSTOMIZATIONS_DIR" ]; then
        error "Directorio de personalizaciones no encontrado: $CUSTOMIZATIONS_DIR"
    fi
    
    if [ ! -f "$CUSTOMIZATIONS_DIR/scripts/apply_customizations.sh" ]; then
        error "Script principal de personalizaciones no encontrado"
    fi
    
    if [ ! -d "$HORILLA_DATA_DIR" ]; then
        error "Directorio horilla_data no encontrado: $HORILLA_DATA_DIR"
    fi
    
    success "Arquitectura modular verificada"
}

# Sincronizar personalizaciones con repo modular
sync_customizations() {
    section "SINCRONIZANDO PERSONALIZACIONES"
    
    log "Actualizando submodule de personalizaciones..."
    cd "$PROJECT_DIR"
    git submodule update --init --recursive
    git submodule update --remote --merge customizations
    
    success "Personalizaciones sincronizadas"
}

# Aplicar personalizaciones usando nuevo sistema modular
apply_customizations() {
    section "APLICANDO PERSONALIZACIONES MODULARES"
    
    log "Ejecutando sistema modular de personalizaciones..."
    cd "$PROJECT_DIR"
    
    # Configurar variable de entorno para que sepa dónde está horilla_data
    export HORILLA_DATA_DIR="$HORILLA_DATA_DIR"
    
    # Ejecutar aplicador principal
    "$CUSTOMIZATIONS_DIR/scripts/apply_customizations.sh" apply
    
    success "Personalizaciones modulares aplicadas"
}

# Migrar configuraciones legacy a nuevo sistema
migrate_legacy_configs() {
    section "MIGRANDO CONFIGURACIONES LEGACY"
    
    log "Verificando configuraciones legacy..."
    
    # Si existen las carpetas legacy, crear enlaces simbólicos
    if [ -d "$PROJECT_DIR/custom_patches" ] && [ -d "$CUSTOMIZATIONS_DIR/patches" ]; then
        log "Configurando compatibilidad legacy para custom_patches..."
        # No eliminamos el original, solo creamos referencia
        ln -sf "$CUSTOMIZATIONS_DIR/patches" "$PROJECT_DIR/custom_patches_modular" 2>/dev/null || true
    fi
    
    if [ -d "$PROJECT_DIR/custom_translations" ] && [ -d "$CUSTOMIZATIONS_DIR/translations" ]; then
        log "Configurando compatibilidad legacy para custom_translations..."
        ln -sf "$CUSTOMIZATIONS_DIR/translations" "$PROJECT_DIR/custom_translations_modular" 2>/dev/null || true
    fi
    
    success "Configuraciones legacy mantenidas con compatibilidad modular"
}

# Verificar estado del sistema híbrido
verify_hybrid_system() {
    section "VERIFICANDO SISTEMA HÍBRIDO"
    
    # Verificar personalizaciones modulares
    log "Verificando personalizaciones modulares..."
    export HORILLA_DATA_DIR="$HORILLA_DATA_DIR"
    "$CUSTOMIZATIONS_DIR/scripts/apply_customizations.sh" status
    
    # Verificar servicios Docker
    log "Verificando servicios Docker..."
    cd "$PROJECT_DIR"
    if docker-compose ps | grep -q "horilla-vainilla.*Up"; then
        success "✅ Servicios Docker funcionando"
    else
        warning "⚠️ Verificar estado de servicios Docker"
    fi
    
    # Verificar acceso web
    log "Verificando acceso web..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8010 | grep -q "200\|301\|302"; then
        success "✅ Interfaz web accesible"
    else
        warning "⚠️ Verificar acceso a interfaz web"
    fi
    
    success "Sistema híbrido verificado"
}

# Crear backup usando sistema híbrido
create_hybrid_backup() {
    section "CREANDO BACKUP HÍBRIDO"
    
    log "Ejecutando backup híbrido (legacy + modular)..."
    
    # Usar script de backup existente que ya funciona
    if [ -f "$PROJECT_DIR/scripts/backup_customizations_with_git.sh" ]; then
        "$PROJECT_DIR/scripts/backup_customizations_with_git.sh"
    else
        warning "Script de backup híbrido no encontrado, usando modular..."
        if [ -f "$CUSTOMIZATIONS_DIR/scripts/backup_customizations_with_git.sh" ]; then
            cd "$PROJECT_DIR"
            export HORILLA_DATA_DIR="$HORILLA_DATA_DIR"
            "$CUSTOMIZATIONS_DIR/scripts/backup_customizations_with_git.sh"
        fi
    fi
    
    success "Backup híbrido completado"
}

# Actualizar sistema híbrido
update_hybrid_system() {
    section "ACTUALIZANDO SISTEMA HÍBRIDO"
    
    log "Actualizando código base Horilla..."
    cd "$HORILLA_DATA_DIR"
    git pull origin 1.0 || warning "Error actualizando horilla_data"
    
    log "Actualizando personalizaciones modulares..."
    sync_customizations
    
    log "Reaplicando personalizaciones..."
    apply_customizations
    
    log "Reiniciando servicios..."
    cd "$PROJECT_DIR"
    docker-compose restart horilla-vainilla
    
    success "Sistema híbrido actualizado"
}

# Mostrar estado completo del sistema
show_system_status() {
    section "ESTADO SISTEMA HÍBRIDO MODULAR"
    
    echo ""
    echo "🏗️ **ARQUITECTURA:**"
    echo "   📁 Principal: $PROJECT_DIR"
    echo "   📁 Personalizaciones: $CUSTOMIZATIONS_DIR"
    echo "   📁 Código base: $HORILLA_DATA_DIR"
    
    echo ""
    echo "🔗 **SUBMODULES:**"
    cd "$PROJECT_DIR"
    git submodule status 2>/dev/null || echo "   ⚠️ Error verificando submodules"
    
    echo ""
    echo "🇨🇷 **PERSONALIZACIONES:**"
    if [ -x "$CUSTOMIZATIONS_DIR/scripts/apply_customizations.sh" ]; then
        export HORILLA_DATA_DIR="$HORILLA_DATA_DIR"
        "$CUSTOMIZATIONS_DIR/scripts/apply_customizations.sh" status 2>/dev/null || echo "   ⚠️ Error verificando personalizaciones"
    else
        echo "   ❌ Sistema modular no disponible"
    fi
    
    echo ""
    echo "🐳 **DOCKER:**"
    cd "$PROJECT_DIR"
    docker-compose ps 2>/dev/null | grep horilla-vainilla || echo "   ⚠️ Error verificando Docker"
    
    echo ""
    echo "🔧 **COMANDOS DISPONIBLES:**"
    echo "   ./scripts/integration.sh apply     # Aplicar personalizaciones"
    echo "   ./scripts/integration.sh sync      # Sincronizar desde repo modular"
    echo "   ./scripts/integration.sh backup    # Backup híbrido"
    echo "   ./scripts/integration.sh update    # Actualización completa"
    echo "   ./scripts/integration.sh verify    # Verificar sistema"
    echo "   ./scripts/integration.sh status    # Estado completo"
    
    echo ""
}

# Función principal
main() {
    echo ""
    echo "=================================================="
    echo "  🔗 INTEGRACIÓN HORILLA HÍBRIDO MODULAR"
    echo "=================================================="
    echo "🏗️ Arquitectura evolutiva: Legacy + Modular"
    echo "📦 Repositorio modular de personalizaciones"
    echo "🔄 Sistema híbrido con Git commits automáticos"
    echo "📅 $(date)"
    echo ""
    
    check_modular_architecture
    
    case "${1:-status}" in
        "apply")
            sync_customizations
            migrate_legacy_configs
            apply_customizations
            verify_hybrid_system
            ;;
        "sync")
            sync_customizations
            ;;
        "backup")
            create_hybrid_backup
            ;;
        "update")
            create_hybrid_backup
            update_hybrid_system
            verify_hybrid_system
            ;;
        "verify"|"check")
            verify_hybrid_system
            ;;
        "migrate")
            migrate_legacy_configs
            ;;
        "status")
            show_system_status
            ;;
        *)
            echo "Uso: $0 [apply|sync|backup|update|verify|migrate|status]"
            echo ""
            echo "Comandos:"
            echo "  apply   - Aplicar personalizaciones modulares"
            echo "  sync    - Sincronizar con repo de personalizaciones"
            echo "  backup  - Crear backup híbrido completo"
            echo "  update  - Actualización completa del sistema"
            echo "  verify  - Verificar estado del sistema"
            echo "  migrate - Migrar configuraciones legacy"
            echo "  status  - Mostrar estado completo (default)"
            echo ""
            echo "Ejemplos:"
            echo "  $0              # Ver estado"
            echo "  $0 apply        # Aplicar personalizaciones"
            echo "  $0 update       # Actualización completa"
            exit 1
            ;;
    esac
    
    echo ""
    echo "=================================================="
    success "✅ OPERACIÓN COMPLETADA"
    echo "=================================================="
    echo ""
}

# Ejecutar función principal
main "$@"
