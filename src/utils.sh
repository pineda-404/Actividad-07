#!/bin/bash
# src/utils.sh - Utilidades básicas para estudiantes

# Colores para logs
readonly COLOR_INFO='\033[0;34m'
readonly COLOR_OK='\033[0;32m'
readonly COLOR_ERROR='\033[0;31m'
readonly COLOR_WARN='\033[1;33m'
readonly COLOR_RESET='\033[0m'

# Funciones básicas de logging
log_info() {
    echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $1" >&2
}

log_ok() {
    echo -e "${COLOR_OK}[OK]${COLOR_RESET} $1" >&2
}

log_error() {
    echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $1" >&2
}

log_warn() {
    echo -e "${COLOR_WARN}[WARN]${COLOR_RESET} $1" >&2
}

# Función simple para cargar .env
load_env() {
    if [[ -f "../.env" ]]; then
        source ../.env
        log_info "Variables cargadas desde .env"
    fi
}

# Función simple de cleanup para trap
cleanup() {
    log_info "Limpiando archivos temporales..."
    # Borrar solo archivos .tmp si existen
    rm -f ../out/*.tmp 2>/dev/null || true
}

# Función principal - diagnóstico básico
simple_network_check() {
    local target_host="$1"
    local failed_check="$2" # "http", "dns", "tls"

    log_warn "Check $failed_check falló para $target_host"
    log_info "Verificando si es problema de red..."

    # Archivo simple para guardar resultados
    local diag_file
    diag_file=$(mktemp ../out/diagnostic_XXXXXX.txt)
    echo "Diagnóstico para: $target_host" >"$diag_file"
    echo "Check que falló: $failed_check" >>"$diag_file"
    echo "Fecha: $(date)" >>"$diag_file"
    echo "" >>"$diag_file"

    if basic_ping_test "$target_host" "$diag_file"; then
        log_info "Conectividad básica: OK"
        # Si hay ping, el problema probablemente es de la aplicación/certificado
        echo "CONCLUSIÓN: Problema probablemente de aplicación/certificado" >>"$diag_file"
    else
        log_error "Sin conectividad básica"
        # Si no hay ping, es problema de red/infraestructura
        echo "CONCLUSIÓN: Problema de red/infraestructura" >>"$diag_file"

        # Test adicional: ¿Es problema de DNS?
        basic_dns_test "$target_host" "$diag_file"
    fi

    log_info "Diagnóstico guardado en: $diag_file"
}

basic_ping_test() {
    local host="$1"
    local diag_file="$2"

    echo "=== TEST DE CONECTIVIDAD ===" >>"$diag_file"

    if ping -c 2 -W 3 "$host" >>"$diag_file" 2>&1; then
        echo "PING: Exitoso" >>"$diag_file"
        return 0
    else
        echo "PING: Falló" >>"$diag_file"
        return 1
    fi
}

basic_dns_test() {
    local host="$1"
    local diag_file="$2"

    echo "" >>"$diag_file"
    echo "=== TEST DE DNS ===" >>"$diag_file"

    if nslookup "$host" >>"$diag_file" 2>&1; then
        echo "DNS: Resuelve correctamente" >>"$diag_file"
        log_info "DNS funciona - problema es de conectividad de red"
    else
        echo "DNS: No resuelve" >>"$diag_file"
        log_error "Problema de DNS - verificar configuración"
    fi
}

show_network_info() {
    local diag_file="$1"

    echo "" >>"$diag_file"
    echo "=== INFO DE RED LOCAL ===" >>"$diag_file"

    # Mostrar gateway (ruta por defecto)
    echo "Gateway:" >>"$diag_file"
    ip route show default >>"$diag_file" 2>&1 || echo "No se pudo obtener gateway" >>"$diag_file"

    # Mostrar DNS configurado
    echo "DNS configurado:" >>"$diag_file"
    cat /etc/resolv.conf | grep nameserver >>"$diag_file" 2>&1 || echo "No se pudo leer DNS" >>"$diag_file"
}
