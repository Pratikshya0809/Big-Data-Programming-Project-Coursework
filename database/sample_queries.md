# Sample Queries — verified against bus_bunching.db 

## Q1: Bunching rate per route 

```sql
SELECT line_ref, COUNT(*) AS n_events,
               ROUND(AVG(is_bunching)*100, 2) AS bunching_pct
        FROM bunching_events GROUP BY line_ref HAVING n_events >= 5
        ORDER BY bunching_pct DESC LIMIT 10;
```

**Result:**

| line_ref | n_events | bunching_pct |
|---|---|---|
| 300 | 27 | 92.59 |
| 2 | 31 | 64.52 |
| X2 | 27 | 59.26 |
| 41 | 29 | 58.62 |
| 61 | 14 | 21.43 |
| 125 | 19 | 21.05 |
| 6A | 11 | 18.18 |
| 104 | 6 | 16.67 |
| 5 | 9 | 11.11 |
| 555 | 11 | 9.09 |

## Q2: Routes with the tightest real scheduled headway

```sql
SELECT line_ref, route_name, ROUND(scheduled_headway_sec,1) AS scheduled_headway_sec
        FROM routes ORDER BY scheduled_headway_sec ASC LIMIT 10;
```

**Result:**

| line_ref | route_name | scheduled_headway_sec |
|---|---|---|
| 721 | Route 721 | 60.0 |
| 1 | Route 1 | 339.4 |
| 111 | Route 111 | 407.8 |
| 99 | Route 99 | 450.0 |
| X2 | Route X2 | 470.2 |
| 125 | Route 125 | 478.5 |
| 61 | Route 61 | 488.3 |
| 2 | Route 2 | 538.9 |
| P1 | Route P1 | 573.9 |
| 3 | Route 3 | 583.4 |

## Q3: Average observed vs scheduled headway, joined (real data)

```sql
SELECT r.line_ref, r.route_name,
               ROUND(AVG(b.observed_headway_sec),1) AS avg_observed_sec,
               ROUND(r.scheduled_headway_sec,1) AS scheduled_headway_sec
        FROM bunching_events b JOIN routes r ON b.line_ref = r.line_ref
        GROUP BY r.line_ref ORDER BY avg_observed_sec ASC LIMIT 10;
```

**Result:**

| line_ref | route_name | avg_observed_sec | scheduled_headway_sec |
|---|---|---|---|
| 109 | Route 109 | 114.0 | 1659.7 |
| 9 | Route 9 | 829.0 | 870.4 |
| 2 | Route 2 | 1207.4 | 538.9 |
| 125 | Route 125 | 1225.7 | 478.5 |
| 41 | Route 41 | 1236.4 | 1960.2 |
| 55 | Route 55 | 1331.7 | 2151.7 |
| 30 | Route 30 | 1372.3 | 843.7 |
| 2X | Route 2X | 1425.8 | 1189.1 |
| 400 | Route 400 | 1787.0 | 6955.0 |
| 555 | Route 555 | 1824.7 | 1033.4 |

## Q4: Count of bunching vs non-bunching events overall

```sql
SELECT is_bunching, COUNT(*) AS n FROM bunching_events GROUP BY is_bunching;
```

**Result:**

| is_bunching | n |
|---|---|
| None | 249 |
| 0 | 227 |
| 1 | 97 |
