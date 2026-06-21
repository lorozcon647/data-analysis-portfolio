# Bitcoin Quantitative Risk Analysis (2014–2026)

Análisis cuantitativo de riesgo financiero sobre 11 años de datos históricos de Bitcoin (4,279 días de trading), desde la perspectiva de un Risk Manager — VaR, simulación Monte Carlo con modelos estocásticos comparados, stress testing y predicción de dirección de precio con Deep Learning.

## Objetivo

Aplicar metodologías de risk management institucional (VaR, CVaR, Maximum Drawdown, Monte Carlo) a un activo de alta volatilidad, y evaluar si la dirección del precio es predecible con técnicas de Machine Learning y Deep Learning.

## Stack técnico

`Python` `PyTorch` `scipy.stats` `Monte Carlo` `Merton Jump Diffusion` `LSTM` `Random Forest` `Gradient Boosting`

## Estructura

```
03-bitcoin-quant/
├── bitcoin_quant_analysis.ipynb
├── data/
│   └── bitcoin_dataset.csv
└── outputs/
```

## Contenido del análisis

**1. Preparación de datos** — 4,279 días de trading (2014-09-18 a 2026-06-05), retornos logarítmicos, medias móviles (21/50/200), volatilidad rolling anualizada con √365 (Bitcoin opera 365 días/año).

**2. Análisis de retornos** — retornos anuales y Sharpe Ratio por año con tasa libre de riesgo dinámica (10Y Treasury histórico, no fija), distribución de retornos vs normal (QQ Plot), confirmación de fat tails.

**3. Risk Management** — VaR histórico y paramétrico (95%/99%), CVaR (Expected Shortfall), Maximum Drawdown histórico.

**4. Simulación Monte Carlo** — comparativa GBM vs Merton Jump Diffusion con parámetros de salto **calibrados empíricamente** (no asumidos) usando umbral de 3σ sobre los datos históricos.

**5. Stress Testing** — impacto de 5 crashes históricos (2018, COVID 2020, 2021, 2022, 2025-26) aplicados al precio actual.

**6. Predicción de dirección** — comparativa de Random Forest, Gradient Boosting y **LSTM en PyTorch** (entrenado en GPU) sobre 20 features técnicos, evaluando la Hipótesis de Mercados Eficientes.

## Hallazgos — Risk Management

| Métrica | Valor | Interpretación |
|---------|-------|----------------|
| Retorno medio diario | 0.114% | ~28% anual compuesto |
| Volatilidad diaria | 3.515% | ~67% anualizada |
| VaR 95% (1 día) | -5.43% | $543 de pérdida por cada $10,000 invertidos |
| VaR 99% (1 día) | -10.56% | $1,056 por cada $10,000 invertidos |
| CVaR 95% (1 día) | -8.60% | Pérdida promedio en el peor 5% de días |
| CVaR 99% (1 día) | -14.38% | Pérdida promedio en el peor 1% de días |
| VaR 99% paramétrico | -8.06% | Subestima el riesgo real en ~2.5pp — confirma fat tails |
| Maximum Drawdown | -83.4% | Mayor caída histórica desde un pico |
| Kurtosis / Skewness | 11.80 / -0.71 | Colas mucho más pesadas que una normal, sesgo negativo |

**Mejores y peores años (Sharpe Ratio con tasa libre de riesgo dinámica):**

| Año | Retorno anual | Sharpe |
|-----|---------------|--------|
| 2017 | +185.5% | 2.34 |
| 2023 | +64.7% | 1.70 |
| 2020 | +96.0% | 1.48 |
| 2018 | -91.9% | -1.39 |
| 2014 | -85.6% | -1.67 |
| 2026 (parcial) | -58.5% | -1.47 |

## Simulación Monte Carlo — GBM vs Merton Jump Diffusion (30 días)

Parámetros de Merton calibrados empíricamente: λ=0.0178 (~6.5 saltos/año), μⱼ=-2.31%, σⱼ=14.68% — identificados sobre 76 días históricos con retornos superiores a 3σ.

| Métrica | GBM | Merton Jump |
|---------|-----|-------------|
| VaR 95% | -26.34% | -30.69% |
| VaR 99% | -35.45% | -41.27% |
| CVaR 95% | -32.22% | -37.02% |
| CVaR 99% | -40.00% | -45.87% |
| Kurtosis de retornos | 0.012 | 0.554 |
| Percentil 95% precio | $84,912 | $88,513 |

Merton es más conservador en pérdidas extremas (saltos con sesgo negativo) pero también genera escenarios alcistas más extremos en el percentil 95% — los saltos operan en ambas direcciones. La distribución de retornos simulada por Merton se aproxima más al histórico real (kurtosis 0.554 vs 0.012 de GBM, comparado con 1.557 del histórico real a 30 días).

## Stress Testing

| Escenario | Caída real | Precio resultante (sobre $60,922 actual) |
|-----------|-----------|------------------------------------------|
| Crash 2018 | -83.1% | $10,302 |
| Crash 2022 | -75.7% | $14,798 |
| Crash May 2021 | -48.5% | $31,379 |
| COVID Mar 2020 | -45.5% | $33,184 |
| Crash 2025-2026 | -10.2% | $54,713 |

## Predicción de dirección — Random Forest vs Gradient Boosting vs LSTM

| Modelo | ROC-AUC | vs Azar |
|--------|---------|---------|
| Random Forest | 0.473 | -0.027 |
| Gradient Boosting | 0.454 | -0.046 |
| **LSTM (PyTorch, 217K parámetros)** | **0.516** | **+0.016** |

El LSTM es el único modelo que supera marginalmente el azar, aunque la loss de entrenamiento cae consistentemente (0.69 → 0.52) mientras el AUC de validación se mantiene plano alrededor de 0.50 — la firma clásica de un modelo que aprende patrones del training set que no generalizan.

**Conclusión:** ningún modelo —ni clásico ni de Deep Learning— supera significativamente AUC=0.50 usando únicamente datos de precio histórico. Esto confirma empíricamente la **Hipótesis de Mercados Eficientes en forma débil** para Bitcoin: los precios pasados no contienen información suficiente para predecir la dirección futura. Mejorar esto requeriría features externos (sentimiento en redes, datos on-chain, variables macro como DXY y tasas de la Fed).

## Próximos pasos
- Incorporar features on-chain (hash rate, direcciones activas, flujos de exchanges)
- Análisis de correlación con S&P 500, oro y DXY
- Modelo Heston de volatilidad estocástica con datos de opciones de Bitcoin
- Optimización de portafolio incluyendo Bitcoin como activo alternativo (ver proyecto Markowitz)
