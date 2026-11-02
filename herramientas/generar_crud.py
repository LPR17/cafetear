"""Genera los procedimientos almacenados de CRUD de Cafetear (versión simple, uno por tabla)."""
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parent.parent / "queries" / "crud"

# Cada tabla: columnas editables y las pocas reglas de negocio que la tabla no controla sola.
# Lo demás (NOT NULL, UNIQUE, claves foráneas) lo resuelve la propia tabla.
ENTITIES = [
    {
        "table": "Proveedor", "pk": "IDProveedor", "identity": True,
        "columns": [("CUIT", "VARCHAR(13)"), ("razonSocial", "VARCHAR(100)")],
        "checks": [],
    },
    {
        "table": "Grano", "pk": "IDGrano", "identity": False,
        "columns": [("alturaCosecha", "INT"), ("regionCosecha", "VARCHAR(60)"), ("fechaCosecha", "DATE")],
        "checks": [],
    },
    {
        "table": "Lote", "pk": "IDLote", "identity": False,
        "columns": [("nombre", "VARCHAR(100)"), ("IDGrano", "INT"), ("IDProveedor", "INT"),
                    ("fechaIngreso", "DATE"), ("fechaTostado", "DATE"), ("cantidadKg", "DECIMAL(6,2)")],
        "checks": [
            ("@cantidadKg <= 0", "La cantidad en kilos debe ser mayor a cero."),
            ("@fechaTostado > @fechaIngreso", "El tostado no puede ser posterior al ingreso del lote."),
        ],
    },
    {
        "table": "Barista", "pk": "IDBarista", "identity": True,
        "columns": [("DNI", "VARCHAR(8)"), ("nombre", "VARCHAR(50)"), ("apellido", "VARCHAR(50)"), ("experiencia", "INT")],
        "checks": [("@experiencia < 0", "La experiencia no puede ser negativa.")],
    },
    {
        "table": "Cliente", "pk": "IDCliente", "identity": True,
        "columns": [("DNI", "VARCHAR(8)"), ("nombre", "VARCHAR(50)"), ("apellido", "VARCHAR(50)")],
        "checks": [],
    },
    {
        "table": "Calibracion", "pk": "IDCalibracion", "identity": False,
        "columns": [("fechaCalibracion", "DATETIME"), ("dosis", "DECIMAL(5,1)"), ("tiempoExtraccion", "INT"),
                    ("rendimiento", "DECIMAL(5,1)"), ("IDBarista", "INT"), ("IDLote", "INT")],
        "checks": [
            ("@dosis <= 0", "La dosis debe ser mayor a cero."),
            ("@tiempoExtraccion <= 0", "El tiempo de extracción debe ser mayor a cero."),
            ("@rendimiento <= 0", "El rendimiento debe ser mayor a cero."),
            ("EXISTS (SELECT 1 FROM Lote WHERE IDLote = @IDLote AND CAST(@fechaCalibracion AS DATE) < fechaIngreso)",
             "La calibración no puede ser anterior al ingreso del lote."),
        ],
    },
    {
        "table": "Calificacion", "pk": "IDCalificacion", "identity": False,
        "columns": [("fecha", "DATETIME"), ("puntaje", "INT"), ("IDCliente", "INT"), ("IDCalibracion", "INT")],
        "checks": [
            ("@puntaje NOT BETWEEN 1 AND 5", "El puntaje debe estar entre 1 y 5."),
            ("EXISTS (SELECT 1 FROM Calificacion WHERE IDCliente = @IDCliente AND IDCalibracion = @IDCalibracion{notself})",
             "Ese cliente ya calificó esta calibración."),
        ],
    },
]

ERROR_NUMBER = 50000


def parameters(items):
    return ",\n".join(f"    {item}" for item in items)


def checks_block(entity, updating):
    not_self = f" AND {entity['pk']} <> @{entity['pk']}" if updating else ""
    lines = []
    for condition, message in entity["checks"]:
        lines.append(f"    IF {condition.format(notself=not_self)}")
        lines.append(f"        THROW {ERROR_NUMBER}, N'{message}', 1;")
    return "\n".join(lines) + "\n\n" if lines else ""


def create_procedure(entity):
    table, pk = entity["table"], entity["pk"]
    names = ", ".join(name for name, _ in entity["columns"])
    values = ", ".join(f"@{name}" for name, _ in entity["columns"])
    params = parameters(f"@{name} {sql_type}" for name, sql_type in entity["columns"])
    if entity["identity"]:
        insert = f"    INSERT INTO {table} ({names})\n    VALUES ({values});\n\n    SELECT SCOPE_IDENTITY() AS {pk};"
    else:
        insert = (f"    DECLARE @{pk} INT = (SELECT ISNULL(MAX({pk}), 0) + 1 FROM {table});\n\n"
                  f"    INSERT INTO {table} ({pk}, {names})\n    VALUES (@{pk}, {values});\n\n"
                  f"    SELECT @{pk} AS {pk};")
    return (f"CREATE OR ALTER PROCEDURE usp_{table}_Crear\n{params}\nAS\nBEGIN\n"
            f"{checks_block(entity, False)}{insert}\nEND\nGO\n")


def get_procedure(entity):
    table, pk = entity["table"], entity["pk"]
    return (f"CREATE OR ALTER PROCEDURE usp_{table}_Obtener\n    @{pk} INT\nAS\nBEGIN\n"
            f"    SELECT * FROM {table} WHERE {pk} = @{pk};\nEND\nGO\n")


def list_procedure(entity):
    table, pk = entity["table"], entity["pk"]
    return f"CREATE OR ALTER PROCEDURE usp_{table}_Listar\nAS\nBEGIN\n    SELECT * FROM {table} ORDER BY {pk};\nEND\nGO\n"


def update_procedure(entity):
    table, pk = entity["table"], entity["pk"]
    params = parameters([f"@{pk} INT"] + [f"@{name} {sql_type}" for name, sql_type in entity["columns"]])
    assignments = ",\n        ".join(f"{name} = @{name}" for name, _ in entity["columns"])
    return (f"CREATE OR ALTER PROCEDURE usp_{table}_Actualizar\n{params}\nAS\nBEGIN\n"
            f"{checks_block(entity, True)}"
            f"    UPDATE {table}\n    SET {assignments}\n    WHERE {pk} = @{pk};\nEND\nGO\n")


def delete_procedure(entity):
    table, pk = entity["table"], entity["pk"]
    return (f"CREATE OR ALTER PROCEDURE usp_{table}_Eliminar\n    @{pk} INT\nAS\nBEGIN\n"
            f"    DELETE FROM {table} WHERE {pk} = @{pk};\nEND\nGO\n")


def file_content(entity):
    header = (f"-- Cafetear · CRUD de {entity['table']} (procedimientos almacenados)\n\n"
              "USE Cafetear;\nGO\n\n")
    sections = [("Crear", create_procedure), ("Obtener", get_procedure), ("Listar", list_procedure),
                ("Actualizar", update_procedure), ("Eliminar", delete_procedure)]
    return header + "\n".join(f"-- {name}\n{builder(entity)}" for name, builder in sections)


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for old in OUT_DIR.glob("*.sql"):
        old.unlink()
    for index, entity in enumerate(ENTITIES, start=1):
        (OUT_DIR / f"{index:02d}_{entity['table'].lower()}.sql").write_text(file_content(entity), encoding="utf-8")
    print(f"{len(ENTITIES)} archivos, {len(ENTITIES) * 5} procedimientos")


if __name__ == "__main__":
    main()
