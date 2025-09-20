TARGET_URL ?= https://example.com
RELEASE ?= v1.0.0-sprint2

# Targets que no generan archivos
.PHONY: help tools build test run pack clean

# Target por defecto
help: ## Mostrar ayuda disponible
	@echo "=== Integrador de Checks de Seguridad ==="
	@echo "Targets disponibles:"
	@echo "  tools      - Verificar herramientas necesarias"
	@echo "  build      - Preparar artefactos intermedios"
	@echo "  test       - Ejecutar tests con Bats"
	@echo "  run        - Ejecutar checks de seguridad"
	@echo "  pack       - Generar paquete en dist/"
	@echo "  clean      - Limpiar out/ y dist/"
	@echo "  help       - Mostrar esta ayuda"
	@echo ""
	@echo "Ejemplo: make run TARGET_URL=https://github.com"

tools: ## Verificar disponibilidad de herramientas
	@echo "Verificando herramientas del temario..."
	@command -v bash >/dev/null 2>&1 || { echo "ERROR: bash faltante"; exit 1; }
	@command -v curl >/dev/null 2>&1 || { echo "ERROR: curl faltante"; exit 1; }
	@command -v dig >/dev/null 2>&1 || { echo "ERROR: dig faltante"; exit 1; }
	@command -v openssl >/dev/null 2>&1 || { echo "ERROR: openssl faltante"; exit 1; }
	@command -v ss >/dev/null 2>&1 || { echo "ERROR: ss faltante"; exit 1; }
	@command -v nc >/dev/null 2>&1 || { echo "ERROR: nc faltante"; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "WARN: bats faltante para tests"; }
	@echo "✓ Herramientas verificadas"

build: tools ## Preparar artefactos intermedios en out/
	@echo "Preparando artefactos intermedios..."
	@mkdir -p out/logs out/reports out/evidence
	@echo "Build info - $(RELEASE)" > out/build_info.txt
	@date >> out/build_info.txt
	@echo "✓ Artefactos preparados en out/"

test: build ## Ejecutar Bats y validar criterios mínimos
	@echo "Ejecutando suite de pruebas..."
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/; \
	else \
		echo "ERROR: bats no disponible - instalar para tests"; \
		exit 1; \
	fi

run: build ## Ejecutar flujo principal
	@echo "Ejecutando checks para $(TARGET_URL)"
	@cd src && TARGET_URL=$(TARGET_URL) bash security_checker.sh

pack: build test ## Generar paquete reproducible en dist/
	@echo "Generando paquete $(RELEASE)..."
	@mkdir -p dist
	@tar -czf dist/security-integrator-$(RELEASE).tar.gz \
		src/ tests/ docs/ Makefile .env.example
	@echo "✓ Paquete: dist/security-integrator-$(RELEASE).tar.gz"

clean: ## Limpieza segura de out/ y dist/
	@echo "Limpiando directorios temporales..."
	@rm -rf out/ dist/
	@echo "✓ Limpieza completada"
