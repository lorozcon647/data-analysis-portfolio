"""
predict_attrition.py
────────────────────
Genera reporte de riesgo de rotación para un conjunto de empleados.

Uso:
    python predict_attrition.py --input data/empleados_nuevos.csv
    python predict_attrition.py --input data/WA_Fn-UseC_-HR-Employee-Attrition.csv

El reporte se guarda en outputs/reporte_riesgo.csv
"""

import pandas as pd
import numpy as np
import joblib
import json
import argparse
import os
from datetime import datetime

# ── Configuración ─────────────────────────────────────────────────────────────
MODEL_PATH   = 'modelo_lr.pkl'
ENCODER_PATH = 'encoders.pkl'
META_PATH    = 'model_meta.json'
OUTPUT_PATH  = 'outputs/reporte_riesgo.csv'


def cargar_modelo():
    """Carga modelo, encoders y metadata."""
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(
            " No se encontró el modelo. Ejecuta primero: python train_model.py")

    model    = joblib.load(MODEL_PATH)
    encoders = joblib.load(ENCODER_PATH)

    with open(META_PATH) as f:
        meta = json.load(f)

    return model, encoders, meta


def clasificar_riesgo(proba):
    """Clasifica probabilidad en nivel de riesgo."""
    if proba >= 0.65:
        return 'ALTO '
    elif proba >= 0.46:
        return 'MEDIO '
    else:
        return 'BAJO '


def predecir(df_input, model, encoders, meta):
    """Genera predicciones de riesgo para cada empleado."""
    df = df_input.copy()

    # Codificar categóricas
    for col in meta['cat_cols']:
        if col in df.columns:
            le = encoders[col]
            df[col] = le.transform(df[col].astype(str))

    # Verificar features disponibles
    features_disponibles = [f for f in meta['features'] if f in df.columns]
    features_faltantes   = [f for f in meta['features'] if f not in df.columns]

    if features_faltantes:
        print(f"  Features faltantes (se rellenan con 0): {features_faltantes}")
        for f in features_faltantes:
            df[f] = 0

    X = df[meta['features']]

    # Predicción
    probabilidades = model.predict_proba(X)[:, 1]
    nivel_riesgo   = [clasificar_riesgo(p) for p in probabilidades]

    return probabilidades, nivel_riesgo


def generar_reporte(df_original, probabilidades, nivel_riesgo):
    """Construye y guarda el reporte final."""
    os.makedirs('outputs', exist_ok=True)

    # Columnas de identificación si existen
    id_cols = ['EmployeeNumber', 'Age', 'Department', 'JobRole',
               'MonthlyIncome', 'YearsAtCompany', 'OverTime']
    id_cols = [c for c in id_cols if c in df_original.columns]

    reporte = df_original[id_cols].copy()
    reporte['Probabilidad_Rotacion'] = (probabilidades * 100).round(1)
    reporte['Nivel_Riesgo']          = nivel_riesgo
    reporte['Fecha_Prediccion']      = datetime.now().strftime('%Y-%m-%d')

    # Ordenar por riesgo descendente
    reporte = reporte.sort_values('Probabilidad_Rotacion', ascending=False)

    reporte.to_csv(OUTPUT_PATH, index=False)
    return reporte


def imprimir_resumen(reporte):
    """Imprime resumen ejecutivo en consola."""
    total = len(reporte)
    alto  = (reporte['Nivel_Riesgo'] == 'ALTO ').sum()
    medio = (reporte['Nivel_Riesgo'] == 'MEDIO ').sum()
    bajo  = (reporte['Nivel_Riesgo'] == 'BAJO ').sum()

    print("\n" + "="*50)
    print("       REPORTE DE RIESGO DE ROTACIÓN")
    print("="*50)
    print(f"  Total empleados analizados: {total:,}")
    print(f"   Riesgo ALTO  (≥65%):    {alto:,}  ({alto/total*100:.1f}%)")
    print(f"   Riesgo MEDIO (46-64%):  {medio:,}  ({medio/total*100:.1f}%)")
    print(f"   Riesgo BAJO  (<46%):    {bajo:,}  ({bajo/total*100:.1f}%)")
    print("="*50)
    print(f"\n Top 10 empleados con mayor riesgo:")
    print(reporte.head(10).to_string(index=False))
    print(f"\n Reporte completo guardado en: {OUTPUT_PATH}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Predicción de rotación de empleados')
    parser.add_argument('--input', required=True, help='Ruta al CSV de empleados')
    args = parser.parse_args()

    print("── Cargando modelo ─────────────────────────────")
    model, encoders, meta = cargar_modelo()
    print(f"   ROC-AUC del modelo: {meta['auc']}")
    print(f"   Umbral de decisión: {meta['umbral']}")

    print(f"\n── Cargando datos: {args.input} ─────────────────")
    df_input = pd.read_csv(args.input)
    print(f"   Empleados a analizar: {len(df_input):,}")

    print("\n── Generando predicciones ──────────────────────")
    probabilidades, nivel_riesgo = predecir(df_input, model, encoders, meta)

    print("\n── Generando reporte ───────────────────────────")
    reporte = generar_reporte(df_input, probabilidades, nivel_riesgo)

    imprimir_resumen(reporte)
