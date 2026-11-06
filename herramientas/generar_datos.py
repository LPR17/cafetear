"""Genera los scripts T-SQL con datos de prueba para la base Cafetear."""
import random
from datetime import date, datetime, timedelta
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parent.parent / "queries"
SEED = 20261029
START_DAY = date(2025, 6, 2)
END_DAY = date(2026, 10, 28)
FIRST_MONTH = (2025, 6)
IDEAL_SECONDS = 28
IDEAL_RATIO = 2.0
PROFILES = {"estandar": (28, 2.0), "ristretto": (20, 1.5), "lungo": (36, 2.6)}
PROFILE_WEIGHTS = [0.8, 0.1, 0.1]
START_HOURS = [7, 8, 9, 12, 13, 16, 17]
START_HOUR_WEIGHTS = [30, 25, 15, 8, 7, 10, 5]
MAX_ATTEMPTS = 3000
ROWS_PER_INSERT = 250
SILENT_FROM = date(2026, 9, 1)

# La calidad percibida mejora de a poco, con bajones puntuales (fin de año con equipo ajustado, un invierno flojo).
BASE_QUALITY = 4.4
QUALITY_AT_START = -0.60
QUALITY_GAIN_PER_MONTH = 0.07
MONTH_EVENTS = {(2025, 12): -0.50, (2026, 1): -0.20, (2026, 2): 0.10, (2026, 6): -0.50}
MIN_SESSION_DAYS = 3
WEEKDAY_OFFSETS = {0: -0.25, 4: 0.10, 5: 0.15}

rng = random.Random(SEED)


def reset_rng(seed):
    global rng
    rng = random.Random(seed)


def month_offset(when):
    trend = QUALITY_AT_START + QUALITY_GAIN_PER_MONTH * months_since_start(when.date())
    return trend + MONTH_EVENTS.get((when.year, when.month), 0.0)


def months_since_start(day):
    return (day.year - FIRST_MONTH[0]) * 12 + day.month - FIRST_MONTH[1]


# ---------- datos maestros ----------

PROVEEDORES = [
    ("30-71458230-4", "Café Andino S.R.L."),
    ("30-70912345-1", "Tostadores del Sur S.A."),
    ("30-71203344-7", "Finca Los Altos S.A."),
    ("33-70655120-9", "Origen Colombia Import S.A."),
    ("30-71877650-2", "Brasil Café Trading S.R.L."),
    ("30-71562918-5", "Sidamo Importaciones S.R.L."),
    ("30-71099321-6", "Cafés del Valle S.A."),
    ("30-70744810-3", "Importadora Tierra Alta S.R.L."),
    ("33-71320485-9", "Granos del Mundo S.A."),
    ("30-71688104-2", "Selecta Cafés S.R.L."),
]

# id, altura, region, fechaCosecha, ajuste de sabor
GRANOS = [
    (1, 1800, "Huila, Colombia", date(2025, 1, 20), 0.25),
    (2, 1100, "Cerrado Mineiro, Brasil", date(2025, 3, 10), -0.10),
    (3, 2000, "Yirgacheffe, Etiopía", date(2025, 2, 5), 0.30),
    (4, 1600, "Antigua, Guatemala", date(2025, 3, 12), 0.00),
    (5, 1000, "Sul de Minas, Brasil", date(2025, 4, 25), -0.15),
    (6, 2100, "Nariño, Colombia", date(2025, 1, 30), 0.10),
    (7, 1900, "Sidamo, Etiopía", date(2025, 2, 18), 0.15),
    (8, 1700, "Tarrazú, Costa Rica", date(2025, 3, 2), 0.20),
    (9, 1950, "Huila, Colombia", date(2025, 6, 18), 0.20),
    (10, 2150, "Yirgacheffe, Etiopía", date(2025, 5, 22), 0.25),
]
LOT_GRAIN_COUNT = 8  # los granos 9 y 10 estan en el catalogo pero todavia no se compraron lotes

LOT_NAME_POOLS = {
    1: ["La Esperanza Lavado", "Pink Bourbon Microlote", "El Mirador Honey", "Villa Rica Natural", "Cerro Azul Lavado"],
    2: ["Fazenda Santa Luzia Natural", "Cerrado Natural", "Fazenda Primavera Pulped", "Serra Dourada Natural", "Boa Esperança Honey"],
    3: ["Kochere Lavado", "Aricha Natural", "Konga Lavado", "Idido Natural", "Gedeb Anaeróbico"],
    4: ["Finca Los Volcanes Lavado", "Finca San Rafael Honey", "El Pilar Lavado", "Hunapú Natural", "Santa Clara Lavado"],
    5: ["Fazenda Boa Vista Natural", "Sul de Minas Pulped Natural", "Serra Verde Natural", "Fazenda Alvorada Honey", "São João Natural"],
    6: ["La Unión Lavado", "Cooperativa Cumbal Lavado", "Buesaco Lavado", "Génova Honey", "El Tablón Natural"],
    7: ["Guji Natural Lote 7", "Bensa Lavado", "Shantawene Natural", "Hambela Lavado", "Aleta Wondo Honey"],
    8: ["Finca La Pastora Honey", "Dota Microlote Anaeróbico", "Santa María Lavado", "San Marcos Honey", "León Cortés Natural"],
}
LOT_COUNT = 40
FIRST_LOT_DAY = date(2025, 5, 20)
LOT_STEP_DAYS = 13
LOT_USAGE_DAYS = 80
LOT_KILOS = [6.0, 8.0, 10.0, 12.0, 15.0]


