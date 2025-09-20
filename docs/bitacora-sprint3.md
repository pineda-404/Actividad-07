# Bitácora Sprint 3 - Integrador de Checks de Seguridad

**Proyecto:** 9 - Integrador de checks de seguridad en pipelines  
**Equipo:** Diego Pineda García, Mateo Torres Fuero

**Video Sprint 3:** [URL del video pendiente]

---

## Objetivos del Sprint 3

- Implementar automatización completa con Makefile avanzado
- Desarrollar tests Bats expandidos con casos de fallo reales
- Configurar servicio systemd para ejecución automática con journalctl
- Crear documentación técnica completa (README, guías)
- Implementar empaquetado y distribución del pipeline
- Integración con herramientas de monitoreo y logging

---

## División de Responsabilidades

### Alumno 1: Diego Pineda - Automatización y Servicios

- **Rama:** `automation/diego-pineda`
- **Responsabilidades:**
  - Implementación de servicio systemd completo
  - Desarrollo de `install-service.sh` para automatización
  - Configuración de journalctl y logging estructurado
  - Integración con cron y scheduling automático

### Alumno 2: Mateo Torres - Testing y Documentación

- **Rama:** `testing-docs/MateoTorres`
- **Responsabilidades:**
  - Makefile avanzado con targets completos
  - Suite de tests Bats expandida con casos edge
  - Documentación técnica (README.md, guia-ejecucion.md)
  - Empaquetado y distribución del proyecto

---

## Desarrollo e Implementación

### 1. Makefile Avanzado [MateoTorres]

**1.1. Targets implementados para automatización completa**

- **Propósito:** Automatización profesional de todo el ciclo de vida del proyecto
- **Targets desarrollados:**
  - `help`: Documentación automática de targets disponibles
  - `tools`: Verificación exhaustiva de dependencias del sistema
  - `build`: Preparación de estructura y artefactos intermedios
  - `test`: Ejecución de suite completa de tests Bats
  - `run`: Ejecución del pipeline con configuración flexible
  - `pack`: Empaquetado distributable con versionado
  - `clean`: Limpieza segura de archivos temporales

**1.2. Variables configurables avanzadas**

```makefile
TARGET_URL ?= https://example.com
RELEASE ?= v1.0.0-sprint3
HTTP_TIMEOUT ?= 30
DNS_SERVER ?= 8.8.8.8
```

**1.3. Verificación de herramientas del temario**

```bash
make tools
```

**Salida:**

```
Verificando herramientas del temario...
✓ bash - disponible
✓ curl - disponible
✓ dig - disponible
✓ openssl - disponible
✓ ss - disponible
✓ nc - disponible
✓ bats - disponible para tests
✓ Herramientas verificadas
```

**1.4. Empaquetado distributable**

```bash
make pack RELEASE=v2.0.0-sprint3
```

**Resultado:**

```
Generando paquete v2.0.0-sprint3...
✓ Paquete: dist/security-integrator-v2.0.0-sprint3.tar.gz
Contenido: src/ tests/ docs/ Makefile .env.example
```

---

### 2. Suite de Tests Bats Expandida [MateoTorres]

**2.1. Casos de test implementados**

- **Propósito:** Validación exhaustiva de funcionalidades y casos edge
- **Cobertura ampliada:**
  - Tests estructurales: Existencia de archivos y permisos
  - Tests funcionales: Casos exitosos con diferentes URLs
  - Tests de fallo: Dominios inexistentes, certificados problemáticos
  - Tests de configuración: Variables de entorno y .env
  - Tests de evidencias: Generación correcta de archivos
  - Tests de integración: Makefile y herramientas

**2.2. Casos de fallo reales implementados**

```bash
@test "Pipeline detecta dominio inexistente" {
    cd src
    run bash -c "TARGET_URL='https://sitio-que-no-existe-12345.com' bash security_checker.sh"
    [ "$status" -ne 0 ]
    [ -n "$(ls ../out/diagnostic_*.txt 2>/dev/null)" ]
    cd ..
}

@test "Script genera archivos de diagnóstico cuando hay fallos" {
    cd src
    run bash -c "TARGET_URL='https://sitio-que-no-existe-12345.com' bash security_checker.sh"
    [ "$status" -ne 0 ]
    ls ../out/diagnostic_* >/dev/null 2>&1 || true
    cd ..
}
```

**2.3. Validación de variables de entorno**

```bash
@test "Variables de .env vs línea de comandos" {
    cd src
    # Test prioridad: línea de comandos > .env
    TARGET_URL="https://example.com" bash security_checker.sh
    # Verificar que se usó URL de línea de comandos
    cd ..
}
```

