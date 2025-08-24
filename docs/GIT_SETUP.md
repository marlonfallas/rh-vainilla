# 📦 GUÍA COMPLETA: SUBIR HORILLA A GIT

## 🎯 Estrategia

Vamos a crear un repositorio Git que:
1. **Mantenga el código original de Horilla como submodule**
2. **Versione solo tus configuraciones y personalizaciones**
3. **No suba datos sensibles (.env, backups, etc.)**
4. **Permita actualizaciones fáciles del código base**

## 📋 Pasos para Configurar Git

### 1️⃣ Preparar el Proyecto

```bash
# Ejecutar script de preparación
cd /nvme0n1-disk/clientes/vainilla/horilla
chmod +x prepare_for_git.sh
./prepare_for_git.sh
```

### 2️⃣ Revisar y Ajustar .gitignore

```bash
# Verificar que .env NO se suba
cat .gitignore | grep .env

# Verificar archivos que se subirán
git status
```

### 3️⃣ Inicializar Repositorio Local

```bash
# Si no se hizo con el script
git init

# Configurar usuario
git config user.name "Marlon Fallas"
git config user.email "marlon@vainillacr.com"
```

### 4️⃣ Agregar Horilla como Submodule

```bash
# IMPORTANTE: Esto mantiene el código original separado
# Si ya existe horilla_data, hacer backup primero
mv horilla_data horilla_data_backup

# Agregar submodule
git submodule add https://github.com/horilla-opensource/horilla.git horilla_data

# Restaurar archivos personalizados
cp horilla_data_backup/entrypoint.sh horilla_data/
cp -r horilla_data_backup/staticfiles horilla_data/
```

### 5️⃣ Primer Commit

```bash
# Agregar archivos (excepto .env y otros sensibles)
git add .
git add -f .github/workflows/ci-cd.yml

# Verificar qué se va a commitear
git status

# Hacer commit inicial
git commit -m "🚀 Initial commit: Horilla HRMS for Vainilla CR

- Dockerized setup with PostgreSQL 16
- Costa Rica configuration (CCSS, taxes, holidays)
- Spanish translations system
- Automated backup scripts
- Complete documentation in Spanish
- GitHub Actions CI/CD pipeline"
```

## 🌐 Subir a GitHub

### Opción A: Crear Repositorio Público

1. Ve a https://github.com/new
2. Nombre: `horilla-vainilla`
3. Descripción: "Horilla HRMS implementation for Costa Rica"
4. **NO** inicialices con README (ya tenemos uno)
5. Crear repositorio

### Opción B: Crear Repositorio Privado

1. Ve a https://github.com/new
2. Nombre: `horilla-vainilla-private`
3. Marca como **Private**
4. Crear repositorio

### Conectar y Subir

```bash
# Agregar remoto (cambia URL por la tuya)
git remote add origin https://github.com/TU-USUARIO/horilla-vainilla.git

# Verificar remoto
git remote -v

# Push inicial
git push -u origin main

# Si tu branch se llama master, cambiarlo a main
git branch -M main
git push -u origin main
```

## 🔒 Configurar Secrets en GitHub

Para el CI/CD automático, ve a Settings → Secrets → Actions:

```yaml
PRODUCTION_HOST: 208.110.93.91
PRODUCTION_USER: marlon
PRODUCTION_SSH_KEY: [Tu clave SSH privada]
```

## 📁 Estructura Final del Repositorio

```
horilla-vainilla/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # CI/CD Pipeline
├── docs/                      # Documentación completa
│   ├── installation/
│   ├── configuration/
│   ├── maintenance/
│   └── customization/
├── scripts/                   # Scripts de utilidad
│   ├── backup-horilla.sh
│   ├── status.sh
│   └── setup_translations.sh
├── custom_translations/       # Traducciones personalizadas
│   ├── custom_translations.txt
│   └── apply_translations.py
├── config/                    # Configuraciones adicionales
├── docker-compose.yml         # Orquestación de contenedores
├── Dockerfile                 # Imagen Docker personalizada
├── .env.example              # Plantilla de variables
├── .gitignore                # Archivos ignorados
├── README.md                 # Documentación principal
├── LICENSE                   # Licencia MIT
└── horilla_data/            # [SUBMODULE] Código original de Horilla
```

