# Bitácora Sprint 2 - Integrador de Checks de Seguridad

**Proyecto:** 9 - Integrador de checks de seguridad en pipelines  
**Equipo:** Diego Pineda García, Mateo Torres Fuero

**Video Sprint 2:** https://youtu.be/h-RxShijzHQ

---

## Objetivos del Sprint 2

- Implementar checks TLS completos con verificación de certificados
- Desarrollar diagnóstico de red con herramientas Unix (ip, ss, ping, nslookup)
- Corregir bugs identificados en Sprint 1
- Integrar variables de entorno desde .env
- Aplicar pipelines Unix para procesamiento de datos (grep, awk, sed, cut)
- Implementar bash robusto con manejo de errores y trap

---

## División de Responsabilidades

### Alumno 1: Diego Pineda - Scripts Bash y funcionalidades principales

- **Rama:** `scripts/diego-pineda`
- **Responsabilidades:**
  - Implementación completa de `tls_checker.sh`
  - Desarrollo de funciones de diagnóstico de red en `utils.sh`
  - Corrección de bugs críticos en `http_checker.sh`
  - Integración robusta de variables de entorno `.env`
  - Aplicación de pipelines Unix en procesamiento

### Alumno 2: Mateo Torres - Herramientas de red y testing

- **Rama:** `network-tools/MateoTorres`
- **Responsabilidades:**
  - Implementación de herramientas de red (ip, ss, nc)
  - Desarrollo de funciones de diagnóstico avanzado
  - Mejoras en robustez de scripts (trap, cleanup)
  - Validación de configuraciones de red
  - Testing manual de casos de fallo

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

### 2. Diagnóstico de Red con Herramientas Unix [DiegoPineda + MateoTorres]

**2.1. Herramientas de red implementadas**

- **Propósito:** Distinguir problemas de seguridad vs problemas de infraestructura de red
- **Herramientas Unix integradas:**
  - `ping`: Verificación de conectividad básica ICMP
  - `nslookup`: Resolución DNS alternativa y diagnóstico
  - `ip route show default`: Verificación de gateway y rutas
  - `ss -tuln`: Análisis de puertos activos localmente
  - `nc` (netcat): Test de conectividad a puertos específicos

**2.2. Funciones de diagnóstico en `utils.sh`**

```bash
# Función principal de coordinación
simple_network_check() {
    local target_host="$1"
    local failed_check="$2"
    # Lógica de diagnóstico escalonado
}

# Test de conectividad con ping
basic_ping_test() {
    ping -c 2 -W 3 "$host" >> "$diag_file"
}

# Verificación de DNS con nslookup
basic_dns_test() {
    nslookup "$host" >> "$diag_file"
}

# Información de red local con ip
show_network_info() {
    ip route show default >> "$diag_file"
    cat /etc/resolv.conf | grep nameserver >> "$diag_file"
}
```

**2.3. Lógica de diagnóstico implementada:**

1. Check HTTP/DNS/TLS falla → activar diagnóstico
2. `ping`: ¿hay conectividad básica?
   - SÍ → problema de aplicación/certificado
   - NO → problema de red/DNS
3. `nslookup`: ¿resuelve el dominio?
   - SÍ → problema de conectividad/firewall
   - NO → problema de DNS/dominio inexistente
4. `ip route`: ¿está configurado el gateway?
5. Generar archivo diagnóstico con conclusiones

**Prueba con herramientas de red:**

```bash
TARGET_URL="https://sitio-que-no-existe-123456.com" ./security_checker.sh
```

**Salida con diagnóstico de red:**

```
[WARN] Check http falló para sitio-que-no-existe-123456.com
[INFO] Verificando si es problema de red...
[ERROR] Sin conectividad básica
[ERROR] Problema de DNS - verificar configuración
[INFO] Diagnóstico guardado en: ../out/diagnostic_abc123.txt
```

**Contenido del archivo de diagnóstico:**

