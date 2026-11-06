# Scripts de la base Cafetear

Scripts en T-SQL (SQL Server) para crear la base, cargarla con datos de ejemplo y definir sus objetos (función, vistas, procedimientos, triggers, índices y roles). Todo es inventado.

Para cargar todo de una vez, mirá el [README de la carpeta de arriba](../README.md): `instalador/Cafetear_completo.sql` ejecuta estos scripts en el orden correcto.

## Qué hay en cada carpeta

Para ejecutarlos de a uno, en este orden:

| Orden | Carpeta | Qué hay |
|---|---|---|
| 1 | `tablas/` | `01_crear_base_y_tablas.sql`: crea la base `cafetear`, las 7 tablas y los 3 índices. Borra lo que hubiera |
| 2 | `datos/` | `02_datos_maestros.sql`: 10 proveedores, 10 granos, 40 lotes, 10 baristas y 60 clientes. `03_calibraciones.sql`: 225 calibraciones entre junio de 2025 y octubre de 2026. `04_calificaciones.sql`: 346 calificaciones. |
| 3 | `funciones/` | 1 función: relación de extracción (rendimiento ÷ dosis) |
| 4 | `vistas/` | 2 vistas: puntaje por calibración y mejor calibración por grano |
| 5 | `procedimientos/` | 3 procedimientos: crear calibración, crear calificación y ranking de baristas |
| 6 | `triggers/` | 2 triggers: control de calificaciones y asignación automática de la calibración |
| 7 | `seguridad/` | `roles.sql`: 2 roles, barista (registra calibraciones y calificaciones) y dueños (ven todo y ejecutan todo). `respaldo.sql`: copia de seguridad y su verificación |
| — | `consultas/` | `Queries.sql`: las consultas de cada integrante |
| — | `pruebas/` | `probar_todo.sql`: prueba todo, incluidos los casos de error, y no deja datos. `verificar_carga.sql`: comprueba que la carga quedó completa, con un OK o ERROR por control |
| — | `instalador/` | `Cafetear_completo.sql`: todo en un solo archivo, se ejecuta con F5 en SSMS y verifica la carga al final |

Los scripts de funciones, vistas, procedimientos, triggers y roles se pueden volver a ejecutar sin problema. Los de `tablas/` y `datos/` borran y recrean las tablas (y sus índices), así que también se pueden volver a ejecutar.

Los datos son siempre los mismos, así que todo el equipo ve lo mismo.

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
