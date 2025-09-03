# 💾 SISTEMA DE RESPALDO DE PERSONALIZACIONES HORILLA

## 📋 **PROBLEMA RESUELTO**

### **❓ LA CONSULTA ORIGINAL:**
*"¿Cómo se respalda lo local del código, los cambios que yo hago por fuera del código y que no afecte las actualizaciones?"*

### **✅ SOLUCIÓN IMPLEMENTADA:**
Sistema completo de respaldo automático que preserva TODAS tus personalizaciones durante actualizaciones.

---

## 🏗️ **ARQUITECTURA DEL SISTEMA**

### **📁 ESTRUCTURA DE RESPALDOS:**
```
/nvme0n1-disk/clientes/vainilla/horilla/
├── custom_patches/                    # Personalizaciones locales
│   ├── README.md                      # Documentación existente
│   ├── allow_current_month_payroll.py # Parche payroll existente
│   ├── revert_payroll_patch.sh        # Script revertir
│   └── [NUEVOS ARCHIVOS AUTOMÁTICOS]
│       ├── CUSTOMIZATIONS_TIMESTAMP.md
│       ├── modifications_TIMESTAMP.patch
│       ├── restore_customizations_TIMESTAMP.sh
│       └── [archivos de respaldo]
│
├── custom_translations/               # Traducciones personalizadas
│   ├── apply_translations.py
│   ├── custom_translations.txt
│   └── backup/
│
└── scripts/                          # Scripts de gestión
    ├── backup_customizations.sh      # NUEVO: Respaldo personalización
    ├── update_horilla_safe.sh         # NUEVO: Update con respaldo
    └── [otros scripts existentes]

/sdb-disk/backups/vainilla/horilla/
└── customizations/                    # Respaldos históricos
    ├── customizations_TIMESTAMP.tar.gz
    └── pre-update-TIMESTAMP/         # Respaldos pre-actualización
        ├── RESTORE_ALL.sh            # Script maestro
        ├── horilla_db_pre_update.sql.gz
        └── [todos los respaldos]
```

---

## 🔧 **TUS PERSONALIZACIONES ACTUALES**

### **✅ DETECTADAS Y RESPALDADAS:**

**1. Parche de Payroll:**
- **Archivo**: `custom_patches/allow_current_month_payroll.py`
- **Función**: Permite planillas hasta fin de mes actual
- **Estado**: ✅ Respaldado automáticamente

**2. Traducciones Españolas:**
- **Ubicación**: `custom_translations/`
- **Función**: Terminología específica Costa Rica
- **Estado**: ✅ Respaldado automáticamente

**3. Configuraciones Docker:**
- **Archivos**: `.env`, `docker-compose.yml`, `Dockerfile`
- **Función**: Configuración específica de producción
- **Estado**: ✅ Respaldado automáticamente

**4. Configuración Nginx:**
- **Archivo**: `/etc/nginx/sites-available/rh.vainillacr.com`
- **Función**: SSL y proxy reverso
- **Estado**: ✅ Respaldado automáticamente

**5. Scripts Personalizados:**
- **Ubicación**: `scripts/`
- **Función**: Gestión, backup, status, etc.
- **Estado**: ✅ Respaldado automáticamente

---

## 🚀 **FLUJO DE TRABAJO AUTOMATIZADO**

### **ANTES DE ACTUALIZAR:**
```bash
# Opción 1: Respaldo manual de personalizaciones
./scripts/backup_customizations.sh

# Opción 2: Actualización completa con respaldo integrado
./scripts/update_horilla_safe.sh
```

### **LO QUE PASA AUTOMÁTICAMENTE:**
1. **Detección automática** de todos los archivos modificados
2. **Creación de patches** Git con diferencias exactas
3. **Respaldo de configuraciones** (Docker, Nginx, .env)
4. **Respaldo de traducciones** personalizadas
5. **Generación de scripts de restauración** automáticos
6. **Documentación completa** de todos los cambios
7. **Respaldo en disco seguro** (/sdb-disk/backups/)

