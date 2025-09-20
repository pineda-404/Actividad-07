#!/bin/bash
# src/utils.sh - Utilidades básicas para estudiantes

# Colores para logs
readonly COLOR_INFO='\033[0;34m'
readonly COLOR_OK='\033[0;32m'
readonly COLOR_ERROR='\033[0;31m'
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
