# Student Performance Analysis — Statistical Hypothesis Testing & Classification

Análisis del rendimiento académico de 10,000 estudiantes con énfasis en pruebas de hipótesis estadísticas rigurosas (t-test, Mann-Whitney U, correlación de Pearson) antes de construir un modelo de clasificación de calificación final.

## Objetivo

Identificar qué factores (estudio, asistencia, acceso a internet, clases extra, sueño) influyen estadísticamente en el rendimiento académico, y predecir la calificación final (A–F) a partir de variables de desempeño durante el curso.

## Stack técnico

`Python` `scipy.stats` `t-test` `Mann-Whitney U` `Pearson correlation` `Logistic Regression`

## Estructura

```
07-student-performance/
├── Students_analysis.ipynb
├── data/
│   └── student_performance_data.csv
└── outputs/
```

## Contenido del análisis

**1. Diagnóstico de calidad** — 10,000 registros, 14 columnas, sin nulos ni duplicados.

**2. Pruebas de hipótesis estadística** — comparación de medias y distribuciones entre grupos categóricos (género, acceso a internet, clases extra) usando t-test de Student y Mann-Whitney U como verificación no paramétrica.

**3. Análisis de correlación** — Pearson entre cada variable numérica y la calificación general, con significancia estadística (p-value) para cada relación.

**4. Heatmap de correlaciones** — matriz completa de variables numéricas.

**5. Modelo de clasificación** — Logistic Regression para predecir la letra de calificación (A–F) a partir de variables de desempeño.

## Hallazgos — Pruebas de hipótesis

| Comparación | Test | Estadístico | p-value | Conclusión |
|--------------|------|--------------|---------|------------|
| Género (M vs F) | t-test | -0.031 | 0.975 | Sin diferencia significativa en rendimiento |
| Género (M vs F) | Mann-Whitney U | — | 0.969 | Confirma el resultado del t-test — distribuciones equivalentes |
| Acceso a internet (Sí vs No) | t-test | 2.909 | 0.0036 | **Diferencia significativa** — Cohen's d = 0.0582 (efecto muy pequeño) |
| Clases extra (Sí vs No) | t-test | 0.622 | 0.534 | Sin evidencia de que las clases extra afecten la calificación |

El acceso a internet es estadísticamente significativo, pero el tamaño del efecto (Cohen's d = 0.058) es prácticamente despreciable — un caso claro de **significancia estadística sin relevancia práctica**, relevante de mencionar dado el tamaño de muestra (n=10,000), que vuelve significativas incluso diferencias mínimas.

## Hallazgos — Correlación de Pearson con calificación general

| Variable | Coeficiente (r) | p-value | Interpretación |
|----------|-------------------|---------|------------------|
| Horas de estudio/día | -0.004 | 0.715 | Sin relación lineal — resultado contraintuitivo |
| Asistencia (%) | 0.149 | 1.3×10⁻⁵⁰ | Correlación positiva débil pero significativa |
| Puntaje de tareas | 0.397 | ~0 | Correlación positiva media |
| Puntaje de medio término | 0.529 | ~0 | Correlación positiva media-alta |
| Puntaje de examen final | 0.689 | ~0 | **Correlación más fuerte** — el examen final domina la calificación general |

**Hallazgo contraintuitivo:** las horas de estudio reportadas no muestran relación lineal con el rendimiento (r=-0.004, p=0.715). Esto sugiere que la *cantidad* de horas de estudio autorreportadas es un predictor débil comparado con el desempeño real medido en evaluaciones (tareas, parciales, examen final) — posiblemente por la calidad variable del estudio o sesgo en el autoreporte.

## Modelo de clasificación

| Modelo | Features | Accuracy |
|--------|----------|----------|
| Logistic Regression | study_hours, attendance, assignment_score, midterm_score, final_exam_score, participation_score, sleep_hours | **0.9860** |

El accuracy es alto porque las features incluyen las puntuaciones individuales (tareas, parcial, examen final) que **componen matemáticamente** el `overall_score` del cual deriva la calificación — es un resultado esperado dado que el modelo predice una variable que es función directa de sus propios predictores, no un caso de generalización sobre datos verdaderamente independientes.

## Próximos pasos
- Comparar con modelos adicionales (Random Forest, Gradient Boosting) para verificar si el accuracy se mantiene
- Excluir las puntuaciones que componen directamente `overall_score` y evaluar predictores verdaderamente independientes (asistencia, sueño, acceso a internet, clases extra)
- Análisis de regresión múltiple para cuantificar el efecto conjunto de variables con relación estadísticamente significativa pero individualmente débil