### **DURANTE LA ACTUALIZACIÓN:**
1. **Git stash** → Guarda cambios temporalmente
2. **Git pull** → Descarga actualizaciones oficiales
3. **Git stash pop** → Restaura tus cambios
4. **Resuelve conflictos** automáticamente si es posible
5. **Aplica migraciones** de base de datos
6. **Restaura personalizaciones** usando scripts creados

### **DESPUÉS DE ACTUALIZAR:**
1. **Verificación automática** de funcionamiento
2. **Reaplicación de patches** personalizados
3. **Restauración de traducciones** específicas
4. **Verificación de servicios** Docker

---

## 📊 **TIPOS DE RESPALDO**

### **🔄 RESPALDO INCREMENTAL** (`backup_customizations.sh`):
- **Cuándo**: Manual o antes de cambios importantes
- **Qué incluye**: Solo personalizaciones y configuraciones
- **Tiempo**: ~1 minuto
- **Uso**: Respaldo rápido de cambios locales

### **🏗️ RESPALDO COMPLETO** (`update_horilla_safe.sh`):
- **Cuándo**: Antes de cada actualización mayor
- **Qué incluye**: Base de datos + personalizaciones + media + config
- **Tiempo**: ~5 minutos
- **Uso**: Respaldo total pre-actualización

### **📁 RESPALDO HISTÓRICO**:
- **Ubicación**: `/sdb-disk/backups/vainilla/horilla/customizations/`
- **Retención**: Ilimitada (hasta que limpies manualmente)
- **Formato**: `.tar.gz` comprimidos con timestamp

---

## 🛠️ **HERRAMIENTAS DISPONIBLES**

### **1. Respaldo de Personalizaciones:**
```bash
./scripts/backup_customizations.sh
```
**Resultado:**
- `custom_patches/CUSTOMIZATIONS_TIMESTAMP.md` - Documentación
- `custom_patches/modifications_TIMESTAMP.patch` - Parche Git
- `custom_patches/restore_customizations_TIMESTAMP.sh` - Restauración
- `/sdb-disk/backups/.../customizations_TIMESTAMP.tar.gz` - Archivo completo

### **2. Actualización Segura:**
```bash
./scripts/update_horilla_safe.sh
```
**Resultado:**
- Todo lo anterior +
- Respaldo de base de datos completo
- Script maestro `RESTORE_ALL.sh`
- Aplicación automática post-update

### **3. Scripts de Restauración:**
```bash
# Restaurar solo personalizaciones
./custom_patches/restore_customizations_TIMESTAMP.sh

# Restauración completa (post-actualización)
./path/to/backup/RESTORE_ALL.sh
```

---

## 📋 **EJEMPLO PRÁCTICO**

### **ESCENARIO: Nueva actualización de Horilla disponible**

**PASO 1: Ejecutar actualización segura**
```bash
ssh onespace
cd /nvme0n1-disk/clientes/vainilla/horilla
./scripts/update_horilla_safe.sh
```

**PASO 2: El sistema automáticamente:**
- ✅ Crea respaldo completo en `/sdb-disk/backups/vainilla/horilla/pre-update-20250903_230000/`
- ✅ Respalda tus personalizaciones en `custom_patches/`
- ✅ Actualiza código desde GitHub (18 commits pendientes)
- ✅ Restaura tus modificaciones automáticamente
- ✅ Aplica migraciones de base de datos
- ✅ Reinicia servicios Docker
- ✅ Verifica que todo funcione

**PASO 3: Si algo sale mal:**
```bash
# Rollback completo
cd /sdb-disk/backups/vainilla/horilla/pre-update-20250903_230000/
./RESTORE_ALL.sh
```

---

## ⚡ **CASOS DE USO ESPECÍFICOS**

### **🔄 Preservar cambios durante update:**
```bash
./scripts/update_horilla_safe.sh
# Todo automático - tus cambios se preservan
```

