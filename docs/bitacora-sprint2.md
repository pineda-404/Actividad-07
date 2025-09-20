# Bitácora Sprint 2 - Integrador de Checks de Seguridad

**Proyecto:** 9 - Integrador de checks de seguridad en pipelines  
**Equipo:** Diego Pineda García, Mateo Torres Fuero

**Video Sprint 2:** [URL del video pendiente]

---

## Objetivos del Sprint 2

- Implementar checks TLS completos con verificación de certificados
- Agregar diagnóstico de red para distinguir problemas de infraestructura vs seguridad
- Expandir tests Bats con casos de fallo reales
- Implementar uso de variables de entorno desde .env
- Configurar servicio systemd para ejecución automatizada
- Mejorar pipeline con herramientas Unix básicas (grep, awk, sed, cut)

---

## División de Responsabilidades

### Alumno 1: Diego Pineda - Funcionalidades principales

- **Rama:** `scripts/diego-pineda`
- **Responsabilidades:**
  - Implementación de `tls_checker.sh` completo
  - Desarrollo de funciones de diagnóstico de red en `utils.sh`
  - Corrección de bugs en `http_checker.sh`
  - Integración de variables de entorno `.env`

### Alumno 2: Mateo Torres - Automatización y Testing

- **Rama:** `Makefile/MateoTorres`
- **Responsabilidades:**
  - Expansión de tests Bats con casos de fallo
  - Mejora del Makefile con nuevos targets
  - Documentación técnica (README.md, guia-ejecucion.md)
  - Configuración de servicio systemd

---

## Desarrollo e Implementación

### 1. Implementación de TLS Checker [DiegoPineda]

**1.1. Desarrollo de `tls_checker.sh`**

