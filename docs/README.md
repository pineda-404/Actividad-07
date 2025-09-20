# Integrador de Checks de Seguridad

Pipeline automatizado para verificar aspectos críticos de seguridad en sitios web: HTTP, DNS y TLS.

## 📋 Descripción

Este proyecto implementa un pipeline de seguridad que ejecuta verificaciones automáticas sobre un sitio web objetivo para detectar problemas de:

- **HTTP**: Códigos de respuesta, disponibilidad del servicio
- **DNS**: Resolución de nombres, configuración correcta
- **TLS**: Validez de certificados, fechas de expiración

El sistema incluye diagnóstico automático de red para distinguir entre problemas de seguridad real y problemas de infraestructura.

## 🎯 Casos de Uso

### Para DevOps/SRE

- Monitoreo continuo de sitios en producción
- Detección temprana de certificados por expirar
- Validación de configuraciones DNS

### Para Equipos de Seguridad

- Auditoría automatizada de certificados TLS
- Verificación de disponibilidad de servicios críticos
- Generación de evidencias para compliance

### Para CI/CD Pipelines

- Validación de deployments
- Tests de seguridad en pipelines automatizados
- Verificación post-despliegue

## 🏗️ Arquitectura

```
├── src/                    # Código fuente principal
│   ├── security_checker.sh # Script principal
│   ├── http_checker.sh     # Verificaciones HTTP
│   ├── dns_checker.sh      # Verificaciones DNS
│   ├── tls_checker.sh      # Verificaciones TLS
│   └── utils.sh            # Utilidades y diagnóstico
├── tests/                  # Tests automatizados (Bats)
├── out/                    # Salidas y evidencias
├── docs/                   # Documentación
└── .env                    # Configuración
```

## 🚀 Instalación Rápida

### Prerrequisitos

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install curl dig openssl netcat-openbsd iproute2 bats

# CentOS/RHEL
sudo yum install curl bind-utils openssl nc iproute bats
```

### Configuración Inicial

1. **Clonar y configurar:**

```bash
git clone https://github.com/pineda-404/PC01-DS.git
cd PC01-DS
cp .env.example .env
```

2. **Configurar objetivo en `.env`:**

```bash
# Editar .env
TARGET_URL="https://mi-sitio.com"
HTTP_TIMEOUT="30"
DNS_SERVER="8.8.8.8"
TLS_PORT="443"
```

3. **Verificar instalación:**

```bash
make tools  # Verifica dependencias
make test   # Ejecuta tests
```

## 📖 Uso

### Ejecución Básica

```bash
# Con URL por defecto del .env
make run

# Con URL específica
make run TARGET_URL="https://github.com"

# Ejecución directa
cd src && ./security_checker.sh
```

### Casos de Ejemplo

**Sitio funcionando correctamente:**

```bash
make run TARGET_URL="https://www.google.com"
# Output: Todos los checks pasan ✅
```

**Problema de certificado:**

```bash
make run TARGET_URL="https://expired.badssl.com"
# Output: TLS check falla, pero HTTP/DNS pasan
```

**Dominio inexistente:**

```bash
make run TARGET_URL="https://sitio-que-no-existe.com"
# Output: Todos los checks fallan + diagnóstico de DNS
```

## 📊 Interpretación de Resultados

### Salida Exitosa

```
[INFO] HTTP check: Código 200 ✅
[INFO] DNS check: 2 registro(s) encontrados ✅
[INFO] TLS check: Certificado válido por 89 días ✅
[OK] Todos los checks completados con éxito
```

### Salida con Errores

```
[ERROR] HTTP check: Error 500 ❌
[INFO] DNS check: Resuelve correctamente ✅
[INFO] TLS check: Certificado válido ✅
[ERROR] HTTP check falló
```

### Con Diagnóstico de Red

```
[ERROR] No se pudo obtener respuesta HTTP
[WARN] Check http falló para sitio-caido.com
[INFO] Verificando si es problema de red...
[ERROR] Sin conectividad básica
[INFO] Diagnóstico guardado en: out/diagnostic_*.txt
```

## 🔍 Archivos de Evidencia

Cada ejecución genera evidencias en `out/`:

- `http_check_*.txt` - Respuestas HTTP completas
- `dns_check_*.txt` - Registros DNS y análisis
- `tls_check_*.txt` - Información de certificados
- `diagnostic_*.txt` - Diagnósticos de red (cuando hay fallos)

### Ejemplo de Evidencia HTTP

```
--- Evidencia HTTP para https://github.com ---
HTTP/2 200
server: GitHub.com
content-type: text/html; charset=utf-8
strict-transport-security: max-age=31536000

