# Cafetear · Base de datos

Base de datos **SQL Server** de una cafetería de especialidad: registra las calibraciones de la máquina de espresso y la opinión de los clientes sobre cada café. Tiene 7 tablas, datos de ejemplo y los objetos que pide la consigna: **función, vistas, procedimientos y triggers**, además de índices y roles. Todo está en archivos `.sql`: no hace falta instalar nada más que SQL Server y SSMS (o Azure Data Studio).

## Cómo cargarlo

Sirve cualquier SQL Server de 2016 SP1 en adelante (Express, Developer o Standard).

1. Conectate a tu servidor en SSMS o Azure Data Studio.
2. Abrí `queries/instalador/Cafetear_completo.sql` y ejecutalo completo (F5). Es el único punto de instalación: crea la base `cafetear`, carga los datos y crea todos los objetos.
3. Al final **verifica la carga**: muestra una tabla de controles (filas de cada tabla y cantidad de objetos: 10 proveedores, 10 granos, 40 lotes, 10 baristas, 60 clientes, 225 calibraciones, 346 calificaciones, 3 procedimientos, 2 vistas, 1 función, 2 triggers y 3 índices) con `OK` en cada línea y el mensaje `OK: la base cafetear se cargó correctamente.` Si algo no coincide, esa línea dice `ERROR` y el script termina con un error.
4. Abrí `queries/consultas/Queries.sql` y ejecutalo: devuelve un resultado por cada una de las 10 consultas. También se puede seleccionar una sola y ejecutarla.
5. Para probar el comportamiento (errores, triggers y permisos), ejecutá `queries/pruebas/probar_todo.sql`: cada línea tiene que decir `OK` y no deja datos.

Es seguro volver a correr la carga: borra y recrea las tablas de `cafetear` y deja siempre los mismos datos.

Cada archivo `.sql` empieza con `USE cafetear;`, así que siempre trabaja sobre la base correcta.

## Qué hay en la carpeta `queries`

| Carpeta | Qué hay |
|---|---|
| `instalador/` | `Cafetear_completo.sql`: todo en un solo archivo, en orden, con la verificación al final |
| `tablas/` | `01_crear_base_y_tablas.sql`: la base, las 7 tablas y los 3 índices |
| `datos/` | Los datos de ejemplo (de junio de 2025 a octubre de 2026) |
| `funciones/` | `fnRelacionExtraccion` |
| `vistas/` | `vwPuntajePorCalibracion` (usa la función y la reutilizan la otra vista y el ranking) y `vwMejorCalibracionPorGrano` |
| `procedimientos/` | `uspCalibracionCrear`, `uspCalificacionCrear` y `uspRankingBaristas` |
| `triggers/` | `trgCalificacionControl` (puntaje de 1 a 5, no anterior a la calibración, una por cliente) y `trgCalificacionAsignarCalibracion` (asigna la calibración más próxima) |
| `seguridad/` | `roles.sql`: los 2 roles, barista (registra calibraciones y calificaciones) y dueños (ven todo y ejecutan todo). `respaldo.sql`: copia de seguridad y su verificación |
| `consultas/` | `Queries.sql`: las 10 consultas del equipo, sin comentarios y separadas por su número. `explicacion_consultas.txt`: qué datos muestra cada una, para qué sirve y un ejemplo de resultado |
| `pruebas/` | `probar_todo.sql`: prueba todo, incluidos los errores. `verificar_carga.sql`: comprueba que la carga quedó completa (la ejecuta el instalador al final) |

El detalle del orden de ejecución y de los datos está en [queries/README.md](queries/README.md).

Fuera de `queries/` están el informe del trabajo (`informe/`, con el DER) y los materiales de la propuesta y la presentación (`propuesta/`).

**Importante:** `Cafetear_completo.sql` es un archivo fijo que repite lo que hay en las carpetas. Si cambiás un script de una carpeta (por ejemplo un trigger), hacé el mismo cambio en el instalador. Está guardado en UTF-16, que es el formato que SSMS y `sqlcmd` leen bien con los acentos; GitHub no los muestra como texto, así que conviene descargarlo o abrirlo en SSMS y guardarlo con la misma codificación.

## Procedimientos y reglas del negocio

```sql
-- Registrar una calibración: devuelve el ID nuevo
EXEC uspCalibracionCrear @fechaCalibracion = '2026-11-05T08:30:00', @dosis = 18.0,
                           @tiempoExtraccion = 28, @rendimiento = 36.0, @idBarista = 1, @idLote = 3;

-- Registrar una calificación: no se indica la calibración, la asigna un trigger
EXEC uspCalificacionCrear @fecha = '2026-11-05T10:00:00', @puntaje = 5, @idCliente = 1;

-- Ranking de baristas en un período
EXEC uspRankingBaristas @desde = '2026-01-01', @hasta = '2026-10-31';
```

El cliente no conoce la calibración que le tocó, así que `trgCalificacionAsignarCalibracion` (un trigger `INSTEAD OF INSERT`) la completa con la más próxima anterior a la fecha de la calificación. Vale para cualquier `INSERT`, venga o no de un procedimiento.

| Dónde | Regla |
|---|---|
| `uspCalibracionCrear` | Dosis, tiempo y rendimiento mayores a cero, y no anterior al ingreso del lote |
| `trgCalificacionControl` | Puntaje de 1 a 5, calificación no anterior a la calibración y un cliente no califica dos veces la misma calibración |
| `trgCalificacionAsignarCalibracion` | Tiene que existir una calibración anterior a la fecha de la calificación |

El resto lo resuelve la propia tabla, con mensajes de SQL Server: tipos de dato, tamaño, `NOT NULL`, `UNIQUE` (CUIT y DNI) y claves foráneas.

## Decisiones de diseño que conviene conocer

- **IDs.** Barista, Cliente y Proveedor usan `IDENTITY`. Grano, Lote, Calibracion y Calificacion no, así que los procedimientos de creación toman el ID como el máximo más uno. Es simple y alcanza para este trabajo, pero dos usuarios creando a la vez podrían chocar.
- **Reglas en procedimientos y triggers, no en la tabla.** Los enunciados 32 a 34 piden agregar restricciones `CHECK` y `UNIQUE` con `ALTER TABLE`. Por eso las tablas no las traen.
- **Datos de ejemplo.** Son inventados, incluidos los CUIT. Cuentan una historia para que las consultas devuelvan resultados interesantes: la calidad mejora con el tiempo con algunos bajones, cada vez hacen falta menos pruebas por día, hay rotación de baristas y clientes que entran y se van.

## Problemas frecuentes

| Problema | Solución |
|---|---|
| `Invalid object name 'Lote'` al ejecutar una consulta | Estás en otra base (por ejemplo `master`). Elegí `cafetear` en el selector o ejecutá `USE cafetear;` |
| Los acentos se ven mal, o la verificación dice que no se cargaron bien | Abriste el instalador y lo guardaste con otra codificación. Volvé a bajarlo y guardalo como Unicode (UTF-16) |
| Algún control de la verificación dice `ERROR` | La base tiene datos u objetos de otra versión. Borrá la base `cafetear` y volvé a ejecutar `Cafetear_completo.sql` |
| Los nombres de los días salen en español | Es normal en un servidor en español. Solo cambia el idioma, no los resultados |
