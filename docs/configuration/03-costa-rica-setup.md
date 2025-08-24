# 03 - Configuración para Costa Rica

## 🇨🇷 Configuraciones Específicas del País

Este documento detalla todas las configuraciones necesarias para adaptar Horilla HRMS a la legislación laboral costarricense.

## 💰 Cargas Sociales y Deducciones

### Configuración de CCSS (Caja Costarricense del Seguro Social)

#### Deducciones del Trabajador
```
Navegación: Payroll → Deductions → Create

CCSS Trabajador:
- Title: CCSS OBRERO 10.67%
- Employee rate: 10.67
- Employer rate: 26.33
- Update compensation: Gross Pay
- Specific Employees: [Dejar vacío para todos]

Banco Popular:
- Title: Banco Popular Trabajador
- Employee rate: 1.0
- Employer rate: 0.5
- Update compensation: Gross Pay
```

#### Desglose de Cargas Sociales
| Concepto | Trabajador | Patrono | Total |
|----------|------------|---------|-------|
| **CCSS - Enfermedad y Maternidad (SEM)** | 5.50% | 9.25% | 14.75% |
| **CCSS - Invalidez, Vejez y Muerte (IVM)** | 4.17% | 5.08% | 9.25% |
| **CCSS - Otros** | 1.00% | 12.00% | 13.00% |
| **Total CCSS** | **10.67%** | **26.33%** | **37.00%** |
| **Banco Popular** | 1.00% | 0.50% | 1.50% |
| **GRAN TOTAL** | **11.67%** | **26.83%** | **38.50%** |

### Impuesto sobre la Renta

#### Configuración de Escalas 2024-2025
```
Navegación: Payroll → Federal Tax → Tax Brackets

Escala Mensual:
- Hasta ₡929,000: Exento
- De ₡929,001 a ₡1,363,000: 10%
- De ₡1,363,001 a ₡2,392,000: 15%
- De ₡2,392,001 a ₡4,783,000: 20%
- Más de ₡4,783,000: 25%
```

## 📅 Configuración de Vacaciones

### Escala de Vacaciones según Código de Trabajo
```
Navegación: Leave → Leave Types → Annual Leave

Configuración:
- Semanas 1-50: 1 día por mes (12 días al año)
- Después de 50 semanas: 14 días al año
- Después de 5 años: +1 día adicional cada 5 años
- Máximo: 20 días al año
```

### Días Feriados Oficiales 2025
```
Navegación: Leave → Holidays → Create

Feriados Obligatorios:
- 1 de enero: Año Nuevo
- 11 de abril: Día de Juan Santamaría
- 17 de abril: Jueves Santo
- 18 de abril: Viernes Santo
- 1 de mayo: Día del Trabajo
- 25 de julio: Anexión de Guanacaste
- 2 de agosto: Día de la Virgen de los Ángeles
- 15 de agosto: Día de la Madre
- 15 de septiembre: Día de la Independencia
- 25 de diciembre: Navidad

Feriados de Pago No Obligatorio:
- 12 de octubre: Día de las Culturas
```

## 💵 Salarios Mínimos 2025

### Configuración por Categoría
```
Navegación: Payroll → Contract → Basic Salary

Salarios Mínimos Mensuales (Decreto MTSS):
- Trabajador No Calificado: ₡365,300
- Trabajador Semicalificado: ₡396,165
- Trabajador Calificado: ₡415,830
- Trabajador Especializado: ₡461,472
- Técnico Medio: ₡508,285
- Técnico Especializado: ₡612,839
- Diplomado Universitario: ₡555,868
- Bachiller Universitario: ₡690,217
- Licenciado Universitario: ₡828,789
```

## 🎄 Aguinaldo (Decimotercer Mes)

### Configuración del Aguinaldo
```
Navegación: Payroll → Allowances → Create

Aguinaldo:
- Title: Aguinaldo 2025
- One time date: 20/12/2025
- Include all active employees: ON
- Is taxable: OFF (exento hasta 1 salario)
- Is fixed: OFF
- If choice: Basic Pay
- If amount: 8.33 (1/12 del año)
```

