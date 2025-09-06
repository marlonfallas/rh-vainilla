# 🚀 RH Vainilla - Clon Puro de Horilla HRMS

## 📋 Información General

Este repositorio es un **clon exacto** del código fuente oficial de [Horilla HRMS](https://github.com/horilla-opensource/horilla) mantenido por Vainilla CR.

### 🎯 Propósito
- **Código Fuente Puro**: Sin modificaciones ni personalizaciones
- **Base Estable**: Para uso con [rh-vainilla-personalizado](https://github.com/marlonfallas/rh-vainilla-personalizado)
- **Sincronización**: Actualizado regularmente con el repositorio oficial

## 🔄 Sincronización con Código Original

Este repositorio se mantiene sincronizado con:
- **Repositorio Original**: [horilla-opensource/horilla](https://github.com/horilla-opensource/horilla)
- **Rama Principal**: `master`
- **Frecuencia**: Actualizaciones semanales automáticas

### Último Sincronizado
- **Fecha**: $(date '+%Y-%m-%d')
- **Commit Original**: [Ver última versión](https://github.com/horilla-opensource/horilla)

## ⚠️ Importante

### ❌ NO Modificar Este Repositorio
- Este repositorio NO debe contener personalizaciones
- NO hacer commits de cambios específicos de Vainilla CR
- NO agregar configuraciones de deployment específicas

### ✅ Para Personalizaciones
- Usar: [rh-vainilla-personalizado](https://github.com/marlonfallas/rh-vainilla-personalizado)
- Las personalizaciones se aplican sobre este código base puro
- Sistema modular mantiene separación limpia

## 🏗️ Arquitectura de Deployment

### Flujo Completo
```
1. rh-vainilla (este repo) = Código fuente puro Horilla
2. rh-vainilla-personalizado = Personalizaciones Costa Rica
3. Docker Build = Combina ambos automáticamente
4. Deploy = Imagen final con personalizaciones aplicadas
```

### Dockerfile Multi-Stage
```dockerfile
# Stage 1: Clonar código base puro
FROM alpine/git as horilla-base
RUN git clone https://github.com/marlonfallas/rh-vainilla.git .

# Stage 2: Aplicar personalizaciones Costa Rica  
FROM python:3.10-slim
COPY --from=horilla-base /src .
COPY . /customizations
RUN /customizations/scripts/apply_customizations.sh
```

## 🔧 Comandos de Desarrollo

### Verificar Sincronización
```bash
# Verificar si está actualizado con el original
git remote add upstream https://github.com/horilla-opensource/horilla.git
git fetch upstream
git status
```

### Actualizar desde Original
```bash
# Solo para mantenedores del repositorio
git fetch upstream
git reset --hard upstream/master
git push origin main --force
```

## 📖 Documentación Original

Para documentación completa de Horilla HRMS:
- **Sitio Oficial**: [horilla.com](https://www.horilla.com/)
- **Documentación**: [docs.horilla.com](https://docs.horilla.com/)
- **Repositorio Original**: [github.com/horilla-opensource/horilla](https://github.com/horilla-opensource/horilla)

## 🇨🇷 Implementación Costa Rica

Para implementar Horilla con personalizaciones Costa Rica:

### Opción 1: Usar Docker (Recomendado)
```bash
# Usar rh-vainilla-personalizado que incluye todo
git clone https://github.com/marlonfallas/rh-vainilla-personalizado.git
cd rh-vainilla-personalizado
docker-compose up -d
```

### Opción 2: Desarrollo Local
```bash
# 1. Clonar código base puro
git clone https://github.com/marlonfallas/rh-vainilla.git
cd rh-vainilla

# 2. Clonar personalizaciones
git clone https://github.com/marlonfallas/rh-vainilla-personalizado.git customizations

# 3. Aplicar personalizaciones
./customizations/scripts/apply_customizations.sh apply

# 4. Continuar con setup normal de Horilla
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

## 🔗 Repositorios Relacionados

### Oficial Horilla
- [horilla-opensource/horilla](https://github.com/horilla-opensource/horilla) - Código fuente oficial

### Vainilla CR
- [rh-vainilla-personalizado](https://github.com/marlonfallas/rh-vainilla-personalizado) - Personalizaciones Costa Rica
- [rh-vainilla](https://github.com/marlonfallas/rh-vainilla) - Este repositorio (código puro)

## 📄 Licencia

Este proyecto mantiene la misma licencia que Horilla original:
- **Licencia**: LGPL-2.1
- **Detalles**: Ver [LICENSE](LICENSE)

## 📞 Soporte

### Para Horilla Original
- **Issues**: [horilla-opensource/horilla/issues](https://github.com/horilla-opensource/horilla/issues)
- **Email**: support@horilla.com

### Para Implementación Costa Rica
- **Issues**: [rh-vainilla-personalizado/issues](https://github.com/marlonfallas/rh-vainilla-personalizado/issues)
- **Email**: marlon@vainillacr.com
- **Web**: [vainillacr.com](https://vainillacr.com)

---

**Vainilla CR** - Especialistas en implementaciones HRMS para Costa Rica

*Este repositorio es mantenido por Vainilla CR como base estable para deployments empresariales de Horilla HRMS en Costa Rica.*