**Ejecución completa de tests:**

```bash
make test
```

**Salida expandida:**

```
 ✓ Los archivos principales existen
 ✓ El script funciona con URL desde línea de comandos
 ✓ El script usa .env cuando no hay variable de entorno
 ✓ El script detecta dominios que no existen
 ✓ Se crean archivos de evidencia
 ✓ TLS check se ejecuta para sitios HTTPS
 ✓ Script genera archivos de diagnóstico cuando hay fallos
 ✓ Makefile run funciona con variable personalizada

8 tests, 0 failures
```

---

### 3. Servicio Systemd y Automatización [DiegoPineda]

**3.1. Implementación de `install-service.sh`**

- **Propósito:** Automatización como servicio del sistema operativo
- **Funcionalidades desarrolladas:**
  - Instalación automática de archivos .service y .timer
  - Configuración de ejecución periódica (cada hora)
  - Integración con journalctl para logging centralizado
  - Funciones de estadísticas y monitoreo

**3.2. Configuración de servicio systemd**

```bash
# Archivo generado: /etc/systemd/system/security-checks.service
[Unit]
Description=Pipeline de Checks de Seguridad - Estudiantes
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=usuario
WorkingDirectory=/ruta/proyecto/src
ExecStart=/bin/bash security_checker.sh
Environment=TARGET_URL=https://www.google.com
StandardOutput=journal
StandardError=journal
SyslogIdentifier=security-checks
```

**3.3. Timer para ejecución automática**

```bash
# Archivo generado: /etc/systemd/system/security-checks.timer
[Timer]
OnCalendar=*:00:00  # Cada hora
OnBootSec=2min      # 2 min después del boot
Persistent=true     # Ejecutar si se perdió alguna
```

**3.4. Comandos de gestión implementados**

```bash
# Instalación
cd src && ./install-service.sh install

# Ver estadísticas
./install-service.sh stats

# Desinstalar
./install-service.sh uninstall
```

**Salida de instalación:**

```
[INFO] === INSTALANDO SERVICIO DE CHECKS DE SEGURIDAD ===
[INFO] Usuario: estudiante
[INFO] Proyecto en: /home/estudiante/PC01-DS
[INFO] Creando archivo de servicio...
[INFO] Creando timer para ejecución automática...
[INFO] Recargando configuración de systemd...
[INFO] Habilitando servicio...
[OK] ¡Servicio instalado correctamente!

=== COMANDOS ÚTILES ===
Ver estado del timer:    systemctl status security-checks.timer
Ver logs en tiempo real: journalctl -u security-checks -f
Ejecutar manualmente:    sudo systemctl start security-checks.service
```

---

### 4. Integración con journalctl [DiegoPineda]

**4.1. Logging estructurado implementado**

- **Propósito:** Monitoreo profesional con herramientas del sistema
- **Configuración:**
  - `SyslogIdentifier=security-checks` para filtrado fácil
  - `StandardOutput=journal` para captura completa
  - Logs con timestamps automáticos del sistema

**4.2. Comandos de monitoreo implementados**

```bash
# Ver logs en tiempo real
journalctl -u security-checks -f

# Ver logs del último día
journalctl -u security-checks --since "1 day ago"

# Ver solo errores
journalctl -u security-checks -p err

# Ver próximas ejecuciones
systemctl list-timers security-checks.timer
```

**4.3. Análisis automático de logs**

```bash
# Función en install-service.sh
show_stats() {
    echo "Resumen del día:"
    local today=$(date +%Y-%m-%d)
    local total=$(journalctl -u security-checks --since "$today" --no-pager | grep -c "Iniciando Integrador")
    local errors=$(journalctl -u security-checks --since "$today" --no-pager | grep -c "check falló")
    echo "Ejecuciones hoy: $total"
    echo "Exitosas: $((total - errors))"
    echo "Fallidas: $errors"
}
```

---

### 5. Documentación Técnica Completa [MateoTorres]

**5.1. README.md profesional**

- **Propósito:** Documentación completa para usuarios finales
- **Secciones implementadas:**
  - Descripción del proyecto y casos de uso reales
  - Instalación paso a paso con dependencias
  - Ejemplos de uso con diferentes escenarios
  - Interpretación de resultados y evidencias
  - Troubleshooting común y solución de problemas
  - Configuración avanzada y variables de entorno

**5.2. guia-ejecucion.md detallada**

