#!/usr/bin/env bash
# Carga la base Cafetear en tu SQL Server de Docker ya existente (contenedor sqlserver_2022_uade).
# Para levantar un entorno nuevo e independiente usá docker compose (ver ../README.md).
#
# Uso:
#   ./cargar_cafetear.sh                         recrea la base con los datos limpios y los procedimientos
#   ./cargar_cafetear.sh --con-errores           suma los errores para los enunciados 27 y 28
#   ./cargar_cafetear.sh --hoy                   suma las calibraciones de hoy (enunciado 31)
#   ./cargar_cafetear.sh --solo-procedimientos   actualiza solo los procedimientos, sin tocar los datos

set -euo pipefail

CONTAINER="${CAFETEAR_CONTAINER:-sqlserver_2022_uade}"
SA_PASSWORD="${SA_PASSWORD:-P4ssw0rd}"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE_DIR="/tmp/cafetear"

initializer_arguments=()

require_running_container() {
  if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)" != "true" ]; then
    echo "El contenedor $CONTAINER no está corriendo." >&2
    exit 1
  fi
}

copy_scripts() {
  docker exec -u root "$CONTAINER" rm -rf "$REMOTE_DIR"
  docker exec -u root "$CONTAINER" mkdir -p "$REMOTE_DIR"
  docker cp "$SCRIPTS_DIR/." "$CONTAINER:$REMOTE_DIR/"
  docker exec -u root "$CONTAINER" chmod -R a+rX "$REMOTE_DIR"
}

build_initializer_arguments() {
  local keep_data=false arg
  for arg in "$@"; do
    if [ "$arg" = "--solo-procedimientos" ]; then
      keep_data=true
    else
      initializer_arguments+=("$arg")
    fi
  done
  $keep_data || initializer_arguments+=("--reset")
  return 0
}

main() {
  require_running_container
  build_initializer_arguments "$@"
  copy_scripts
  docker exec -e SA_PASSWORD="$SA_PASSWORD" "$CONTAINER" bash "$REMOTE_DIR/inicializar.sh" ${initializer_arguments[@]+"${initializer_arguments[@]}"}
}

main "$@"
