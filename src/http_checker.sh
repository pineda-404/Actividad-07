# src/http_checker.sh
# Contiene la lógica para las verificaciones HTTP.

check_http() {
    # Hacemos la variable local para que no afecte a otros ámbitos
    local url="$1"

    # Usamos la función de utils.sh
    log_info "Iniciando check HTTP para '$url'..."

    local http_response
    http_response=$(curl -Is "$url" || true)

    local evidence_file
    evidence_file=$(mktemp ../out/http_check_XXXXXX.txt)
    echo "--- Evidencia HTTP para $url ---" >"$evidence_file"
    echo "$http_response" >>"$evidence_file"
    log_info "Evidencia HTTP guardada en: $evidence_file"

    if [[ -z "$http_response" ]]; then
        log_error "No se pudo obtener respuesta HTTP de '$url'. ¿Hay conexión a internet?"
        return 1
    fi

    #Extraemos la primera línea y luego el segundo campo .
    local http_status
    http_status=$(echo "$http_response" | head -n 1 | awk '{print $2}')

    if [[ "$http_status" != "200" ]]; then
        log_error "Se esperaba un código HTTP 200, pero se obtuvo '$http_status'."
        return 1
    fi

    log_ok "El código de estado HTTP es 200."
    return 0
}
