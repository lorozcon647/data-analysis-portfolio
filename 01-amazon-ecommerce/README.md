#  Amazon India E-Commerce Sales Analysis

Análisis completo de 128,975 transacciones de ventas de Amazon India (2022) — 121,180 órdenes tras limpieza — con enfoque en patrones de venta, predicción de cancelaciones y segmentación de productos.

##  Objetivo

Identificar patrones de ventas, drivers de cancelaciones y segmentos de productos para apoyar decisiones comerciales.

##  Stack técnico

`Python` `pandas` `SQL (DuckDB)` `scikit-learn` `K-Means` `PCA` `matplotlib/seaborn`

##  Estructura

```
01-amazon-ecommerce/
├── amazon_ecommerce_analysis.ipynb
├── data/
│   ├── Amazon_Sale_Report.csv
│   ├── International_sale_Report.csv
│   └── Sale_Report.csv
└── outputs/
```

##  Contenido del análisis

**1. Limpieza de datos** — manejo de nulos, parseo de fechas, estandarización de columnas, creación de variable target para cancelaciones.

**2. EDA** — tendencias temporales de ventas, ingresos por categoría, distribución geográfica por estado, tasa de cancelación por categoría, comparativa Amazon Fulfillment vs Merchant y B2B vs B2C.

**3. SQL con DuckDB** — queries con CTEs y window functions (`RANK()`) para rankings de categorías por mes, comparativa de tallas entre mercado doméstico e internacional.

**4. Modelo de clasificación de cancelaciones** — comparativa Logistic Regression vs Random Forest, con análisis de **ajuste de umbral de decisión** (umbral óptimo en 0.46 en lugar del default 0.5) para balancear precision/recall según el costo de negocio de cada tipo de error.

**5. Clustering** — segmentación de combinaciones categoría×talla con K-Means (k=4) y visualización con PCA, identificando segmentos de alto volumen/ingreso vs alto riesgo de cancelación.

##  Hallazgos principales

| # | Hallazgo | Implicación de negocio |
|---|----------|------------------------|
| 1 | **Set y Kurta** son las categorías dominantes en volumen e ingreso | Priorizar disponibilidad y campañas en estas categorías |
| 2 | **Maharashtra, Karnataka y Telangana** concentran ~43.5% del revenue | Enfocar logística y marketing en estos 3 estados |
| 3 | Tasa de cancelación global ~8.9% (10,766 de 121,180 órdenes) | Justifica validación de pedidos o depósito anticipado |
| 4 | **Amazon Fulfillment** genera la mayoría del ingreso vs Merchant | Incentivos para que merchants migren a FBA |
| 5 | El cumplimiento y la cantidad de la orden son los predictores más fuertes de cancelación | Alertas automáticas en órdenes de alto valor sin historial |

##  Modelos — Logistic Regression vs Random Forest

| Modelo | ROC-AUC | Precision (Cancelada) | Recall (Cancelada) | Observación |
|--------|---------|------------------------|---------------------|-------------|
| Logistic Regression (umbral=0.46) | 0.820 | 0.52 | 0.51 | Balance moderado — detecta ~51% de cancelaciones reales |
| Random Forest | 0.830 | 1.00 | 0.48 | Mayor AUC, pero conservador — cuando alerta, casi siempre acierta |

**Nota metodológica:** ambos modelos tienen capacidad discriminativa similar (AUC ~0.82–0.83), pero comportamientos distintos. Random Forest con umbral default (0.5) es extremadamente preciso (100%) pero pierde la mitad de las cancelaciones reales (recall 48%). Logistic Regression con umbral ajustado (0.46, encontrado vía análisis de la curva Precision-Recall) sacrifica algo de precisión a cambio de mantener un recall similar con menor riesgo de falsas alarmas masivas. La elección final depende del costo operativo: si una cancelación no detectada es más costosa que una falsa alarma, se prefiere maximizar recall ajustando el umbral de cualquiera de los dos modelos.

##  Próximos pasos
- Integrar datos de devoluciones para mejorar el modelo de cancelación
- Desarrollar dashboard interactivo en Power BI con los KPIs identificados
- Aplicar análisis de cohortes para medir retención de clientes B2B
