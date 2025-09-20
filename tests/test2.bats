#!/usr/bin/env bats

# Limpiar antes de cada test
setup() {
    rm -rf out/
    mkdir -p out
}

# ================================
# TESTS BÁSICOS (desde Sprint 1)
# ================================

@test "Los archivos principales existen" {
    [ -f "src/security_checker.sh" ]
    [ -f "src/utils.sh" ]
    [ -f "src/http_checker.sh" ]
    [ -f "src/dns_checker.sh" ]
    [ -f "src/tls_checker.sh" ]
}

@test "El script funciona con google.com" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
    cd ..
}

@test "Se crean archivos de evidencia" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh

    # Verificar que hay archivos en out/
    [ -n "$(ls ../out/)" ]
    cd ..
}

# ================================
# TESTS NUEVOS SPRINT 2
# Casos de fallo reales
# ================================

@test "Pipeline detecta dominio inexistente" {
    cd src
    run bash -c "TARGET_URL='https://este-dominio-no-existe-12345.com' bash security_checker.sh"
    
    # Debe fallar (exit code != 0)
    [ "$status" -ne 0 ]
    
    # Debe crear archivo de diagnóstico
    [ -n "$(ls ../out/diagnostic_*.txt 2>/dev/null)" ]
    cd ..
}

@test "Pipeline detecta HTTP vs HTTPS correctamente" {
    cd src
    # URL HTTP no debe hacer check TLS
    TARGET_URL="http://httpbin.org/get" bash security_checker.sh
    
    # No debe haber archivos de TLS para HTTP
    [ -z "$(ls ../out/tls_check_*.txt 2>/dev/null)" ]
    cd ..
}

@test "Pipeline genera evidencias para cada check exitoso" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
    
    # Debe haber evidencia de HTTP
    [ -n "$(ls ../out/http_check_*.txt 2>/dev/null)" ]
    
    # Debe haber evidencia de DNS  
    [ -n "$(ls ../out/dns_check_*.txt 2>/dev/null)" ]
    
    # Debe haber evidencia de TLS
    [ -n "$(ls ../out/tls_check_*.txt 2>/dev/null)" ]
    cd ..
}

@test "Diagnóstico se ejecuta cuando falla DNS" {
    cd src
    run bash -c "TARGET_URL='https://dominio-que-no-resuelve-123456.test' bash security_checker.sh"
    
    # Debe fallar
    [ "$status" -ne 0 ]
    
    # Debe crear archivo de diagnóstico
    diagnostic_file=$(ls ../out/diagnostic_*.txt 2>/dev/null | head -1)
    [ -n "$diagnostic_file" ]
    
    # El diagnóstico debe contener información útil
    grep -q "TEST DE DNS" "$diagnostic_file"
    cd ..
}

@test "Evidencias contienen información esperada" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
    
    # Verificar contenido de evidencia HTTP
    http_evidence=$(ls ../out/http_check_*.txt | head -1)
    [ -n "$http_evidence" ]
    grep -q "HTTP" "$http_evidence"
    
    # Verificar contenido de evidencia DNS
    dns_evidence=$(ls ../out/dns_check_*.txt | head -1)
    [ -n "$dns_evidence" ]
    grep -q "DNS" "$dns_evidence"
    cd ..
}

# ================================
# TESTS DE ROBUSTEZ (Sprint 2)
# ================================

@test "Pipeline maneja URLs malformadas" {
    cd src
    run bash -c "TARGET_URL='esto-no-es-una-url' bash security_checker.sh"
    
    # Debe fallar pero no crashear
    [ "$status" -ne 0 ]
    
    # No debe dejar procesos colgados o archivos .tmp
    [ -z "$(ls ../out/*.tmp 2>/dev/null)" ]
    cd ..
}

@test "Pipeline limpia archivos temporales al salir" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
    
    # No debe quedar ningún archivo .tmp
    [ -z "$(ls ../out/*.tmp 2>/dev/null)" ]
    cd ..
}

@test "Variables de entorno funcionan correctamente" {
    cd src
    HTTP_TIMEOUT=5 TARGET_URL="https://www.google.com" bash security_checker.sh
    
    # Debe completar exitosamente con timeout personalizado
    [ "$?" -eq 0 ]
    cd ..
}

# ================================
# TESTS DE CERTIFICADOS (TLS)
# ================================

@test "Pipeline detecta sitios con certificados válidos" {
    cd src
    TARGET_URL="https://www.google.com" bash security_checker.sh
    
    # TLS debe pasar para Google
    tls_evidence=$(ls ../out/tls_check_*.txt | head -1)
    [ -n "$tls_evidence" ]
    
    # No debe contener mensajes de error
    ! grep -q "ERROR" "$tls_evidence"
    cd ..
}

# Test comentado - requiere sitio con certificado expirado conocido
# @test "Pipeline detecta certificados expirados" {
#     cd src
#     run bash -c "TARGET_URL='https://expired.badssl.com' bash security_checker.sh"
#     
#     # Debe fallar por certificado expirado
#     [ "$status" -ne 0 ]
#     cd ..
# }

# ================================
# TEST DE INTEGRACIÓN FINAL
# ================================

@test "Makefile run funciona con diferentes URLs" {
    make run TARGET_URL="https://httpbin.org/get"
    make run TARGET_URL="http://httpbin.org/get"
}