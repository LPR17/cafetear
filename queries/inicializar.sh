#!/usr/bin/env bash
# Inicializa la base Cafetear: tablas, datos de ejemplo y procedimientos almacenados.
# Corre dentro de un contenedor con sqlcmd: lo usa el servicio "init" de docker compose
# y también cargar_cafetear.sh.
#
# Opciones:
#   --reset         borra y vuelve a crear las tablas con los datos de ejemplo
#   --con-errores   suma los datos con errores (enunciados 27 y 28)
#   --hoy           suma las calibraciones de hoy (enunciado 31)
#
# Variables de entorno:
#   SA_PASSWORD     contraseña del usuario sa (obligatoria)
#   SQL_HOST        servidor SQL (por defecto localhost)
#   RESET_DB=1      equivale a --reset
#   WITH_ERRORS=1   equivale a --con-errores
#   WITH_TODAY=1    equivale a --hoy
#
# Sin --reset, si la base ya existe no se tocan los datos: solo se actualizan los procedimientos.

set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SQL_HOST="${SQL_HOST:-localhost}"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

reset="${RESET_DB:-0}"
with_errors="${WITH_ERRORS:-0}"
with_today="${WITH_TODAY:-0}"

parse_arguments() {
  for arg in "$@"; do
    case "$arg" in
      --reset) reset=1 ;;
      --con-errores) with_errors=1 ;;
      --hoy) with_today=1 ;;
      *) echo "Opción desconocida: $arg" >&2; exit 1 ;;
    esac
  done
}

run_sql() {
  "$SQLCMD" -C -b -f 65001 -S "$SQL_HOST" -U sa -P "$SA_PASSWORD" "$@"
}

run_file() {
  local file="$1" output
  echo "→ ${file#"$SCRIPTS_DIR"/}"
  output=$(run_sql -i "$file") || { echo "$output" >&2; exit 1; }
}

database_is_initialized() {
  local answer
  answer=$(run_sql -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN OBJECT_ID('Cafetear.dbo.Calibracion', 'U') IS NOT NULL THEN 1 ELSE 0 END" | tr -d '[:space:]')
  [ "$answer" = "1" ]
}

load_data() {
  run_file "$SCRIPTS_DIR/tablas/01_crear_base_y_tablas.sql"
  run_file "$SCRIPTS_DIR/datos/02_datos_maestros.sql"
  run_file "$SCRIPTS_DIR/datos/03_calibraciones.sql"
  run_file "$SCRIPTS_DIR/datos/04_calificaciones.sql"
  [ "$with_errors" = "1" ] && run_file "$SCRIPTS_DIR/datos/05_datos_con_errores.sql"
  [ "$with_today" = "1" ] && run_file "$SCRIPTS_DIR/datos/06_calibraciones_de_hoy.sql"
  return 0
}

run_folder() {
  local file
  for file in "$SCRIPTS_DIR/$1"/*.sql; do
    run_file "$file"
  done
}

load_objects() {
  run_folder funciones
  run_folder vistas
  run_folder procedimientos/crud
  run_folder procedimientos
  run_folder triggers
  run_folder indices
  run_folder seguridad
}

print_summary() {
  run_sql -d Cafetear -Q "
SET NOCOUNT ON;
SELECT 'Proveedor' AS tabla, COUNT(*) AS filas FROM Proveedor
UNION ALL SELECT 'Grano', COUNT(*) FROM Grano
UNION ALL SELECT 'Lote', COUNT(*) FROM Lote
UNION ALL SELECT 'Barista', COUNT(*) FROM Barista
UNION ALL SELECT 'Cliente', COUNT(*) FROM Cliente
UNION ALL SELECT 'Calibracion', COUNT(*) FROM Calibracion
UNION ALL SELECT 'Calificacion', COUNT(*) FROM Calificacion;
SELECT (SELECT COUNT(*) FROM sys.procedures WHERE name LIKE 'usp[_]%') AS procedimientos,
       (SELECT COUNT(*) FROM sys.views) AS vistas,
       (SELECT COUNT(*) FROM sys.objects WHERE type IN ('FN', 'IF', 'TF')) AS funciones,
       (SELECT COUNT(*) FROM sys.triggers WHERE parent_class = 1) AS triggers,
       (SELECT COUNT(*) FROM sys.indexes i JOIN sys.objects o ON o.object_id = i.object_id WHERE o.is_ms_shipped = 0 AND i.name LIKE 'IX[_]%') AS indices;"
}

main() {
  parse_arguments "$@"
  if [ "$reset" = "1" ] || ! database_is_initialized; then
    echo "Cargando tablas y datos de ejemplo..."
    load_data
  else
    echo "La base Cafetear ya existe: no se tocan los datos (usá --reset para empezar de cero)."
  fi
  echo "Actualizando funciones, vistas, procedimientos, triggers, índices y roles..."
  load_objects
  print_summary
}

main "$@"
