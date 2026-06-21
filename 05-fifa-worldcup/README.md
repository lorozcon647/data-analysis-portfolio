# FIFA World Cup Historical Analysis (1930–2022)

92 años de historia del Mundial — 964 partidos, 88 equipos, 22 torneos — analizados con SQL avanzado (CTEs, window functions), análisis de ventaja del local, rendimiento de países sede, y modelo predictivo de resultados.

## Objetivo

Explorar patrones históricos de goles, rendimiento de equipos y países sede, y evaluar qué tan predecible es el resultado de un partido de Copa del Mundo con variables estructurales (era, fase, región).

## Stack técnico

`Python` `SQL` `DuckDB` `Window Functions` `SVM` `LightGBM`

## Estructura

```
05-fifa-worldcup/
├── fifa_worldcup_analysis.ipynb
├── data/
│   ├── matches.csv
│   ├── teams.csv
│   ├── groups.csv
│   └── tournaments.csv
└── outputs/
```

## Contenido del análisis

**1. Limpieza** — 964 partidos, 86 equipos únicos, clasificación en fase de grupos (735 partidos) vs eliminatoria (229 partidos), asignación de era histórica y región geográfica por equipo.

**2. Goles por torneo** — evolución histórica total y promedio, comparativa fase de grupos vs eliminatoria.

**3. Equipos** — ranking de victorias, derrotas, goles a favor; apariciones por torneo a lo largo de la historia.

**4. Rendimiento de país sede** — win rate del anfitrión en cada edición del torneo.

**5. Tendencias en eliminatoria** — goles promedio y frecuencia de tiempo extra por fase (octavos, cuartos, semis, final).

**6. Resultados por región y era** — ventaja del local, distribución de victorias por continente.

**7. SQL con DuckDB** — ranking con `RANK()`, evolución temporal con `LAG()`, equipos más finalistas con CTEs y `UNION ALL`.

**8. Modelo predictivo** — clasificación de resultado (Home Win / Draw / Away Win) con SVM y LightGBM.

## Hallazgos principales

| # | Hallazgo | Detalle |
|---|----------|---------|
| 1 | 1954 fue el torneo más goleador | 5.38 goles/partido — récord histórico |
| 2 | 1990 fue el más defensivo | 2.21 goles/partido — mínimo histórico |
| 3 | La fase de grupos produce más goles que la eliminatoria | La brecha se ha reducido desde 1990 |
| 4 | **Brasil** lidera en partidos (114) y victorias (76, win rate 66.7%) | El equipo histórico más dominante |
| 5 | Alemania (West Germany + Germany) supera a Italia y Argentina en victorias totales | 68 victorias combinadas |
| 6 | El torneo creció de 13 equipos (1930) a 32 (desde 1998) | Próxima expansión a 48 en 2026 |
| 7 | Los países sede tienen win rate promedio superior al 50% | Ventaja real, no solo percepción |
| 8 | Home Win: 52.1% vs Away Win: 25.7% | Ganar de visitante es consistentemente más difícil |
| 9 | Europa y Sudamérica concentran +80% de las victorias históricas | Concentración geográfica del poder futbolístico |
| 10 | Mexico City es la ciudad con más partidos jugados | Sede en 1970 y 1986 |

## Finalistas históricos (SQL con CTE + UNION ALL)

| Equipo | Finales | Títulos | Subcampeonatos | % Títulos |
|--------|---------|---------|------------------|-----------|
| Brazil | 6 | 4 | 2 | 66.7% |
| West Germany | 6 | 3 | 3 | 50.0% |
| Italy | 6 | 3 | 3 | 50.0% |
| Argentina | 6 | 2 | 4 | 33.3% |
| Uruguay | 1 | 1 | 0 | 100.0% |
| Spain | 1 | 1 | 0 | 100.0% |

## Evolución de goles con Window Functions (SQL — `LAG()`)

El query identifica el cambio de goles promedio respecto al torneo anterior. El salto más grande de la historia ocurrió en **1954** (+1.38 goles/partido vs 1950), seguido de la caída más fuerte en **1958** (-1.78 vs 1954) — el torneo pasó de ser extremadamente ofensivo a normalizarse en un solo ciclo.

## Modelo predictivo de resultado

| Modelo | Accuracy | Recall (Away Win) | Recall (Draw) | Recall (Home Win) |
|--------|----------|---------------------|----------------|---------------------|
| SVM (kernel RBF) | 54% | 0.24 | 0.00 | 0.93 |
| **LightGBM** | **55%** | 0.48 | 0.05 | 0.80 |

Ambos modelos predicen bien Home Win pero fallan sistemáticamente en **Draw** — el resultado más difícil de anticipar en fútbol. SVM ignora completamente la clase empate (recall 0%); LightGBM mejora algo en Away Win y Draw, aunque el accuracy total (55%) apenas supera el baseline de predecir siempre Home Win (52%).

**Nota metodológica:** con solo 964 partidos y features estructurales básicas (era, región, fase), ningún modelo —incluyendo arquitecturas más complejas— superaría significativamente este desempeño. La mejora real requeriría features de calidad: ranking FIFA al momento del partido, historial head-to-head entre equipos, y forma reciente — no un modelo más sofisticado sobre los mismos datos limitados.

## Próximos pasos
- Incorporar ranking FIFA histórico como feature
- Análisis de rendimiento de entrenadores por torneo
- Simulación Monte Carlo de brackets eliminatorios
- Historial head-to-head entre equipos como predictor
