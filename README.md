# Cafetear · Base de datos

SQL Server 2022 en Docker con la base **Cafetear** (7 tablas), datos de ejemplo y un **CRUD completo hecho con procedimientos almacenados**. Todo se levanta con un comando y **todo el equipo ve exactamente los mismos datos**: están guardados como archivos `.sql` fijos y no se generan al azar en cada máquina.

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

Y, en la segunda tabla: 37 procedimientos, 4 vistas, 4 funciones, 2 triggers y 7 índices. Si tu resultado es distinto, algo no cargó bien: mirá la sección de problemas frecuentes.

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
| Recargar solo los procedimientos | `docker compose run --rm init` |
| Sumar los errores a propósito (enunciados 27 y 28) | `WITH_ERRORS=1 RESET_DB=1 docker compose run --rm init` |
| Sumar las calibraciones de hoy (enunciado 31) | `WITH_TODAY=1 RESET_DB=1 docker compose run --rm init` |

Volver a hacer `docker compose up` **no pisa** los datos que cargaste. Solo actualiza los procedimientos con lo que haya en `queries/crud`. Por eso, cuando un compañero cambia un procedimiento, los demás lo reciben corriendo `docker compose run --rm init`.

## Qué hay en la carpeta `queries`

| Archivo o carpeta | Qué es |
|---|---|
| `01` a `04` | Crean las tablas y cargan los datos de ejemplo: de junio de 2025 a octubre de 2026 |
| `05_datos_con_errores.sql` | Opcional: errores a propósito para los enunciados 27 y 28 |
| `06_calibraciones_de_hoy.sql` | Opcional: calibraciones con la fecha de hoy, para el enunciado 31 |
| `07_limpiar_errores.sql` | Borra lo del 05 |
| `crud/` | Los 35 procedimientos del CRUD, un archivo por tabla |
| `objetos/` | Funciones, vistas, procedimientos de reporte, triggers, índices y roles |
| `pruebas/` | `probar_crud.sql` y `probar_objetos.sql`: prueban todo, incluidos los errores, y no dejan datos |
| `mantenimiento/backup_y_restauracion.sql` | Copia de seguridad y restauración |
| `Queries.sql` | Espacio para las consultas de cada uno |
| `inicializar.sh`, `cargar_cafetear.sh` | Scripts de carga (el segundo es para quien ya tiene su propio SQL Server en Docker) |

Los archivos `01` a `07` y `crud/` **no se editan a mano**: los generan los programas de la carpeta `herramientas` (ver más abajo). Los de `objetos/` sí se editan a mano.

## Regla del equipo: el CRUD va solo por procedimientos

Para crear, leer, modificar y borrar datos se usan los procedimientos y no `INSERT`, `UPDATE` ni `DELETE` directos. Así las reglas de negocio (puntaje de 1 a 5, no calibrar un lote antes de que ingrese, etc.) se aplican siempre en el mismo lugar.

Cada tabla tiene cinco procedimientos con el nombre `usp_<Tabla>_<Acción>`:

| Tabla | Procedimientos |
|---|---|
| Proveedor | `usp_Proveedor_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Grano | `usp_Grano_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Lote | `usp_Lote_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Barista | `usp_Barista_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Cliente | `usp_Cliente_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Calibracion | `usp_Calibracion_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |
| Calificacion | `usp_Calificacion_Crear`, `_Obtener`, `_Listar`, `_Actualizar`, `_Eliminar` |

### Cómo se usan

```sql
-- Crear: devuelve el ID nuevo
EXEC usp_Barista_Crear @DNI = '30111222', @nombre = N'Ana', @apellido = N'Gómez', @experiencia = 3;

-- Obtener uno, listar todos y actualizar
EXEC usp_Barista_Obtener @IDBarista = 8;
EXEC usp_Barista_Listar;
EXEC usp_Barista_Actualizar @IDBarista = 8, @DNI = '30111222', @nombre = N'Ana', @apellido = N'Gómez', @experiencia = 4;

-- Eliminar
EXEC usp_Barista_Eliminar @IDBarista = 8;
```

Obtener y Listar devuelven la fila tal cual está en la tabla (`SELECT *`). Los nombres de grano, proveedor, barista o cliente se obtienen con `JOIN` en tus consultas, que es justamente lo que se practica en los enunciados.

### Errores

Los procedimientos son cortos a propósito. Solo validan las reglas de negocio que la tabla no controla sola, y avisan con un mensaje en español:

| Tabla | Regla |
|---|---|
| Lote | La cantidad en kilos es mayor a cero y el tostado no es posterior al ingreso |
| Barista | La experiencia no es negativa |
| Calibracion | Dosis, tiempo y rendimiento son mayores a cero, y no es anterior al ingreso del lote |
| Calificacion | El puntaje va de 1 a 5 y el mismo cliente no califica dos veces la misma calibración |

El resto lo resuelve la propia tabla, con mensajes de SQL Server en inglés: un CUIT o DNI repetido (`UNIQUE`), un grano, proveedor, barista, lote o cliente que no existe (clave foránea), y borrar algo que otras tablas todavía usan. Para borrar hay que borrar primero lo que depende de eso, por ejemplo las calificaciones antes que la calibración. No hay borrado en cascada.

## Decisiones de diseño que conviene conocer

- **IDs.** Barista, Cliente y Proveedor usan `IDENTITY`, como en el DER. Grano, Lote, Calibracion y Calificacion no, así que su procedimiento de creación toma el ID como el máximo más uno. Es simple y alcanza para trabajar en el TP, pero dos usuarios creando a la vez podrían chocar.
- **Reglas en los procedimientos y no en la tabla.** Los enunciados 32 a 34 piden agregar restricciones `CHECK` y `UNIQUE` con `ALTER TABLE`. Por eso las tablas no las traen, y mientras tanto los procedimientos ya hacen esas validaciones.
- **Datos de ejemplo.** Son inventados, incluidos los CUIT. Cuentan una historia para que las queries devuelvan resultados interesantes: la calidad mejora con el tiempo con algunos bajones, cada vez hacen falta menos pruebas por día, hay rotación de baristas y clientes que entran y se van. El detalle está en `queries/README.md`.

## Cambiar los datos o los procedimientos

Los programas están en la carpeta `herramientas` y necesitan Python 3:

| Programa | Qué genera |
|---|---|
| `python3 herramientas/generar_datos.py` | Los archivos `queries/01` a `07` y `queries/README.md` |
| `python3 herramientas/generar_crud.py` | Los 35 procedimientos de `queries/crud` |

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