def build_lots():
    """Un lote nuevo cada 13 días, rotando los 8 granos con lotes y los 10 proveedores."""
    lots, names = [], {}
    for index in range(LOT_COUNT):
        grain = (index * 3) % LOT_GRAIN_COUNT + 1
        lot_id = index + 1
        entry = FIRST_LOT_DAY + timedelta(days=LOT_STEP_DAYS * index)
        # id, grano, proveedor, ingreso, dias de tostado previos, kg, dias de uso
        lots.append((lot_id, grain, index % len(PROVEEDORES) + 1, entry, 3 + (index * 5) % 6,
                     LOT_KILOS[index % len(LOT_KILOS)], LOT_USAGE_DAYS))
        names[lot_id] = LOT_NAME_POOLS[grain][index // LOT_GRAIN_COUNT]
    return lots, names


LOTES, LOT_NAMES = build_lots()
NEVER_CALIBRATED_LOT = LOT_COUNT  # el ultimo en llegar, todavia sin usar


def lot_nearest(target):
    candidates = [lot for lot in LOTES if lot[0] != NEVER_CALIBRATED_LOT]
    return min(candidates, key=lambda lot: abs((lot[3] - target).days))[0]


DECLINING_LOT = lot_nearest(date(2026, 8, 20))
PROBLEM_LOT = lot_nearest(date(2026, 3, 2))
IMPROVING_LOT = lot_nearest(date(2026, 6, 10))

# id, DNI, nombre, apellido, experiencia, ajuste, ruido, granos permitidos, peso, desde, hasta
BARISTAS = [
    (1, "28450121", "Martina", "Ríos", 8, 0.35, 0.35, {1, 2, 3, 4, 5, 6, 7, 8}, 4, date(2025, 6, 1), None),
    (2, "31220987", "Lucas", "Benítez", 5, 0.15, 0.50, {1, 2, 3, 4, 5, 6, 7, 8}, 4, date(2025, 6, 1), None),
    (3, "36874512", "Sofía", "Carrizo", 3, 0.00, 0.60, {1, 2, 3, 4, 5}, 3, date(2025, 9, 1), None),
    (4, "41093376", "Mateo", "Duarte", 1, -0.30, 0.70, {1, 2, 5}, 2, date(2026, 3, 2), None),
    (5, "33781450", "Valentina", "Pereyra", 6, 0.20, 0.50, {1, 3, 4, 6, 7}, 3, date(2025, 6, 1), date(2026, 5, 31)),
    (6, "39665208", "Julián", "Acosta", 2, -0.10, 0.60, {2, 4, 5, 7}, 2, date(2025, 9, 15), None),
    (7, "35118843", "Camila", "Ferrer", 4, 0.00, 1.40, {3, 4, 6, 7}, 2, date(2025, 8, 1), None),
    (8, "37552901", "Ramiro", "Quiroga", 2, -0.05, 0.60, {1, 2, 3, 4, 5, 6, 7}, 2, date(2025, 6, 1), date(2025, 10, 31)),
    (9, "34219876", "Florencia", "Montero", 3, 0.10, 0.55, {1, 3, 4, 6}, 2, date(2025, 11, 1), date(2026, 2, 28)),
    (10, "42180533", "Tomás", "Arias", 1, -0.20, 0.65, {1, 2, 4, 5, 7}, 2, date(2026, 6, 1), None),
]
NEVER_LOW_BARISTA = 1          # nunca recibe menos de 3
NO_RECENT_RATINGS_BARISTA = 6  # sin calificaciones desde septiembre de 2026
LAST_BAD_BARISTA = 4           # su ultima calibracion queda con puntajes bajos
INCONSISTENT_BARISTA = 7       # recibe 5 y 1 o 2
ALL_BARISTA_CLIENTS = (1, 2, 3)  # califican calibraciones de todos los baristas
FULL_COVERAGE_BARISTAS = (1, 2)
DISAGREEING_CLIENTS = (42, 43, 44)  # califican el mismo lote con 5 y con 1

FIRST_NAMES = [
    "Agustina", "Bruno", "Carolina", "Diego", "Emilia", "Federico", "Gabriela", "Hernán", "Inés", "Joaquín",
    "Karina", "Leandro", "Milagros", "Nicolás", "Olivia", "Pablo", "Romina", "Santiago", "Tamara", "Ulises",
    "Violeta", "Walter", "Ximena", "Yamila", "Zoe", "Andrés", "Belén", "Cristian", "Daniela", "Esteban",
]
LAST_NAMES = [
    "Gómez", "Fernández", "López", "Martínez", "Rodríguez", "Sánchez", "Pérez", "Romero", "Díaz", "Torres",
    "Álvarez", "Ruiz", "Suárez", "Molina", "Castro", "Ortiz", "Silva", "Núñez", "Medina", "Herrera",
]
CLIENT_COUNT = 60
HEAVY_RATERS = set(range(1, 9))
CHURN_SHARE = 0.35


def build_clients():
    """Clientes con su ventana de actividad: los habituales siempre, el resto entra (y a veces se va)."""
    names = set()
    clients, windows = [], {}
    dnis = rng.sample(range(24_000_000, 46_000_000), CLIENT_COUNT)
    while len(clients) < CLIENT_COUNT:
        first, last = rng.choice(FIRST_NAMES), rng.choice(LAST_NAMES)
        if (first, last) in names:
            continue
        names.add((first, last))
        client_id = len(clients) + 1
        clients.append((client_id, str(dnis[client_id - 1]), first, last))
        windows[client_id] = client_window(client_id)
    return clients, windows


def client_window(client_id):
    if client_id in HEAVY_RATERS:
        return START_DAY, None
    start = START_DAY + timedelta(days=rng.randint(0, (END_DAY - START_DAY).days - 20))
    leaves = rng.random() < CHURN_SHARE
    return start, (start + timedelta(days=rng.randint(45, 270)) if leaves else None)


# ---------- calibraciones ----------

def lot_by_id(lot_id):
    return next(lot for lot in LOTES if lot[0] == lot_id)


def grain_adjust(grain_id):
    return next(g[4] for g in GRANOS if g[0] == grain_id)


def is_working(barista, day):
    return barista[9] <= day and (barista[10] is None or day <= barista[10])


def active_lots_for(barista, day):
    lots = []
    for lot_id, grain_id, _, entry, _, _, usage_days in LOTES:
        if lot_id == NEVER_CALIBRATED_LOT or grain_id not in barista[7]:
            continue
        if entry <= day <= entry + timedelta(days=usage_days):
            lots.append(lot_id)
    return lots


def session_probability(day):
    """Al principio se calibra poco y se registra poco; con el tiempo el uso del sistema crece."""
    return 0.06 + 0.14 * months_since_start(day) / months_since_start(END_DAY)


def trials_range(day):
    """Con el sistema se necesitan menos pruebas por día: de 3 a 5 al principio a 1 a 3 hoy."""
    months = months_since_start(day)
    if months < 4:
        return 3, 5
    return (2, 4) if months < 10 else (1, 3)


def trial_values(position, total, profile, base_dose):
    target_seconds, target_ratio = PROFILES[profile]
    dose = round(max(15.0, min(21.0, base_dose + rng.choice([0, 0, 0.5, -0.5]))), 1)
    if position == total:
        seconds = target_seconds + rng.randint(-3, 3)
        ratio = target_ratio + rng.uniform(-0.15, 0.15)
    else:
        factor = (total - position) / total
        seconds = target_seconds + rng.choice([-1, 1]) * round(rng.randint(3, 9) * factor + 1)
        ratio = target_ratio + rng.choice([-1, 1]) * rng.uniform(0.15, 0.6) * factor
    return dose, seconds, round(dose * ratio, 1)


def session_start(day):
    hour = rng.choices(START_HOURS, weights=START_HOUR_WEIGHTS, k=1)[0]
    return datetime(day.year, day.month, day.day, hour, rng.randint(0, 59))


def build_session(barista_id, lot_id, day):
    profile = rng.choices(list(PROFILES), weights=PROFILE_WEIGHTS, k=1)[0]
    base_dose = round(rng.uniform(16.0, 20.5), 1)
    trials = rng.randint(*trials_range(day))
    when = session_start(day)
    session = []
    for position in range(1, trials + 1):
        dose, seconds, yield_g = trial_values(position, trials, profile, base_dose)
        session.append({
            "barista": barista_id, "lot": lot_id, "when": when, "dose": dose,
            "seconds": seconds, "yield": yield_g, "final": position == trials,
        })
        when = when + timedelta(minutes=rng.randint(8, 20))
    return session


def lot_usage_days(lot):
    entry, usage = lot[3], lot[6]
    days = [entry + timedelta(days=i) for i in range(usage + 1)]
    return [d for d in days if START_DAY <= d <= END_DAY and d.weekday() != 6]


def missing_coverage_sessions(calibrations):
    """Sesiones extra para que los baristas 1 y 2 hayan calibrado los 8 granos."""
    grain_of = {lot[0]: lot[1] for lot in LOTES}
    sessions = []
    for barista_id in FULL_COVERAGE_BARISTAS:
        covered = {grain_of[c["lot"]] for c in calibrations if c["barista"] == barista_id}
        for grain in (g for g in range(1, LOT_GRAIN_COUNT + 1) if g not in covered):
            lot = rng.choice([l for l in LOTES if l[1] == grain and l[0] != NEVER_CALIBRATED_LOT])
            sessions.extend(build_session(barista_id, lot[0], rng.choice(lot_usage_days(lot))))
    return sessions


def session_calendar():
    """Los días con calibraciones: cada mes tiene al menos MIN_SESSION_DAYS y la actividad crece con el tiempo."""
    days = [START_DAY + timedelta(days=i) for i in range((END_DAY - START_DAY).days + 1)]
    by_month = {}
    for day in (d for d in days if d.weekday() != 6):
        by_month.setdefault((day.year, day.month), []).append(day)
    chosen = []
    for month_days in by_month.values():
        wanted = max(MIN_SESSION_DAYS, round(len(month_days) * session_probability(month_days[0])))
        chosen.extend(rng.sample(month_days, wanted))
    return sorted(chosen)


def build_calibrations():
    calibrations = []
    for day in session_calendar():
        working = [b for b in BARISTAS if is_working(b, day)]
        picked_ids = {b[0] for b in rng.choices(working, weights=[b[8] for b in working], k=rng.choice([1, 1, 2]))}
        for barista in (b for b in working if b[0] in picked_ids):
            lots = active_lots_for(barista, day)
            if lots:
                calibrations.extend(build_session(barista[0], rng.choice(lots), day))
    calibrations.extend(missing_coverage_sessions(calibrations))
    calibrations.sort(key=lambda c: (c["when"], c["barista"]))
    for index, calibration in enumerate(calibrations, start=1):
        calibration["id"] = index
    return calibrations


# ---------- calificaciones ----------

def rating_mean(calibration, barista):
    lot = lot_by_id(calibration["lot"])
    when = calibration["when"]
    ratio = calibration["yield"] / calibration["dose"]
    roast_date = lot[3] - timedelta(days=lot[4])
    days_since_roast = (when.date() - roast_date).days
    freshness = -0.03 * min(max(0, days_since_roast - 18), 30)
    closeness = -0.08 * abs(calibration["seconds"] - IDEAL_SECONDS) - 1.0 * abs(ratio - IDEAL_RATIO)
    return (BASE_QUALITY + grain_adjust(lot[1]) + lot_adjust(lot, when) + barista[5] + freshness + closeness
            + month_offset(when) + WEEKDAY_OFFSETS.get(when.weekday(), 0.0))


def lot_adjust(lot, when):
    if lot[0] == PROBLEM_LOT:
        return -1.1
    if lot[0] == DECLINING_LOT:
        return -min(1.3, 0.04 * max(0, (when.date() - date(2026, 9, 20)).days))
    if lot[0] == IMPROVING_LOT:
        return min(0.5, 0.02 * (when.date() - lot[3]).days)
    return 0.0


def clamp_score(value, barista_id):
    score = max(1, min(5, round(value)))
    return max(3, score) if barista_id == NEVER_LOW_BARISTA else score


def is_active_client(window, day):
    start, end = window
    return start <= day and (end is None or day <= end)


def pick_client(used, day, windows):
    pool = [c for c in range(1, CLIENT_COUNT + 1) if c not in used and is_active_client(windows[c], day)]
    pool = pool or [c for c in HEAVY_RATERS if c not in used]
    weights = [4 if c in HEAVY_RATERS else 1 for c in pool]
    return rng.choices(pool, weights=weights, k=1)[0]


CLOSING_HOUR = 20


def rating_moment(calibration, minutes):
    """Momento de la reseña: nunca después del cierre del local."""
    moment = calibration["when"] + timedelta(minutes=minutes)
    closing = calibration["when"].replace(hour=CLOSING_HOUR, minute=30, second=0)
    return min(moment, closing)


def rating_count(calibration, barista_id):
    recent_silent = barista_id == NO_RECENT_RATINGS_BARISTA and calibration["when"].date() >= SILENT_FROM
    if recent_silent:
        return 0
    if calibration["final"]:
        return rng.choice([0, 1, 2, 3, 3, 4, 4, 5, 6, 7, 8])
    return 1 if rng.random() < 0.12 else 0


def build_ratings(calibrations, windows):
    ratings, used_pairs = [], {}
    barista_by_id = {b[0]: b for b in BARISTAS}
    for calibration in calibrations:
        barista = barista_by_id[calibration["barista"]]
        used = used_pairs.setdefault(calibration["id"], set())
        mean = rating_mean(calibration, barista)
        for _ in range(rating_count(calibration, barista[0])):
            client = pick_client(used, calibration["when"].date(), windows)
            used.add(client)
            score = clamp_score(mean + rng.gauss(0, barista[6]), barista[0])
            moment = rating_moment(calibration, rng.randint(40, 600))
            ratings.append({"client": client, "calibration": calibration["id"], "score": score, "when": moment})
    return ratings, used_pairs


def add_rating(ratings, used_pairs, calibration, client, score):
    used = used_pairs.setdefault(calibration["id"], set())
    if client in used:
        for rating in ratings:
            if rating["calibration"] == calibration["id"] and rating["client"] == client:
                rating["score"] = score
        return
    used.add(client)
    moment = rating_moment(calibration, rng.randint(40, 300))
    ratings.append({"client": client, "calibration": calibration["id"], "score": score, "when": moment})


def is_ratable(barista_id, calibration):
    recent = calibration["when"].date() >= SILENT_FROM
    return not (barista_id == NO_RECENT_RATINGS_BARISTA and recent)


def enforce_story_cases(calibrations, ratings, used_pairs):
    by_barista = {}
    for calibration in calibrations:
        by_barista.setdefault(calibration["barista"], []).append(calibration)

    # clientes que probaron el cafe de todo el equipo (division relacional)
    for client in ALL_BARISTA_CLIENTS:
        for barista_id, items in by_barista.items():
            rated = [r for r in ratings if r["client"] == client
                     and any(c["id"] == r["calibration"] and c["barista"] == barista_id for c in items)]
            if not rated:
                eligible = [c for c in items if c["final"] and is_ratable(barista_id, c)]
                add_rating(ratings, used_pairs, eligible[0], client, clamp_score(4 + rng.gauss(0, 0.5), barista_id))

    # barista inconsistente: recibe al menos un 5 y al menos un 1 o 2
    finals = [c for c in by_barista[INCONSISTENT_BARISTA] if c["final"]]
    add_rating(ratings, used_pairs, finals[0], 40, 5)
    add_rating(ratings, used_pairs, finals[-1], 41, 1)

    # barista con la ultima calibracion mala: todos sus puntajes son 1 o 2
    last = max(by_barista[LAST_BAD_BARISTA], key=lambda c: c["when"])
    last["final"] = True
    for client in rng.sample(range(10, 40), 4):
        add_rating(ratings, used_pairs, last, client, rng.choice([1, 2]))
    for rating in ratings:
        if rating["calibration"] == last["id"]:
            rating["score"] = min(rating["score"], 2)

    add_disagreements(calibrations, ratings, used_pairs)
    fit_before_next_calibration(calibrations, ratings)

    ratings.sort(key=lambda r: (r["when"], r["client"]))
    for index, rating in enumerate(ratings, start=1):
        rating["id"] = index
    return last


def fit_before_next_calibration(calibrations, ratings):
    """El cliente no elige la calibracion: la calificacion queda asociada a la ultima anterior a su fecha.

    Por eso cada reseña se acomoda entre su calibracion y la siguiente del local.
    """
    by_time = sorted(calibrations, key=lambda c: (c["when"], c["id"]))
    position = {c["id"]: index for index, c in enumerate(by_time)}
    for rating in ratings:
        index = position[rating["calibration"]]
        calibration = by_time[index]
        following = by_time[index + 1:index + 2]
        gap_seconds = (following[0]["when"] - calibration["when"]).total_seconds() if following else float("inf")
        assert gap_seconds >= 120, "calibraciones demasiado juntas"
        wanted_seconds = (rating["when"] - calibration["when"]).total_seconds()
        rating["when"] = calibration["when"] + timedelta(seconds=min(wanted_seconds, gap_seconds - 60))


def add_disagreements(calibrations, ratings, used_pairs):
    """Clientes que dan un 5 y un 1 a dos calibraciones del mismo lote: sirve para ver si la nota depende del cliente."""
    finals_by_lot = {}
    for c in calibrations:
        if c["final"] and c["barista"] != NEVER_LOW_BARISTA and is_ratable(c["barista"], c):
            finals_by_lot.setdefault(c["lot"], []).append(c)
    lots = [lot_id for lot_id, finals in sorted(finals_by_lot.items()) if len(finals) >= 2]
    for position, client in enumerate(DISAGREEING_CLIENTS):
        first, second = finals_by_lot[lots[position % len(lots)]][:2]
        add_rating(ratings, used_pairs, first, client, 5)
        add_rating(ratings, used_pairs, second, client, 1)


# ---------- salida SQL ----------

def sql_text(value):
    return "N'" + value.replace("'", "''") + "'"


def sql_datetime(value):
    return "'" + value.strftime("%Y-%m-%dT%H:%M:%S") + "'"


def sql_date(value):
    return "'" + value.strftime("%Y-%m-%d") + "'"


def insert_statements(table, columns, rows):
    chunks = [rows[i:i + ROWS_PER_INSERT] for i in range(0, len(rows), ROWS_PER_INSERT)]
    statements = []
    for chunk in chunks:
        body = ",\n".join("    (" + ", ".join(row) + ")" for row in chunk)
        statements.append(f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n{body};\n")
    return "\n".join(statements)


def write(name, content):
    path = OUT_DIR / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


HEADER = "-- Cafetear · {title}\n-- {note}\n\nUSE Cafetear;\nGO\nSET NOCOUNT ON;\n\n"

DDL = """-- Cafetear · Crear la base y las tablas
-- Ejecutar primero. Borra y vuelve a crear todo, así que sirve para empezar de cero.
-- Las restricciones CHECK y UNIQUE de los enunciados 32 a 34 NO están acá a propósito: son parte del ejercicio.

IF DB_ID('Cafetear') IS NULL
    CREATE DATABASE Cafetear;
GO
USE Cafetear;
GO

DROP TABLE IF EXISTS Calificacion;
DROP TABLE IF EXISTS Calibracion;
DROP TABLE IF EXISTS Lote;
DROP TABLE IF EXISTS Grano;
DROP TABLE IF EXISTS Proveedor;
DROP TABLE IF EXISTS Barista;
DROP TABLE IF EXISTS Cliente;
GO

CREATE TABLE Proveedor (
    IDProveedor INT IDENTITY(1,1) PRIMARY KEY,
    CUIT        VARCHAR(13)  NOT NULL UNIQUE,
    razonSocial VARCHAR(100) NOT NULL
);

CREATE TABLE Grano (
    IDGrano       INT PRIMARY KEY,
    alturaCosecha INT          NOT NULL,   -- metros sobre el nivel del mar
    regionCosecha VARCHAR(60)  NOT NULL,
    fechaCosecha  DATE         NOT NULL
);

CREATE TABLE Lote (
    IDLote       INT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,   -- nombre de la finca, microlote o proceso
    IDGrano      INT NOT NULL REFERENCES Grano(IDGrano),
    IDProveedor  INT NOT NULL REFERENCES Proveedor(IDProveedor),
    fechaIngreso DATE NOT NULL,
    fechaTostado DATE NOT NULL,
    cantidadKg   DECIMAL(6,2) NOT NULL
);

CREATE TABLE Barista (
    IDBarista   INT IDENTITY(1,1) PRIMARY KEY,
    DNI         VARCHAR(8)  NOT NULL UNIQUE,
    nombre      VARCHAR(50) NOT NULL,
    apellido    VARCHAR(50) NOT NULL,
    experiencia INT         NOT NULL       -- años de experiencia
);

CREATE TABLE Cliente (
    IDCliente INT IDENTITY(1,1) PRIMARY KEY,
    DNI       VARCHAR(8)  NOT NULL UNIQUE,
    nombre    VARCHAR(50) NOT NULL,
    apellido  VARCHAR(50) NOT NULL
);

CREATE TABLE Calibracion (
    IDCalibracion    INT PRIMARY KEY,
    fechaCalibracion DATETIME     NOT NULL,
    dosis            DECIMAL(5,1) NOT NULL,   -- gramos de café molido
    tiempoExtraccion INT          NOT NULL,   -- segundos
    rendimiento      DECIMAL(5,1) NOT NULL,   -- gramos de café en la taza
    IDBarista        INT NOT NULL REFERENCES Barista(IDBarista),
    IDLote           INT NOT NULL REFERENCES Lote(IDLote)
);

CREATE TABLE Calificacion (
    IDCalificacion INT PRIMARY KEY,
    fecha          DATETIME NOT NULL,
    puntaje        INT      NOT NULL,
    IDCliente      INT NOT NULL REFERENCES Cliente(IDCliente),
    IDCalibracion  INT NOT NULL REFERENCES Calibracion(IDCalibracion)
);
GO
"""


def master_sql(clients):
    parts = [HEADER.format(title="Datos maestros", note="Proveedor, Grano, Lote, Barista y Cliente. Ejecutar después de 01 y antes de 03.")]
    parts.append("-- Proveedor (los CUIT son inventados)\n")
    parts.append(insert_statements("Proveedor", ["CUIT", "razonSocial"],
                                   [[sql_text(c), sql_text(n)] for c, n in PROVEEDORES]))
    parts.append("\n-- Grano: el tipo de café y su origen\n")
    parts.append(insert_statements("Grano", ["IDGrano", "alturaCosecha", "regionCosecha", "fechaCosecha"],
                                   [[str(g[0]), str(g[1]), sql_text(g[2]), sql_date(g[3])] for g in GRANOS]))
    parts.append(f"\n-- Lote: una bolsa concreta de café, con su nombre (el lote {NEVER_CALIBRATED_LOT} queda sin calibrar a propósito)\n")
    parts.append(insert_statements(
        "Lote", ["IDLote", "nombre", "IDGrano", "IDProveedor", "fechaIngreso", "fechaTostado", "cantidadKg"],
        [[str(l[0]), sql_text(LOT_NAMES[l[0]]), str(l[1]), str(l[2]), sql_date(l[3]),
          sql_date(l[3] - timedelta(days=l[4])), f"{l[5]:.2f}"] for l in LOTES]))
    parts.append("\n-- Barista (IDENTITY: los IDs salen 1 a 7 si la tabla estaba vacía)\n")
    parts.append(insert_statements("Barista", ["DNI", "nombre", "apellido", "experiencia"],
                                   [[sql_text(b[1]), sql_text(b[2]), sql_text(b[3]), str(b[4])] for b in BARISTAS]))
    parts.append("\n-- Cliente (IDENTITY: los IDs salen 1 a 60 si la tabla estaba vacía)\n")
    parts.append(insert_statements("Cliente", ["DNI", "nombre", "apellido"],
                                   [[sql_text(c[1]), sql_text(c[2]), sql_text(c[3])] for c in clients]))
    return "\n".join(parts)


def calibration_rows(calibrations):
    return [[str(c["id"]), sql_datetime(c["when"]), f"{c['dose']:.1f}", str(c["seconds"]),
             f"{c['yield']:.1f}", str(c["barista"]), str(c["lot"])] for c in calibrations]


def rating_rows(ratings):
    return [[str(r["id"]), sql_datetime(r["when"]), str(r["score"]), str(r["client"]), str(r["calibration"])] for r in ratings]


CAL_COLUMNS = ["IDCalibracion", "fechaCalibracion", "dosis", "tiempoExtraccion", "rendimiento", "IDBarista", "IDLote"]
RAT_COLUMNS = ["IDCalificacion", "fecha", "puntaje", "IDCliente", "IDCalibracion"]


def anomalies_sql(calibrations, ratings):
    final_cals = [c for c in calibrations if c["final"] and c["when"].date() > date(2026, 9, 5)]
    chosen = rng.sample(final_cals, 3)
    early = [[str(8001 + i), sql_datetime(c["when"] - timedelta(days=1 + i)), "4", str(50 + i), str(c["id"])]
             for i, c in enumerate(chosen)]
    duplicated = rng.sample([r for r in ratings if r["score"] >= 4], 3)
    duplicates = [[str(8101 + i), sql_datetime(r["when"] + timedelta(minutes=5)), str(max(1, r["score"] - 2)),
                   str(r["client"]), str(r["calibration"])] for i, r in enumerate(duplicated)]
    lot = LOTES[-3]
    before_entry = [["8001", sql_datetime(datetime.combine(lot[3] - timedelta(days=5), datetime.min.time()).replace(hour=8)),
                     "18.0", "28", "36.0", "3", str(lot[0])]]
    parts = [HEADER.format(title="Datos con errores a propósito",
                           note="Sirve para los enunciados 27 y 28. Ejecutar 07 antes de agregar las restricciones de los enunciados 32 a 34.")]
    parts.append("-- Calificaciones con fecha anterior a la de su calibración (enunciado 27)\n")
    parts.append(insert_statements("Calificacion", RAT_COLUMNS, early))
    parts.append("\n-- Una calibración con fecha anterior al ingreso de su lote (enunciado 27)\n")
    parts.append(insert_statements("Calibracion", CAL_COLUMNS, before_entry))
    parts.append("\n-- El mismo cliente califica dos veces la misma calibración (enunciado 28)\n")
    parts.append(insert_statements("Calificacion", RAT_COLUMNS, duplicates))
    return "\n".join(parts)


def current_lots_for(barista):
    """Lotes en uso hoy que el barista puede calibrar, del más nuevo al más viejo."""
    candidates = [lot for lot in LOTES if lot[0] != NEVER_CALIBRATED_LOT and lot[1] in barista[7]
                  and lot[3] <= END_DAY <= lot[3] + timedelta(days=lot[6])]
    return sorted(candidates, key=lambda lot: lot[3], reverse=True)


def today_sql():
    baristas = {b[0]: b for b in BARISTAS}
    lot_for = {1: current_lots_for(baristas[1])[0][0], 4: current_lots_for(baristas[4])[0][0],
               2: current_lots_for(baristas[2])[1][0]}
    return f"""-- Cafetear · Calibraciones de hoy
-- Para el enunciado 31 (vista de calibraciones de hoy). Se puede ejecutar todos los días: borra y vuelve a cargar las de hoy.

USE Cafetear;
GO
SET NOCOUNT ON;

DELETE FROM Calificacion WHERE IDCalificacion BETWEEN 9001 AND 9099;
DELETE FROM Calibracion  WHERE IDCalibracion  BETWEEN 9001 AND 9099;

DECLARE @hoy DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

INSERT INTO Calibracion (IDCalibracion, fechaCalibracion, dosis, tiempoExtraccion, rendimiento, IDBarista, IDLote) VALUES
    (9001, DATEADD(MINUTE, 420, @hoy), 18.0, 22, 33.0, 1, {lot_for[1]}),
    (9002, DATEADD(MINUTE, 432, @hoy), 18.0, 25, 34.5, 1, {lot_for[1]}),
    (9003, DATEADD(MINUTE, 444, @hoy), 18.0, 28, 36.0, 1, {lot_for[1]}),
    (9004, DATEADD(MINUTE, 450, @hoy), 17.5, 33, 38.0, 4, {lot_for[4]}),
    (9005, DATEADD(MINUTE, 462, @hoy), 17.5, 30, 36.5, 4, {lot_for[4]}),
    (9006, DATEADD(MINUTE, 474, @hoy), 17.5, 27, 35.0, 4, {lot_for[4]}),
    (9007, DATEADD(MINUTE, 480, @hoy), 19.0, 29, 38.5, 2, {lot_for[2]}),
    (9008, DATEADD(MINUTE, 492, @hoy), 19.0, 28, 38.0, 2, {lot_for[2]});

INSERT INTO Calificacion (IDCalificacion, fecha, puntaje, IDCliente, IDCalibracion) VALUES
    (9001, DATEADD(MINUTE, 520, @hoy), 5, 1, 9003),
    (9002, DATEADD(MINUTE, 535, @hoy), 4, 2, 9003),
    (9003, DATEADD(MINUTE, 560, @hoy), 4, 12, 9006),
    (9004, DATEADD(MINUTE, 575, @hoy), 3, 25, 9006),
    (9005, DATEADD(MINUTE, 590, @hoy), 5, 7, 9008);
"""


CLEAN_SQL = """-- Cafetear · Limpiar los datos con errores
-- Ejecutar antes de agregar las restricciones UNIQUE y CHECK (enunciados 32 a 34), si no, el ALTER TABLE falla.

USE Cafetear;
GO

DELETE FROM Calificacion WHERE IDCalificacion BETWEEN 8001 AND 8199;
DELETE FROM Calibracion  WHERE IDCalibracion = 8001;
GO
"""


def readme_text(n_cal, n_rat):
    return f"""# Scripts de la base Cafetear

Scripts en T-SQL (SQL Server) para crear la base, cargarla con datos de ejemplo y definir sus objetos (función, vistas, procedimientos, triggers, índices y roles). Todo es inventado.

Para levantar todo con Docker, mirá el [README de la carpeta de arriba](../README.md): `docker compose up -d` ejecuta estos scripts en el orden correcto.

## Qué hay en cada carpeta

Para ejecutarlos a mano, en este orden:

| Orden | Carpeta | Qué hay |
|---|---|---|
| 1 | `tablas/` | `01_crear_base_y_tablas.sql`: crea la base `Cafetear` y las 7 tablas. Borra lo que hubiera |
| 2 | `datos/` | `02_datos_maestros.sql`: {len(PROVEEDORES)} proveedores, {len(GRANOS)} granos, {LOT_COUNT} lotes, {len(BARISTAS)} baristas y {CLIENT_COUNT} clientes. `03_calibraciones.sql`: {n_cal} calibraciones entre junio de 2025 y octubre de 2026. `04_calificaciones.sql`: {n_rat} calificaciones. Opcionales: `05_datos_con_errores.sql` (errores a propósito para los enunciados 27 y 28), `06_calibraciones_de_hoy.sql` (enunciado 31) y `07_limpiar_errores.sql` (borra lo del 05; correr antes de los enunciados 32 a 34) |
| 3 | `funciones/` | 1 función: relación de extracción (rendimiento ÷ dosis) |
| 4 | `vistas/` | 2 vistas: puntaje por calibración y mejor calibración por grano |
| 5 | `procedimientos/` | 3 procedimientos: crear calibración, crear calificación y ranking de baristas |
| 6 | `triggers/` | 2 triggers: control de calificaciones y asignación automática de la calibración |
| 7 | `indices/` | 3 índices sobre claves foráneas y fechas |
| 8 | `seguridad/` | 2 roles (barista y analista) con sus permisos |
| — | `consultas/` | `Queries.sql`: las consultas de cada integrante |
| — | `pruebas/` | `probar_todo.sql`: prueba todo, incluidos los casos de error, y no deja datos |
| — | `mantenimiento/` | `backup_y_restauracion.sql`: copia de seguridad y su verificación. `limpiar_objetos.sql`: lo usa la carga para recrear los objetos |

Los scripts `inicializar.sh` y `cargar_cafetear.sh` hacen toda la carga automáticamente. Los scripts de funciones, vistas, procedimientos, triggers, índices y roles se pueden volver a ejecutar sin problema.

Los triggers se crean después de cargar los datos. Por eso `datos/05_datos_con_errores.sql` solo se puede correr si los triggers todavía no existen: usá la carga con `--con-errores`, que lo hace en el orden correcto.

Los archivos de `tablas/` y `datos/` los genera `../herramientas/generar_datos.py`: no se editan a mano. Los datos son siempre los mismos, así que todo el equipo ve lo mismo.

## Qué historia cuentan los datos

- **La calidad cambia mes a mes.** Arranca baja en junio de 2025, mejora, tiene bajones en diciembre de 2025 y en junio de 2026, y cierra alta. Los lunes puntúan un poco peor.
- **Cada vez se necesitan menos pruebas por día.** Al principio un barista hace de 3 a 5 pruebas hasta dar con la calibración, y hoy de 1 a 3.
- **Hay rotación.** Ramiro Quiroga estuvo hasta octubre de 2025, Florencia Montero de noviembre de 2025 a febrero de 2026 y Valentina Pereyra hasta mayo de 2026. Sofía, Julián, Camila, Mateo y Tomás Arias fueron entrando.
- **Los clientes entran y se van.** Hay clientes habituales y otros que dejan de opinar.

## Casos armados para los enunciados

- **{LOT_NAMES[DECLINING_LOT]} (lote {DECLINING_LOT})** empieza a bajar de puntaje desde fines de septiembre de 2026 (enunciado 22).
- **{LOT_NAMES[PROBLEM_LOT]} (lote {PROBLEM_LOT})** rinde mal durante toda su vida (enunciado 8).
- **{LOT_NAMES[IMPROVING_LOT]} (lote {IMPROVING_LOT})** mejora con el tiempo.
- **Hay lotes que nunca se calibraron**, entre ellos el último en llegar, {LOT_NAMES[NEVER_CALIBRATED_LOT]} (lote {NEVER_CALIBRATED_LOT}) (enunciado 2).
- **Baristas 1 y 2** calibraron granos de las 8 regiones (enunciado 18). El grano 8 solo lo calibran ellos dos.
- **Martina Ríos (1)** nunca recibe menos de 3 (enunciado 14).
- **Camila Ferrer (7)** recibe 5 y también 1 o 2 (enunciado 15).
- **Mateo Duarte (4)** tiene la última calibración con puntajes bajos (enunciado 23).
- **Julián Acosta (6)** no tiene calificaciones desde septiembre de 2026 (enunciado 25).
- **Clientes 1, 2 y 3** calificaron calibraciones de los {len(BARISTAS)} baristas (enunciado 17).
- **Los granos 9 y 10** están en el catálogo pero todavía no tienen lotes.
- Muchas calibraciones de prueba no tienen calificaciones, porque los clientes solo opinan sobre el café final (enunciado 16).

Los IDs de Barista y Cliente son IDENTITY, así que las calibraciones y calificaciones asumen que esas tablas arrancaron vacías (por eso el script 01 las vuelve a crear).
"""


def verify(calibrations, ratings, used_pairs, last_bad):
    """Chequeos de consistencia sobre los datos generados."""
    assert all(lot_by_id(c["lot"])[3] <= c["when"].date() for c in calibrations), "calibracion antes del ingreso"
    cal_when = {c["id"]: c["when"] for c in calibrations}
    assert all(r["when"] > cal_when[r["calibration"]] for r in ratings), "calificacion antes de la calibracion"
    assert all(nearest_calibration_id(calibrations, r["when"]) == r["calibration"] for r in ratings), "calibracion no es la mas proxima"
    pairs = [(r["client"], r["calibration"]) for r in ratings]
    assert len(pairs) == len(set(pairs)), "calificaciones duplicadas"
    assert all(1 <= r["score"] <= 5 for r in ratings)
    assert not any(c["lot"] == NEVER_CALIBRATED_LOT for c in calibrations)
    cal_by_id = {c["id"]: c for c in calibrations}
    low_scores = [r for r in ratings if cal_by_id[r["calibration"]]["barista"] == NEVER_LOW_BARISTA and r["score"] < 3]
    assert not low_scores, "la barista 1 recibio menos de 3"
    recent = [r for r in ratings if cal_by_id[r["calibration"]]["barista"] == NO_RECENT_RATINGS_BARISTA
              and r["when"].date() >= SILENT_FROM]
    assert not recent, "el barista 6 recibio calificaciones recientes"
    verify_coverage(calibrations)
    last_scores = [r["score"] for r in ratings if r["calibration"] == last_bad["id"]]
    assert last_scores and max(last_scores) <= 2, "ultima calibracion de Mateo"
    inconsistent = [r["score"] for r in ratings if cal_by_id[r["calibration"]]["barista"] == INCONSISTENT_BARISTA]
    assert 5 in inconsistent and min(inconsistent) <= 2
    for client in ALL_BARISTA_CLIENTS:
        rated = {cal_by_id[r["calibration"]]["barista"] for r in ratings if r["client"] == client}
        assert rated == {b[0] for b in BARISTAS}, f"cliente {client} no califico a todos"
    verify_volume_and_stories(calibrations, ratings, cal_by_id)
    verify_variety(calibrations, ratings, cal_by_id)


def nearest_calibration_id(calibrations, moment):
    """La misma regla que usa el procedimiento: la ultima calibracion anterior a la fecha (si empatan, la de ID mayor)."""
    return max((c for c in calibrations if c["when"] <= moment), key=lambda c: (c["when"], c["id"]))["id"]


def verify_coverage(calibrations):
    grain_of = {lot[0]: lot[1] for lot in LOTES}
    covered = {}
    for c in calibrations:
        covered.setdefault(c["barista"], set()).add(grain_of[c["lot"]])
    full = [b for b, grains in covered.items() if len(grains) == LOT_GRAIN_COUNT]
    assert sorted(full) == [1, 2], f"division relacional: {full}"
    grain_baristas = {}
    for c in calibrations:
        grain_baristas.setdefault(grain_of[c["lot"]], set()).add(c["barista"])
    assert len(grain_baristas[8]) == 2 and all(len(grain_baristas[g]) >= 3 for g in range(1, 8))


def lot_scores(ratings, cal_by_id, lot_id, month=None):
    return [r["score"] for r in ratings if cal_by_id[r["calibration"]]["lot"] == lot_id
            and (month is None or r["when"].month == month)]


def verify_volume_and_stories(calibrations, ratings, cal_by_id):
    assert 150 <= len(calibrations) <= 260, f"cantidad de calibraciones: {len(calibrations)}"
    used_lots = {c["lot"] for c in calibrations}
    assert len(used_lots) >= 28, "pocos lotes usados"
    per_barista = {b[0]: sum(1 for c in calibrations if c["barista"] == b[0]) for b in BARISTAS}
    assert all(n >= 6 for n in per_barista.values()), "barista con pocas calibraciones"
    assert any(c["barista"] == NO_RECENT_RATINGS_BARISTA and c["when"].date() >= SILENT_FROM for c in calibrations)
    september = lot_scores(ratings, cal_by_id, DECLINING_LOT, 9)
    october = lot_scores(ratings, cal_by_id, DECLINING_LOT, 10)
    assert len(september) >= 3 and len(october) >= 3, "pocas notas del lote que baja"
    assert sum(october) / len(october) <= sum(september) / len(september) - 0.4, "el lote que baja no baja"
    problem = lot_scores(ratings, cal_by_id, PROBLEM_LOT)
    assert len(problem) >= 6 and sum(problem) / len(problem) < 3.5, "el lote problematico no es problematico"


def monthly_means(ratings):
    by_month = {}
    for r in ratings:
        by_month.setdefault((r["when"].year, r["when"].month), []).append(r["score"])
    return {month: sum(scores) / len(scores) for month, scores in by_month.items() if len(scores) >= 6}


def trials_per_day(calibrations, months):
    chosen = [c for c in calibrations if (c["when"].year, c["when"].month) in months]
    days = {(c["barista"], c["when"].date()) for c in chosen}
    return len(chosen) / len(days)


def clients_that_disagree(ratings, cal_by_id):
    scores_by_client_lot = {}
    for r in ratings:
        key = (r["client"], cal_by_id[r["calibration"]]["lot"])
        scores_by_client_lot.setdefault(key, []).append(r["score"])
    return {client for (client, _), scores in scores_by_client_lot.items() if max(scores) - min(scores) >= 3}


def verify_variety(calibrations, ratings, cal_by_id):
    means = monthly_means(ratings)
    assert len(means) >= 14, "pocos meses con datos suficientes"
    assert max(means.values()) - min(means.values()) >= 0.8, "la calidad casi no varia entre meses"
    ordered = [means[month] for month in sorted(means)]
    assert sum(ordered[-4:]) / 4 >= sum(ordered[:4]) / 4 + 0.5, "la calidad no mejora con el tiempo"
    first = {(2025, m) for m in (6, 7, 8, 9)}
    last = {(2026, m) for m in (7, 8, 9, 10)}
    assert trials_per_day(calibrations, first) >= trials_per_day(calibrations, last) + 1.0, "las pruebas por dia no bajan"
    months_of = {}
    for r in ratings:
        months_of.setdefault(r["client"], set()).add((r["when"].year, r["when"].month))
    dropped = [c for c, months in months_of.items() if (2026, 9) in months and (2026, 10) not in months]
    assert len(dropped) >= 3, "pocos clientes que dejan de opinar"
    assert sum(1 for r in ratings if (r["when"].year, r["when"].month) == (2026, 2)) >= 3
    assert len(clients_that_disagree(ratings, cal_by_id)) >= 2, "no hay clientes con notas muy distintas en un mismo lote"


def generate_valid_dataset():
    for attempt in range(MAX_ATTEMPTS):
        seed = SEED + attempt
        reset_rng(seed)
        try:
            clients, windows = build_clients()
            calibrations = build_calibrations()
            ratings, used_pairs = build_ratings(calibrations, windows)
            last_bad = enforce_story_cases(calibrations, ratings, used_pairs)
            verify(calibrations, ratings, used_pairs, last_bad)
            return seed, clients, calibrations, ratings
        except (AssertionError, IndexError, KeyError, ValueError, StopIteration):
            continue
    raise RuntimeError("no se encontro una combinacion que cumpla los casos")


def main():
    seed, clients, calibrations, ratings = generate_valid_dataset()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    write("tablas/01_crear_base_y_tablas.sql", DDL)
    write("datos/02_datos_maestros.sql", master_sql(clients))
    write("datos/03_calibraciones.sql",
          HEADER.format(title="Calibraciones", note="Ejecutar después de 02.") + insert_statements("Calibracion", CAL_COLUMNS, calibration_rows(calibrations)))
    write("datos/04_calificaciones.sql",
          HEADER.format(title="Calificaciones", note="Ejecutar después de 03.") + insert_statements("Calificacion", RAT_COLUMNS, rating_rows(ratings)))
    write("datos/05_datos_con_errores.sql", anomalies_sql(calibrations, ratings))
    write("datos/06_calibraciones_de_hoy.sql", today_sql())
    write("datos/07_limpiar_errores.sql", CLEAN_SQL)
    write("README.md", readme_text(len(calibrations), len(ratings)))
    print(f"semilla={seed} calibraciones={len(calibrations)} calificaciones={len(ratings)} clientes={len(clients)}")


if __name__ == "__main__":
    main()
