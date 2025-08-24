# 01 - Requisitos del Sistema

## 📋 Requisitos Mínimos

### Hardware
- **CPU**: 2 cores mínimo (4+ recomendado)
- **RAM**: 4GB mínimo (8GB+ recomendado)
- **Disco**: 20GB espacio libre
- **Red**: Conexión estable a internet

### Software
- **Sistema Operativo**: Ubuntu 20.04+ / Debian 10+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Nginx**: 1.18+
- **Git**: 2.25+
- **Python**: 3.10+ (dentro del contenedor)
- **PostgreSQL**: 16 (dentro del contenedor)

## 🔧 Verificación de Requisitos

### Comandos de Verificación
```bash
# Verificar versión de Ubuntu/Debian
lsb_release -a

# Verificar Docker
docker --version

# Verificar Docker Compose
docker-compose --version

# Verificar Nginx
nginx -v

# Verificar Git
git --version

# Verificar espacio en disco
df -h

# Verificar memoria
free -h

# Verificar CPUs
nproc
```

## 🌐 Requisitos de Red

### Puertos Necesarios
- **80**: HTTP (redirige a HTTPS)
- **443**: HTTPS
- **8010**: Aplicación Horilla (interno)
- **5432**: PostgreSQL (interno)

### Dominios y DNS
- Dominio configurado apuntando al servidor
- Registro A o CNAME configurado
- Ejemplo: `rh.vainillacr.com → 208.110.93.91`

## 📦 Dependencias del Sistema

### Paquetes Ubuntu/Debian
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y \
    curl \
    wget \
    git \
    nginx \
    certbot \
    python3-certbot-nginx \
    docker.io \
    docker-compose
```

## 🔒 Requisitos de Seguridad

### Firewall
```bash
# Configurar UFW
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### Permisos de Usuario
- Usuario con acceso sudo
- Permisos para Docker
- Acceso a directorios de instalación

```bash
# Agregar usuario al grupo docker
sudo usermod -aG docker $USER
```

## ✅ Lista de Verificación Pre-Instalación

- [ ] Sistema operativo actualizado
- [ ] Docker y Docker Compose instalados
- [ ] Nginx instalado y funcionando
- [ ] Git instalado
- [ ] Dominio configurado y apuntando al servidor
- [ ] Puertos 80 y 443 abiertos
- [ ] Al menos 20GB de espacio libre
- [ ] Usuario con permisos sudo
- [ ] Backup del sistema (si aplica)

## 📊 Recursos Recomendados para Producción

### Para 50-100 usuarios
- **CPU**: 4 cores
- **RAM**: 8GB
- **Disco**: 50GB SSD
- **Red**: 100 Mbps

### Para 100-500 usuarios
- **CPU**: 8 cores
- **RAM**: 16GB
- **Disco**: 100GB SSD
- **Red**: 1 Gbps

### Para 500+ usuarios
- **CPU**: 16+ cores
- **RAM**: 32GB+
- **Disco**: 200GB+ SSD
- **Red**: 1 Gbps dedicado
- **Considerar**: Cluster PostgreSQL, Redis cache

---

📌 **Siguiente**: [02-docker-setup.md](02-docker-setup.md)
