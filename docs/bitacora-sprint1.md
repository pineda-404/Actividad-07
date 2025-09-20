# Bitácora Sprint 1 - Integrador de Checks de Seguridad
**Proyecto:** 9 - Integrador de checks de seguridad en pipelines
**Equipo:** Diego Pineda García, Mateo Torres Fuero

**Video Sprint 1:** https://www.youtube.com/watch?v=SSWEP1uIkNQ
---

## Objetivos del Sprint 1
- Crear estructura inicial del repositorio
- Desarrollar Makefile básico
- Escribir prueba Bats representativa
- Realizar primeros checks de HTTP/DNS

---

## División de Responsabilidades

### Alumno 1: Diego Pineda - Lógica principal y scripts
- **Rama:** `develop`
- **Responsabilidades:** 
  - Estructura del repositorio
  - Implementación del script principal `src/security_checker.sh`
  - Funciones básicas para checks HTTP/DNS
  - Primeros checks con herramientas CLI (`curl`, `dig`)

### Alumno 2: Mateo Torres - Automatización y Testing
- **Rama:** `Makefile/MateoTorres` 
- **Responsabilidades:**
  - Creación del Makefile
  - Implementación de `tests/test.bats`
  - Documentación inicial
  - Validación de herramientas disponibles

---

## Configuración e Implementación inicial

### 1. Configuración Inicial del Repositorio [DiegoPineda]

**Crear estructura base del proyecto** 
```bash
mkdir -p src tests docs systemd out dist
touch Makefile
git init
git checkout -b develop
```

**Resultado:**
```
Directorio creado exitosamente con estructura:
├── src/
├── tests/
├── docs/
├── systemd/
├── out/
├── dist/
└── Makefile
```

---

### 2. Implementación de los Script [DiegoPineda]

**2.1. Implementación de `security_checker.sh` (Script Principal)**
- **Propósito:** Integrador de checks de seguridad.
- **Funcionalidades:**
  - Configuración por variables de entorno (`TARGET_URL` con valor por defecto).
  - Importación modular de utilidades y checkers específicos.
  - Extracción automática de dominio desde URL usando `sed`.
  - Ejecución secuencial de checks con manejo de códigos de salida.
  - Creación automática del directorio `out/` para evidencias.

**Prueba de funcionamiento:**
```bash
cd src
./security_checker.sh
```

**Salida:**
```
[INFO] --- Iniciando Integrador de Checks de Seguridad ---
[INFO] Target a verificar: https://www.google.com
[INFO] Dominio: www.google.com
[INFO] === Ejecutando checks de seguridad ===
[INFO] Iniciando check HTTP para 'https://www.google.com'...
[INFO] Evidencia HTTP guardada en: out/http_check_ClkbgR.txt
[OK] El código de estado HTTP es 200.
[INFO] HTTP check completado exitosamente
[INFO] Iniciando check DNS para 'www.google.com'...
[INFO] Evidencia DNS guardada en: out/dns_check_KFoxHU.txt
[OK] Se encontró al menos un registro DNS A para 'www.google.com'.
[INFO] DNS check completado exitosamente
[INFO] --- Todos los checks completados con éxito ---
```

**2.2. Implementación de `dns_chcker.sh`**
- **Propósito:** Validación de resolución DNS tipo A.
- **Funcionalidades:**
  - Uso de `dig A +noall +answer` para obtener solo registros A
  - Generación automática de archivos de evidencia con `mktemp`
  - Validación de respuesta no vacía para detectar dominios inexistentes
  - Almacenamiento de evidencias en `out/dns_check_*.txt`

**2.3. Implementación de `http_chcker.sh`**
- **Propósito:** Validación de códigos de estado HTTP.
- **Funcionalidades:**
  - Uso de `curl -Is` para obtener solo headers.
  - Extracción de código de estado con pipeline `head -n 1 | awk '{print $2}'`.
  - Validación específica del código 200.
  - Generación de evidencias en `out/http_check_*.txt`.

**2.4. Implementación de `utils.sh`**
- **Propósito:** Códigos de color para facilitar la lectura de la información

---

### 3. Creación del Makefile Inicial [MateoTorres]
- **Propósito:** Automatización de tareas principales.
- **Funcionalidades implementadas:**
  - Variable configurable: `TARGET_URL` con valor por defecto `https://example.com`.
  - Target `run`: Ejecuta el script principal con cambio de directorio a `src/`.
  - Target `test`: Invoca framework Bats para ejecución de las pruebas.
  - Target `clean`: Limpieza del directorio `out/` para reset del estado.
  - Target `help`: Lista las funcionalidades de Makefile.


**Prueba de funcionamiento:**
```bash
make run
```

**Salida:**
```
Ejecutando checks para https://example.com
cd src && TARGET_URL=https://example.com bash security_checker.sh
[INFO] --- Iniciando Integrador de Checks de Seguridad ---
[INFO] Target a verificar: https://example.com
[INFO] Dominio: example.com
[INFO] === Ejecutando checks de seguridad ===
[INFO] Iniciando check HTTP para 'https://example.com'...
[INFO] Evidencia HTTP guardada en: out/http_check_b9K2J9.txt
[OK] El código de estado HTTP es 200.
[INFO] HTTP check completado exitosamente
[INFO] Iniciando check DNS para 'example.com'...
[INFO] Evidencia DNS guardada en: out/dns_check_LqssE3.txt
[OK] Se encontró al menos un registro DNS A para 'example.com'.
[INFO] DNS check completado exitosamente
[INFO] --- Todos los checks completados con éxito ---
```

---

### 4. Pruebas `tests/test.bats` [MateoTorres]

- **Propósito:** Validación de funcionalidades básicas
- **Setup():** Limpia y recetea `out/` antes de cada test
- **Tests implementados:**
  - Test estructural: Confirma la existencia de los 4 módulos principales
  - Test funcional (2): Verifica que todo proceda de manera adecuada en un caso de éxito y otro fallido.
  - Test de archivos de evidencia: Confirma que se crean archivos en `out/`
  - Test en Makefile: Valida que `make run` funciona correctamente.

**Prueba de funcionamiento:**
```bash
bats tests/test.bats
```

**Salida:**
```
 ✓ Los archivos principales existen
 ✓ El script funciona con google.com
 ✓ El script detecta dominios que no existen
 ✓ Se crean archivos de evidencia
 ✓ Makefile run funciona

5 tests, 0 failures
```
