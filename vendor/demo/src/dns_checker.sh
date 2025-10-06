# src/dns_checker.sh
# Contiene la lógica para las verificaciones DNS.

check_dns() {
    local domain="$1"

    local dns_server="${DNS_SERVER:-8.8.8.8}"

    log_info "Iniciando check DNS para '$domain'..."

    # Ejecutamos dig con servidor DNS específico para obtener solo la respuesta del registro A.
    local dns_response
    dns_response=$(dig "@$dns_server" A "$domain" +noall +answer || true)

    local evidence_file
    evidence_file=$(mktemp ../out/dns_check_XXXXXX.txt)

    echo "--- Evidencia DNS (Registro A) para $domain ---" >"$evidence_file"
    echo "$dns_response" >>"$evidence_file"
    log_info "Evidencia DNS guardada en: $evidence_file"

    # Si la respuesta está vacía, no se encontró el registro.
    if [[ -z "$dns_response" ]]; then
        log_error "No se encontró un registro A para el dominio '$domain'."

        # DIAGNÓSTICO SIMPLE: ¿Es problema de DNS o el dominio no existe?
        simple_network_check "$domain" "dns"

        return 1
    fi

    # Pipeline Unix: contar cuántos registros A encontramos
    local record_count
    record_count=$(echo "$dns_response" | wc -l | tr -d ' ')

    log_ok "Se encontró(ron) $record_count registro(s) DNS A para '$domain'."

    # Mostrar las IPs encontradas usando pipeline Unix
    log_info "IPs resueltas:"
    echo "$dns_response" | awk '{print $5}' | while read -r ip; do
        log_info "  -> $ip"
    done

    return 0
}
