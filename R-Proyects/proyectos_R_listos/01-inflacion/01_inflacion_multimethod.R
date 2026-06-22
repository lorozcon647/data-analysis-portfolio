# ══════════════════════════════════════════════════════════════════════════════
# Proyección de la Tasa de Inflación en México
# Comparativa de 4 métodos: Regresión Lineal, SVM (con tuning), K-Means, ARIMA
# ══════════════════════════════════════════════════════════════════════════════
#
# Dataset: INFLACION.csv — variables macroeconómicas anuales de México
#   Año, PIB, Crecimiento_PIB, TIIE, CETES, INPC, Tasa de Inflación (target)
#
# Objetivo: comparar distintos enfoques (regresión clásica, ML, clustering,
# series de tiempo) para modelar y proyectar la inflación anual.

# ── 1. Librerías ────────────────────────────────────────────────────────────────
library(ggplot2)
library(dplyr)
library(kernlab)   # SVM (ksvm)
library(caret)     # Validación cruzada
library(forecast)  # ARIMA

# ── 2. Carga de datos ────────────────────────────────────────────────────────────
# Ruta relativa — coloca INFLACION.csv en una carpeta data/ junto a este script
inflacion <- read.csv("data/INFLACION.csv")

# R convierte automáticamente nombres con espacios/paréntesis/acentos a puntos
# al leer el CSV (check.names=TRUE por defecto). Renombramos a nombres simples
# y consistentes para todo el script.
colnames(inflacion) <- c("Año", "PIB", "Crecimiento_PIB", "TIIE", "CETES", "INPC", "Inflacion_target")

# ── 3. Exploración inicial ───────────────────────────────────────────────────────
str(inflacion)
summary(inflacion)

# Visualización de la serie histórica
ggplot(data = inflacion, aes(x = Año, y = Inflacion_target)) +
  geom_point(color = "blue") +
  geom_line(color = "red") +
  labs(title = "Tasa de Inflación Anual — México (1996-2023)",
       x = "Año", y = "Tasa de Inflación (%)") +
  theme_minimal()

# ── 4. Preparación de datos ──────────────────────────────────────────────────────
# Removemos 'Año' para el modelado (no es feature predictiva, es índice temporal)
testSet <- select(inflacion, -Año)
colnames(testSet) <- c("PIB", "Crecimiento_PIB", "TIIE", "CETES", "INPC", "Inflacion")

# Normalización Min-Max — necesaria para SVM y K-Means, no afecta a Regresión Lineal
normalize <- function(x, min, max) (x - min) / (max - min)
desnormalize <- function(x, min, max) x * (max - min) + min

min_vals <- apply(testSet, 2, min)
max_vals <- apply(testSet, 2, max)
testSet_norm <- as.data.frame(mapply(normalize, testSet, min_vals, max_vals))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 1 — Regresión Lineal
# ══════════════════════════════════════════════════════════════════════════════
model_lm <- lm(Inflacion ~ ., data = testSet_norm)
print(summary(model_lm))

prediction_lm <- predict(model_lm, testSet_norm)
rmse_lm <- sqrt(mean((prediction_lm - testSet_norm$Inflacion)^2))
mae_lm  <- mean(abs(prediction_lm - testSet_norm$Inflacion))

cat("=== Regresión Lineal ===\n")
cat("RMSE: ", rmse_lm, "\n")
cat("MAE:  ", mae_lm,  "\n\n")


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 2 — SVM con búsqueda de hiperparámetros (Grid Search + CV)
# ══════════════════════════════════════════════════════════════════════════════
sigma_values  <- c(0.1, 0.5, 1, 2, 5)
degree_values <- c(1, 2, 3, 4)

best_sigma  <- NULL
best_degree <- NULL
best_rmse   <- Inf

# NOTA: train_control se define pero no se usa directamente en este grid search
# manual. Para una validación cruzada real habría que envolver el ksvm dentro
# de caret::train() — se deja como mejora pendiente (ver sección "Próximos pasos"
# en el README del proyecto).
train_control <- trainControl(method = "cv", number = 10)

for (sigma in sigma_values) {
  for (degree in degree_values) {
    model_svm_tmp <- ksvm(
      Inflacion ~ ., data = testSet_norm,
      type = "eps-svr", kernel = "anovadot",
      kpar = list(sigma = sigma, degree = degree)
    )
    pred_tmp  <- predict(model_svm_tmp, testSet_norm)
    rmse_tmp  <- sqrt(mean((pred_tmp - testSet_norm$Inflacion)^2))

    if (rmse_tmp < best_rmse) {
      best_rmse   <- rmse_tmp
      best_sigma  <- sigma
      best_degree <- degree
    }
  }
}

