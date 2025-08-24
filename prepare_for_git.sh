#!/bin/bash

# Script para preparar el proyecto Horilla para Git
# Mantiene separación entre código original y personalizaciones

echo "========================================="
echo "  PREPARANDO HORILLA PARA GIT"
echo "========================================="

cd /nvme0n1-disk/clientes/vainilla/horilla

# 1. Crear estructura de Git
echo ""
echo "📁 Creando estructura Git..."

# Inicializar repositorio
git init

# 2. Crear .gitignore apropiado
echo ""
echo "📝 Creando .gitignore..."

cat > .gitignore << 'EOF'
# Environment Variables
.env
.env.local
.env.*.local

# Horilla Original Source (es un submodulo)
# horilla_data/

# Database
/nvme1n1-disk/databases/
*.sql
*.sql.gz
*.dump

# Media and Static Files
media/
staticfiles/
static/

# Python
*.pyc
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/

# Docker volumes
postgres-data/
redis-data/

# Backups
*.backup
*.bak
backups/
/sdb-disk/backups/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
*.tmp

# Certificates (sensitive)
*.pem
*.key
*.crt
*.csr

# Custom - No subir
custom_translations/backup/
EOF

echo "✅ .gitignore creado"

# 3. Crear README.md del repositorio
echo ""
echo "📄 Creando README del repositorio..."

cat > README_REPO.md << 'EOF'
# 🏢 Horilla HRMS - Implementación Vainilla

## 📋 Descripción

Implementación personalizada de [Horilla HRMS](https://github.com/horilla-opensource/horilla) para Vainilla CR, adaptada a la legislación laboral costarricense.

## 🚀 Características

- ✅ Configurado para Costa Rica (CCSS, cargas sociales, aguinaldo)
- ✅ Traducciones al español personalizadas
- ✅ Sistema de respaldos automatizado
- ✅ Dockerizado con PostgreSQL 16
- ✅ SSL con Let's Encrypt
- ✅ Documentación completa en español

## 📁 Estructura del Proyecto

```
.
├── docker-compose.yml          # Configuración de contenedores
├── Dockerfile                  # Imagen personalizada
├── docs/                       # Documentación completa
│   ├── installation/          # Guías de instalación
│   ├── configuration/         # Configuración del sistema
│   ├── maintenance/           # Mantenimiento y respaldos
│   └── customization/         # Personalizaciones
├── custom_translations/        # Sistema de traducciones
├── scripts/                    # Scripts de utilidad
├── horilla_data/              # Código fuente de Horilla (submodule)
└── config/                    # Configuraciones adicionales
```

## 🔧 Instalación Rápida

### Prerequisitos
- Ubuntu 20.04+ / Debian 10+
- Docker 20.10+
- Docker Compose 2.0+
- Nginx
- Git

### Clonar Repositorio
```bash
git clone https://github.com/tu-usuario/horilla-vainilla.git
cd horilla-vainilla
git submodule update --init --recursive
```

### Configuración
```bash
# Copiar variables de entorno
cp .env.example .env

# Editar configuración
nano .env

# Construir y levantar servicios
docker-compose up -d
```

## 📚 Documentación

Ver la documentación completa en el directorio [`docs/`](docs/README.md)

## 🇨🇷 Configuración para Costa Rica

- CCSS configurada (10.67% trabajador, 26.33% patrono)
- Banco Popular (1% trabajador, 0.5% patrono)
- Cálculo de aguinaldo automático
- Escalas de impuesto sobre la renta 2024-2025
- Vacaciones según Código de Trabajo

## 🔄 Actualizaciones

```bash
# Actualizar código base de Horilla
git submodule update --remote --merge

# Aplicar traducciones personalizadas
python3 custom_translations/apply_translations.py

# Reiniciar servicios
docker-compose restart
```

## 🛡️ Respaldos

Respaldos automáticos configurados diariamente a las 2:00 AM:
- Base de datos PostgreSQL
- Archivos multimedia
- Configuraciones

## 📝 Licencia

Este proyecto de implementación está bajo [MIT License](LICENSE).
Horilla HRMS está bajo su propia [licencia](https://github.com/horilla-opensource/horilla).

## 👥 Equipo

- **Implementación**: Marlon Fallas - Vainilla CR
- **Asistencia Técnica**: Claude AI Assistant
- **Fecha**: Enero 2025

## 🔗 Enlaces

- [Horilla Oficial](https://www.horilla.com)
- [Documentación Horilla](https://www.horilla.com/docs/)
- [Repositorio Original](https://github.com/horilla-opensource/horilla)
EOF

echo "✅ README del repositorio creado"

# 4. Configurar horilla_data como submodule
echo ""
echo "🔗 Configurando Horilla como submodule..."

# Remover el directorio actual temporalmente
mv horilla_data horilla_data_backup

# Agregar como submodule
git submodule add https://github.com/horilla-opensource/horilla.git horilla_data

# Restaurar configuraciones locales
cp -r horilla_data_backup/staticfiles horilla_data/ 2>/dev/null || true
cp horilla_data_backup/entrypoint.sh horilla_data/ 2>/dev/null || true

echo "✅ Submodule configurado"

# 5. Crear estructura de scripts
echo ""
echo "📂 Organizando scripts..."

mkdir -p scripts
mv backup-horilla.sh scripts/ 2>/dev/null || true
mv status.sh scripts/ 2>/dev/null || true
mv setup_translations.sh scripts/ 2>/dev/null || true
mv set_spanish.sh scripts/ 2>/dev/null || true

# 6. Crear archivo de ejemplo de variables
echo ""
echo "⚙️ Creando .env.example..."

cat > .env.example << 'EOF'
# Horilla Environment Configuration
# Production Settings

# Django Settings
DEBUG=False
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=rh.yourdomain.com,localhost,127.0.0.1
CSRF_TRUSTED_ORIGINS=https://rh.yourdomain.com
TIME_ZONE=America/Costa_Rica

# Database Configuration
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla
DB_USER=horilla
DB_PASSWORD=your-db-password-here
DB_HOST=postgres-horilla-vainilla
DB_PORT=5432

# Initial Setup Password
DB_INIT_PASSWORD=your-init-password-here

# Language Settings
LANGUAGE_CODE=es
USE_I18N=True
USE_L10N=True

# Email Settings (optional)
# EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
# EMAIL_HOST=smtp.gmail.com
# EMAIL_PORT=587
# EMAIL_USE_TLS=True
# EMAIL_HOST_USER=your-email@gmail.com
# EMAIL_HOST_PASSWORD=your-app-password
EOF

echo "✅ .env.example creado"

# 7. Crear LICENSE
echo ""
echo "📜 Creando LICENSE..."

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Vainilla CR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

echo "✅ LICENSE creado"

echo ""
echo "========================================="
echo "✅ PROYECTO PREPARADO PARA GIT"
echo "========================================="
echo ""
echo "📝 Próximos pasos:"
echo "1. Revisar archivos: git status"
echo "2. Agregar archivos: git add ."
echo "3. Primer commit: git commit -m 'Initial commit: Horilla HRMS for Vainilla'"
echo "4. Crear repo en GitHub"
echo "5. Agregar remoto: git remote add origin https://github.com/tu-usuario/horilla-vainilla.git"
echo "6. Push: git push -u origin main"
