# Cafetear: DER

```mermaid
erDiagram
    Proveedor {
        int idProveedor PK
        string cuit
        string razonSocial
    }
    Grano {
        int idGrano PK
        int alturaCosecha
        string regionCosecha
        date fechaCosecha
    }
    Lote {
        int idLote PK
        int idGrano FK
        int idProveedor FK
        date fechaIngreso
        date fechaTostado
        decimal cantidadKg
    }
    Barista {
        int idBarista PK
        string dni
        string nombre
        string apellido
        int experiencia
    }
    Calibracion {
        int idCalibracion PK
        datetime fechaCalibracion
        decimal dosis
        int tiempoExtraccion
        decimal rendimiento
        int idBarista FK
        int idLote FK
    }
    Cliente {
        int idCliente PK
        string dni
        string nombre
        string apellido
    }
    Calificacion {
        int idCalificacion PK
        datetime fecha
        int puntaje
        int idCliente FK
        int idCalibracion FK
    }

    Proveedor ||--o{ Lote : provee
    Grano ||--o{ Lote : "se compra en"
    Lote ||--o{ Calibracion : "se usa en"
    Barista ||--o{ Calibracion : realiza
    Calibracion ||--o{ Calificacion : recibe
    Cliente ||--o{ Calificacion : deja
```

## Modelo relacional

```
Proveedor (idProveedor PK IDENTITY, cuit UNIQUE NOT NULL, razonSocial)
Grano (idGrano PK, alturaCosecha, regionCosecha, fechaCosecha)
Lote (idLote PK, idGrano FK, idProveedor FK, fechaIngreso, fechaTostado, cantidadKg)
Barista (idBarista PK IDENTITY, dni UNIQUE NOT NULL, nombre, apellido, experiencia)
Calibracion (idCalibracion PK, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, idBarista FK, idLote FK)
Cliente (idCliente PK IDENTITY, dni UNIQUE NOT NULL, nombre, apellido)
Calificacion (idCalificacion PK, fecha, puntaje, idCliente FK, idCalibracion FK)
```

## Unidades de calibracion

- `dosis`: gramos de café molido.
- `tiempoExtraccion`: segundos.
- `rendimiento`: gramos de café líquido en la taza.
- La relación de extracción (rendimiento / dosis, por ejemplo 1:2) se calcula en las consultas y no se guarda.

## Alcance

Sin blends: cada calibración usa un único lote. Las mezclas de granos quedan como mejora futura.
