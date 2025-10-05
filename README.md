## Repositorio para la Actividad 7

### Preguntas

#### A) Evitar (o no) `--ff`

- Ejecuta una fusión FF real (ver 1).
- **Pregunta:** ¿Cuándo **evitarías** `--ff` en un equipo y por qué?

#### B) Trabajo en equipo con `--no-ff`

- Crea dos ramas con cambios paralelos y **fusiónalas con `--no-ff`**.
- **Preguntas:** ¿Qué ventajas de trazabilidad aporta? ¿Qué problemas surgen con **exceso** de merges?
  La principal ventaja de --no-ff es que preserva explícitamente el contexto de la fusión, exigiendo que se cree un merge commit incluso cuando no es realmente necesario.
  El exceso de merges ensucia y hace mas complicado de entender el historial de commits.
