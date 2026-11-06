# Cafetear · Base de datos

SQL Server 2022 en Docker con la base **Cafetear** (7 tablas), datos de ejemplo y los objetos que pide la consigna: **función, vistas, procedimientos, triggers**, índices y roles. Todo se levanta con un comando y **todo el equipo ve exactamente los mismos datos**: están guardados como archivos `.sql` fijos y no se generan al azar en cada máquina.

## Levantarlo

Necesitás Docker Desktop (con 4 GB de memoria asignados; SQL Server pide 2 GB como mínimo).

```bash
cd cafetear
docker compose up -d
```

La primera vez tarda 1 o 2 minutos (descarga la imagen y crea la base). Para ver cómo salió la carga:

```bash
docker compose logs init
```

Tiene que terminar mostrando estas cantidades, que son las mismas para todos:

| Tabla | Filas |
|---|---|
| Proveedor | 10 |
| Grano | 10 |
| Lote | 40 |
| Barista | 10 |
| Cliente | 60 |
| Calibracion | 225 |
| Calificacion | 346 |

Y, en la segunda tabla: 3 procedimientos, 2 vistas, 1 función, 2 triggers y 3 índices. Si tu resultado es distinto, algo no cargó bien: mirá la sección de problemas frecuentes.

## Conectarse

| Dato | Valor |
|---|---|
| Servidor | `localhost`, puerto `1433` |
| Usuario | `sa` |
| Contraseña | `Cafetear_2026!` |
| Base | `Cafetear` |

En el cliente SQL (extensión de VS Code, Azure Data Studio, DBeaver) activá **Trust server certificate**, porque el certificado es local.

Si el puerto 1433 ya lo usa otro SQL Server, o querés otra contraseña, copiá `.env.example` como `.env` y cambiá `DB_PORT` o `SA_PASSWORD`.

## Comandos que vas a usar

| Qué querés hacer | Comando |
|---|---|
| Ver el estado | `docker compose ps` |
| Apagar y conservar tus datos | `docker compose down` |
| Apagar y borrar todo | `docker compose down -v` |
| Volver a los datos de ejemplo | `RESET_DB=1 docker compose run --rm init` |
| Recargar solo los objetos (procedimientos, vistas, triggers, etc.) | `docker compose run --rm init` |
| Sumar los errores a propósito (enunciados 27 y 28) | `WITH_ERRORS=1 RESET_DB=1 docker compose run --rm init` |
| Sumar las calibraciones de hoy (enunciado 31) | `WITH_TODAY=1 RESET_DB=1 docker compose run --rm init` |

Volver a hacer `docker compose up` **no pisa** los datos que cargaste. Solo actualiza los procedimientos, funciones, vistas, triggers, índices y roles con lo que haya en `queries/procedimientos`, `funciones`, `vistas`, `triggers`, `indices` y `seguridad`. Por eso, cuando un compañero cambia un procedimiento, los demás lo reciben corriendo `docker compose run --rm init`.

## Qué hay en la carpeta `queries`

| Carpeta | Qué hay |
|---|---|
| `tablas/` | `01_crear_base_y_tablas.sql`: la base y las 7 tablas |
| `datos/` | Los datos de ejemplo (de junio de 2025 a octubre de 2026), más dos scripts opcionales con errores a propósito (enunciados 27 y 28) y calibraciones de hoy (enunciado 31), y el que limpia los errores |
| `procedimientos/` | `procedimientos.sql`: `usp_Calibracion_Crear`, `usp_Calificacion_Crear` y `usp_RankingBaristas` |
| `funciones/` | `fn_RelacionExtraccion` |
| `vistas/` | `vw_PuntajePorCalibracion` (usa la función y la reutilizan la otra vista y el ranking) y `vw_MejorCalibracionPorGrano` |
| `triggers/` | `trg_Calificacion_Control` (puntaje de 1 a 5, no anterior a la calibración, una por cliente) y `trg_Calificacion_AsignarCalibracion` (asigna la calibración más próxima) |
| `indices/` | Los 3 índices |
| `seguridad/` | Los 2 roles (barista y analista) y sus permisos |
| `consultas/` | `Queries.sql`: las consultas de cada uno |
| `pruebas/` | `probar_todo.sql`: prueba todo, incluidos los errores, y no deja datos |
| `mantenimiento/` | `backup_y_restauracion.sql`: copia de seguridad y restauración. `limpiar_objetos.sql`: lo usa la carga para recrear los objetos |
| `inicializar.sh`, `cargar_cafetear.sh` | Scripts de carga (el segundo es para quien ya tiene su propio SQL Server en Docker) |

Los archivos de `tablas/` y `datos/` **no se editan a mano**: los genera `herramientas/generar_datos.py` (ver más abajo). Lo demás sí se edita a mano. El detalle del orden de ejecución está en [queries/README.md](queries/README.md).

