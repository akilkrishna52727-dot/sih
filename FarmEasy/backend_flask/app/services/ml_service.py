import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import joblib
import os

class MLService:
    def __init__(self):
        # Resolve paths relative to backend root to avoid CWD issues
        backend_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        models_dir = os.path.join(backend_root, 'ml_models')
        self.model_path = os.path.join(models_dir, 'crop_recommendation_model.pkl')
        self.label_encoder_path = os.path.join(models_dir, 'label_encoder.pkl')
        self.model = None
        self.label_encoder = None
        self.load_or_train_model()
    
    def load_or_train_model(self):
        """Load existing model or train a new one"""
        try:
            if os.path.exists(self.model_path) and os.path.exists(self.label_encoder_path):
                self.model = joblib.load(self.model_path)
                self.label_encoder = joblib.load(self.label_encoder_path)
            else:
                self.train_model()
        except Exception:
            # If loading fails (e.g., corrupted files), retrain and overwrite
            self.train_model()
    
    def train_model(self):
        """Train the crop recommendation model with sample data"""
        # Sample training data (in production, use real agricultural data)
        data = {
            'nitrogen': [90, 85, 60, 74, 78, 69, 87, 65, 70, 80, 75, 85, 60, 70, 65, 80, 90, 75, 85, 70],
            'phosphorus': [42, 58, 55, 67, 48, 55, 42, 58, 45, 50, 60, 45, 70, 55, 45, 60, 50, 65, 40, 55],
            'potassium': [43, 41, 44, 67, 42, 51, 43, 41, 50, 45, 40, 50, 45, 60, 50, 45, 40, 50, 45, 60],
            'ph_level': [6.5, 7.0, 6.8, 6.2, 6.9, 7.2, 6.5, 7.0, 6.7, 6.8, 7.1, 6.6, 7.0, 6.5, 6.9, 6.7, 6.8, 7.0, 6.5, 6.8],
            'organic_carbon': [2.5, 3.0, 2.8, 2.2, 2.9, 3.2, 2.5, 3.0, 2.7, 2.8, 3.1, 2.6, 3.0, 2.5, 2.9, 2.7, 2.8, 3.0, 2.5, 2.8],
            'crop': ['rice', 'wheat', 'cotton', 'sugarcane', 'rice', 'wheat', 'rice', 'wheat', 'cotton', 'rice',
                    'wheat', 'cotton', 'sugarcane', 'rice', 'cotton', 'wheat', 'rice', 'wheat', 'cotton', 'sugarcane']
        }
        
        df = pd.DataFrame(data)
        
        # Prepare features and target
        X = df[['nitrogen', 'phosphorus', 'potassium', 'ph_level', 'organic_carbon']]
        y = df['crop']
        
        # Encode labels
        self.label_encoder = LabelEncoder()
        y_encoded = self.label_encoder.fit_transform(y)
        
        # Train model
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.model.fit(X, y_encoded)
        
        # Save model and encoder
        os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
        joblib.dump(self.model, self.model_path)
        joblib.dump(self.label_encoder, self.label_encoder_path)
    
    def predict_crop(self, nitrogen, phosphorus, potassium, ph_level, organic_carbon):
        """Predict the best crop based on soil parameters"""
        if not self.model or not self.label_encoder:
            return None, 0.0
        
        # Prepare input data
        features = np.array([[nitrogen, phosphorus, potassium, ph_level, organic_carbon]])
        
        # Make prediction
        prediction = self.model.predict(features)[0]
        probabilities = self.model.predict_proba(features)[0]
        confidence = np.max(probabilities)
        
        # Decode prediction
        crop_name = self.label_encoder.inverse_transform([prediction])[0]
        
        return crop_name, confidence
    
    def get_crop_recommendations(self, nitrogen, phosphorus, potassium, ph_level, organic_carbon, top_k: int = 3):
        """Return top-k crop recommendations with confidences.

        Args:
            nitrogen, phosphorus, potassium, ph_level, organic_carbon: float features
            top_k: number of recommendations to return

        Returns:
            List[{'crop': str, 'confidence': float, 'confidence_percentage': float}]
        """
        if not self.model or not self.label_encoder:
            return []

        features = np.array([[nitrogen, phosphorus, potassium, ph_level, organic_carbon]])
        # Get probability distribution over classes
        probabilities = self.model.predict_proba(features)[0]
        # Indices of classes sorted by probability desc
        top_indices = np.argsort(probabilities)[::-1][:max(1, top_k)]
        class_labels = self.label_encoder.inverse_transform(top_indices)

        recommendations = []
        for idx, cls_idx in enumerate(top_indices):
            prob = float(probabilities[cls_idx])
            recommendations.append({
                'crop': str(class_labels[idx]),
                'confidence': prob,
                'confidence_percentage': round(prob * 100.0, 2)
            })

        return recommendations
    

# Global ML service instance
ml_service = MLService()
