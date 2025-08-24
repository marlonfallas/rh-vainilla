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
