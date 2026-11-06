# Scripts de la base Cafetear

Scripts en T-SQL (SQL Server) para crear la base, cargarla con datos de ejemplo y definir sus objetos (procedimientos, funciones, vistas, triggers, índices y roles). Todo es inventado.

Para levantar todo con Docker, mirá el [README de la carpeta de arriba](../README.md): `docker compose up -d` ejecuta estos scripts en el orden correcto.

## Qué hay en cada carpeta

Para ejecutarlos a mano, en este orden:

| Orden | Carpeta | Qué hay |
|---|---|---|
| 1 | `tablas/` | `01_crear_base_y_tablas.sql`: crea la base `Cafetear` y las 7 tablas. Borra lo que hubiera |
| 2 | `datos/` | `02_datos_maestros.sql`: 10 proveedores, 10 granos, 40 lotes, 10 baristas y 60 clientes. `03_calibraciones.sql`: 225 calibraciones entre junio de 2025 y octubre de 2026. `04_calificaciones.sql`: 346 calificaciones. Opcionales: `05_datos_con_errores.sql` (errores a propósito para los enunciados 27 y 28), `06_calibraciones_de_hoy.sql` (enunciado 31) y `07_limpiar_errores.sql` (borra lo del 05; correr antes de los enunciados 32 a 34) |
| 3 | `funciones/` | 4 funciones: relación de extracción, puntaje promedio de un lote, días desde el tostado y calibraciones de un barista |
| 4 | `vistas/` | 4 vistas: puntaje por calibración, rendimiento por lote, mejor calibración por grano y calibraciones de hoy |
| 5 | `procedimientos/` | `crud/`: los 35 procedimientos del CRUD, un archivo por tabla (`usp_<Tabla>_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar`). `reportes.sql`: `usp_RankingBaristas` y `usp_ReporteLote` |
| 6 | `triggers/` | 3 triggers: control de calibraciones, control de calificaciones y asignación automática de la calibración |
| 7 | `indices/` | 7 índices sobre claves foráneas y fechas |
| 8 | `seguridad/` | 3 roles (barista, analista, administrador) con sus permisos |
| — | `consultas/` | `Queries.sql`: las consultas de cada integrante |
| — | `pruebas/` | `probar_crud.sql` y `probar_objetos.sql`: prueban todo, incluidos los casos de error, y no dejan datos |
| — | `mantenimiento/` | `backup_y_restauracion.sql`: hace y verifica una copia de seguridad |

Los scripts `inicializar.sh` y `cargar_cafetear.sh` hacen toda la carga automáticamente. Los scripts de funciones, vistas, procedimientos, triggers, índices y roles se pueden volver a ejecutar sin problema.

Los triggers se crean después de cargar los datos. Por eso `datos/05_datos_con_errores.sql` solo se puede correr si los triggers todavía no existen: usá la carga con `--con-errores`, que lo hace en el orden correcto.

Los archivos de `tablas/` y `datos/` y los de `procedimientos/crud/` los generan los programas de `../herramientas/`: no se editan a mano. Los datos son siempre los mismos, así que todo el equipo ve lo mismo.

## Qué historia cuentan los datos

- **La calidad cambia mes a mes.** Arranca baja en junio de 2025, mejora, tiene bajones en diciembre de 2025 y en junio de 2026, y cierra alta. Los lunes puntúan un poco peor.
- **Cada vez se necesitan menos pruebas por día.** Al principio un barista hace de 3 a 5 pruebas hasta dar con la calibración, y hoy de 1 a 3.
- **Hay rotación.** Ramiro Quiroga estuvo hasta octubre de 2025, Florencia Montero de noviembre de 2025 a febrero de 2026 y Valentina Pereyra hasta mayo de 2026. Sofía, Julián, Camila, Mateo y Tomás Arias fueron entrando.
- **Los clientes entran y se van.** Hay clientes habituales y otros que dejan de opinar.

## Casos armados para los enunciados

- **Boa Esperança Honey (lote 36)** empieza a bajar de puntaje desde fines de septiembre de 2026 (enunciado 22).
- **Konga Lavado (lote 23)** rinde mal durante toda su vida (enunciado 8).
- **Idido Natural (lote 31)** mejora con el tiempo.
- **Hay lotes que nunca se calibraron**, entre ellos el último en llegar, El Tablón Natural (lote 40) (enunciado 2).
- **Baristas 1 y 2** calibraron granos de las 8 regiones (enunciado 18). El grano 8 solo lo calibran ellos dos.
- **Martina Ríos (1)** nunca recibe menos de 3 (enunciado 14).
- **Camila Ferrer (7)** recibe 5 y también 1 o 2 (enunciado 15).
- **Mateo Duarte (4)** tiene la última calibración con puntajes bajos (enunciado 23).
- **Julián Acosta (6)** no tiene calificaciones desde septiembre de 2026 (enunciado 25).
- **Clientes 1, 2 y 3** calificaron calibraciones de los 10 baristas (enunciado 17).
- **Los granos 9 y 10** están en el catálogo pero todavía no tienen lotes.
- Muchas calibraciones de prueba no tienen calificaciones, porque los clientes solo opinan sobre el café final (enunciado 16).

Los IDs de Barista y Cliente son IDENTITY, así que las calibraciones y calificaciones asumen que esas tablas arrancaron vacías (por eso el script 01 las vuelve a crear).
