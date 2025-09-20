# src/http_checker.sh
# Contiene la lógica para las verificaciones HTTP.

check_http() {
    # Hacemos la variable local para que no afecte a otros ámbitos
    local url="$1"

    # Usamos la función de utils.sh
    log_info "Iniciando check HTTP para '$url'..."

    local http_response
    http_response=$(timeout "${HTTP_TIMEOUT:-30}" curl -Is "$url" 2>/dev/null || true)

    local evidence_file
    evidence_file=$(mktemp ../out/http_check_XXXXXX.txt)
    echo "--- Evidencia HTTP para $url ---" >"$evidence_file"

    if [[ -n "$http_response" ]]; then
        echo "$http_response" >>"$evidence_file"
    else
        echo "Sin respuesta HTTP obtenida" >>"$evidence_file"
    fi

    log_info "Evidencia HTTP guardada en: $evidence_file"

    if [[ -z "$http_response" ]]; then
        log_error "No se pudo obtener respuesta HTTP de '$url'."
        echo "ERROR: Sin conectividad HTTP" >>"$evidence_file"

        # Diagnóstico cuando no hay respuesta
        local domain
        domain=$(echo "$url" | sed -e 's|https://||' -e 's|http://||' -e 's|/.*$||')
        simple_network_check "$domain" "http"

        return 1
    fi

    # Extraer código de estado usando pipeline Unix básico
    local http_status
    http_status=$(echo "$http_response" | head -n 1 | awk '{print $2}')

    if [[ -z "$http_status" || ! "$http_status" =~ ^[0-9]+$ ]]; then
        log_error "No se pudo extraer código de estado HTTP válido."
        echo "ERROR: Respuesta HTTP malformada" >>"$evidence_file"
        return 1
    fi

    # Análisis del código de estado
    echo "" >>"$evidence_file"
    echo "=== ANÁLISIS DEL CÓDIGO HTTP ===" >>"$evidence_file"
    echo "Código obtenido: $http_status" >>"$evidence_file"

    case "$http_status" in
    "200")
        echo "✓ Código 200: Exitoso" >>"$evidence_file"
        log_ok "El código de estado HTTP es 200."
        return 0
        ;;
    "301" | "302" | "307" | "308")
        echo "⚠ Código $http_status: Redirección" >>"$evidence_file"
        log_info "Código de redirección $http_status (aceptable)"
        return 0
        ;;
    "404")
        echo "✗ Código 404: Página no encontrada" >>"$evidence_file"
        log_error "Error 404: La página no existe."
        return 1
        ;;
    "403")
        echo "✗ Código 403: Acceso prohibido" >>"$evidence_file"
        log_error "Error 403: Acceso denegado."
        return 1
        ;;
    "500")
        echo "✗ Código 500: Error interno del servidor" >>"$evidence_file"
        log_error "Error 500: El servidor tiene un problema interno."
        return 1
        ;;
    "503")
        echo "✗ Código 503: Servicio no disponible" >>"$evidence_file"
        log_error "Error 503: Servicio temporalmente no disponible."
        return 1
        ;;
    *)
        if [[ $http_status -ge 200 && $http_status -lt 300 ]]; then
            echo "✓ Código $http_status: Exitoso" >>"$evidence_file"
            log_ok "Código HTTP $http_status es exitoso."
            return 0
        else
            echo "✗ Código $http_status: Error" >>"$evidence_file"
            log_error "Error HTTP $http_status."
            return 1
        fi
        ;;
    esac
}
