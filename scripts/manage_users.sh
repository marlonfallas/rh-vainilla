#!/bin/bash

# ==========================================
# GESTIÓN DE USUARIOS HORILLA HRMS
# ==========================================

cd /nvme0n1-disk/clientes/vainilla/horilla

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_users() {
    echo -e "${BLUE}=========================================="
    echo "  USUARIOS ACTUALES EN HORILLA HRMS"
    echo -e "==========================================${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User
from employee.models import Employee

users = User.objects.all()
print(f'📊 Total de usuarios: {users.count()}\n')

for user in users:
    print(f'👤 {user.username}')
    print(f'   📧 Email: {user.email}')
    print(f'   📝 Nombre completo: {user.first_name} {user.last_name}'.strip())
    print(f'   🔐 Administrador: {'✅ SÍ' if user.is_superuser else '❌ NO'}')
    print(f'   👥 Staff: {'✅ SÍ' if user.is_staff else '❌ NO'}')
    print(f'   ✅ Activo: {'✅ SÍ' if user.is_active else '❌ NO'}')
    print(f'   📅 Último acceso: {user.last_login or 'Nunca'}')
    
    try:
        employee = Employee.objects.get(employee_user_id=user)
        print(f'   👷 Empleado: {employee.employee_first_name} {employee.employee_last_name}')
        print(f'   📱 Teléfono: {employee.phone}')
    except Employee.DoesNotExist:
        print(f'   ⚠️ Sin perfil de empleado')
    
    print()
"
}

create_admin_user() {
    echo -e "${YELLOW}=========================================="
    echo "  CREAR NUEVO USUARIO ADMINISTRADOR"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    echo -n "📧 Email: "
    read email
    echo -n "🔑 Contraseña: "
    read -s password
    echo
    echo -n "📝 Nombre: "
    read first_name
    echo -n "📝 Apellido: "
    read last_name
    
    echo ""
    echo -e "${BLUE}Creando usuario administrador...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    if User.objects.filter(username='$username').exists():
        print('❌ ERROR: El usuario ya existe')
    elif User.objects.filter(email='$email').exists():
        print('❌ ERROR: El email ya está en uso')
    else:
        user = User.objects.create_superuser(
            username='$username',
            email='$email',
            password='$password',
            first_name='$first_name',
            last_name='$last_name'
        )
        print(f'✅ Usuario administrador {user.username} creado exitosamente')
        print(f'📧 Email: {user.email}')
        print(f'🔐 Permisos: Superusuario y Staff')
except Exception as e:
    print(f'❌ Error creando usuario: {e}')
"
}

change_password() {
    echo -e "${YELLOW}=========================================="
    echo "  CAMBIAR CONTRASEÑA DE USUARIO"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    echo -n "🔑 Nueva contraseña: "
    read -s new_password
    echo
    
    echo ""
    echo -e "${BLUE}Cambiando contraseña...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    user = User.objects.get(username='$username')
    user.set_password('$new_password')
    user.save()
    print(f'✅ Contraseña cambiada para {user.username}')
except User.DoesNotExist:
    print('❌ ERROR: Usuario no encontrado')
except Exception as e:
    print(f'❌ Error: {e}')
"
}

make_admin() {
    echo -e "${YELLOW}=========================================="
    echo "  CONVERTIR USUARIO EN ADMINISTRADOR"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    
    echo ""
    echo -e "${BLUE}Otorgando permisos de administrador...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    user = User.objects.get(username='$username')
    user.is_superuser = True
    user.is_staff = True
    user.save()
    print(f'✅ {user.username} ahora es administrador')
    print(f'🔐 Permisos: Superusuario y Staff')
except User.DoesNotExist:
    print('❌ ERROR: Usuario no encontrado')
except Exception as e:
    print(f'❌ Error: {e}')
"
}

remove_admin() {
    echo -e "${YELLOW}=========================================="
    echo "  REMOVER PERMISOS DE ADMINISTRADOR"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    
    echo ""
    echo -e "${BLUE}Removiendo permisos de administrador...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    user = User.objects.get(username='$username')
    if user.username == 'mfallas':
        print('❌ ERROR: No se puede remover permisos del usuario principal mfallas')
    else:
        user.is_superuser = False
        user.is_staff = False
        user.save()
        print(f'✅ Permisos de administrador removidos de {user.username}')
except User.DoesNotExist:
    print('❌ ERROR: Usuario no encontrado')
except Exception as e:
    print(f'❌ Error: {e}')
"
}

deactivate_user() {
    echo -e "${YELLOW}=========================================="
    echo "  DESACTIVAR USUARIO"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    
    echo ""
    echo -e "${BLUE}Desactivando usuario...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    user = User.objects.get(username='$username')
    if user.username == 'mfallas':
        print('❌ ERROR: No se puede desactivar el usuario principal mfallas')
    else:
        user.is_active = False
        user.save()
        print(f'✅ Usuario {user.username} desactivado')
except User.DoesNotExist:
    print('❌ ERROR: Usuario no encontrado')
except Exception as e:
    print(f'❌ Error: {e}')
"
}

activate_user() {
    echo -e "${YELLOW}=========================================="
    echo "  ACTIVAR USUARIO"
    echo -e "==========================================${NC}"
    
    echo -n "👤 Nombre de usuario: "
    read username
    
    echo ""
    echo -e "${BLUE}Activando usuario...${NC}"
    
    docker-compose exec -T horilla-vainilla python manage.py shell -c "
from django.contrib.auth.models import User

try:
    user = User.objects.get(username='$username')
    user.is_active = True
    user.save()
    print(f'✅ Usuario {user.username} activado')
except User.DoesNotExist:
    print('❌ ERROR: Usuario no encontrado')
except Exception as e:
    print(f'❌ Error: {e}')
"
}

# Menú principal
main_menu() {
    while true; do
        echo ""
        echo -e "${GREEN}=========================================="
        echo "      GESTIÓN DE USUARIOS HORILLA"
        echo -e "==========================================${NC}"
        echo ""
        echo "1. 👥 Ver todos los usuarios"
        echo "2. ➕ Crear usuario administrador"
        echo "3. 🔑 Cambiar contraseña"
        echo "4. ⬆️ Hacer administrador"
        echo "5. ⬇️ Remover admin"
        echo "6. ❌ Desactivar usuario"
        echo "7. ✅ Activar usuario"
        echo "8. 🚪 Salir"
        echo ""
        echo -n "Selecciona una opción (1-8): "
        read option
        
        case $option in
            1) show_users ;;
            2) create_admin_user ;;
            3) change_password ;;
            4) make_admin ;;
            5) remove_admin ;;
            6) deactivate_user ;;
            7) activate_user ;;
            8) echo -e "${GREEN}¡Hasta luego!${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Opción inválida${NC}" ;;
        esac
        
        echo ""
        echo -n "Presiona Enter para continuar..."
        read
    done
}

# Ejecutar menú principal
main_menu