=== ANÁLISIS DEL CÓDIGO HTTP ===
Código obtenido: 200
✓ Código 200: Exitoso
```

## 🔧 Configuración Avanzada

### Variables de Entorno (.env)

```bash
# URL objetivo
TARGET_URL="https://mi-empresa.com"

# Timeouts y puertos
HTTP_TIMEOUT="30"
TLS_PORT="443"

# Servidor DNS para consultas
DNS_SERVER="8.8.8.8"    # Google DNS
# DNS_SERVER="1.1.1.1"  # Cloudflare DNS
# DNS_SERVER="9.9.9.9"  # Quad9 DNS
```

### Makefile Targets

```bash
make help      # Ver todos los comandos
make tools     # Verificar herramientas
make build     # Preparar directorios
make test      # Ejecutar tests Bats
make run       # Ejecutar pipeline
make pack      # Generar paquete distributable
make clean     # Limpiar archivos temporales
```

## 🧪 Testing

### Ejecutar Tests

```bash
# Todos los tests
make test

# Tests específicos
bats tests/test.bats -f "archivos principales"

# Con output detallado
bats tests/test.bats -v
```

### Cobertura de Tests

- ✅ Existencia de archivos principales
- ✅ Funcionamiento con URLs válidas
- ✅ Detección de dominios inexistentes
- ✅ Generación correcta de evidencias
- ✅ Manejo de variables de entorno
- ✅ Integración con Makefile

## 🚨 Troubleshooting

### Problemas Comunes

**Error: "curl command not found"**

```bash
# Instalar dependencias
sudo apt install curl
```

**Error: "No se pudo obtener respuesta HTTP"**

- Verificar conectividad: `ping google.com`
- Revisar proxy/firewall corporativo
- Comprobar archivo `out/diagnostic_*.txt`

**Warning: "TTL muy bajo"**

- Normal para CDNs como Cloudflare
- Indica cambios frecuentes de DNS

**Error: "Certificado expirado"**

- Problema real de seguridad
- Contactar administrador del sitio para renovación

### Logs de Diagnóstico

El sistema genera diagnósticos automáticos en caso de fallo:

1. **Test de ping** - Conectividad básica
2. **Test de nslookup** - Resolución DNS
3. **Información de red local** - Gateway y configuración

## 📚 Documentación Adicional

- [`guia-ejecucion.md`](guia-ejecucion.md) - Guía paso a paso detallada
- [`bitacora-sprint1.md`](bitacora-sprint1.md) - Desarrollo Sprint 1
- [`bitacora-sprint2.md`](bitacora-sprint2.md) - Desarrollo Sprint 2

## 🔒 Consideraciones de Seguridad

- El pipeline NO almacena credenciales
- Solo realiza consultas de solo lectura
- Todas las evidencias se guardan localmente
- Compatible con ambientes corporativos restrictivos

## 📞 Soporte

Para problemas o mejoras, revisar:

1. Archivos de diagnóstico en `out/`
2. Output de `make tools` para dependencias
3. Tests con `bats tests/test.bats -v`

---

**Versión:** Sprint 2 - Pipeline de Seguridad Integrado  
**Licencia:** Educativo - Proyecto Académico
