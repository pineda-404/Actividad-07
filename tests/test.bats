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
}

@test "El script funciona con google.com" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
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
    TARGET_URL="https://www.google.com" bash security_checker.sh

    # Verificar que hay archivos en out/ (desde donde estamos: src/)
    [ -n "$(ls out/)" ]
    cd ..
}

@test "Makefile run funciona" {
    make run TARGET_URL="https://www.google.com"
}
