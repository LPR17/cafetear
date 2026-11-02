# Scripts de la base Cafetear

Scripts en T-SQL (SQL Server) para crear la base, cargarla con datos de ejemplo y definir el CRUD. Todo es inventado.

Para levantar todo con Docker, mirá el [README de la carpeta de arriba](../README.md): `docker compose up -d` ejecuta estos scripts y los procedimientos de `crud/` solo.

Para ejecutarlos a mano, en este orden:

| Orden | Archivo | Qué hace |
|---|---|---|
| 1 | `01_crear_base_y_tablas.sql` | Crea la base `Cafetear` y las 7 tablas. Borra lo que hubiera |
| 2 | `02_datos_maestros.sql` | 6 proveedores, 8 granos, 40 lotes, 7 baristas y 60 clientes |
| 3 | `03_calibraciones.sql` | 207 calibraciones entre junio de 2025 y octubre de 2026 |
| 4 | `04_calificaciones.sql` | 363 calificaciones de clientes |
| 5 | `05_datos_con_errores.sql` | Opcional: errores a propósito para los enunciados 27 y 28 |
| 6 | `06_calibraciones_de_hoy.sql` | Opcional: calibraciones con la fecha de hoy, para el enunciado 31 |
| 7 | `07_limpiar_errores.sql` | Borra lo del paso 5. Correr antes de los enunciados 32 a 34 |
| 8 | `crud/*.sql` | Los 35 procedimientos del CRUD (`usp_<Tabla>_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar`). Se pueden volver a ejecutar sin problema |

`pruebas/probar_crud.sql` prueba todos los procedimientos, incluidos los casos de error, y no deja datos. Los scripts `inicializar.sh` y `cargar_cafetear.sh` hacen toda la carga automáticamente.

Los archivos 01 a 07 los genera `../herramientas/generar_datos.py`: no se editan a mano. Los datos son siempre los mismos, así que todo el equipo ve lo mismo.

## Qué historia cuentan los datos

- **La calidad cambia mes a mes.** Arranca baja en junio de 2025, mejora, tiene bajones en diciembre de 2025 y en junio de 2026, y cierra alta. Los lunes puntúan un poco peor.
- **Cada vez se necesitan menos pruebas por día.** Al principio un barista hace de 3 a 5 pruebas hasta dar con la calibración, y hoy de 1 a 3.
- **Hay rotación.** Valentina Pereyra se fue en mayo de 2026, y Sofía, Mateo, Julián y Camila fueron entrando.
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
- **Clientes 1, 2 y 3** calificaron calibraciones de los 7 baristas (enunciado 17).
- Muchas calibraciones de prueba no tienen calificaciones, porque los clientes solo opinan sobre el café final (enunciado 16).

Los IDs de Barista y Cliente son IDENTITY, así que las calibraciones y calificaciones asumen que esas tablas arrancaron vacías (por eso el script 01 las vuelve a crear).
