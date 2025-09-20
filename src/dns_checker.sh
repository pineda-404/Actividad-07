# src/dns_checker.sh
# Contiene la lógica para las verificaciones DNS.

check_dns() {
    local domain="$1"

    log_info "Iniciando check DNS para '$domain'..."

    # Ejecutamos dig para obtener solo la respuesta del registro A.
    local dns_response
    dns_response=$(dig A "$domain" +noall +answer || true)

    local evidence_file
    evidence_file=$(mktemp ../out/dns_check_XXXXXX.txt)

    echo "--- Evidencia DNS (Registro A) para $domain ---" >"$evidence_file"
    echo "$dns_response" >>"$evidence_file"
    log_info "Evidencia DNS guardada en: $evidence_file"

    # Si la respuesta está vacia, no se encontró el registro.
    if [[ -z "$dns_response" ]]; then
        log_error "No se encontró un registro A para el dominio '$domain'."
        return 1
    fi

    log_ok "Se encontró al menos un registro DNS A para '$domain'."
    return 0
}
