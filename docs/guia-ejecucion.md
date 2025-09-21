# Guía de Ejecución - Pipeline de Checks de Seguridad

Guía práctica para ejecutar el pipeline de seguridad desde cero hasta uso básico.

## Requisitos del Sistema

### Herramientas necesarias

```bash
# Verificar que tienes instalado:
curl --version     # Cliente HTTP
dig -v            # Consultas DNS
openssl version   # Verificaciones TLS
nc -h             # Test de conectividad
bats --version    # Tests (opcional)
```

### Instalar dependencias faltantes

```bash
# Ubuntu/Debian
sudo apt install curl dnsutils openssl netcat-openbsd bats

# CentOS/RHEL
sudo yum install curl bind-utils openssl nc bats
```

## Configuración Inicial

### 1. Descargar el proyecto

```bash
# Clonar repositorio
git clone <url-del-repositorio>
cd PC01-DS

# Verificar estructura
ls -la
# Debes ver: src/ tests/ docs/ out/ Makefile
```

### 2. Configurar variables (.env)

```bash
# Crear archivo de configuración
cp .env.example .env

# Editar con tu editor preferido
nano .env
```

**Configuración básica (.env):**

```bash
TARGET_URL="https://www.google.com"
HTTP_TIMEOUT="30"
TLS_PORT="443"
DNS_SERVER="8.8.8.8"
```

### 3. Verificar instalación

```bash
make tools
# Salida esperada: "✓ Herramientas verificadas"
```

## Ejecución Básica

### Método 1: Con Makefile (recomendado)

```bash
# Ejecución con URL por defecto del .env
make run

# Ejecución con URL específica
make run TARGET_URL="https://github.com"

# Limpiar archivos anteriores
make clean
```

### Método 2: Ejecución directa

```bash
cd src
./security_checker.sh

# Con variable específica
TARGET_URL="https://example.com" ./security_checker.sh
```

## Interpretación de Resultados

### Ejecución exitosa

```
[INFO] --- Iniciando Integrador de Checks de Seguridad ---
[INFO] Target a verificar: https://www.google.com
[INFO] === Ejecutando checks de seguridad ===
[OK] HTTP check completado exitosamente
[OK] DNS check completado exitosamente
[OK] TLS check completado exitosamente
[OK] --- Todos los checks completados con éxito ---
```

### Ejecución con errores

```
[ERROR] HTTP check falló
[INFO] Verificando si es problema de red...
[ERROR] Sin conectividad básica
[INFO] Diagnóstico guardado en: out/diagnostic_*.txt
```

## Archivos de Evidencia

### Ubicación

```bash
ls out/
# Verás archivos como:
# http_check_abc123.txt
# dns_check_def456.txt
# tls_check_ghi789.txt
# diagnostic_xyz999.txt (solo si hay errores)
```

### Revisar evidencias

```bash
# Evidencia HTTP
cat out/http_check_*.txt

# Evidencia DNS
cat out/dns_check_*.txt

# Evidencia TLS
cat out/tls_check_*.txt

# Diagnóstico (si hubo errores)
cat out/diagnostic_*.txt
```

## Casos de Uso Típicos

### 1. Verificar sitio web corporativo

```bash
make run TARGET_URL="https://mi-empresa.com"
```

### 2. Probar sitio con problemas

```bash
make run TARGET_URL="https://sitio-que-no-existe.com"
# Revisa out/diagnostic_*.txt para ver el diagnóstico
```

### 3. Verificar certificado próximo a expirar

```bash
make run TARGET_URL="https://sitio-con-certificado-viejo.com"
# Revisa out/tls_check_*.txt para días restantes
```

### 4. Usar DNS alternativo

```bash
DNS_SERVER="1.1.1.1" make run TARGET_URL="https://ejemplo.com"
```

## Tests

### Ejecutar tests básicos

```bash
make test
```

### Salida esperada

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

## Solución de Problemas

### Error: "curl command not found"

```bash
# Instalar curl
sudo apt install curl
# o
sudo yum install curl
```

### Error: "dig not found"

```bash
# Ubuntu/Debian
sudo apt install dnsutils
# CentOS/RHEL
sudo yum install bind-utils
```

### Error: "Permission denied"

```bash
# Dar permisos de ejecución
chmod +x src/security_checker.sh
```

### Error: "No se pudo obtener respuesta HTTP"

```bash
# 1. Verificar conectividad
ping google.com

# 2. Revisar proxy corporativo
echo $http_proxy
echo $https_proxy

# 3. Revisar diagnóstico automático
cat out/diagnostic_*.txt
```

### Certificado expirado o inválido

```bash
# Revisar detalles del certificado
cat out/tls_check_*.txt
# Buscar líneas como:
# "Días hasta expiración: -5" (expirado)
# "ERROR: Certificado no válido"
```

## Configuración Avanzada

### Variables de entorno disponibles

```bash
TARGET_URL="https://mi-sitio.com"      # URL a verificar
HTTP_TIMEOUT="30"                      # Timeout HTTP/TLS en segundos
TLS_PORT="443"                        # Puerto TLS (normalmente 443)
DNS_SERVER="8.8.8.8"                 # Servidor DNS específico
```

### Ejemplos de DNS alternativos

```bash
DNS_SERVER="8.8.8.8"      # Google DNS
DNS_SERVER="1.1.1.1"      # Cloudflare DNS
DNS_SERVER="9.9.9.9"      # Quad9 DNS
DNS_SERVER="208.67.222.222" # OpenDNS
```

### Timeouts personalizados

```bash
# Para sitios lentos
HTTP_TIMEOUT="60" make run TARGET_URL="https://sitio-lento.com"

# Para puertos no estándar
TLS_PORT="8443" make run TARGET_URL="https://servicio-especial.com"
```

## Comandos Útiles del Makefile

```bash
make help      # Ver todos los comandos disponibles
make tools     # Verificar herramientas del sistema
make build     # Preparar directorios de salida
make test      # Ejecutar tests automáticos
make run       # Ejecutar pipeline principal
make clean     # Limpiar archivos temporales
```

## Códigos de Estado Comunes

### HTTP

- **200**: Sitio funcionando correctamente
- **301/302**: Redirección (generalmente normal)
- **403**: Acceso prohibido
- **404**: Página no encontrada
- **500**: Error interno del servidor
- **503**: Servicio no disponible

### DNS

- **Resuelve correctamente**: DNS funcional
- **No resuelve**: Dominio inexistente o DNS con problemas
- **Múltiples IPs**: Posible CDN o balanceador de carga

### TLS

- **Certificado válido**: Conexión segura establecida
- **Certificado expirado**: Renovación necesaria urgente
- **Error de verificación**: Problema con la autoridad certificadora

---

## Referencia Rápida

```bash
# Comandos esenciales
make run                                    # Ejecución básica
make run TARGET_URL="https://mi-sitio.com" # URL específica
make test                                   # Ejecutar tests
make clean                                  # Limpiar archivos
ls out/                                     # Ver evidencias generadas
cat out/diagnostic_*.txt                    # Ver diagnósticos de errores
```