- **Propósito:** Verificación completa de certificados SSL/TLS
- **Funcionalidades implementadas:**
  - Conexión TLS usando `openssl s_client` con timeout configurable
  - Verificación de validez de certificados (Verify return code: 0)
  - Extracción de información del certificado (fechas, emisor, subject)
  - Cálculo automático de días hasta expiración
  - Alertas tempranas para certificados próximos a expirar
  - Clasificación de tipos de CA (Let's Encrypt, comerciales, otros)

**Prueba de funcionamiento:**

```bash
TARGET_URL="https://www.google.com" ./security_checker.sh
```

**Salida TLS:**

```
[INFO] Iniciando check TLS para 'https://www.google.com'...
[INFO] Probando conectividad TLS...
[OK] Conectividad TLS establecida correctamente
[INFO] Extrayendo información del certificado...
[INFO] Certificado expira: Feb 26 08:24:47 2024 GMT
[INFO] Emisor del certificado: CN=GTS CA 1C3
[INFO] CA comercial detectada: CN=GTS CA 1C3
[OK] Certificado válido por 42 días más
[INFO] Evidencia TLS guardada en: ../out/tls_check_xyz123.txt
[OK] Verificación TLS completada para 'www.google.com'
```

---

### 2. Diagnóstico de Red [DiegoPineda]

**2.1. Ampliación de `utils.sh` con funciones de diagnóstico**

- **Propósito:** Distinguir problemas de seguridad vs problemas de infraestructura
- **Funcionalidades agregadas:**
  - `simple_network_check()`: Coordinador principal del diagnóstico
  - `basic_ping_test()`: Verificación de conectividad básica con ping
  - `basic_dns_test()`: Verificación de resolución DNS con nslookup
  - `show_network_info()`: Información de gateway y DNS configurado usando ip route

**Flujo de diagnóstico implementado:**

1. Check HTTP/DNS/TLS falla
2. Se ejecuta `simple_network_check()`
3. Test de ping: ¿hay conectividad básica?
   - SÍ → Problema de aplicación/certificado
   - NO → Problema de red/DNS
4. Test de DNS: ¿resuelve el dominio?
5. Generación de archivo de diagnóstico con conclusiones

**Prueba con dominio inexistente:**

```bash
TARGET_URL="https://sitio-que-no-existe-123456.com" ./security_checker.sh
```

**Salida diagnóstico:**

```
[ERROR] No se pudo obtener respuesta HTTP de 'https://sitio-que-no-existe-123456.com'.
[WARN] Check http falló para sitio-que-no-existe-123456.com
[INFO] Verificando si es problema de red...
[ERROR] Sin conectividad básica
[ERROR] Problema de DNS - verificar configuración
[INFO] Diagnóstico guardado en: ../out/diagnostic_abc123.txt
```

---

### 3. Corrección de Bugs [DiegoPineda]

**3.1. Fix crítico en `http_checker.sh`**

- **Problema identificado:** Sites como `httpstat.us` no respondían, pero sitios como `httpbin.org/status/500` devolvían códigos de error correctamente
- **Causa:** `curl` puede devolver exit code != 0 pero tener respuesta HTTP válida
- **Solución implementada:**
  - Mejor separación de stderr: `curl -Is "$url" 2>/dev/null`
  - Timeout configurable: `timeout "${HTTP_TIMEOUT:-30}"`
  - Validación robusta de códigos de estado con regex: `[[ "$http_status" =~ ^[0-9]+$ ]]`
  - Análisis mejorado de códigos HTTP (200, 301/302, 404, 500, 503)

**Prueba con código de error:**

```bash
TARGET_URL="https://httpbin.org/status/500" ./security_checker.sh
```

**Salida corregida:**

```
[INFO] Iniciando check HTTP para 'https://httpbin.org/status/500'...
[INFO] Evidencia HTTP guardada en: ../out/http_check_def456.txt
[ERROR] Error 500: El servidor tiene un problema interno.
[ERROR] HTTP check falló
```

---

### 4. Variables de Entorno [DiegoPineda]

**4.1. Implementación de configuración `.env`**

- **Propósito:** Configuración centralizada y flexible del pipeline
- **Variables implementadas:**
  - `TARGET_URL`: URL objetivo principal
  - `HTTP_TIMEOUT`: Timeout para requests HTTP y TLS
  - `DNS_SERVER`: Servidor DNS específico para consultas
  - `TLS_PORT`: Puerto TLS configurable (default 443)

**4.2. Actualización de `dns_checker.sh` para usar DNS_SERVER**

- Modificación para usar servidor DNS específico: `dig "@$dns_server" A "$domain"`
- Diagnóstico mejorado con DNS alternativo cuando falla el principal
- Comparación automática entre DNS configurado vs DNS del sistema

**4.3. Mejora en `load_env()` para prioridad de variables**

- Variables de línea de comandos tienen prioridad sobre .env
- Compatibilidad con Makefile: `TARGET_URL=https://ejemplo.com make run`

**Configuración .env final:**

```bash
TARGET_URL="https://www.google.com"
HTTP_TIMEOUT="30"
TLS_PORT="443"
DNS_SERVER="8.8.8.8"
```

---

### 5. Expansión de Tests [MateoTorres]

**5.1. Nuevos tests en `test.bats`**

- **Tests agregados:**
  - Verificación de manejo de variables de entorno vs línea de comandos
  - Detección correcta de archivos de evidencia específicos (HTTP, DNS, TLS)
  - Verificación que HTTPS genera archivos TLS pero HTTP no
  - Validación de generación de archivos de diagnóstico en fallos
  - Test de integración con Makefile usando diferentes URLs

**Cobertura de testing mejorada:**

```bash
bats tests/test.bats
```

**Salida ampliada:**

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

### 6. Mejoras en Makefile [MateoTorres]

**6.1. Nuevos targets implementados:**

- `tools`: Verificación de herramientas necesarias (curl, dig, openssl, bats)
- `build`: Preparación de estructura de directorios y artefactos
- `pack`: Generación de paquete distributable en dist/
- Mejora en `clean`: Limpieza segura de out/ y dist/

**6.2. Variables configurables ampliadas:**

- `RELEASE`: Versionado para paquetes
- Soporte para override de TARGET_URL desde línea de comandos

---

### 7. Implementación de Servicio Systemd [MateoTorres]

**7.1. Creación de `install-service.sh`**

- **Propósito:** Instalación automatizada como servicio del sistema
- **Funcionalidades:**
  - Generación automática de archivos .service y .timer
  - Configuración de ejecución horaria automática
  - Integración con journalctl para logging centralizado
  - Scripts de instalación, desinstalación y estadísticas

**7.2. Configuración de monitoreo:**

- Logs estructurados con `SyslogIdentifier=security-checks`
- Timer configurable para ejecución periódica
- Funciones de análisis de logs y generación de reportes

---

### 8. Pipelines Unix [Conjunto]

**8.1. Uso de herramientas Unix en processing:**

- **http_checker.sh:** `head -n 1 | awk '{print $2}'` para extraer códigos
- **dns_checker.sh:** `awk '{print $5}' | sort -V | uniq` para procesar IPs
- **tls_checker.sh:** `grep | cut | sed` para parsear certificados
- **utils.sh:** `wc -l | tr -d ' '` para contar registros

**8.2. Ejemplos implementados:**

```bash
# Extracción de código HTTP
http_status=$(echo "$http_response" | head -n 1 | awk '{print $2}')

# Análisis de IPs DNS
ips_found=$(echo "$dns_response" | awk '{print $5}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)

# Conteo de registros
record_count=$(echo "$dns_response" | wc -l | tr -d ' ')
```

---

## Documentación Técnica [MateoTorres]

### 8.1. Creación de README.md completo

- Descripción del proyecto y arquitectura
- Casos de uso para DevOps, Seguridad y CI/CD
- Instalación paso a paso con dependencias
- Ejemplos de uso y interpretación de resultados
- Troubleshooting común y consideraciones de seguridad

### 8.2. Desarrollo de guia-ejecucion.md

- Tutorial detallado desde instalación hasta uso avanzado
- Revisión paso a paso de evidencias generadas
- Casos de uso prácticos con ejemplos reales
- Configuración avanzada e integración CI/CD
- Solución específica de problemas comunes

---

## Evidencias de Funcionamiento

### Caso Exitoso:

```bash
TARGET_URL="https://example.com" make run
```

**Resultado:** HTTP 200, DNS resuelve, TLS válido por 89 días

### Caso de Fallo con Diagnóstico:

```bash
TARGET_URL="https://sitio-inexistente.com" make run
```

**Resultado:** Fallo con diagnóstico automático de DNS y conectividad

### Tests Completos:

```bash
make test
```

**Resultado:** 8 tests pasando, cobertura completa de funcionalidades

---

## Conclusiones Sprint 2

### Objetivos Completados ✅

- ✅ TLS checker completo con análisis de certificados
- ✅ Diagnóstico de red para distinguir tipos de problemas
- ✅ Variables de entorno configurables (.env)
- ✅ Tests Bats expandidos con casos de fallo
- ✅ Pipelines Unix básicos implementados
- ✅ Servicio systemd para automatización
- ✅ Documentación técnica completa

### Funcionalidades Principales

- Pipeline robusto con manejo de errores y diagnóstico
- Configuración flexible mediante variables de entorno
- Evidencias detalladas para auditoría y debugging
- Integración lista para ambientes de producción
- Tests automatizados que validan funcionalidad completa

### Métricas del Proyecto

- **Archivos de código:** 5 scripts principales
- **Tests:** 8 casos cubriendo funcionalidad completa
- **Documentación:** README + bitácoras
- **Automatización:** Makefile
- **Evidencias:** Generación automática con timestamps únicos