## 🔄 Flujo de Trabajo con Git

### Hacer Cambios

```bash
# Crear rama para cambios
git checkout -b feature/nueva-funcionalidad

# Hacer cambios...
# Por ejemplo, actualizar traducciones
nano custom_translations/custom_translations.txt

# Commit
git add .
git commit -m "feat: Agregar nuevas traducciones"

# Push
git push origin feature/nueva-funcionalidad

# Crear Pull Request en GitHub
```

### Actualizar Horilla Original

```bash
# Actualizar submodule a última versión
git submodule update --remote horilla_data

# Verificar cambios
cd horilla_data
git log --oneline -5
cd ..

# Commit la actualización
git add horilla_data
git commit -m "chore: Actualizar Horilla a última versión"
git push
```

### Desplegar Cambios

```bash
# En el servidor de producción
cd /nvme0n1-disk/clientes/vainilla/horilla
git pull origin main
git submodule update --init --recursive

# Reconstruir si hay cambios en Docker
docker-compose build
docker-compose up -d

# Aplicar migraciones si hay
docker-compose exec horilla-vainilla python manage.py migrate
```

## 🏷️ Versionado Semántico

Usa tags para versiones:

```bash
# Crear tag de versión
git tag -a v1.0.0 -m "Primera versión estable con configuración CR"
git push origin v1.0.0

# Ver tags
git tag -l

# Formato recomendado:
# v1.0.0 - Cambios mayores
# v1.1.0 - Nuevas funcionalidades
# v1.1.1 - Correcciones y ajustes menores
```

## 📝 Plantilla de Commits

Usa conventional commits:

```
feat: Nueva funcionalidad
fix: Corrección de bug
docs: Cambios en documentación
style: Cambios de formato
refactor: Refactorización de código
test: Agregar tests
chore: Tareas de mantenimiento
```

Ejemplos:
```bash
git commit -m "feat: Agregar cálculo automático de aguinaldo"
git commit -m "fix: Corregir cálculo de CCSS para tiempo parcial"
git commit -m "docs: Actualizar guía de instalación"
git commit -m "chore: Actualizar dependencias de Docker"
```

## ⚠️ Importante: Seguridad

### NUNCA subas:
- ❌ Archivo `.env` con credenciales reales
- ❌ Certificados SSL (*.pem, *.key)
- ❌ Backups de base de datos
- ❌ Archivos de media/uploads de usuarios
- ❌ Logs con información sensible

### SIEMPRE:
- ✅ Usa `.env.example` como plantilla
- ✅ Documenta las variables necesarias
- ✅ Usa GitHub Secrets para CI/CD
- ✅ Revisa `git status` antes de commit

## 🚀 GitHub Actions

El pipeline CI/CD automáticamente:
1. Ejecuta tests
2. Construye imagen Docker
3. Despliega a producción (si está en main)

Para activarlo:
1. Sube el código a GitHub
2. Configura los secrets
3. Los workflows se ejecutan automáticamente

## 💡 Tips Adicionales

### Clonar en Otro Servidor

```bash
# Clonar con submodules
git clone --recursive https://github.com/tu-usuario/horilla-vainilla.git

# O si ya clonaste sin submodules
git submodule update --init --recursive
```

### Backup del Repositorio

```bash
# Crear bundle completo
git bundle create horilla-backup.bundle --all

# Restaurar desde bundle
git clone horilla-backup.bundle horilla-restored
```

### Limpiar Historia (si necesario)

```bash
# Eliminar archivos sensibles de la historia
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all
```

## 📞 Soporte

- **Issues**: Usa GitHub Issues para reportar problemas
- **Documentación**: Todo está en `/docs`
- **Updates**: Revisa releases en GitHub

---

✅ **¡Listo!** Ahora tienes una guía completa para versionar tu proyecto Horilla profesionalmente.
