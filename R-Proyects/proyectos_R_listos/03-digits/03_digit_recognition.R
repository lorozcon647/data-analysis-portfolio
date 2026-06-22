# ══════════════════════════════════════════════════════════════════════════════
# Reconocimiento de Dígitos Manuscritos (estilo MNIST)
# Comparativa Árbol de Decisión vs SVM con train/validation/test split
# ══════════════════════════════════════════════════════════════════════════════
#
# Dataset: digits.csv — imágenes de 28x28 píxeles (784 features) de dígitos
# manuscritos del 0 al 9, cada fila es una imagen aplanada + columna Class

# ── 1. Librerías ────────────────────────────────────────────────────────────────
library(rpart)
library(caret)
library(kernlab)
library(rpart.plot)

# ── 2. Carga de datos ────────────────────────────────────────────────────────────
digits <- read.csv("data/digits.csv", stringsAsFactors = TRUE)

# ── 3. División en Train / Validation / Test ─────────────────────────────────────
# 60% entrenamiento, 20% validación (selección de modelo), 20% prueba (evaluación final)
set.seed(123)

index1 <- createDataPartition(digits$Class, p = 0.60, list = FALSE)
trainingSet <- digits[index1, ]

rest_digits <- digits[-index1, ]
index2 <- createDataPartition(rest_digits$Class, p = 0.50, list = FALSE)
validationSet <- rest_digits[index2, ]
testSet       <- rest_digits[-index2, ]

cat("Train:      ", nrow(trainingSet),   "imágenes\n")
cat("Validation: ", nrow(validationSet), "imágenes\n")
cat("Test:       ", nrow(testSet),       "imágenes\n\n")

# ── 4. Visualización de un dígito aleatorio ──────────────────────────────────────
id <- floor(runif(1, min = 1, max = nrow(trainingSet) + 1))
digit <- matrix(trainingSet[id, 2:785], nrow = 28, byrow = TRUE)
digit <- apply(digit, 2, as.numeric)
digit <- t(apply(digit, 2, rev))
image(1:28, 1:28, digit, col = gray((0:255)/255), xlab = "", ylab = "",
      main = paste("Dígito de ejemplo — Clase:", trainingSet$Class[id]))

# ── 5. Función de evaluación de accuracy ─────────────────────────────────────────
evaluate <- function(confusion_matrix) {
  accuracy <- 0
  for (i in 1:nrow(confusion_matrix)) {
    accuracy <- accuracy + confusion_matrix[i, i]
  }
  accuracy / sum(confusion_matrix)
}


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 1 — Árbol de Decisión
# ══════════════════════════════════════════════════════════════════════════════
model_rpart <- rpart(Class ~ ., data = trainingSet,
                     method = 'class', minsplit = 2, model = TRUE)

prediction_rpart <- predict(model_rpart, validationSet, type = 'class')
confusion_rpart  <- table(actual = validationSet$Class, predicted = prediction_rpart)
precision_rpart  <- evaluate(confusion_rpart)

cat("=== Árbol de Decisión (validación) ===\n")
cat("Accuracy: ", round(precision_rpart, 4), "\n\n")


# ══════════════════════════════════════════════════════════════════════════════
# MÉTODO 2 — SVM (kernel RBF)
# ══════════════════════════════════════════════════════════════════════════════
model_svm <- ksvm(Class ~ ., data = trainingSet,
                  type = "C-svc", kernel = "rbfdot")

prediction_svm <- predict(model_svm, validationSet)
confusion_svm  <- table(actual = validationSet$Class, predicted = prediction_svm)
precision_svm  <- evaluate(confusion_svm)

cat("=== SVM RBF (validación) ===\n")
cat("Accuracy: ", round(precision_svm, 4), "\n\n")


# ══════════════════════════════════════════════════════════════════════════════
# Selección del mejor modelo y evaluación final en TEST
# ══════════════════════════════════════════════════════════════════════════════
# Se elige el modelo con mejor accuracy en validación (SVM en este caso) y se
# evalúa UNA SOLA VEZ sobre el conjunto de test — nunca antes de esta decisión,
# para evitar contaminar la evaluación final.
prediction_final <- predict(model_svm, testSet)
confusion_final  <- table(actual = testSet$Class, predicted = prediction_final)
precision_final  <- evaluate(confusion_final)

cat("=== Modelo Final (SVM) — Evaluación en TEST ===\n")
cat("Accuracy: ", round(precision_final, 4), "\n")
print(confusion_final)
