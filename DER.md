# Cafetear: DER

```mermaid
erDiagram
    PROVEEDOR {
        int IDProveedor PK
        string CUIT UK
        string razonSocial
    }
    GRANO {
        int IDGrano PK
        int alturaCosecha
        string regionCosecha
        date fechaCosecha
    }
    LOTE {
        int IDLote PK
        int IDGrano FK
        int IDProveedor FK
        date fechaIngreso
        date fechaTostado
        decimal cantidadKg
    }
    BARISTA {
        int IDBarista PK
        string DNI UK
        string nombre
        string apellido
        int experiencia
    }
    CALIBRACION {
        int IDCalibracion PK
        datetime fechaCalibracion
        decimal dosis
        int tiempoExtraccion
        decimal rendimiento
        int IDBarista FK
        int IDLote FK
    }
    CLIENTE {
        int IDCliente PK
        string DNI UK
        string nombre
        string apellido
    }
    CALIFICACION {
        int IDCalificacion PK
        datetime fecha
        int puntaje
        int IDCliente FK
        int IDCalibracion FK
    }

    PROVEEDOR ||--o{ LOTE : provee
    GRANO ||--o{ LOTE : "se compra en"
    LOTE ||--o{ CALIBRACION : "se usa en"
    BARISTA ||--o{ CALIBRACION : realiza
    CALIBRACION ||--o{ CALIFICACION : recibe
    CLIENTE ||--o{ CALIFICACION : deja
```

## Modelo relacional

```
Proveedor (IDProveedor PK IDENTITY, CUIT UNIQUE NOT NULL, razonSocial)
Grano (IDGrano PK, alturaCosecha, regionCosecha, fechaCosecha)
Lote (IDLote PK, IDGrano FK, IDProveedor FK, fechaIngreso, fechaTostado, cantidadKg)
Barista (IDBarista PK IDENTITY, DNI UNIQUE NOT NULL, nombre, apellido, experiencia)
Calibracion (IDCalibracion PK, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista FK, IDLote FK)
Cliente (IDCliente PK IDENTITY, DNI UNIQUE NOT NULL, nombre, apellido)
Calificacion (IDCalificacion PK, fecha, puntaje, IDCliente FK, IDCalibracion FK)
```

## Unidades de Calibracion

- `dosis`: gramos de café molido.
- `tiempoExtraccion`: segundos.
- `rendimiento`: gramos de café líquido en la taza.
- La relación de extracción (rendimiento / dosis, por ejemplo 1:2) se calcula en las consultas y no se guarda.

## Alcance

Sin blends: cada calibración usa un único lote. Las mezclas de granos quedan como mejora futura.
