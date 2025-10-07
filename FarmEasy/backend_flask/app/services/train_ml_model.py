import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
import pickle
import os

def main():
    # 1. Load sample soil dataset
    # Replace with your actual dataset path
    dataset_path = os.path.join(os.path.dirname(__file__), '../data/sample_soil_data.csv')
    df = pd.read_csv(dataset_path)

    # 2. Train RandomForestClassifier on features
    features = ['nitrogen', 'phosphorus', 'potassium', 'ph_level', 'organic_carbon']
    X = df[features]
    y = df['crop_label']

    # 3. Encode labels with LabelEncoder
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42)
    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)

    # 4. Save model and label encoder
    model_dir = os.path.join(os.path.dirname(__file__), '../ml_models')
    os.makedirs(model_dir, exist_ok=True)
    model_path = os.path.join(model_dir, 'crop_recommendation_model.pkl')
    encoder_path = os.path.join(model_dir, 'label_encoder.pkl')
    with open(model_path, 'wb') as f:
        pickle.dump(clf, f)
    with open(encoder_path, 'wb') as f:
        pickle.dump(label_encoder, f)

    # 5. Print training accuracy and feature importances
    accuracy = clf.score(X_test, y_test)
    print(f'Training accuracy: {accuracy:.4f}')
    print('Feature importances:')
    for feat, imp in zip(features, clf.feature_importances_):
        print(f'  {feat}: {imp:.4f}')

if __name__ == '__main__':
    main()
