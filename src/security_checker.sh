#!/usr/bin/env bash
set -euo pipefail

# Asegurar que directorio out existe
mkdir -p out

# Importar archivos
source utils.sh
source http_checker.sh
source dns_checker.sh

# Función principal
main() {
    log_info "--- Iniciando Integrador de Checks de Seguridad ---"

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
        log_info "HTTP check completado exitosamente"
    else
        log_error "HTTP check falló"
        exit 1
    fi

    if check_dns "$domain"; then
        log_info "DNS check completado exitosamente"
    else
        log_error "DNS check falló"
        exit 1
    fi

    log_info "--- Todos los checks completados con éxito ---"
}

# Ejecutar función principal
main "$@"
