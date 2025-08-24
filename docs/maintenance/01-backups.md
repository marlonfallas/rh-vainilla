# 01 - Sistema de Respaldos

## 🔄 Visión General

Sistema automatizado de respaldos para Horilla HRMS que incluye base de datos, archivos multimedia y configuraciones.

## 📂 Estructura de Respaldos

```
/sdb-disk/backups/vainilla/horilla/
├── horilla_db_YYYYMMDD_HHMMSS.sql.gz     # Respaldo de base de datos
├── horilla_media_YYYYMMDD_HHMMSS.tar.gz  # Archivos multimedia
├── env_YYYYMMDD_HHMMSS.bak               # Variables de entorno
└── full_backup_YYYYMMDD_HHMMSS.tar.gz    # Respaldo completo
```

## 🔧 Script de Respaldo Principal

### Ubicación
```bash
/nvme0n1-disk/clientes/vainilla/horilla/backup-horilla.sh
```

### Contenido del Script
```bash
#!/bin/bash

# Variables de configuración
BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_CONTAINER="postgres-horilla-vainilla"
DB_NAME="horilla"
DB_USER="horilla"
APP_DIR="/nvme0n1-disk/clientes/vainilla/horilla"
RETENTION_DAYS=10

# Crear directorio si no existe
mkdir -p $BACKUP_DIR

echo "======================================"
echo "  RESPALDO HORILLA - $TIMESTAMP"
echo "======================================"

# 1. Respaldo de Base de Datos
echo "📊 Respaldando base de datos..."
docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME | gzip > "$BACKUP_DIR/horilla_db_$TIMESTAMP.sql.gz"

# 2. Respaldo de Archivos Multimedia
echo "📁 Respaldando archivos multimedia..."
tar -czf "$BACKUP_DIR/horilla_media_$TIMESTAMP.tar.gz" -C "$APP_DIR" media/

# 3. Respaldo de Configuración
echo "⚙️ Respaldando configuración..."
cp "$APP_DIR/.env" "$BACKUP_DIR/env_$TIMESTAMP.bak"

# 4. Respaldo de Traducciones Personalizadas
echo "🌐 Respaldando traducciones..."
tar -czf "$BACKUP_DIR/translations_$TIMESTAMP.tar.gz" -C "$APP_DIR" custom_translations/

# 5. Limpiar respaldos antiguos
echo "🧹 Limpiando respaldos antiguos..."
find $BACKUP_DIR -name "*.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.bak" -mtime +$RETENTION_DAYS -delete

echo "✅ Respaldo completado exitosamente"
echo "📍 Ubicación: $BACKUP_DIR"
```

## ⏰ Respaldos Automáticos con Cron

### Configurar Crontab
```bash
# Editar crontab
crontab -e

# Agregar líneas para respaldos automáticos
# Respaldo diario a las 2:00 AM
0 2 * * * /nvme0n1-disk/clientes/vainilla/horilla/backup-horilla.sh >> /var/log/horilla-backup.log 2>&1

# Respaldo semanal completo (domingos 3:00 AM)
0 3 * * 0 /nvme0n1-disk/clientes/vainilla/horilla/backup-full.sh >> /var/log/horilla-backup-full.log 2>&1
```

## 💾 Respaldo Completo del Sistema

### Script de Respaldo Completo
```bash
#!/bin/bash
# backup-full.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
APP_DIR="/nvme0n1-disk/clientes/vainilla/horilla"

echo "======================================"
echo "  RESPALDO COMPLETO - $TIMESTAMP"
echo "======================================"

# Detener servicios
cd $APP_DIR
docker-compose stop

# Crear respaldo completo
tar -czf "$BACKUP_DIR/full_backup_$TIMESTAMP.tar.gz" \
    --exclude="$APP_DIR/horilla_data/.git" \
    --exclude="$APP_DIR/horilla_data/__pycache__" \
    $APP_DIR \
    /nvme1n1-disk/databases/vainilla/postgres-horilla

# Reiniciar servicios
docker-compose start

echo "✅ Respaldo completo finalizado"
```

## 🔄 Restauración de Respaldos

### Restaurar Base de Datos
```bash
# Variables
BACKUP_FILE="horilla_db_20250127_020000.sql.gz"
DB_CONTAINER="postgres-horilla-vainilla"
DB_NAME="horilla"
DB_USER="horilla"

# Detener aplicación
docker-compose stop horilla-vainilla

# Restaurar base de datos
gunzip < /sdb-disk/backups/vainilla/horilla/$BACKUP_FILE | \
    docker exec -i $DB_CONTAINER psql -U $DB_USER $DB_NAME

# Reiniciar aplicación
docker-compose start horilla-vainilla
```

### Restaurar Archivos Multimedia
```bash
# Variables
BACKUP_FILE="horilla_media_20250127_020000.tar.gz"
APP_DIR="/nvme0n1-disk/clientes/vainilla/horilla"

# Hacer backup del estado actual
mv $APP_DIR/media $APP_DIR/media.old

# Restaurar archivos
tar -xzf /sdb-disk/backups/vainilla/horilla/$BACKUP_FILE -C $APP_DIR

# Verificar permisos
chown -R marlon:marlon $APP_DIR/media
```

