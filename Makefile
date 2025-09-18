# Makefile para el integrador de seguridad

# Variable por defecto
TARGET_URL = https://example.com

run: ## Ejecutar el integrador de seguridad
	@echo "Ejecutando checks para $(TARGET_URL)"
	cd src && TARGET_URL=$(TARGET_URL) bash security_checker.sh

test: ## Ejecutar tests
	@echo "Ejecutando tests..."
	bats tests/

clean: ## Limpiar archivos temporales
	@echo "Limpiando..."
	rm -rf out/

help: ## Mostrar ayuda
	@echo "Comandos disponibles:"
	@echo "  run   - Ejecutar checks de seguridad"
	@echo "  test  - Ejecutar tests"
	@echo "  clean - Limpiar archivos"
	@echo ""
	@echo "Ejemplo: make run TARGET_URL=https://github.com"