# ══════════════════════════════════════════════════════════════════════════════
# JSSP — Selección Óptima de Método Heurístico (Job Shop Scheduling Problem)
# Comparativa de 6 algoritmos de clasificación + análisis de costo
# ══════════════════════════════════════════════════════════════════════════════
#
# Contexto: en problemas de programación de trabajos (JSSP), distintos métodos
# heurísticos (T1, T2, T3) producen distintos costos según las características
# de cada instancia del problema. En lugar de aplicar siempre el mismo método,
# entrenamos un clasificador para predecir CUÁL método dará el menor costo
# para una instancia dada — antes de resolverla.
#
# Dataset: JSSP-Entrenamiento(2021).csv / JSSP-Prueba(2021).csv
#   Features describiendo cada instancia + columnas T1, T2, T3 (costo de cada método)

# ── 1. Librerías ────────────────────────────────────────────────────────────────
library(dplyr)       # Manipulación de datos
library(caret)       # confusionMatrix y herramientas de ML
library(OneR)        # Algoritmo One Rule
library(RWeka)       # JRip (algoritmo Ripper)
library(rpart)       # Árboles de decisión
library(rpart.plot)  # Visualización de árboles
library(kernlab)     # SVM
library(e1071)       # Naive Bayes
library(neuralnet)   # Redes neuronales

# ── 2. Carga de datos ────────────────────────────────────────────────────────────
trainingSet <- read.csv("data/JSSP-Entrenamiento(2021).csv", stringsAsFactors = TRUE)
testSet     <- read.csv("data/JSSP-Prueba(2021).csv",        stringsAsFactors = TRUE)

# ── 3. Construcción de la variable target ────────────────────────────────────────
# BEST_METHOD = el método (T1/T2/T3) con menor costo para cada instancia.
# Una vez calculado, eliminamos T1/T2/T3 como features para no hacer "data leakage"
# (el modelo no debe ver los costos reales, solo las características de la instancia)
METHOD <- as.factor(c('T1', 'T2', 'T3'))

trainingSet <- trainingSet %>%
  mutate(BEST_METHOD = apply(select(., T1, T2, T3), 1, function(x) METHOD[which.min(x)])) %>%
  select(., -T1, -T2, -T3)

testSet_features <- testSet %>%
  mutate(BEST_METHOD = apply(select(., T1, T2, T3), 1, function(x) METHOD[which.min(x)])) %>%
  select(., -T1, -T2, -T3)


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 1 — OneR (One Rule)
# ══════════════════════════════════════════════════════════════════════════════
model_OneR <- OneR::OneR(BEST_METHOD ~ ., data = trainingSet)
print(model_OneR)

prediction_OneR <- predict(model_OneR, testSet_features)
cat("\n=== OneR ===\n")
print(confusionMatrix(prediction_OneR, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 2 — JRip (Reglas de Ripper)
# ══════════════════════════════════════════════════════════════════════════════
model_JRip <- JRip(BEST_METHOD ~ ., data = trainingSet)
print(model_JRip)

prediction_JRip <- predict(model_JRip, testSet_features)
cat("\n=== JRip ===\n")
print(confusionMatrix(prediction_JRip, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 3 — Árbol de Decisión (rpart)
# ══════════════════════════════════════════════════════════════════════════════
model_rpart <- rpart(BEST_METHOD ~ ., data = trainingSet,
                     method = 'class', minsplit = 2, model = TRUE)

prediction_rpart <- predict(model_rpart, testSet_features, type = 'class')
cat("\n=== Árbol de Decisión ===\n")
print(confusionMatrix(prediction_rpart, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 4 — SVM (kernel ANOVA)
# ══════════════════════════════════════════════════════════════════════════════
model_svm <- ksvm(BEST_METHOD ~ ., data = trainingSet,
                  type = "C-svc", kernel = "anovadot")

prediction_svm <- predict(model_svm, testSet_features)
cat("\n=== SVM ===\n")
print(confusionMatrix(prediction_svm, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 5 — Naive Bayes
# ══════════════════════════════════════════════════════════════════════════════
model_Bayes <- naiveBayes(BEST_METHOD ~ ., data = trainingSet)

prediction_Bayes <- predict(model_Bayes, testSet_features)
cat("\n=== Naive Bayes ===\n")
print(confusionMatrix(prediction_Bayes, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 6 — Red Neuronal
# ══════════════════════════════════════════════════════════════════════════════
model_neuralnet <- neuralnet(BEST_METHOD ~ ., data = trainingSet,
                              hidden = c(7, 5, 3), act.fct = "logistic",
                              stepmax = 1e8)

prediction_neural <- predict(model_neuralnet, testSet_features)
predicted_classes  <- apply(prediction_neural, 1, which.max)
predicted_classes[predicted_classes == 1] <- "T1"
predicted_classes[predicted_classes == 2] <- "T2"
predicted_classes[predicted_classes == 3] <- "T3"
predicted_classes <- as.factor(predicted_classes)

cat("\n=== Red Neuronal ===\n")
print(confusionMatrix(predicted_classes, testSet_features$BEST_METHOD))


# ══════════════════════════════════════════════════════════════════════════════
# Evaluación de negocio — Costo real de aplicar el mejor modelo (SVM)
# ══════════════════════════════════════════════════════════════════════════════
# Aquí sí usamos el testSet original (con T1/T2/T3 visibles) para calcular
# cuánto costaría en la práctica seguir las recomendaciones del modelo,
# comparado con el costo de siempre usar el método T2 fijo.
testSet$PREDICTION <- prediction_svm

create.cost <- function(values) {
  if (values[1] == "T1") {
    as.numeric(values[2])
  } else if (values[1] == "T2") {
    as.numeric(values[3])
  } else {
    as.numeric(values[4])
  }
}

testSet$COST <- select(testSet, PREDICTION, T1, T2, T3) %>%
  apply(1, create.cost)

cat("\n=== Comparativa de Costos ===\n")
cat("Costo total usando siempre T2 (método fijo):  ", sum(testSet$T2),  "\n")
cat("Costo total usando el modelo SVM (dinámico):  ", sum(testSet$COST), "\n")
cat("Ahorro:                                       ",
    sum(testSet$T2) - sum(testSet$COST), "\n")

boxplot(testSet$T2, testSet$COST,
        names = c("Método fijo (T2)", "Modelo SVM"),
        main = "Comparación de Costos: Método Fijo vs Modelo Predictivo",
        ylab = "Costo")