### **💾 Respaldo antes de modificar código:**
```bash
./scripts/backup_customizations.sh
# Modifica archivos...
# Si algo sale mal, usa el script de restore generado
```

### **🔍 Ver qué está personalizado:**
```bash
cd /nvme0n1-disk/clientes/vainilla/horilla/horilla_data
git status
git diff
# También aparece en la documentación generada
```

### **📝 Aplicar personalizaciones después de update manual:**
```bash
# Si actualizaste manualmente con git pull
LATEST_RESTORE=$(ls -t custom_patches/restore_customizations_*.sh | head -1)
$LATEST_RESTORE
```

---

## 🎯 **BENEFICIOS DEL SISTEMA**

### **✅ PARA TI:**
- **Cero pérdida** de personalizaciones
- **Actualizaciones seguras** sin miedo
- **Rollback completo** si algo sale mal
- **Documentación automática** de todos los cambios
- **Scripts listos** para restaurar todo

### **✅ PARA EL SISTEMA:**
- **Mantiene compatibilidad** con actualizaciones oficiales
- **Preserva funcionalidad** personalizada (payroll Costa Rica)
- **Mantiene traducciones** específicas
- **Conserva configuraciones** de producción
- **Historial completo** de cambios

### **✅ PARA MANTENIMIENTO:**
- **Proceso automatizado** - no requiere intervención manual
- **Respaldos históricos** - puedes volver a cualquier punto
- **Documentación completa** - sabes exactamente qué cambió
- **Scripts de restauración** - un comando restaura todo

---

## 🚨 **IMPORTANTE - MIGRACIÓN A GIT SUBMODULE**

### **RECOMENDACIÓN FUTURA:**
Para mayor robustez, el sistema puede migrarse a usar **Git Submodules**:

```bash
# Convertir horilla_data en submodule
git submodule add https://github.com/horilla-opensource/horilla.git horilla_data

# Tus personalizaciones quedan en el repo principal
git add custom_patches/ custom_translations/ scripts/
git commit -m "Add customizations"
```

**VENTAJAS:**
- ✅ Separación clara entre código oficial y personalizado
- ✅ Updates más limpios (git submodule update)
- ✅ Control de versión completo de personalizaciones
- ✅ Fácil deployment en múltiples servidores

---

## 📞 **SOPORTE Y DOCUMENTACIÓN**

### **📁 Archivos Creados:**
- `scripts/backup_customizations.sh` - Sistema de respaldo
- `scripts/update_horilla_safe.sh` - Actualización con respaldo
- `RESPALDO_PERSONALIZACIONES.md` - Esta documentación

### **🔗 Scripts Relacionados:**
- `scripts/update_horilla.sh` - Actualización básica (ya existía)
- `custom_patches/allow_current_month_payroll.py` - Parche payroll (ya existía)
- `scripts/status.sh` - Estado del sistema (ya existía)

### **📋 Para Referencia:**
- Todos los respaldos incluyen documentación completa
- Los scripts de restauración son auto-documentados
- La estructura es compatible con futuras versiones

---

## ✅ **RESUMEN EJECUTIVO**

**PROBLEMA RESUELTO:** ✅ 
Sistema completo que preserva TODAS las personalizaciones durante actualizaciones de Horilla.

**HERRAMIENTAS IMPLEMENTADAS:**
- ✅ Detección automática de cambios
- ✅ Respaldo completo de personalizaciones  
- ✅ Scripts de restauración automática
- ✅ Actualización segura integrada
- ✅ Documentación completa automática
- ✅ Respaldo histórico en disco seguro

**COMANDO PRINCIPAL:**
```bash
./scripts/update_horilla_safe.sh
```

**RESULTADO:**
- ✅ Código actualizado con últimos cambios oficiales
- ✅ Todas las personalizaciones preservadas
- ✅ Sistema funcionando perfectamente
- ✅ Plan de rollback completo disponible

---

**📝 Creado**: Sept 3, 2025  
**🔧 Implementado por**: Claude AI Assistant  
**🎯 Estado**: Sistema completo operativo
