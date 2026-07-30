# Sample Queries — verified against the expanded bunchingbus schema (real BODS data)

## Q1: Bunching rate per route

```sql
SELECT line_ref, COUNT(*) AS n_events,
       ROUND(AVG(is_bunching)*100, 2) AS bunching_pct
FROM bunching_events
WHERE is_bunching IS NOT NULL
GROUP BY line_ref HAVING n_events >= 5
ORDER BY bunching_pct DESC LIMIT 10;
```

**Result:**

| line_ref | n_events | bunching_pct |
|---|---|---|
| 300 | 108 | 92.59 |
| 2 | 124 | 64.52 |
| X2 | 108 | 59.26 |
| 41 | 116 | 58.62 |
| 2X | 16 | 25.00 |
| 61 | 56 | 21.43 |
| 125 | 76 | 21.05 |
| 6A | 44 | 18.18 |
| 104 | 24 | 16.67 |
| 5 | 36 | 11.11 |

## Q2: Fleet summary per operator (operators ⋈ vehicle_locations)

```sql
SELECT o.operator_ref, o.operator_name,
       COUNT(DISTINCT v.vehicle_ref) AS distinct_vehicles,
       COUNT(*) AS total_polls,
       ROUND(AVG(v.bearing), 1) AS avg_bearing
FROM vehicle_locations v
JOIN operators o ON v.operator_ref = o.operator_ref
GROUP BY o.operator_ref;
```

**Result:**

| operator_ref | operator_name | distinct_vehicles | total_polls | avg_bearing |
|---|---|---|---|---|
| SCCU | Stagecoach Cumbria | 331 | 400 | 139.9 |
| SCMY | Stagecoach Merseyside & South Lancashire | 197 | 362 | 110.5 |

## Q3: Busiest routes by live GPS activity (vehicle_locations ⋈ routes)

```sql
SELECT v.line_ref, r.route_name, COUNT(*) AS n_polls
FROM vehicle_locations v
JOIN routes r ON v.line_ref = r.line_ref
GROUP BY v.line_ref, r.route_name
ORDER BY n_polls DESC LIMIT 10;
```

**Result:**

| line_ref | route_name | n_polls |
|---|---|---|
| 19 | Route 19 | 109 |
| 10A | Route 10A | 67 |
| 2 | Route 2 | 33 |
| 41 | Route 41 | 31 |
| 300 | Route 300 | 29 |
| 1 | Route 1 | 29 |
| X2 | Route X2 | 29 |
| 125 | Route 125 | 21 |
| 30 | Route 30 | 18 |
| 61 | Route 61 | 16 |

## Q4: Scheduled stops per route (timetable_stops ⋈ routes)

```sql
SELECT t.line_ref, r.route_name, COUNT(*) AS n_scheduled_stops
FROM timetable_stops t
JOIN routes r ON t.line_ref = r.line_ref
GROUP BY t.line_ref, r.route_name
ORDER BY n_scheduled_stops DESC LIMIT 10;
```

**Result:**

| line_ref | route_name | n_scheduled_stops |
|---|---|---|
| 125 | Route 125 | 34166 |
| 1 | Route 1 | 26409 |
| 61 | Route 61 | 25725 |
| 3 | Route 3 | 21138 |
| 111 | Route 111 | 20043 |
| 68 | Route 68 | 19224 |
| 30 | Route 30 | 18861 |
| 1A | Route 1A | 16109 |
| X2 | Route X2 | 14979 |
| 2 | Route 2 | 14701 |

## Q5: Bunching rate by operator (3-table chain: operators → vehicle_locations → routes → bunching_events)

```sql
SELECT o.operator_ref, o.operator_name,
       COUNT(DISTINCT v.line_ref) AS routes_served,
       ROUND(AVG(b.is_bunching)*100, 2) AS bunching_pct
FROM operators o
JOIN vehicle_locations v ON o.operator_ref = v.operator_ref
JOIN bunching_events b ON v.line_ref = b.line_ref
WHERE b.is_bunching IS NOT NULL
GROUP BY o.operator_ref, o.operator_name;
```

**Result:**

| operator_ref | operator_name | routes_served | bunching_pct |
|---|---|---|---|
| SCCU | Stagecoach Cumbria | 74 | 29.94 |
| SCMY | Stagecoach Merseyside & South Lancashire | 48 | 34.81 |