### Cálculo del Aguinaldo
- Período: 1 dic anterior al 30 nov actual
- Monto: Suma de salarios ordinarios / 12
- Pago: Antes del 20 de diciembre
- Exención: Hasta el monto de 1 salario mensual

## 🏥 Incapacidades y Licencias

### Configuración de Incapacidades CCSS
```
Navegación: Leave → Leave Types → Create

Incapacidad por Enfermedad:
- Primeros 3 días: 50% empleador
- Del día 4 en adelante: 60% CCSS
- Máximo: Según dictamen médico

Licencia de Maternidad:
- Duración: 4 meses (1 antes, 3 después)
- Pago: 100% (50% empleador, 50% CCSS)

Licencia de Paternidad:
- Duración: 8 días hábiles
- Pago: 100% empleador
```

## ⏰ Jornadas Laborales

### Configuración de Turnos
```
Navegación: Employee → Shift → Create

Jornada Diurna:
- Horario: 5:00 AM - 7:00 PM
- Máximo: 8 horas diarias, 48 semanales

Jornada Nocturna:
- Horario: 7:00 PM - 5:00 AM
- Máximo: 6 horas diarias, 36 semanales

Jornada Mixta:
- Combinación diurna/nocturna
- Máximo: 7 horas diarias, 42 semanales
```

### Horas Extra
```
Navegación: Payroll → Allowances → Create

Configuración:
- Tiempo y medio (1.5x): Primeras horas extra
- Doble (2x): Domingos y feriados
- Máximo legal: 4 horas diarias
```

## 📋 Liquidación Laboral

### Prestaciones Legales
```
Navegación: Offboarding → Settings

Cesantía:
- Hasta 3 meses: 7 días
- 6 meses: 14 días
- 1 año: 19.5 días por año
- 2 años: 20 días por año
- 3 años: 20.5 días por año
- 4 años: 21 días por año
- 5+ años: 21.24 días por año
- Máximo: 8 años

Preaviso:
- Menos de 3 meses: Ninguno
- 3-6 meses: 1 semana
- 6-12 meses: 15 días
- Más de 1 año: 1 mes

Vacaciones No Disfrutadas:
- Pago proporcional según tiempo laborado
```

## 📊 Reportes Obligatorios

### Planilla CCSS
```
Navegación: Reports → Payroll Reports

Incluir:
- Número de asegurado
- Salarios reportados
- Deducciones CCSS
- Aportes patronales
- Fecha de pago
```

### Declaración D-151 (Retenciones)
```
Información requerida:
- Cédula del trabajador
- Salario bruto
- Deducciones aplicadas
- Impuesto retenido
- Salario neto
```

## 🔧 Scripts de Configuración Automática

### Script de Configuración CR
```bash
#!/bin/bash
# Ubicación: /nvme0n1-disk/clientes/vainilla/horilla/setup_costa_rica.sh

echo "Configurando Horilla para Costa Rica..."

# Configurar zona horaria
docker exec horilla-vainilla python -c "
from django.conf import settings
settings.TIME_ZONE = 'America/Costa_Rica'
"

# Configurar moneda
docker exec horilla-vainilla python -c "
from django.conf import settings
settings.CURRENCY = 'CRC'
settings.CURRENCY_SYMBOL = '₡'
"

echo "✅ Configuración para Costa Rica completada"
```

## 📚 Referencias Legales

- [Código de Trabajo de Costa Rica](http://www.mtss.go.cr/elministerio/marco-legal/documentos/Codigo_Trabajo_RPL.pdf)
- [CCSS - Reglamentos](https://www.ccss.sa.cr/)
- [Ministerio de Trabajo (MTSS)](http://www.mtss.go.cr/)
- [Ministerio de Hacienda - Tributación](https://www.hacienda.go.cr/)

---

📌 **Relacionado**: 
- [02-payroll-config.md](02-payroll-config.md)
- [04-translations.md](04-translations.md)
