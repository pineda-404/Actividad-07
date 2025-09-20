#!/usr/bin/env bash
set -euo pipefail

# Trap para limpieza
trap cleanup EXIT

# Crear directorio out
mkdir -p ../out

# Importar archivos
source utils.sh
source http_checker.sh
source dns_checker.sh
source tls_checker.sh

# Cargar variables de entorno
load_env

# Función principal
main() {
    log_info "--- Iniciando Integrador de Checks de Seguridad ---"

    # Usar variables de .env (12-Factor III)
    local target_url="${TARGET_URL:-https://www.google.com}"

    if [[ -z "$target_url" ]]; then
        log_error "La variable TARGET_URL no puede estar vacía."
        exit 1
    fi

    log_info "Target a verificar: $target_url"

    # Extraer dominio simple
    local domain
    domain=$(echo "$target_url" | sed -e 's|https://||' -e 's|http://||' -e 's|/.*$||')
    log_info "Dominio: $domain"

    # Ejecutar checks
    log_info "=== Ejecutando checks de seguridad ==="

    if check_http "$target_url"; then
        log_ok "HTTP check completado exitosamente"
    else
        log_error "HTTP check falló"
        exit 1
    fi

    if check_dns "$domain"; then
        log_ok "DNS check completado exitosamente"
    else
        log_error "DNS check falló"
        exit 1
    fi

    # Solo verificar TLS si es URL HTTPS
    if [[ "$target_url" =~ ^https:// ]]; then
        if check_tls "$target_url"; then
            log_ok "TLS check completado exitosamente"
        else
            log_error "TLS check falló"
            exit 1
        fi
    else
        log_info "URL es HTTP, saltando verificación TLS"
    fi

    log_ok "--- Todos los checks completados con éxito ---"
}

# Ejecutar función principal
main "$@"
