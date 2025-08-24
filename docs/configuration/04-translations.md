# 04 - Sistema de Traducciones Personalizadas

## 🌐 Visión General

Sistema que permite personalizar las traducciones de Horilla sin afectar las actualizaciones desde GitHub.

## 📂 Estructura del Sistema

```
/nvme0n1-disk/clientes/vainilla/horilla/
├── custom_translations/
│   ├── custom_translations.txt    # Archivo de traducciones personalizadas
│   ├── apply_translations.py      # Script para aplicar traducciones
│   ├── apply_cr_terms.sh         # Términos específicos de Costa Rica
│   └── backup/                   # Respaldos automáticos
├── set_spanish.sh                # Cambiar idioma a español
└── setup_translations.sh         # Configurar sistema de traducciones
```

## 🔧 Configuración Inicial

### Paso 1: Cambiar a Español
```bash
cd /nvme0n1-disk/clientes/vainilla/horilla/
./set_spanish.sh
```

### Paso 2: Verificar Idioma
```bash
grep LANGUAGE_CODE .env
# Debe mostrar: LANGUAGE_CODE=es
```

## 📝 Personalizar Traducciones

### Formato del Archivo
El archivo `custom_translations/custom_translations.txt` usa el formato:
```
ORIGINAL|TRADUCCIÓN
```

### Ejemplo de Traducciones
```bash
# Editar archivo de traducciones
nano custom_translations/custom_translations.txt
```

Contenido ejemplo:
```
# TRADUCCIONES PERSONALIZADAS PARA COSTA RICA
# ==========================================

# Términos de RRHH
Allowance|Bonificación
Deduction|Deducción
Employee|Colaborador
Leave|Vacaciones
Attendance|Asistencia
Payroll|Planilla
Badge ID|Código de Empleado
Department|Departamento
Shift|Turno

# Términos Financieros
Basic Pay|Salario Base
Gross Pay|Salario Bruto
Net Pay|Salario Neto
Tax|Impuesto sobre la Renta
Insurance|CCSS
Overtime|Horas Extra
Bonus|Aguinaldo
Commission|Comisión

# Módulos
Recruitment|Reclutamiento
Onboarding|Inducción
Offboarding|Desvinculación
Performance|Evaluación

# Términos de Permisos
Sick Leave|Incapacidad
Annual Leave|Vacaciones Anuales
Maternity Leave|Licencia de Maternidad
Paternity Leave|Licencia de Paternidad

# Estados
Pending|Pendiente
Approved|Aprobado
Rejected|Rechazado
Draft|Borrador
Active|Activo
Inactive|Inactivo
```

## 🚀 Aplicar Traducciones

### Método 1: Script Python
```bash
# Aplicar traducciones
python3 custom_translations/apply_translations.py

# Compilar mensajes
docker exec horilla-vainilla python manage.py compilemessages

# Reiniciar servicio
docker-compose restart horilla-vainilla
```

### Método 2: Script Bash
```bash
# Aplicar términos de Costa Rica
./custom_translations/apply_cr_terms.sh

# Reiniciar
docker-compose restart horilla-vainilla
```

## 🔄 Mantener Traducciones Después de Actualización

### Proceso de Actualización
```bash
# 1. Actualizar código desde GitHub
cd horilla_data
git pull origin master
cd ..

# 2. Reaplicar traducciones personalizadas
python3 custom_translations/apply_translations.py

# 3. Compilar mensajes
docker exec horilla-vainilla python manage.py compilemessages

# 4. Reiniciar servicio
docker-compose restart horilla-vainilla
```

### Script Automático de Actualización
```bash
# Crear script de actualización
cat > update_with_translations.sh << 'EOF'
#!/bin/bash
echo "Actualizando Horilla con traducciones..."

# Actualizar código
cd horilla_data
git pull origin master
cd ..

# Aplicar traducciones
python3 custom_translations/apply_translations.py

# Compilar y reiniciar
docker exec horilla-vainilla python manage.py compilemessages
docker-compose restart horilla-vainilla

echo "✅ Actualización completada con traducciones"
EOF

chmod +x update_with_translations.sh
```

## 📋 Traducciones Recomendadas para Costa Rica

### Términos Legales y Fiscales
```
Social Security|Caja Costarricense del Seguro Social
Income Tax|Impuesto sobre la Renta
Christmas Bonus|Aguinaldo
Vacation Pay|Pago de Vacaciones
Severance|Cesantía
Notice Period|Preaviso
Popular Bank|Banco Popular
Worker's Compensation|Riesgos del Trabajo
```

### Términos de Planilla
```
Payslip|Comprobante de Pago
Pay Period|Período de Pago
Deductions|Deducciones
Earnings|Ingresos
Net Pay|Salario Neto
Gross Pay|Salario Bruto
Basic Salary|Salario Base
Allowances|Bonificaciones
```

## 🔍 Verificar Traducciones

### Ver traducciones aplicadas
```bash
# Buscar término específico
docker exec horilla-vainilla grep -n "Allowance" /app/horilla/locale/es/LC_MESSAGES/django.po

# Ver todas las traducciones personalizadas
cat custom_translations/custom_translations.txt | grep -v "^#"
```

## 🛠️ Solución de Problemas

### Las traducciones no se aplican
```bash
# Verificar idioma configurado
grep LANGUAGE_CODE .env

# Forzar recompilación
docker exec horilla-vainilla python manage.py compilemessages --force

# Limpiar caché
docker exec horilla-vainilla python manage.py clear_cache

# Reiniciar contenedor completo
docker-compose down
docker-compose up -d
```

### Restaurar traducciones originales
```bash
# Restaurar desde backup
cp custom_translations/backup/django.po.original.* \
   horilla_data/horilla/locale/es/LC_MESSAGES/django.po

# Recompilar
docker exec horilla-vainilla python manage.py compilemessages

# Reiniciar
docker-compose restart horilla-vainilla
```

## 📚 Referencias

- [Django i18n Documentation](https://docs.djangoproject.com/en/4.2/topics/i18n/)
- [gettext Format](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html)
- [Horilla GitHub](https://github.com/horilla-opensource/horilla)

---

📌 **Relacionado**: 
- [03-costa-rica-setup.md](03-costa-rica-setup.md)
- [02-payroll-config.md](02-payroll-config.md)
