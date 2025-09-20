#!/bin/bash
# src/tls_checker.sh
# Contiene la lógica para verificaciones TLS/certificados

check_tls() {
    local url="$1"
    local domain

    # Extraer dominio de la URL
    domain=$(echo "$url" | sed -e 's|https://||' -e 's|http://||' -e 's|/.*$||')

    log_info "Iniciando check TLS para '$domain'..."

    # Archivo para guardar evidencia
    local evidence_file
    evidence_file=$(mktemp ../out/tls_check_XXXXXX.txt)

    {
        echo "--- Evidencia TLS para $domain ---"
        echo "Fecha: $(date)"
        echo "Puerto: ${TLS_PORT:-443}"
        echo ""
    } >"$evidence_file"

    # Verificar que sea HTTPS
    if [[ ! "$url" =~ ^https:// ]]; then
        log_error "URL debe usar HTTPS para verificación TLS: $url"
        echo "ERROR: URL no es HTTPS" >>"$evidence_file"
        return 1
    fi

    # Test básico de conectividad TLS
    log_info "Probando conectividad TLS..."

    local tls_test
    if tls_test=$(timeout "${HTTP_TIMEOUT:-30}" openssl s_client -connect "$domain:${TLS_PORT:-443}" -servername "$domain" </dev/null 2>&1); then
        echo "=== Test de conectividad TLS ===" >>"$evidence_file"
        echo "$tls_test" >>"$evidence_file"

        # Verificar si la conexión fue exitosa
        if echo "$tls_test" | grep -q "Verify return code: 0 (ok)"; then
            log_ok "Conectividad TLS establecida correctamente"

            # Extraer información del certificado
            extract_cert_info "$domain" "$evidence_file"

        elif echo "$tls_test" | grep -q "certificate verify failed"; then
            log_error "Verificación de certificado falló para $domain"
            echo "ERROR: Certificado no válido" >>"$evidence_file"
            return 1

        else
            log_error "Conexión TLS falló para $domain"
            echo "ERROR: Conexión TLS falló" >>"$evidence_file"
            return 1
        fi
    else
        log_error "Timeout o error en conexión TLS para $domain"
        echo "ERROR: Timeout en conexión TLS" >>"$evidence_file"
        return 1
    fi

    log_info "Evidencia TLS guardada en: $evidence_file"
    log_ok "Verificación TLS completada para '$domain'"
    return 0
}

# Función auxiliar para extraer información del certificado
extract_cert_info() {
    local domain="$1"
    local evidence_file="$2"

    log_info "Extrayendo información del certificado..."

    # Obtener certificado y extraer información básica
    local cert_info
    if cert_info=$(timeout 10 openssl s_client -connect "$domain:${TLS_PORT:-443}" -servername "$domain" </dev/null 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null); then

        echo "" >>"$evidence_file"
        echo "=== Información del Certificado ===" >>"$evidence_file"
        echo "$cert_info" >>"$evidence_file"

        # Extraer fecha de expiración
        local expiry_date
        expiry_date=$(echo "$cert_info" | grep "notAfter=" | cut -d= -f2)

        if [[ -n "$expiry_date" ]]; then
            log_info "Certificado expira: $expiry_date"
            echo "Fecha de expiración: $expiry_date" >>"$evidence_file"

            # Verificar si expira pronto (advertencia temprana)
            check_cert_expiry "$expiry_date" "$evidence_file"
        fi

        # Extraer emisor del certificado
        local issuer
        issuer=$(echo "$cert_info" | grep "issuer=" | cut -d= -f2-)
        if [[ -n "$issuer" ]]; then
            log_info "Emisor del certificado: $issuer"
            echo "Emisor: $issuer" >>"$evidence_file"
        fi

    else
        log_error "No se pudo obtener información del certificado"
        echo "ERROR: No se pudo extraer información del certificado" >>"$evidence_file"
    fi
}

# Función para verificar si el certificado expira pronto
check_cert_expiry() {
    local expiry_date="$1"
    local evidence_file="$2"

    # Convertir fecha a timestamp (método simple para estudiantes)
    local expiry_timestamp
    if expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null); then
        local current_timestamp
        current_timestamp=$(date +%s)

        local days_until_expiry
        days_until_expiry=$(((expiry_timestamp - current_timestamp) / 86400))

        echo "Días hasta expiración: $days_until_expiry" >>"$evidence_file"

        if [[ $days_until_expiry -lt 0 ]]; then
            log_error "CERTIFICADO EXPIRADO hace $((days_until_expiry * -1)) días"
            echo "ALERTA: CERTIFICADO EXPIRADO" >>"$evidence_file"
        elif [[ $days_until_expiry -lt 7 ]]; then
            log_error "CERTIFICADO EXPIRA EN $days_until_expiry DÍAS - RENOVAR URGENTE"
            echo "ALERTA: Certificado expira muy pronto" >>"$evidence_file"
        elif [[ $days_until_expiry -lt 30 ]]; then
            log_info "Advertencia: Certificado expira en $days_until_expiry días"
            echo "ADVERTENCIA: Renovar certificado pronto" >>"$evidence_file"
        else
            log_ok "Certificado válido por $days_until_expiry días más"
        fi
    else
        log_error "No se pudo parsear fecha de expiración: $expiry_date"
        echo "ERROR: Fecha de expiración no válida" >>"$evidence_file"
    fi
}