cat("=== SVM — Mejores hiperparámetros ===\n")
cat("Sigma:  ", best_sigma,  "\n")
cat("Degree: ", best_degree, "\n")
cat("RMSE:   ", best_rmse,   "\n\n")

# Modelo final con los mejores hiperparámetros encontrados
model_svm <- ksvm(
  Inflacion ~ ., data = testSet_norm,
  type = "eps-svr", kernel = "anovadot",
  kpar = list(sigma = best_sigma, degree = best_degree)
)
prediction_svm <- predict(model_svm, testSet_norm)
mae_svm <- mean(abs(prediction_svm - testSet_norm$Inflacion))
cat("MAE (SVM optimizado): ", mae_svm, "\n\n")


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 3 — K-Means Clustering (segmentación de regímenes macroeconómicos)
# ══════════════════════════════════════════════════════════════════════════════
data_cluster <- select(testSet_norm, -Inflacion)  # clustering sin ver el target

maxClusters <- 12
error <- rep(0, maxClusters)
for (i in 1:maxClusters) {
  set.seed(42)
  model_km <- kmeans(data_cluster, centers = i)
  error[i] <- sum(model_km$withinss)
}

# Elbow Plot — selección visual del número óptimo de clusters
elbow <- data.frame(Cluster = 1:maxClusters, Error = error)
ggplot(data = elbow, aes(x = Cluster, y = Error)) +
  geom_point(color = "blue") +
  geom_line(color = "red") +
  labs(title = "Elbow Plot — Número Óptimo de Clusters",
       x = "Número de Clusters", y = "Error Total (Within-SS)") +
  theme_minimal()

# Ajustar el número de clusters finales según el codo observado en la gráfica
optimalClusters <- 4
set.seed(42)
model_km_final <- kmeans(data_cluster, centers = optimalClusters)
inflacion$Cluster <- as.factor(model_km_final$cluster)

ggplot(inflacion, aes(x = Año, y = Inflacion_target, color = Cluster)) +
  geom_point(size = 2) +
  geom_line() +
  labs(title = "Regímenes Macroeconómicos Identificados por Clustering",
       x = "Año", y = "Tasa de Inflación (%)", color = "Cluster") +
  theme_minimal()


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 4 — ARIMA (Series de Tiempo)
# ══════════════════════════════════════════════════════════════════════════════
inflacion_ts <- ts(inflacion$Inflacion_target,
                   start = inflacion$Año[1], frequency = 1)

model_arima <- auto.arima(inflacion_ts)
print(summary(model_arima))

forecast_arima <- forecast(model_arima, h = 2)
print(forecast_arima)
plot(forecast_arima)


# ══════════════════════════════════════════════════════════════════════════════
# Proyección para datos nuevos (ej. 2024, datos truncados a septiembre)
# ══════════════════════════════════════════════════════════════════════════════
new_data <- data.frame(
  Año = 2024, PIB = 25191645.38, Crecimiento_PIB = 1.7,
  TIIE = 10.96, CETES = 10.4, INPC = -15.12911602, Inflacion = 4.99
)

# Actualizar max_vals de PIB si el nuevo dato supera el histórico
if (new_data$PIB > max_vals["PIB"]) max_vals["PIB"] <- new_data$PIB

new_data_norm <- data.frame(
  PIB             = normalize(new_data$PIB,             min_vals["PIB"],             max_vals["PIB"]),
  Crecimiento_PIB = normalize(new_data$Crecimiento_PIB, min_vals["Crecimiento_PIB"], max_vals["Crecimiento_PIB"]),
  TIIE            = normalize(new_data$TIIE,            min_vals["TIIE"],            max_vals["TIIE"]),
  CETES           = normalize(new_data$CETES,           min_vals["CETES"],           max_vals["CETES"]),
  INPC            = normalize(new_data$INPC,            min_vals["INPC"],            max_vals["INPC"])
)

new_data$Proyeccion_lm  <- desnormalize(predict(model_lm,  new_data_norm), min_vals["Inflacion"], max_vals["Inflacion"])
new_data$Proyeccion_svm <- desnormalize(predict(model_svm, new_data_norm), min_vals["Inflacion"], max_vals["Inflacion"])
new_data$Proyeccion_arima <- as.numeric(forecast_arima$mean[1])

cat("=== Proyecciones para 2024 ===\n")
print(new_data[c("Año", "Inflacion", "Proyeccion_lm", "Proyeccion_svm", "Proyeccion_arima")])
