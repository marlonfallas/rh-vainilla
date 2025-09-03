#!/bin/bash

# ==========================================
# CREAR USUARIO RÁPIDO CON CONTRASEÑA MANUAL
# ==========================================

cd /nvme0n1-disk/clientes/vainilla/horilla

echo "=========================================="
echo "    CREAR USUARIO CON CONTRASEÑA MANUAL"
echo "=========================================="

echo -n "👤 Nombre de usuario: "
read username
echo -n "📧 Email: "
read email
echo -n "🔑 Contraseña: "
read password
echo -n "📝 Nombre: "
read first_name
echo -n "📝 Apellido: "
read last_name

echo -n "🔐 ¿Es administrador? (s/N): "
read is_admin

echo ""
echo "Creando usuario..."

if [[ "$is_admin" == "s" || "$is_admin" == "S" ]]; then
    ADMIN_FLAGS="is_superuser=True, is_staff=True"
    ADMIN_TEXT="Administrador"
else
    ADMIN_FLAGS="is_superuser=False, is_staff=False"
    ADMIN_TEXT="Usuario regular"
fi

docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    if User.objects.filter(username='$username').exists():
        print('❌ ERROR: El usuario ya existe')
    elif User.objects.filter(email='$email').exists():
        print('❌ ERROR: El email ya está en uso')
    else:
        if '$is_admin' in ['s', 'S']:
            user = User.objects.create_superuser(
                username='$username',
                email='$email',
                password='$password',
                first_name='$first_name',
                last_name='$last_name'
            )
        else:
            user = User.objects.create_user(
                username='$username',
                email='$email',
                password='$password',
                first_name='$first_name',
                last_name='$last_name'
            )
        
        print('✅ Usuario creado exitosamente:')
        print(f'   👤 Usuario: {user.username}')
        print(f'   📧 Email: {user.email}')
        print(f'   📝 Nombre: {user.first_name} {user.last_name}')
        print(f'   🔑 Contraseña: $password')
        print(f'   🔐 Tipo: $ADMIN_TEXT')
        print(f'   🌐 Acceso: https://rh.vainillacr.com')
except Exception as e:
    print(f'❌ Error creando usuario: {e}')
"
