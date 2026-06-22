# Multi-Asset Portfolio Optimization (Markowitz)

Optimización de portafolio en dos capas usando Modern Portfolio Theory: 16 acciones del S&P 500 optimizadas primero como bloque de equity, luego combinadas con activos alternativos (oro, plata, bonos, petróleo, Bitcoin ETF) para construir el portafolio final.

## Objetivo

Construir un portafolio institucional aplicando frontera eficiente, encontrar las asignaciones de Máximo Sharpe y Mínima Varianza en cada capa, y evaluar el perfil de riesgo del portafolio final con métricas de Risk Management.

## Stack técnico

`Python` `yfinance` `SQLite3` `scipy.optimize` `Modern Portfolio Theory` `VaR/CVaR`

## Estructura

```
06-markowitz-portfolio/
├── markowitz_portfolio.ipynb
├── data/
│   ├── portfolio_prices.csv
│   └── portfolio.db
└── outputs/
```

## Contenido del análisis

**1. Web Scraping** — descarga con `yfinance` de 16 acciones (Tech, Finance, Health, Energy, Consumer) y 5 activos alternativos (GLD, SLV, TLT, USO, IBIT) para el período 2019-2024.

**2. Almacenamiento en SQLite3** — base de datos con 3 tablas (`daily_prices`, `asset_metadata`, `log_returns`), consultadas con SQL directo.

**3. EDA** — scatter Risk/Return por sector, precios normalizados, heatmap de correlaciones, cálculo de Beta respecto al NASDAQ 100 (en lugar de S&P 500, para evitar el sesgo de endogeneidad de las Magnificent 7).

**4. Capa 1 — Optimización de acciones** — frontera eficiente con 3,000 simulaciones Monte Carlo, portafolios de Máximo Sharpe y Mínima Varianza vía `scipy.optimize.minimize` (SLSQP).

**5. Capa 2 — Optimización multi-asset** — el portafolio óptimo de la Capa 1 se trata como un activo sintético y se combina con oro, plata, bonos, petróleo y Bitcoin ETF.

**6. Risk Analysis** — VaR histórico y paramétrico, CVaR, Maximum Drawdown, contribución de riesgo por activo, stress testing con 5 escenarios históricos.

## Universo de activos y métricas individuales (2019-2024)

| Ticker | Sector | Retorno anual | Volatilidad anual | Sharpe |
|--------|--------|----------------|---------------------|--------|
| NVDA | Technology | 61.93% | 51.60% | 1.200 |
| TSLA | Consumer | 50.22% | 64.34% | 0.780 |
| AAPL | Technology | 31.76% | 30.85% | 1.029 |
| MSFT | Technology | 24.98% | 29.03% | 0.860 |
| WMT | Consumer | 19.44% | 21.43% | 0.907 |
| JPM | Finance | 17.63% | 30.59% | 0.576 |

NVDA dominó el período con retornos extremos (outlier). Tecnología lidera en retorno pero también concentra la mayor volatilidad del universo.

**Beta promedio por sector (vs NASDAQ 100):**

| Sector | Beta |
|--------|------|
| Technology | 1.195 |
| Consumer | 0.977 |
| Finance | 0.698 |
| Energy | 0.495 |
| Health | 0.381 |

## Capa 1 — Portafolios óptimos de acciones

| Métrica | Max Sharpe | Min Varianza |
|---------|-----------|--------------|
| Retorno anual | 39.34% | 10.75% |
| Volatilidad anual | 28.67% | 15.82% |
| Sharpe Ratio | 1.233 | 0.427 |

**Pesos del portafolio Max Sharpe:** WMT (40.0%), NVDA (37.7%), AAPL (13.8%), TSLA (7.0%), GS (1.5%) — el optimizador concentra el capital en pocos activos de alto Sharpe individual, respetando el límite de 40% por posición.

## Capa 2 — Portafolio multi-asset final (2024)

| Métrica | Max Sharpe | Min Varianza |
|---------|-----------|--------------|
| Retorno anual | 51.93% | 14.03% |
| Volatilidad anual | 16.50% | 9.71% |
| Sharpe Ratio | 2.904 | 1.033 |

**Pesos del portafolio final (Max Sharpe):** Equity L1 (58.0%), Oro/GLD (37.9%), Bitcoin ETF/IBIT (4.1%) — plata, bonos y petróleo recibieron peso óptimo de 0%.

La incorporación de activos alternativos **mejora dramáticamente el Sharpe Ratio** (de 1.233 en Capa 1 a 2.904 en Capa 2) mientras **reduce la volatilidad** (de 28.67% a 16.50%) — el oro actúa como diversificador efectivo frente al bloque de equity concentrado en tecnología.

## Risk Analysis del portafolio final

| Métrica | Valor |
|---------|-------|
| Retorno diario promedio | 0.206% |
| Volatilidad diaria | 1.040% |
| VaR 95% histórico | -1.67% ($167 por cada $10,000) |
| VaR 99% histórico | -2.51% ($251 por cada $10,000) |
| CVaR 95% | -2.20% |
| CVaR 99% | -2.91% |
| VaR 95% paramétrico | -1.50% |
| Maximum Drawdown (2024) | -10.2% |

**Contribución de riesgo por activo** (no proporcional al peso): Equity L1 con 58% del peso aporta el 77.1% del riesgo total; GLD con 37.9% del peso solo aporta el 17.1% del riesgo — confirmando que el oro diversifica de forma efectiva. Bitcoin ETF, con apenas 4.1% de peso, contribuye 5.8% al riesgo — su alta volatilidad individual se nota incluso en una posición pequeña.

## Stress Testing — Portafolio de $100,000

| Escenario | Caída estimada | Valor final |
|-----------|------------------|--------------|
| COVID Crash (Mar 2020) | -34.0% | $66,000 |
| Crypto Winter (Nov 2022) | -25.0% | $75,000 |
| Fed Rate Hike (2022) | -19.0% | $81,000 |
| Silicon Valley Bank (Mar 2023) | -8.0% | $92,000 |
| Flash Crash Yen (Aug 2024) | -6.0% | $94,000 |

## Próximos pasos
- Rebalanceo periódico (mensual/trimestral) con backtesting fuera de muestra
- Optimización con restricción de CVaR en lugar de varianza
- Análisis de sensibilidad a cambios en la tasa libre de riesgo
- Extender el período de Capa 2 una vez que IBIT acumule más historia de precios
