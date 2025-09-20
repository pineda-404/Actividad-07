# src/utils.sh

# Definimos colores para los logs para que sean más legibles.
readonly COLOR_INFO='\033[0;34m'
readonly COLOR_OK='\033[0;32m'
readonly COLOR_ERROR='\033[0;31m'
readonly COLOR_RESET='\033[0m'

log_info() {
    echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $1"
}

log_ok() {
    echo -e "${COLOR_OK}[OK]${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $1" >&2
}
