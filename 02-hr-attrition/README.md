# IBM HR Analytics — Employee Attrition Prediction

Predicción de rotación de empleados sobre el dataset IBM HR Employee Attrition (1,470 empleados, 35 variables), con análisis de cohortes, comparativa de modelos y **pipeline productivo de scoring**.

## Objetivo

Identificar los factores que impulsan la rotación de empleados y construir un modelo predictivo para apoyar decisiones de retención de RRHH.

## Stack técnico

`Python` `pandas` `scikit-learn` `GridSearchCV` `Logistic Regression` `Random Forest` `Gradient Boosting` `joblib`

## Estructura

```
02-hr-attrition/
├── hr_attrition_analysis.ipynb
├── train_model.py
├── predict_attrition.py
├── data/
│   └── WA_Fn-UseC_-HR-Employee-Attrition.csv
└── outputs/
```

## Contenido del análisis

**1. Limpieza** — dataset sin valores nulos (1,470 filas × 35 columnas), eliminación de columnas constantes, mapeo de escalas ordinales a etiquetas legibles.

**2. EDA** — perfil demográfico (edad, género, estado civil), rotación por departamento y rol, relación ingreso/años en empresa vs rotación, impacto del overtime, satisfacción laboral y balance vida-trabajo.

**3. Análisis de correlaciones** — heatmap de las 10 variables más correlacionadas con `Attrition`.

**4. Análisis de cohortes por antigüedad** — segmentación en 5 rangos de años en la empresa, revelando que el riesgo de rotación se concentra fuertemente en los primeros 2 años.

**5. Modelo predictivo** — comparativa de 3 modelos (Logistic Regression, Random Forest, Gradient Boosting con GridSearchCV).

**6. Pipeline productivo** — `train_model.py` entrena y serializa el modelo con `joblib`; `predict_attrition.py` recibe un CSV de empleados y genera un reporte de riesgo clasificado en ALTO/MEDIO/BAJO.

## Hallazgo principal — Análisis de cohortes

| Antigüedad | Tasa de rotación | N |
|------------|-------------------|---|
| **0–2 años** | **28.9%** | 298 |
| 3–5 años | 13.8% | 434 |
| 6–10 años | 12.3% | 448 |
| 11–20 años | 6.7% | 180 |
| 20+ años | 12.1% | 66 |

**Casi 1 de cada 3 empleados nuevos abandona la empresa en sus primeros 2 años** — casi el doble que el promedio general (16.1%). Este es el hallazgo de mayor impacto de negocio: el presupuesto de retención debería concentrarse en el período de onboarding y los primeros 24 meses, no distribuirse uniformemente.

## Otros hallazgos

| # | Hallazgo | Recomendación |
|---|----------|---------------|
| 1 | Empleados **solteros** rotan más que casados | Programas de integración social y comunidad |
| 2 | **Overtime** está asociado a mayor rotación | Auditar carga de trabajo; compensar horas extra |
| 3 | **Sales** y roles técnicos lideran rotación | Revisar estructura salarial y plan de carrera |
| 4 | **Viajes frecuentes** elevan la rotación | Política de compensación por viaje y flexibilidad |

## Comparativa de modelos

| Modelo | ROC-AUC | Recall (Rotó) | Precision (Rotó) | Observación |
|--------|---------|---------------|-------------------|-------------|
| **Logistic Regression** | 0.791 | **0.70** | 0.30 | Mejor recall — detecta más rotaciones reales |
| Random Forest | 0.792 | 0.40 | 0.47 | Mejor precision — menos falsas alarmas |
| Gradient Boosting (GridSearchCV) | 0.786 | 0.19 | 0.56 | Muy conservador — no apto para detección |

**Recomendación:** para RRHH, **Logistic Regression** es preferible a pesar de su AUC similar al Random Forest, porque el costo de no detectar una rotación (pérdida de talento, costo de reemplazo) suele ser mayor que el de una falsa alarma (ofrecer retención a quien no la necesitaba). Además, su interpretabilidad permite explicar a un director de RRHH exactamente por qué un empleado fue marcado como riesgo.

GridSearchCV sobre Gradient Boosting encontró como mejores parámetros: `{'learning_rate': 0.1, 'max_depth': 5, 'min_samples_leaf': 5, 'n_estimators': 200}` — pero el modelo resultante es el más conservador de los tres (recall de solo 19%), lo que confirma que un mayor ajuste de hiperparámetros no garantiza el modelo más útil para el caso de negocio.

## Pipeline de producción

```bash
python train_model.py
python predict_attrition.py --input data/WA_Fn-UseC_-HR-Employee-Attrition.csv
```

Genera `outputs/reporte_riesgo.csv` con cada empleado clasificado por nivel de riesgo ( ALTO /  MEDIO /  BAJO), ordenado de mayor a menor probabilidad de rotación.

## Próximos pasos
- Implementar el pipeline en un flujo automatizado de RRHH con alertas
- Enriquecer con datos de encuestas de clima organizacional
- Ajuste de umbral de decisión para optimizar el trade-off precision/recall según el costo operativo real
