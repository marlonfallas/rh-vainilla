#!/usr/bin/env python3
"""
Script para aplicar traducciones personalizadas a Horilla
Mantiene compatibilidad con actualizaciones de GitHub
"""

import os
import re
import shutil
from datetime import datetime

def apply_custom_translations():
    base_dir = "/nvme0n1-disk/clientes/vainilla/horilla"
    po_file = f"{base_dir}/horilla_data/horilla/locale/es/LC_MESSAGES/django.po"
    custom_file = f"{base_dir}/custom_translations/custom_translations.txt"
    
    # Leer traducciones personalizadas
    translations = {}
    with open(custom_file, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip() and not line.startswith('#') and '|' in line:
                original, custom = line.strip().split('|')
                translations[original] = custom
    
    # Hacer backup
    backup_file = f"{base_dir}/custom_translations/backup/django.po.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(po_file, backup_file)
    
    # Aplicar traducciones
    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for original, custom in translations.items():
        # Buscar y reemplazar en el archivo .po
        pattern = f'msgid "{original}"\\nmsgstr ".*?"'
        replacement = f'msgid "{original}"\\nmsgstr "{custom}"'
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    
    # Guardar cambios
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Traducciones aplicadas: {len(translations)} términos")
    print(f"📁 Backup guardado en: {backup_file}")

if __name__ == "__main__":
    apply_custom_translations()