### Restaurar Configuración
```bash
# Variables
BACKUP_FILE="env_20250127_020000.bak"
APP_DIR="/nvme0n1-disk/clientes/vainilla/horilla"

# Hacer backup actual
cp $APP_DIR/.env $APP_DIR/.env.current

# Restaurar configuración
cp /sdb-disk/backups/vainilla/horilla/$BACKUP_FILE $APP_DIR/.env

# Reiniciar servicios
cd $APP_DIR
docker-compose restart
```

## 📊 Verificación de Respaldos

### Script de Verificación
```bash
#!/bin/bash
# verify-backups.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"

echo "======================================"
echo "  VERIFICACIÓN DE RESPALDOS"
echo "======================================"

# Listar últimos respaldos
echo "📋 Últimos 5 respaldos de BD:"
ls -lht $BACKUP_DIR/horilla_db_*.gz | head -5

echo ""
echo "📁 Últimos 5 respaldos de media:"
ls -lht $BACKUP_DIR/horilla_media_*.tar.gz | head -5

echo ""
echo "⚙️ Últimos 5 respaldos de configuración:"
ls -lht $BACKUP_DIR/env_*.bak | head -5

echo ""
echo "💾 Espacio usado:"
du -sh $BACKUP_DIR

echo ""
echo "📊 Respaldos por tipo:"
echo "Base de datos: $(ls $BACKUP_DIR/horilla_db_*.gz 2>/dev/null | wc -l)"
echo "Media: $(ls $BACKUP_DIR/horilla_media_*.tar.gz 2>/dev/null | wc -l)"
echo "Configuración: $(ls $BACKUP_DIR/env_*.bak 2>/dev/null | wc -l)"
```

## 🚨 Respaldo de Emergencia

### Comando Rápido
```bash
# Respaldo rápido de base de datos
docker exec postgres-horilla-vainilla pg_dump -U horilla horilla | \
    gzip > ~/emergency_backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

## 📦 Respaldo Remoto

### Sincronización con Servidor Remoto
```bash
#!/bin/bash
# sync-remote-backup.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
REMOTE_SERVER="backup@servidor-remoto.com"
REMOTE_DIR="/backups/horilla"

# Sincronizar respaldos
rsync -avz --delete \
    $BACKUP_DIR/ \
    $REMOTE_SERVER:$REMOTE_DIR/

echo "✅ Sincronización remota completada"
```

### Respaldo en la Nube (S3)
```bash
# Instalar AWS CLI
apt-get install awscli

# Configurar credenciales
aws configure

# Sincronizar con S3
aws s3 sync $BACKUP_DIR s3://mi-bucket/horilla-backups/ \
    --delete \
    --exclude "*.tmp"
```

## 📋 Política de Retención

### Esquema Recomendado
- **Diarios**: Últimos 7 días
- **Semanales**: Últimas 4 semanas
- **Mensuales**: Últimos 12 meses
- **Anuales**: Permanente

### Script de Retención Avanzada
```bash
#!/bin/bash
# retention-policy.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"

# Mantener diarios (últimos 7 días)
find $BACKUP_DIR -name "*_db_*.gz" -mtime +7 -mtime -30 -delete

# Mantener semanales (domingos de las últimas 4 semanas)
# [Lógica para mantener solo respaldos de domingo]

# Mantener mensuales (día 1 de cada mes)
# [Lógica para mantener solo respaldos del día 1]

echo "✅ Política de retención aplicada"
```

## 🔍 Monitoreo de Respaldos

### Alertas por Email
```bash
#!/bin/bash
# backup-monitor.sh

BACKUP_DIR="/sdb-disk/backups/vainilla/horilla"
ADMIN_EMAIL="admin@vainillacr.com"
TODAY=$(date +%Y%m%d)

# Verificar si existe respaldo de hoy
if ! ls $BACKUP_DIR/horilla_db_$TODAY*.gz 1> /dev/null 2>&1; then
    echo "⚠️ No se encontró respaldo de hoy" | \
        mail -s "ALERTA: Falta respaldo Horilla" $ADMIN_EMAIL
fi
```

## 📈 Métricas y Logs

### Ubicación de Logs
```
/var/log/horilla-backup.log        # Log de respaldos diarios
/var/log/horilla-backup-full.log   # Log de respaldos completos
```

### Revisar Logs
```bash
# Ver últimos respaldos
tail -n 50 /var/log/horilla-backup.log

# Buscar errores
grep ERROR /var/log/horilla-backup.log

# Ver tamaño de logs
du -sh /var/log/horilla-backup*
```

## 🛠️ Troubleshooting

### Problema: Respaldo falla por espacio
```bash
# Verificar espacio
df -h /sdb-disk

# Limpiar respaldos antiguos manualmente
find /sdb-disk/backups -name "*.gz" -mtime +30 -delete
```

### Problema: Base de datos corrupta al restaurar
```bash
# Verificar integridad del respaldo
gunzip -t backup.sql.gz

# Restaurar con verbose
gunzip < backup.sql.gz | docker exec -i postgres-horilla-vainilla psql -v ON_ERROR_STOP=1 -U horilla horilla
```

---

📌 **Siguiente**: [02-updates.md](02-updates.md)
