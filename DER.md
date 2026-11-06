# Cafetear: DER

```mermaid
erDiagram
    proveedor {
        int idProveedor PK
        string cuit
        string razonSocial
    }
    grano {
        int idGrano PK
        int alturaCosecha
        string regionCosecha
        date fechaCosecha
    }
    lote {
        int idLote PK
        int idGrano FK
        int idProveedor FK
        date fechaIngreso
        date fechaTostado
        decimal cantidadKg
    }
    barista {
        int idBarista PK
        string dni
        string nombre
        string apellido
        int experiencia
    }
    calibracion {
        int idCalibracion PK
        datetime fechaCalibracion
        decimal dosis
        int tiempoExtraccion
        decimal rendimiento
        int idBarista FK
        int idLote FK
    }
    cliente {
        int idCliente PK
        string dni
        string nombre
        string apellido
    }
    calificacion {
        int idCalificacion PK
        datetime fecha
        int puntaje
        int idCliente FK
        int idCalibracion FK
    }

    proveedor ||--o{ lote : provee
    grano ||--o{ lote : "se compra en"
    lote ||--o{ calibracion : "se usa en"
    barista ||--o{ calibracion : realiza
    calibracion ||--o{ calificacion : recibe
    cliente ||--o{ calificacion : deja
```

## Modelo relacional

```
proveedor (idProveedor PK IDENTITY, cuit UNIQUE NOT NULL, razonSocial)
grano (idGrano PK, alturaCosecha, regionCosecha, fechaCosecha)
lote (idLote PK, idGrano FK, idProveedor FK, fechaIngreso, fechaTostado, cantidadKg)
barista (idBarista PK IDENTITY, dni UNIQUE NOT NULL, nombre, apellido, experiencia)
calibracion (idCalibracion PK, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, idBarista FK, idLote FK)
cliente (idCliente PK IDENTITY, dni UNIQUE NOT NULL, nombre, apellido)
calificacion (idCalificacion PK, fecha, puntaje, idCliente FK, idCalibracion FK)
```

## Unidades de calibracion

- `dosis`: gramos de café molido.
- `tiempoExtraccion`: segundos.
- `rendimiento`: gramos de café líquido en la taza.
- La relación de extracción (rendimiento / dosis, por ejemplo 1:2) se calcula en las consultas y no se guarda.

## Alcance

Sin blends: cada calibración usa un único lote. Las mezclas de granos quedan como mejora futura.
