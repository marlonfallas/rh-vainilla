# 🚀 Horilla HRMS - Instalación para Vainilla

## 📋 Información General
- **URL**: https://rh.vainillacr.com
- **Puerto**: 8010 (interno)
- **Base de Datos**: PostgreSQL 16 (contenedor separado)
- **Ubicación**: /nvme0n1-disk/clientes/vainilla/horilla/

## 🔑 Credenciales Importantes

### Base de Datos
- **Usuario DB**: horilla
- **Password DB**: [Ver en .env]
- **Nombre DB**: horilla
- **Host**: postgres-horilla-vainilla

### Acceso Inicial
- **DB_INIT_PASSWORD**: [Ver en .env]
- Usar este password en la primera configuración desde la interfaz web

## 📁 Estructura de Directorios
```
/nvme0n1-disk/clientes/vainilla/horilla/
├── docker-compose.yml      # Configuración de contenedores
├── .env                    # Variables de entorno (SENSIBLE)
├── Dockerfile              # Imagen personalizada
├── horilla_data/           # Código fuente (git repo)
├── media/                  # Archivos subidos por usuarios
├── config/                 # Configuraciones adicionales
└── backup-horilla.sh       # Script de backup

/nvme1n1-disk/databases/vainilla/postgres-horilla/
└── [PostgreSQL Data]       # Base de datos

/sdb-disk/backups/vainilla/horilla/
└── [Backups]              # Backups automáticos
```

## 🚀 Comandos Útiles

### Gestión de Servicios
```bash
# Navegar al directorio
cd /nvme0n1-disk/clientes/vainilla/horilla/

# Ver estado
docker-compose ps

# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Reiniciar
docker-compose restart

# Ver logs
docker-compose logs -f horilla-vainilla
docker-compose logs -f postgres-horilla-vainilla
```

### Actualización del Sistema
```bash
# Método 1: Git Pull (Recomendado)
cd /nvme0n1-disk/clientes/vainilla/horilla/horilla_data
git pull origin master
cd ..
docker-compose restart horilla-vainilla
docker-compose exec horilla-vainilla python manage.py migrate

# Método 2: Rebuild completo
cd /nvme0n1-disk/clientes/vainilla/horilla/
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Backup Manual
```bash
cd /nvme0n1-disk/clientes/vainilla/horilla/
./backup-horilla.sh
```

### Acceso a la Base de Datos
```bash
# Conectar a PostgreSQL
docker exec -it postgres-horilla-vainilla psql -U horilla -d horilla

# Backup de BD
docker exec postgres-horilla-vainilla pg_dump -U horilla horilla > backup.sql

# Restore de BD
docker exec -i postgres-horilla-vainilla psql -U horilla horilla < backup.sql
```

### Django Management
```bash
# Crear superusuario
docker-compose exec horilla-vainilla python manage.py createsuperuser

# Migraciones
docker-compose exec horilla-vainilla python manage.py migrate

# Collectstatic
docker-compose exec horilla-vainilla python manage.py collectstatic --noinput

# Shell de Django
docker-compose exec horilla-vainilla python manage.py shell
```

## 🔧 Configuración de Nginx

El archivo de configuración está en:
`/etc/nginx/sites-available/rh.vainillacr.com`

Para activarlo:
```bash
sudo ln -s /etc/nginx/sites-available/rh.vainillacr.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔒 SSL/HTTPS

Generar certificado SSL:
```bash
sudo certbot --nginx -d rh.vainillacr.com
```

## 📊 Monitoreo

### Ver uso de recursos
```bash
docker stats horilla-vainilla postgres-horilla-vainilla
```

### Espacio en disco
```bash
du -sh /nvme0n1-disk/clientes/vainilla/horilla/
du -sh /nvme1n1-disk/databases/vainilla/postgres-horilla/
```

## 🔄 Proceso de Primera Configuración

1. Acceder a https://rh.vainillacr.com
2. Elegir una opción:
   - **Initialize Database**: Para producción
   - **Load Demo Data**: Para pruebas
3. Usar el DB_INIT_PASSWORD del archivo .env
4. Configurar:
   - Super Admin
   - Compañía principal
   - Departamento inicial
   - Posición de trabajo

## 🐛 Troubleshooting

### Si el servicio no inicia
```bash
# Ver logs detallados
docker-compose logs --tail=100 horilla-vainilla

# Verificar base de datos
docker exec postgres-horilla-vainilla pg_isready

# Reiniciar todo
docker-compose down
docker-compose up -d
```

### Si hay errores de migración
```bash
# Entrar al contenedor
docker-compose exec horilla-vainilla bash

# Ejecutar migraciones manualmente
python manage.py migrate --run-syncdb
```

### Si falta espacio
```bash
# Limpiar Docker
docker system prune -a

# Ver qué ocupa espacio
du -sh /nvme0n1-disk/clientes/vainilla/horilla/media/*
```

## 📝 Notas Importantes

- **Backups**: Se ejecutan manualmente o por cron
- **Actualizaciones**: Hacer backup antes de actualizar
- **Seguridad**: El .env contiene credenciales sensibles
- **Puerto**: 8010 está reservado para este servicio
- **Dominio**: rh.vainillacr.com configurado en Nginx

## 🔗 Enlaces

- **Repositorio**: https://github.com/horilla-opensource/horilla
- **Documentación**: https://www.horilla.com/docs/
- **Soporte**: https://github.com/horilla-opensource/horilla/issues

---
Instalado: 2025-01-27
Por: Claude AI Assistant
