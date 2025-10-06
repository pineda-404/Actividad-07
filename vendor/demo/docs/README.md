# PC1 - Integrador de Checks de Seguridad

Este proyecto es la implementación de un integrador de seguridad en Bash como parte de la Primera Práctica Calificada. La herramienta ejecuta una serie de chequeos (HTTP, DNS, TLS) sobre una URL objetivo para verificar su estado y configuración de seguridad.

## Estructura del Proyecto

El repositorio está organizado de la siguiente manera para separar responsabilidades:

- `src/`: Contiene todo el código fuente en scripts de Bash. El script principal es `security_checker.sh`, que utiliza los demás (`http_checker.sh`, `dns_checker.sh`) como módulos.
- `tests/`: Contiene los casos de prueba automatizados escritos con el framework Bats.
- `docs/`: Documentación del proyecto, incluyendo las bitácoras de cada sprint.
- `out/`: Directorio donde se guardan los archivos de evidencia generados en cada ejecución.
- `dist/`: Directorio para los paquetes finales del proyecto.
- `Makefile`: Archivo de automatización para facilitar la ejecución de tareas comunes como correr el programa o ejecutar los tests.

## Herramientas Utilizadas

Este proyecto se basa en herramientas estándar de la línea de comandos de Linux:

- **Bash:** Para la lógica de los scripts.
- **`curl`:** Para realizar las peticiones HTTP y analizar las respuestas.
- **`dig`:** Para las consultas DNS y la verificación de registros.
- **`make`:** Para automatizar el flujo de trabajo.
- **`bats`:** Para las pruebas automatizadas de los scripts.
- **Unix Toolkit (`sed`, `awk`, `grep`):** Para procesar y extraer información de las salidas de los comandos.

## Cómo Usar el Proyecto

### 1. Prerrequisitos

Asegúrate de tener instaladas las herramientas necesarias. En un sistema basado en Debian/Ubuntu:

```bash
sudo apt update && sudo apt install curl dnsutils bats
```

````

### 2. Configuración

La URL a verificar se configura mediante una variable de entorno. Para desarrollo local, puedes crear un archivo `.env` en la raíz del proyecto.

1.  Copia la plantilla de ejemplo:
    ```bash
    cp .env.example .env
    ```
2.  Edita el archivo `.env` con la URL que desees probar:
    ```
    TARGET_URL="https://example.com"
    ```

### 3. Ejecución

El `Makefile` proporciona los comandos principales para interactuar con el proyecto. Deben ejecutarse desde la raíz del repositorio.

- **Ejecutar los chequeos de seguridad:**

  ```bash
  make run
  ```

  Esto usará la URL definida en el archivo `.env`. Los archivos de evidencia se guardarán en la carpeta `out/`.

- **Ejecutar con una URL personalizada:**
  Puedes sobreescribir la URL desde la línea de comandos:

  ```bash
  make run TARGET_URL="https://github.com"
  ```

- **Ejecutar las pruebas automatizadas:**

  ```bash
  make test
  ```

- **Limpiar los archivos generados:**
  ```bash
  make clean
  ```

## Flujo de Trabajo (Git)

El proyecto sigue un flujo de trabajo basado en ramas:

- Cada integrante trabaja en su propia rama personal (ej. `rama/alumno1`).
- Los cambios se proponen para ser integrados en la rama `develop` a través de Pull Requests.
- Al final de cada sprint, la rama `develop` se fusiona en `main`.
````
