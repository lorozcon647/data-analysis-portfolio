# ══════════════════════════════════════════════════════════════════════════════
# Análisis de Ventas de Videojuegos — Práctica de manipulación de datos con dplyr
# ══════════════════════════════════════════════════════════════════════════════
#
# Dataset: vgsales.csv — ventas de videojuegos por región (NA, EU, JP, Other, Global)
#
# Nota: este es uno de mis primeros ejercicios en R, lo incluyo en el portafolio
# para mostrar el punto de partida — manipulación básica de datos con dplyr,
# sin modelado estadístico ni Machine Learning.

library(dplyr)

# ── 1. Carga y diagnóstico inicial ───────────────────────────────────────────────
sales <- read.csv("data/vgsales.csv", stringsAsFactors = TRUE, na.strings = "N/A")

str(sales)
summary(sales)

# Revisar cuántos valores nulos tiene la columna Year
sales %>%
  select(Year) %>%
  is.na() %>%
  table()

# Eliminar filas con valores nulos
sales <- na.omit(sales)
cat("Filas tras limpieza:", nrow(sales), "\n\n")

# ── 2. Juego más vendido por región ──────────────────────────────────────────────
# Columnas 7 a 11 corresponden a NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales
for (i in 7:11) {
  column_name <- names(sales)[i]

  sales %>%
    slice_max(.[[column_name]]) %>%
    select(Name, all_of(column_name)) %>%
    print()
}

# ── 3. Ventas de Nintendo en Japón, 2000-2005 ─────────────────────────────────────
total_JP <- 0
for (i in 2000:2005) {
  total_JP <- total_JP + sales %>%
    filter(Year == i, Publisher == 'Nintendo') %>%
    pull(JP_Sales) %>%
    sum()
}
cat("Ventas de Nintendo en Japón (2000-2005):", total_JP, "millones\n\n")

# ── 4. Juegos publicados por plataforma ──────────────────────────────────────────
freq <- sales %>%
  pull(Platform) %>%
  table()

barplot(freq, las = 2, col = "light green", ylim = c(0, 2500),
        main = "Juegos Publicados por Plataforma",
        xlab = "Plataforma", ylab = "Número de Juegos")

# ── 5. Ventas de juegos de Acción en Norteamérica ─────────────────────────────────
ventas_accion_na <- sales %>%
  filter(Genre == 'Action') %>%
  pull(NA_Sales) %>%
  sum()
cat("Ventas de juegos de Acción en NA:", ventas_accion_na, "millones\n\n")

# ── 6. Ventas europeas por género, 2008-2019 ─────────────────────────────────────
sales %>%
  filter(Year >= 2008, Year <= 2019) %>%
  group_by(Genre) %>%
  summarise(EU_Total = sum(EU_Sales)) %>%
  print()

# ── 7. Verificación de consistencia: Global_Sales vs suma de regiones ────────────
sales <- sales %>%
  mutate(Total_Sales = NA_Sales + EU_Sales + JP_Sales + Other_Sales)

cat("¿Global_Sales coincide con la suma de regiones?\n")
print(table(sales$Global_Sales == sales$Total_Sales))
cat("Diferencia absoluta total:", sum(abs(sales$Global_Sales - sales$Total_Sales)), "\n")
cat("Diferencia absoluta máxima:", max(abs(sales$Global_Sales - sales$Total_Sales)), "\n")
