## Repositorio para la Actividad 7

### Preguntas

#### A) Evitar (o no) `--ff`

- Ejecuta una fusión FF real (ver 1).
- **Pregunta:** ¿Cuándo **evitarías** `--ff` en un equipo y por qué?
  Evitaria --ff-only cuando el equipo necesita preservar el contexto explícito de una fusión. Aveces los equipos no desean usar opciones como un rebase ya que sobreescribe el historial de las ramas. Otra razon podria ser que los merges marcan hitos importantes como una version o una funcionalidad agregada.

#### B) Trabajo en equipo con `--no-ff`

- Crea dos ramas con cambios paralelos y **fusiónalas con `--no-ff`**.
- **Preguntas:** ¿Qué ventajas de trazabilidad aporta? ¿Qué problemas surgen con **exceso** de merges?
  La principal ventaja de --no-ff es que preserva explícitamente el contexto de la fusión, exigiendo que se cree un merge commit incluso cuando no es realmente necesario.
  El exceso de merges ensucia y hace mas complicado de entender el historial de commits.

#### C) Squash con muchos commits

- Haz 3-4 commits en `feature-3` y aplánalos con `--squash`.
- **Preguntas:** ¿Cuándo conviene? ¿Qué se **pierde** respecto a merges estándar?
  Los casos donde convienen hacer un squahs son:
- Para limpiar el "ruido" del desarrollo
- Para tratar una funcionalidad como una unidad atómica
- Para simplificar el historial
  Lo que se pierde seria el contexto explicito de la fusión, el historial de desarrollo y la autoria individual de los commits ya que el nuevo commit tendra como autor a la persona que hizo el squash.