```
=== TEST DE CONECTIVIDAD ===
PING sitio-que-no-existe-123456.com (sitio-que-no-existe-123456.com): 56 data bytes
ping: cannot resolve sitio-que-no-existe-123456.com: Unknown host
PING: Falló

=== TEST DE DNS ===
Server: 8.8.8.8
Address: 8.8.8.8#53
** server can't find sitio-que-no-existe-123456.com: NXDOMAIN
DNS: No resuelve

CONCLUSIÓN: Problema de red/infraestructura
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

### 4. Variables de Entorno y Configuración [DiegoPineda]

**4.1. Implementación de configuración centralizada (.env)**

- **Propósito:** Configuración flexible y reutilizable del pipeline
- **Variables implementadas:**

```bash
TARGET_URL="https://www.google.com"     # URL objetivo
HTTP_TIMEOUT="30"                       # Timeout para HTTP y TLS
TLS_PORT="443"                         # Puerto TLS configurable
DNS_SERVER="8.8.8.8"                  # Servidor DNS específico
```

**4.2. Modificación de `load_env()` en `utils.sh`**

- Prioridad correcta: línea de comandos > variables de entorno > .env
- Compatibilidad con diferentes formas de ejecución
- Logging informativo sobre origen de configuración

**4.3. Integración de DNS_SERVER en `dns_checker.sh`**

```bash
# Uso de servidor DNS específico desde .env
local dns_server="${DNS_SERVER:-8.8.8.8}"
dns_response=$(dig "@$dns_server" A "$domain" +noall +answer || true)
```

**Beneficios implementados:**

- Configuración consistente entre ejecuciones
- Facilita testing con diferentes parámetros
- Permite uso de DNS corporativos o públicos específicos
- Compatible con automatización y CI/CD

---

### 5. Pipelines Unix y Procesamiento de Datos [DiegoPineda + MateoTorres]

**5.1. Herramientas Unix integradas en scripts:**

- **grep**: Búsqueda de patrones en respuestas HTTP/TLS
- **awk**: Extracción de campos específicos (códigos HTTP, IPs DNS)
- **sed**: Transformación de texto y limpieza de URLs
- **cut**: División de campos en certificados TLS
- **head/tail**: Procesamiento de líneas específicas
- **sort/uniq**: Ordenamiento y eliminación de duplicados
- **wc**: Conteo de registros y estadísticas

**5.2. Ejemplos implementados por checker:**

**HTTP Checker - Extracción de código:**

```bash
# Pipeline para extraer código HTTP
http_status=$(echo "$http_response" | head -n 1 | awk '{print $2}')

# Validación con expresión regular
if [[ ! "$http_status" =~ ^[0-9]+$ ]]; then
    log_error "Código HTTP no válido"
fi
```

**DNS Checker - Procesamiento de IPs:**

````bash
# Extracción y ordenamiento de IPs
ips_found=$(echo "$dns_response" | awk '{print $5}' | \
           grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+

---

## Evidencias de Funcionamiento

### Caso Exitoso:
```bash
TARGET_URL="https://example.com" make run
````

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
- **Evidencias:** Generación automática con timestamps únicos | \
   sort -V | uniq)

# Conteo de registros únicos

unique_ips=$(echo "$ips_found" | wc -l)

````

**TLS Checker - Análisis de certificados:**
```bash
# Extracción de fecha de expiración
expiry_date=$(echo "$cert_info" | grep "notAfter=" | cut -d= -f2)

# Cálculo de días usando pipelines
days_left=$(( (expiry_timestamp - current_timestamp) / 86400 ))
````

**5.3. Aplicación de principios Unix:**

- Una herramienta por tarea específica
- Combinación de herramientas simples para tareas complejas
- Procesamiento de texto eficiente con streams
- Reutilización de código mediante pipelines

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
- ✅ Documentación técnica completa

### Funcionalidades Principales

- Pipeline robusto con manejo de errores y diagnóstico
- Configuración flexible mediante variables de entorno
- Evidencias detalladas para auditoría y debugging
- Tests automatizados que validan funcionalidad completa

### Métricas del Proyecto

- **Archivos de código:** 5 scripts principales
- **Tests:** 8 casos cubriendo funcionalidad completa
- **Documentación:** README + guía de ejecución + bitácoras
- **Evidencias:** Generación automática con timestamps únicos