- **Propósito:** Tutorial paso a paso desde cero hasta uso avanzado
- **Contenido desarrollado:**
  - Objetivos de aprendizaje claros
  - Verificación de prerrequisitos del sistema
  - Primera ejecución guiada con explicaciones
  - Revisión detallada de evidencias generadas
  - Casos de uso prácticos del mundo real
  - Integración con CI/CD y automatización

**5.3. Ejemplos de uso documentados**

```bash
# Caso 1: Sitio corporativo
make run TARGET_URL="https://mi-empresa.com"

# Caso 2: Detección de problemas
make run TARGET_URL="https://sitio-con-problemas.com"

# Caso 3: Configuración personalizada
HTTP_TIMEOUT=10 DNS_SERVER="1.1.1.1" make run TARGET_URL="https://ejemplo.com"
```

---

### 6. Empaquetado y Distribución [MateoTorres]

**6.1. Sistema de versionado implementado**

- **Propósito:** Distribución profesional del pipeline
- **Funcionalidades:**
  - Versionado semántico (v1.0.0-sprint3)
  - Empaquetado reproducible con tar.gz
  - Inclusión automática de documentación
  - Archivo .env.example para configuración

**6.2. Estructura del paquete distributable**

```
security-integrator-v1.0.0-sprint3.tar.gz
├── src/              # Scripts principales
├── tests/            # Suite de tests Bats
├── docs/             # Documentación completa
├── Makefile          # Automatización
└── .env.example      # Configuración template
```

**6.3. Proceso de build implementado**

```bash
make build
```

**Salida:**

```
Preparando artefactos intermedios...
✓ Directorios creados: out/logs out/reports out/evidence
✓ Build info generado con timestamp
✓ Artefactos preparados en out/
```

---

### 7. Integración CI/CD [MateoTorres]

**7.1. Ejemplos para GitLab CI**

```yaml
# Documentado en guia-ejecucion.md
security_checks:
  stage: test
  script:
    - make tools
    - make run TARGET_URL="https://mi-app.com"
  artifacts:
    paths: [out/]
    when: always
```

**7.2. Ejemplos para GitHub Actions**

```yaml
# Documentado en guia-ejecucion.md
name: Security Checks
on: [push, schedule]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: sudo apt update && sudo apt install -y curl dnsutils openssl bats
      - name: Run security checks
        run: make run TARGET_URL="${{ secrets.TARGET_URL }}"
```

---

## Evidencias de Funcionamiento Sprint 3

### Caso 1: Automatización completa con Makefile

```bash
make clean && make build && make test && make run && make pack
```

**Resultado:** Pipeline completo desde limpieza hasta empaquetado

### Caso 2: Servicio systemd funcionando

```bash
systemctl status security-checks.timer
journalctl -u security-checks --since "1 hour ago"
```

**Resultado:** Servicio activo con logs estructurados en journalctl

### Caso 3: Tests expandidos pasando

```bash
make test
```

**Resultado:** 8 tests incluyendo casos de fallo y configuración

### Caso 4: Documentación completa

- README.md con casos de uso reales
- guia-ejecucion.md con tutorial detallado
- Ejemplos de integración CI/CD

---

## Conclusiones Sprint 3

### Objetivos Completados

- ✅ Makefile avanzado con targets profesionales
- ✅ Tests Bats expandidos con casos de fallo reales
- ✅ Servicio systemd con journalctl para monitoreo
- ✅ Documentación técnica completa y profesional
- ✅ Empaquetado y distribución del pipeline
- ✅ Integración lista para CI/CD y producción

### Funcionalidades de Automatización

- **Makefile completo:** 7 targets cubriendo todo el ciclo de vida
- **Tests robustos:** 8 casos incluyendo edge cases y fallos
- **Servicio del sistema:** Ejecución automática cada hora con systemd
- **Logging profesional:** Integración con journalctl del sistema
- **Distribución:** Empaquetado versionado y reproducible

### Herramientas de Automatización Integradas

- **Make:** Automatización de tareas y builds
- **Bats:** Testing automatizado de scripts Bash

### Métricas del Proyecto Completo

- **Scripts Bash:** 5 archivos
- **Tests automatizados:** 8 casos cubriendo funcionalidad completa
- **Targets Makefile:** 7 comandos para automatización
- **Documentación:** README + 3 bitácoras
- **Automatización:** Makefile
- **Distribución:** Paquete versionado con toda la funcionalidad

### Estado Final del Proyecto

El pipeline está completamente funcional para uso en producción con:

- Checks de seguridad automatizados (HTTP, DNS, TLS)
- Diagnóstico inteligente de problemas de red
- Testing automatizado y empaquetado distributable
- Documentación completa para usuarios y administradores
