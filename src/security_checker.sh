#!/usr/bin/env bash
set -euo pipefail

# Importamos las funciones
source "src/utils.sh"
source "src/http_checker.sh"
source "src/dns_checker.sh"

# Función principal
main() {
    log_info "---Iniciando Integrador de Checks de Seguridad---"
    # Leemos TARGET_URL, sino existe tomamos por defecto google
    local target_url="${TARGET_URL:-"https://www.google.com"}"

    if [[ -z "$target_url" ]]; then
        log_error "La variable TARGET_URL no puede estar vacía."
        exit 1
    fi

    log_info "Target a verificar: ${target_url}"

    # Extraemos el nombre de dominio de la URL para usarlo en el check de DNS.
    local domain
    domain=$(echo "$target_url" | sed -e 's|https://||' -e 's|http://||' -e 's|/.*$||')

    # Llamamos a las funciones de los otros scripts para hacer los checks
    check_http "$target_url"
    check_dns "$domain"

    log_info "---Todos los checks completados con exito---"
}

main "$@"
