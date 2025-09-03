# 🔄 GUÍA DE ACTUALIZACIONES HORILLA HRMS

## 📊 Estado Actual de Actualizaciones

### **📍 Situación Actual (Sept 3, 2025)**
- **Commits atrasados**: 18 commits
- **Última actualización local**: 22 Agosto 2025 (commit 7781eb5b)
- **Última actualización disponible**: 03 Septiembre 2025 (commit 3948408d)
- **Modificaciones locales**: 3 archivos (sin conflictos)

### **🔒 Actualizaciones de Seguridad Disponibles**
- **XSS Protection**: Mejoras en patrones de detección XSS
- **API Security**: Correcciones en HORILLA_API
- **Input Validation**: Actualizaciones en validación de formularios

### **🐛 Fixes Importantes Disponibles**
- **PAYROLL**: Corrección en filing status (356e00c7)
- **EMPLOYEE**: Fix #905 (198ac689)
- **ONBOARDING**: Fix #896 (f52853d2)
- **RECRUITMENT**: Fix #875 (8b1d8255)
- **ACCESSIBILITY**: Fix para filtros multi-select (f0036bfe)

## 🚀 Proceso de Actualización

### **1. Verificación Pre-Actualización**
```bash
# Información completa de actualizaciones
./scripts/update_info.sh

# Verificar conflictos potenciales
./scripts/check_conflicts.sh

# Estado actual del sistema
./scripts/status.sh
```

### **2. Backup Preventivo**
```bash
# Backup completo
./scripts/backup-horilla.sh

# El backup incluye:
# - Base de datos PostgreSQL
# - Archivos media/uploads
# - Configuración (.env)
# - Código con modificaciones locales
```

### **3. Actualización Automática**
```bash
# Actualización con proceso automático y seguro
./scripts/update_horilla.sh

# O en modo desatendido (para cron)
./scripts/update_horilla.sh --auto
```

### **4. Verificación Post-Actualización**
```bash
# Verificar funcionamiento
./scripts/status.sh

# Acceder al sitio
curl -I https://rh.vainillacr.com

# Ver logs en tiempo real
docker logs horilla-vainilla -f
```

## 📋 Archivos Modificados Localmente

### **1. entrypoint.sh**
**Modificación**: Script de inicio personalizado
- ✅ **Preservar**: Mejoras de estabilidad y logging
- 🔧 **Función**: Configuración específica para producción

### **2. payroll/forms/component_forms.py**
**Modificación**: Validación de fechas personalizada
- ✅ **Preservar**: Permite payslips hasta fin de mes actual
- 🔧 **Función**: Lógica de negocio específica para Costa Rica

```python
# Modificación personalizada: Permitir hasta el fin del mes actual
last_day = monthrange(today.year, today.month)[1]
month_end = datetime.date(today.year, today.month, last_day)
```

### **3. payroll/signals.py**
**Modificación**: Señales personalizadas de payroll
- ✅ **Preservar**: Lógica específica del negocio
- 🔧 **Función**: Triggers personalizados para procesos de nómina

## 🔧 Scripts Disponibles

### **Scripts de Gestión**
```bash
./scripts/status.sh              # Estado completo del sistema
./scripts/backup-horilla.sh      # Backup manual completo
./scripts/update_info.sh         # Info de actualizaciones (dry-run)
./scripts/update_horilla.sh      # Actualización automática segura
./scripts/check_conflicts.sh     # Verificar conflictos pre-update
./scripts/set_spanish.sh         # Configurar idioma español
```

### **Scripts Docker**
```bash
# Gestión básica
docker-compose ps                 # Estado contenedores
docker-compose restart           # Reiniciar servicios
docker-compose logs -f horilla-vainilla  # Logs en tiempo real

# Comandos Django
docker-compose exec horilla-vainilla python manage.py migrate
docker-compose exec horilla-vainilla python manage.py collectstatic
docker-compose exec horilla-vainilla python manage.py createsuperuser
```

## ⚙️ Proceso de Actualización Detallado

### **Paso 1: Preparación**
- ✅ Verificar sistema funcionando
- ✅ Crear backup completo
- ✅ Identificar modificaciones locales
- ✅ Verificar conflictos potenciales

### **Paso 2: Git Stash y Pull**
- 🔄 Guardar cambios locales en stash
- 🔄 Pull de actualizaciones desde GitHub
- 🔄 Restaurar cambios locales sobre nueva base

### **Paso 3: Actualización Docker**
- 🐳 Rebuild imagen si requirements.txt cambió
- 🐳 Aplicar migraciones de base de datos
- 🐳 Recopilar archivos estáticos
- 🐳 Compilar traducciones

### **Paso 4: Verificación**
- ✅ Contenedores funcionando
- ✅ Base de datos accesible
- ✅ Interfaz web respondiendo
- ✅ SSL/HTTPS funcionando

## 📅 Calendario Recomendado

### **Inmediato (Próximos días)**
- **Prioridad**: ALTA (actualizaciones de seguridad)
- **Window**: Horario de menor tráfico
- **Duración estimada**: 5-10 minutos

### **Rutina Mensual**
- **Frecuencia**: Primera semana del mes
- **Verificar**: `./scripts/update_info.sh`
- **Aplicar**: Si hay 10+ commits o fixes de seguridad

## 🚨 Plan de Rollback

### **En caso de problemas**
```bash
# 1. Detener servicios
docker-compose down

# 2. Restaurar desde backup más reciente
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla/pre-update-YYYYMMDD_HHMMSS"

# 3. Restaurar base de datos
gunzip < $BACKUP_DIR/horilla_db_pre_update.sql.gz | \
docker exec -i postgres-horilla-vainilla psql -U horilla horilla

# 4. Restaurar archivos
cd /nvme0n1-disk/clientes/vainilla/horilla
rm -rf horilla_data/
tar -xzf $BACKUP_DIR/horilla_data_with_changes.tar.gz -C .

# 5. Reiniciar servicios
docker-compose up -d
```

## 📞 Contacto y Soporte

- **Documentación**: https://www.horilla.com/docs/
- **Issues**: https://github.com/horilla-opensource/horilla/issues
- **Logs sistema**: `docker logs horilla-vainilla`
- **Configuración**: `/nvme0n1-disk/clientes/vainilla/horilla/.env`

---

**📝 Última actualización**: Sept 3, 2025  
**👤 Administrador**: marlon@onespacecr.com  
**🌐 URL**: https://rh.vainillacr.com
