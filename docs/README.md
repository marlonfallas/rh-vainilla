# 📚 Documentación Horilla HRMS - Vainilla

## 🏢 Sistema de Recursos Humanos
**Versión**: 1.0  
**Fecha de Instalación**: 2025-01-27  
**URL de Producción**: https://rh.vainillacr.com  
**Implementado por**: Claude AI Assistant + Marlon Fallas

---

## 📁 Estructura de Documentación

```
docs/
├── README.md                    # Este archivo (índice principal)
├── installation/                # Proceso de instalación
│   ├── 01-requirements.md      # Requisitos del sistema
│   ├── 02-docker-setup.md      # Configuración Docker
│   ├── 03-nginx-ssl.md         # Configuración Nginx y SSL
│   └── 04-initial-setup.md     # Configuración inicial
├── configuration/               # Configuraciones del sistema
│   ├── 01-company-setup.md     # Configuración de empresa
│   ├── 02-payroll-config.md    # Configuración de planilla
│   ├── 03-costa-rica-setup.md  # Configuraciones para CR
│   └── 04-translations.md      # Traducciones personalizadas
├── maintenance/                 # Mantenimiento y operaciones
│   ├── 01-backups.md           # Sistema de respaldos
│   ├── 02-updates.md           # Actualizaciones
│   ├── 03-monitoring.md        # Monitoreo
│   └── 04-troubleshooting.md   # Solución de problemas
└── customization/              # Personalizaciones
    ├── 01-translations.md      # Sistema de traducciones
    ├── 02-modules.md           # Módulos personalizados
    └── 03-integrations.md      # Integraciones

```

## 🚀 Inicio Rápido

### Acceso al Sistema
- **URL**: https://rh.vainillacr.com
- **Usuario Admin**: [Configurado durante instalación]
- **Puerto Docker**: 8010

### Comandos Esenciales
```bash
# Navegar al directorio
cd /nvme0n1-disk/clientes/vainilla/horilla/

# Ver estado
./status.sh

# Reiniciar servicios
docker-compose restart

# Ver logs
docker-compose logs -f horilla-vainilla

# Backup manual
./backup-horilla.sh
```

## 🏗️ Arquitectura del Sistema

### Stack Tecnológico
- **Backend**: Django (Python 3.10)
- **Base de Datos**: PostgreSQL 16
- **Contenedores**: Docker & Docker Compose
- **Proxy**: Nginx
- **SSL**: Let's Encrypt

### Estructura de Directorios
```
/nvme0n1-disk/clientes/vainilla/horilla/    # Aplicación
/nvme1n1-disk/databases/vainilla/postgres-horilla/  # Base de datos
/sdb-disk/backups/vainilla/horilla/         # Respaldos
```

## 🔧 Configuraciones Principales

### Variables de Entorno (.env)
- `DB_INIT_PASSWORD`: Password inicial de configuración
- `SECRET_KEY`: Llave secreta de Django
- `DB_PASSWORD`: Contraseña de PostgreSQL
- `ALLOWED_HOSTS`: Dominios permitidos
- `TIME_ZONE`: America/Costa_Rica

### Contenedores Docker
- `horilla-vainilla`: Aplicación principal
- `postgres-horilla-vainilla`: Base de datos

## 📋 Módulos del Sistema

1. **👥 Employee Management** - Gestión de empleados
2. **📅 Attendance** - Control de asistencia
3. **🏖️ Leave Management** - Gestión de vacaciones
4. **💰 Payroll** - Planilla y pagos
5. **📊 Performance** - Evaluación de desempeño
6. **🎯 Recruitment** - Reclutamiento
7. **📈 Reports** - Reportes y análisis

## 🛠️ Mantenimiento

### Respaldos Automáticos
- Script: `backup-horilla.sh`
- Ubicación: `/sdb-disk/backups/vainilla/horilla/`
- Retención: 10 últimos respaldos

### Actualizaciones
```bash
cd horilla_data
git pull origin master
cd ..
docker-compose restart horilla-vainilla
docker-compose exec horilla-vainilla python manage.py migrate
```

## 🌐 Personalizaciones para Costa Rica

### Cargas Sociales Configuradas
- CCSS Trabajador: 10.67%
- CCSS Patrono: 26.33%
- Banco Popular: 1%
- Impuesto sobre la Renta: Según escala

### Traducciones Personalizadas
- Sistema de traducción independiente
- Archivo: `custom_translations/custom_translations.txt`
- Script: `custom_translations/apply_translations.py`

## 📞 Soporte y Contacto

### Información Técnica
- **Servidor**: OneSpace (208.110.93.91)
- **Usuario SSH**: marlon
- **Directorio Base**: `/nvme0n1-disk/clientes/vainilla/horilla/`

### Repositorio Original
- **GitHub**: https://github.com/horilla-opensource/horilla
- **Documentación Oficial**: https://www.horilla.com/docs/

## 📝 Notas de Versión

### v1.0 - Instalación Inicial (2025-01-27)
- ✅ Instalación completa del sistema
- ✅ Configuración para Costa Rica
- ✅ Sistema de traducciones personalizado
- ✅ Integración con Nginx y SSL
- ✅ Scripts de mantenimiento

---

📌 **Tip**: Para más detalles, consulta los archivos específicos en cada subdirectorio de `docs/`
