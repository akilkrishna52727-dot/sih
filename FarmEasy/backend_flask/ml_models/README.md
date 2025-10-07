# ML Models

This folder contains the trained machine learning models for crop recommendation.

- `crop_recommendation_model.pkl`: Trained RandomForestClassifier model (binary).
- `label_encoder.pkl`: Trained LabelEncoder (binary).

To generate these files, run `app/services/train_ml_model.py` after placing your soil dataset in `app/data/sample_soil_data.csv`.