## Procedimientos y reglas del negocio

Para registrar calibraciones y calificaciones se usan los procedimientos, así las reglas se aplican siempre en el mismo lugar:

```sql
-- Registrar una calibración: devuelve el ID nuevo
EXEC usp_Calibracion_Crear @fechaCalibracion = '2026-11-05T08:30:00', @dosis = 18.0,
                           @tiempoExtraccion = 28, @rendimiento = 36.0, @IDBarista = 1, @IDLote = 3;

-- Registrar una calificación: no se indica la calibración, la asigna un trigger
EXEC usp_Calificacion_Crear @fecha = '2026-11-05T10:00:00', @puntaje = 5, @IDCliente = 1;

-- Ranking de baristas en un período
EXEC usp_RankingBaristas @desde = '2026-01-01', @hasta = '2026-10-31';
```

El cliente no conoce la calibración que le tocó, así que `trg_Calificacion_AsignarCalibracion` (un trigger `INSTEAD OF INSERT`) la completa con la más próxima anterior a la fecha de la calificación. Vale para cualquier `INSERT`, venga o no de un procedimiento.

### Errores

| Dónde | Regla |
|---|---|
| `usp_Calibracion_Crear` | Dosis, tiempo y rendimiento mayores a cero, y no anterior al ingreso del lote |
| `trg_Calificacion_Control` | Puntaje de 1 a 5, calificación no anterior a la calibración y un cliente no califica dos veces la misma calibración |
| `trg_Calificacion_AsignarCalibracion` | Tiene que existir una calibración anterior a la fecha de la calificación |

El resto lo resuelve la propia tabla, con mensajes de SQL Server en inglés: tipos de dato, tamaño, `NOT NULL`, `UNIQUE` (CUIT y DNI) y claves foráneas.

## Decisiones de diseño que conviene conocer

- **IDs.** Barista, Cliente y Proveedor usan `IDENTITY`, como en el DER. Grano, Lote, Calibracion y Calificacion no, así que los procedimientos de creación toman el ID como el máximo más uno. Es simple y alcanza para trabajar en el TP, pero dos usuarios creando a la vez podrían chocar.
- **Reglas en procedimientos y triggers, no en la tabla.** Los enunciados 32 a 34 piden agregar restricciones `CHECK` y `UNIQUE` con `ALTER TABLE`. Por eso las tablas no las traen, y mientras tanto los procedimientos y triggers ya hacen esas validaciones.
- **Datos de ejemplo.** Son inventados, incluidos los CUIT. Cuentan una historia para que las queries devuelvan resultados interesantes: la calidad mejora con el tiempo con algunos bajones, cada vez hacen falta menos pruebas por día, hay rotación de baristas y clientes que entran y se van. El detalle está en `queries/README.md`.

## Cambiar los datos

El programa está en la carpeta `herramientas` y necesita Python 3:

| Programa | Qué genera |
|---|---|
| `python3 herramientas/generar_datos.py` | Los archivos de `queries/tablas`, `queries/datos` y `queries/README.md` |

Los datos salen siempre iguales mientras no se toque el programa. Si alguien cambia algo y lo vuelve a generar, hay que avisar al equipo para que todos recarguen con `RESET_DB=1 docker compose run --rm init`.

## Trabajar en equipo con git

El proyecto tiene un repositorio git listo. Las contraseñas del `.env` no se suben. Para compartirlo:

```bash
git add .
git commit -m "Base de datos Cafetear"
git remote add origin <url-del-repositorio>
git push -u origin main
```

Quien lo clona solo necesita `docker compose up -d`. El archivo `.gitattributes` evita que Windows rompa los scripts cambiando los finales de línea.

## Problemas frecuentes

| Problema | Solución |
|---|---|
| `port is already allocated` | El 1433 está ocupado. Creá un `.env` con `DB_PORT=14330` y volvé a levantar |
| El contenedor `db` queda en `unhealthy` | Falta memoria: subí la de Docker Desktop a 4 GB |
| `Login failed for user 'sa'` | La contraseña del volumen viejo es otra. Corré `docker compose down -v` y volvé a levantar |
| Mac con chip Apple, arranca lento | Es normal: la imagen de SQL Server corre emulada, puede tardar 1 o 2 minutos |
| Las cantidades no coinciden con la tabla de arriba | Alguien cargó datos propios o las calibraciones de hoy. Volvé a los datos de ejemplo con `RESET_DB=1 docker compose run --rm init` |
| `bash\r: No such file or directory` en Windows | Los scripts quedaron con finales de línea de Windows. Con git y el `.gitattributes` no pasa. Si descargaste un zip, volvelos a bajar con git |
