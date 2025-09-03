#!/usr/bin/env python3
"""
Parche personalizado para permitir generar planillas del mes actual completo
Autor: Vainilla CR
Fecha: 2024-08-24
Versión: 2.0 - Corregido problema de import
"""

import os
import re
from datetime import datetime

def patch_payroll_form():
    """
    Modifica la validación de fechas para permitir hasta el último día del mes actual
    """
    file_path = "/nvme0n1-disk/clientes/vainilla/horilla/horilla_data/payroll/forms/component_forms.py"
    
    # Hacer backup
    backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Buscar y reemplazar la validación
    old_validation = """        if end_date > today:
            raise forms.ValidationError(
                {"end_date": "The end date cannot be in the future."}
            )"""
    
    new_validation = """        # Modificación personalizada: Permitir hasta el fin del mes actual
        last_day = monthrange(today.year, today.month)[1]
        month_end = datetime.date(today.year, today.month, last_day)
        
        if end_date > month_end:
            raise forms.ValidationError(
                {"end_date": f"La fecha final no puede ser posterior al {month_end.strftime('%d/%m/%Y')}"}
            )"""
    
    if old_validation in content:
        # Hacer backup
        with open(backup_path, 'w') as f:
            f.write(content)
        
        # Aplicar parche
        new_content = content.replace(old_validation, new_validation)
        
        # Agregar imports necesarios
        if "from calendar import monthrange" not in new_content:
            new_content = new_content.replace(
                "import datetime",
                "import datetime\nfrom calendar import monthrange"
            )
        
        with open(file_path, 'w') as f:
            f.write(new_content)
        
        print(f"✅ Parche aplicado exitosamente")
        print(f"📁 Backup guardado en: {backup_path}")
        return True
    else:
        print("⚠️ El código ya fue modificado o cambió la estructura")
        return False

if __name__ == "__main__":
    patch_payroll_form()
