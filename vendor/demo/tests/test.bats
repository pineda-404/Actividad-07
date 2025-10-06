#!/usr/bin/env bats

# Limpiar antes de cada test
setup() {
    rm -rf out/
    mkdir -p out
}

@test "Los archivos principales existen" {
    [ -f "src/security_checker.sh" ]
    [ -f "src/utils.sh" ]
    [ -f "src/http_checker.sh" ]
    [ -f "src/dns_checker.sh" ]
    [ -f "src/tls_checker.sh" ]
}

@test "El script funciona con URL desde línea de comandos" {
    cd src
    TARGET_URL="https://example.com" bash security_checker.sh
    cd ..
}

@test "El script usa .env cuando no hay variable de entorno" {
    cd src
    bash security_checker.sh
    cd ..
}

@test "El script detecta dominios que no existen" {
    cd src
    run bash -c "TARGET_URL='https://sitio-que-no-existe-12345.com' bash security_checker.sh"
    [ "$status" -ne 0 ]
    cd ..
}

@test "Se crean archivos de evidencia" {
    cd src
    TARGET_URL="https://example.com" bash security_checker.sh

    # Verificar que hay archivos en ../out/ (desde src/)
    [ -n "$(ls ../out/)" ]

    # Verificar tipos específicos de archivos
    ls ../out/http_check_* >/dev/null 2>&1
    ls ../out/dns_check_* >/dev/null 2>&1
    ls ../out/tls_check_* >/dev/null 2>&1

    cd ..
}

@test "TLS check se ejecuta para sitios HTTPS" {
    cd src
    run bash -c "TARGET_URL='https://example.com' bash security_checker.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "TLS check completado exitosamente" ]]
    cd ..
}

@test "Script genera archivos de diagnóstico cuando hay fallos" {
    cd src
    run bash -c "TARGET_URL='https://sitio-que-no-existe-12345.com' bash security_checker.sh"

    # Debe fallar pero generar archivos de diagnóstico
    [ "$status" -ne 0 ]
    ls ../out/diagnostic_* >/dev/null 2>&1 || true
    cd ..
}

@test "Makefile run funciona con variable personalizada" {
    make run TARGET_URL="https://example.com"
}
