"""
train_model.py
──────────────
Entrena el modelo de predicción de rotación de empleados
y guarda el modelo serializado para uso en producción.

Uso:
    python train_model.py
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_auc_score
import joblib
import json
import os

# ── Configuración ─────────────────────────────────────────────────────────────
DATA_PATH    = 'data/WA_Fn-UseC_-HR-Employee-Attrition.csv'
MODEL_PATH   = 'modelo_lr.pkl'
ENCODER_PATH = 'encoders.pkl'
META_PATH    = 'model_meta.json'
UMBRAL       = 0.493

CAT_COLS = ['BusinessTravel', 'Department', 'EducationField',
            'Gender', 'JobRole', 'MaritalStatus', 'OverTime']

FEATURE_COLS = ['Age', 'BusinessTravel', 'DailyRate', 'Department',
                'DistanceFromHome', 'Education', 'EnvironmentSatisfaction',
                'Gender', 'JobInvolvement', 'JobLevel', 'JobRole',
                'JobSatisfaction', 'MaritalStatus', 'MonthlyIncome',
                'NumCompaniesWorked', 'OverTime', 'PercentSalaryHike',
                'StockOptionLevel', 'TotalWorkingYears', 'TrainingTimesLastYear',
                'WorkLifeBalance', 'YearsAtCompany', 'YearsInCurrentRole',
                'YearsSinceLastPromotion', 'YearsWithCurrManager']


def load_and_clean(path):
    """Carga y limpia el dataset."""
    df = pd.read_csv(path)
    df.drop(columns=['EmployeeCount', 'Over18', 'StandardHours', 'EmployeeNumber'],
            inplace=True, errors='ignore')
    df['Attrition_bin'] = (df['Attrition'] == 'Yes').astype(int)
    return df


def encode_features(df, encoders=None, fit=True):
    """
    Codifica variables categóricas.
    Si fit=True entrena nuevos encoders.
    Si fit=False usa encoders existentes (para predicción).
    """
    df = df.copy()
    if fit:
        encoders = {}
        for col in CAT_COLS:
            le = LabelEncoder()
            df[col] = le.fit_transform(df[col].astype(str))
            encoders[col] = le
    else:
        for col in CAT_COLS:
            le = encoders[col]
            df[col] = le.transform(df[col].astype(str))
    return df, encoders


def train(df, encoders):
    """Entrena el modelo de Logistic Regression."""
    df_enc, _ = encode_features(df, encoders=encoders, fit=False)

    X = df_enc[FEATURE_COLS]
    y = df_enc['Attrition_bin']

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y)

    model = LogisticRegression(max_iter=500, class_weight='balanced', random_state=42)
    model.fit(X_train, y_train)

    # Evaluación
    proba = model.predict_proba(X_test)[:, 1]
    pred  = (proba >= UMBRAL).astype(int)
    auc   = roc_auc_score(y_test, proba)

    print("=== Evaluación del modelo ===")
    print(classification_report(y_test, pred, target_names=['No rotó', 'Rotó']))
    print(f"ROC-AUC: {auc:.4f}")
    print(f"Umbral de decisión: {UMBRAL}")

    return model, auc


def save_artifacts(model, encoders, auc):
    """Guarda modelo, encoders y metadata."""
    joblib.dump(model, MODEL_PATH)
    joblib.dump(encoders, ENCODER_PATH)

    meta = {
        'umbral': UMBRAL,
        'auc': round(auc, 4),
        'features': FEATURE_COLS,
        'cat_cols': CAT_COLS
    }
    with open(META_PATH, 'w') as f:
        json.dump(meta, f, indent=2)

    print(f"\n Modelo guardado en:   {MODEL_PATH}")
    print(f" Encoders guardados en: {ENCODER_PATH}")
    print(f" Metadata guardada en:  {META_PATH}")


if __name__ == '__main__':
    print("── Cargando datos ──────────────────────────────")
    df = load_and_clean(DATA_PATH)
    print(f"   Empleados: {len(df):,} | Rotación: {df['Attrition_bin'].mean()*100:.1f}%")

    print("\n── Codificando features ────────────────────────")
    _, encoders = encode_features(df, fit=True)
    print(f"   Variables codificadas: {CAT_COLS}")

    print("\n── Entrenando modelo ───────────────────────────")
    model, auc = train(df, encoders)

    print("\n── Guardando artefactos ────────────────────────")
    save_artifacts(model, encoders, auc)
