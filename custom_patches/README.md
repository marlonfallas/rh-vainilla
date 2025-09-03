# Parches Personalizados para Horilla - Vainilla CR

## 📋 Descripción
Este directorio contiene parches personalizados para adaptar Horilla a las necesidades específicas de Vainilla CR.

## 🎯 Parche: Permitir Planillas del Mes Actual

### Problema Original
Horilla no permite generar planillas con fechas futuras, lo que impide preparar la planilla completa del mes en curso.

### Solución
El parche modifica la validación para permitir fechas hasta el último día del mes actual.

### Uso

#### Aplicar el parche:
```bash
python3 /nvme0n1-disk/clientes/vainilla/horilla/custom_patches/allow_current_month_payroll.py
```

#### Revertir el parche:
```bash
/nvme0n1-disk/clientes/vainilla/horilla/custom_patches/revert_payroll_patch.sh
```

### ⚠️ Importante
- Este parche debe reaplicarse después de cada actualización de Horilla
- Siempre se crea un backup antes de aplicar cambios
- Los backups se guardan en el mismo directorio con timestamp

### Archivos Modificados
- `/nvme0n1-disk/clientes/vainilla/horilla/horilla_data/payroll/forms/component_forms.py`

### Cambios Realizados
- Línea 448-451: Cambio de validación de `today` a `fin_de_mes_actual`
- Mensaje de error personalizado en español

## 📝 Historial
- 2024-08-24: Creación inicial del parche
