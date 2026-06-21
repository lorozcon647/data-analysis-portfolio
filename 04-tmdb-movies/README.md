# TMDB Movie Database Analysis

Análisis exploratorio de 9,826 películas del catálogo de The Movie Database (TMDB), con manejo de variables multi-valor (géneros), análisis de correlaciones y modelo predictivo de rating alto.

## Objetivo

Identificar tendencias de popularidad, géneros dominantes y características que predicen una película bien calificada por la audiencia.

## Stack técnico

`Python` `pandas` `scikit-learn` `Logistic Regression` `Random Forest` `Gradient Boosting`

## Estructura

```
04-tmdb-movies/
├── netflix_movies_analysis.ipynb
├── data/
│   └── mymoviedb.csv
└── outputs/
```

## Contenido del análisis

**1. Limpieza** — el dataset requiere `engine='python'` en `pd.read_csv` por campos de texto muy largos (overview, poster URL) que rompen el parser C por defecto. Eliminación de filas sin título/género (20 de 9,837), conversión de columnas numéricas mal tipadas como string, separación de géneros multi-valor con `explode()`.

**2. EDA** — distribución de ratings y popularidad, top películas por cada métrica, popularidad y rating por género, producción por idioma, tendencias anuales 2000-2024, heatmap género×año.

**3. Correlaciones** — relación entre popularidad, rating y número de votos.

**4. Modelo predictivo** — clasificación binaria de "rating alto" (≥7.0) comparando 3 modelos.

## Hallazgos principales

| # | Hallazgo | Detalle |
|---|----------|---------|
| 1 | **Popularidad ≠ Calidad** | Correlación de 0.054 — prácticamente nula |
| 2 | Spider-Man: No Way Home es la película más popular (5,084) | Pero no aparece en el top de rating |
| 3 | El Padrino y Shawshank Redemption lideran rating | Clásicos con miles de votos, no los más populares |
| 4 | **Documentary** tiene el rating promedio más alto | Audiencia más selecta y comprometida |
| 5 | Action y Adventure lideran popularidad pero no rating | Géneros de atracción masiva ≠ géneros mejor valorados |
| 6 | Inglés domina en volumen (77%) pero no en rating | Películas en japonés, ruso y coreano tienen ratings más altos |
| 7 | Pico de producción en 2021 | Recuperación post-COVID con boom de streaming |
| 8 | Correlación votos-rating: 0.254 | Débil pero positiva — más votos, ligeramente mejor calidad promedio |

## Distribución del dataset

- 9,826 películas tras limpieza (de 9,837 originales)
- Rango de fechas: 1902-04-17 a 2024-07-03
- 19 géneros únicos, 43 idiomas únicos
- Rating promedio: 6.44 — el 75% de las películas se concentra entre 5.9 y 7.1

## Comparativa de modelos — Predicción de rating alto (≥7.0)

| Modelo | ROC-AUC | Recall (Rating alto) | Precision (Rating alto) |
|--------|---------|------------------------|---------------------------|
| Logistic Regression | 0.677 | 0.57 | 0.52 |
| Random Forest | 0.793 | 0.60 | 0.63 |
| **Gradient Boosting** | **0.832** | 0.43 | 0.78 |

**Trade-off entre modelos:** Gradient Boosting tiene el mayor AUC (0.832) pero es conservador — solo detecta el 43% de las películas de rating alto, aunque cuando lo hace acierta el 78% de las veces. Random Forest ofrece mejor balance (recall 60%, AUC 0.793). La elección depende del caso de uso: una plataforma de streaming que busca maximizar recomendaciones de calidad preferiría Random Forest; un estudio evaluando proyectos con bajo margen de error preferiría Gradient Boosting.

`vote_count` resultó ser el predictor más fuerte de rating alto — más relevante que el género principal o el idioma. El año de lanzamiento también tiene más peso predictivo que estas dos variables categóricas.

## Próximos pasos
- Análisis de sentimiento sobre `Overview` con NLP para extraer features de texto
- Incorporar datos de presupuesto y recaudación (box office)
- Sistema de recomendación basado en similitud de géneros y rating
