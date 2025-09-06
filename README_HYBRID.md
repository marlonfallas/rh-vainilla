# 🏢 Horilla HRMS - Vainilla CR (Arquitectura Híbrida)

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/marlonfallas/rh-vainilla)
[![Horilla](https://img.shields.io/badge/horilla-1.0.0-green.svg)](https://github.com/horilla-opensource/horilla)
[![Customizations](https://img.shields.io/badge/customizations-modular-orange.svg)](https://github.com/marlonfallas/rh-vainilla-personalizado)

Sistema completo de gestión de recursos humanos basado en Horilla HRMS, personalizado para el mercado costarricense con **arquitectura híbrida modular**.

## 🏗️ Arquitectura Híbrida

Este repositorio implementa una **arquitectura evolutiva** que combina:

### 📦 Código Base Oficial
- **horilla_data/**: Código oficial de Horilla HRMS
- **horilla_data_backup/**: Respaldo del código base original

### 🇨🇷 Personalizaciones Modulares
- **customizations/**: Submodule con personalizaciones Costa Rica
- **Repositorio**: [rh-vainilla-personalizado](https://github.com/marlonfallas/rh-vainilla-personalizado)

### 🔧 Sistema Legacy (Compatibilidad)
- **custom_patches/**: Patches legacy (mantenidos para compatibilidad)
- **custom_translations/**: Traducciones legacy
- **scripts/**: Scripts híbridos legacy + modular

## 🚀 Uso Rápido

### Instalación Nueva
```bash
# Clonar repositorio principal
git clone https://github.com/marlonfallas/rh-vainilla.git
cd rh-vainilla

# Inicializar submodules
git submodule update --init --recursive

# Aplicar personalizaciones modulares
./scripts/integration.sh apply

# Levantar servicios
docker-compose up -d
```

### Sistema Existente
```bash
# Actualizar a arquitectura híbrida
git pull origin main
git submodule update --init --recursive

# Migrar configuraciones legacy
./scripts/integration.sh migrate

# Aplicar sistema modular
./scripts/integration.sh apply
```

## 🎯 Comandos Principales

### Sistema Híbrido Integrado
```bash
# Estado completo del sistema
./scripts/integration.sh status

# Aplicar personalizaciones modulares
./scripts/integration.sh apply

# Sincronizar con repo de personalizaciones
./scripts/integration.sh sync

# Backup híbrido completo
./scripts/integration.sh backup

# Actualización completa del sistema
./scripts/integration.sh update
```

### Personalizaciones Modulares (Directo)
```bash
# Aplicar todas las personalizaciones CR
./customizations/scripts/apply_customizations.sh

# Solo patches de código
./customizations/patches/apply_patches.sh

# Solo traducciones
./customizations/translations/apply_translations.sh

# Verificar estado
./customizations/scripts/apply_customizations.sh status
```

### Sistema Legacy (Compatibilidad)
```bash
# Backup híbrido (legacy + Git)
./scripts/backup_customizations_with_git.sh

# Actualización híbrida
./scripts/update_horilla_hybrid.sh

# Gestión de usuarios
./scripts/manage_users.sh
```

## 📁 Estructura del Proyecto

```
rh-vainilla/
├── horilla_data/              # Código oficial Horilla
├── customizations/            # Submodule personalizaciones CR
│   ├── patches/              #   Modificaciones código
│   ├── translations/         #   Traducciones Costa Rica
│   ├── scripts/             #   Herramientas modulares
│   ├── infrastructure/      #   Configuraciones Docker/Nginx
│   └── docs/               #   Documentación técnica
├── custom_patches/           # Legacy patches (compatibilidad)
├── custom_translations/      # Legacy traducciones (compatibilidad)
├── scripts/                 # Scripts híbridos
│   ├── integration.sh       #   Sistema híbrido principal
│   ├── backup_*.sh         #   Backups legacy + Git
│   └── update_*.sh         #   Actualizaciones híbridas
├── docker-compose.yml       # Configuración servicios
├── Dockerfile              # Imagen personalizada
└── README.md              # Esta documentación
```

## 🇨🇷 Características Costa Rica

### Nómina y Cálculos
- **Procesamiento mes actual** según legislación CR
- **Aguinaldo proporcional** automatizado
- **Vacaciones acumulativas** por ley
- **Deducciones CCSS, INS** automáticas

### Localización Completa
- **Terminología específica** Costa Rica
- **Formatos oficiales** Ministerio Trabajo
- **Zona horaria** América/Costa_Rica
- **Moneda** Colones costarricenses (CRC)

### Documentación Legal
- **Contratos de trabajo** formato CR
- **Planillas CCSS** automáticas
- **Reportes oficiales** gobierno
- **Constancias salariales** bancarias

## 🔄 Workflows de Trabajo

### Desarrollo
```bash
# 1. Hacer cambios en personalizaciones
cd customizations/
# (editar archivos)
git add . && git commit -m "mejora X"
git push origin main

# 2. Sincronizar en proyecto principal
cd ..
./scripts/integration.sh sync
./scripts/integration.sh apply

# 3. Probar y commitear integración
git add customizations
git commit -m "Update customizations"
```

### Producción
```bash
# Backup antes de cambios
./scripts/integration.sh backup

# Actualización completa
./scripts/integration.sh update

# Verificar funcionamiento
./scripts/integration.sh verify
```

### Rollback si es necesario
```bash
# Revertir personalizaciones
./customizations/patches/apply_patches.sh revert

# Restaurar desde backup Git
git log --oneline -10
git reset --hard [commit-anterior]

# O usar backup completo
# (ejecutar script de restauración específico)
```

## 🛠️ Desarrollo y Contribuciones

### Estructura Modular
- **Personalizaciones**: [rh-vainilla-personalizado](https://github.com/marlonfallas/rh-vainilla-personalizado)
- **Documentación**: Cada módulo incluye README específico
- **Tests**: Validación automática de personalizaciones
- **CI/CD**: Integración continua configurada

### Agregar Nueva Personalización
1. Clonar repo de personalizaciones
2. Crear branch para nueva feature
3. Implementar en módulo correspondiente
4. Documentar en README del módulo
5. Pull request al repo de personalizaciones
6. Sincronizar en proyecto principal

## 📊 Ventajas Arquitectura Híbrida

### Separación de Responsabilidades
- **Código oficial**: Mantenido separado
- **Personalizaciones**: Modulares y reutilizables
- **Configuraciones**: Versionadas independientemente

### Mantenibilidad
- **Updates limpios** del código base
- **Personalizaciones preservadas** automáticamente
- **Rollbacks granulares** por componente

### Escalabilidad
- **Reutilizable** para otros clientes
- **Modular** por tipo de personalización
- **Documentado** para fácil onboarding

### Compatibilidad
- **Sistema legacy** mantenido
- **Migración gradual** sin disrupciones
- **Scripts híbridos** funcionando

## 📞 Soporte

- **Documentación Técnica**: [customizations/docs/](customizations/docs/)
- **Issues Personalizaciones**: [GitHub Issues Customizations](https://github.com/marlonfallas/rh-vainilla-personalizado/issues)
- **Issues Proyecto Principal**: [GitHub Issues](https://github.com/marlonfallas/rh-vainilla/issues)
- **Email**: marlon@vainillacr.com

## 📄 Licencia

Este proyecto mantiene la licencia MIT del proyecto base Horilla.

---

**Desarrollado por Vainilla CR** - Especialistas en soluciones HRMS para Costa Rica

*Sistema híbrido que evoluciona gradualmente hacia arquitectura completamente modular*
