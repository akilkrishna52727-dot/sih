import os
from datetime import datetime
from typing import Optional, Dict, Any, List
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, mean_squared_error
import joblib


class EnhancedMLService:
    def __init__(self):
        backend_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        models_dir = os.path.join(backend_root, 'ml_models')
        os.makedirs(models_dir, exist_ok=True)
        self.crop_model_path = os.path.join(models_dir, 'enhanced_crop_model.pkl')
        self.yield_model_path = os.path.join(models_dir, 'enhanced_yield_model.pkl')
        self.price_model_path = os.path.join(models_dir, 'enhanced_price_model.pkl')
        self.scaler_path = os.path.join(models_dir, 'enhanced_scaler.pkl')
        self.label_encoder_path = os.path.join(models_dir, 'enhanced_label_encoder.pkl')
        self.crop_model = None
        self.yield_model = None
        self.price_model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.crop_data = self._load_crop_database()

    def _load_crop_database(self):
        return {
            'rice': {
                'avg_yield_per_hectare': 4.5, 'base_price_per_kg': 25,
                'seasonal_factor': 1.2, 'subsidy_schemes': ['PM-KISAN', 'PMFBY']
            },
            'wheat': {
                'avg_yield_per_hectare': 3.8, 'base_price_per_kg': 22,
                'seasonal_factor': 1.1, 'subsidy_schemes': ['PM-KISAN', 'PMFBY']
            },
            'cotton': {
                'avg_yield_per_hectare': 2.2, 'base_price_per_kg': 85,
                'seasonal_factor': 1.4, 'subsidy_schemes': ['Cotton Technology Mission']
            },
            'sugarcane': {
                'avg_yield_per_hectare': 75.0, 'base_price_per_kg': 3.5,
                'seasonal_factor': 1.0, 'subsidy_schemes': ['Sugar Development Fund']
            },
            'maize': {
                'avg_yield_per_hectare': 4.1, 'base_price_per_kg': 18,
                'seasonal_factor': 1.15, 'subsidy_schemes': ['PM-KISAN', 'Nutrient Based Subsidy']
            }
        }

    def _generate_synthetic_training_data(self, n: int = 1000) -> pd.DataFrame:
        rng = np.random.default_rng(42)
        crops = ['rice', 'wheat', 'cotton', 'sugarcane', 'maize']
        data = {
            'N': rng.normal(80, 20, n).clip(10, 150),
            'P': rng.normal(50, 15, n).clip(5, 120),
            'K': rng.normal(45, 15, n).clip(5, 120),
            'temperature': rng.normal(26, 5, n).clip(10, 45),
            'humidity': rng.normal(65, 10, n).clip(20, 100),
            'ph': rng.normal(6.8, 0.5, n).clip(4.5, 8.5),
            'rainfall': rng.normal(200, 80, n).clip(0, 600),
        }
        df = pd.DataFrame(data)
        df['label'] = rng.choice(crops, n)

        # Derive synthetic yield/price around crop priors
        yields = []
        prices = []
        for crop in df['label']:
            base = self.crop_data[crop]
            yields.append(max(0.5, rng.normal(base['avg_yield_per_hectare'], 0.5)))
            prices.append(max(2.0, rng.normal(base['base_price_per_kg'], base['base_price_per_kg'] * 0.1)))
        df['yield'] = yields
        df['price'] = prices
        return df

    def _save_models(self):
        joblib.dump(self.crop_model, self.crop_model_path)
        joblib.dump(self.yield_model, self.yield_model_path)
        joblib.dump(self.price_model, self.price_model_path)
        joblib.dump(self.scaler, self.scaler_path)
        joblib.dump(self.label_encoder, self.label_encoder_path)

    def _load_models(self):
        self.crop_model = joblib.load(self.crop_model_path)
        self.yield_model = joblib.load(self.yield_model_path)
        self.price_model = joblib.load(self.price_model_path)
        self.scaler = joblib.load(self.scaler_path)
        self.label_encoder = joblib.load(self.label_encoder_path)

    def train_models(self, training_data_path: Optional[str] = None):
        if training_data_path:
            df = pd.read_csv(training_data_path)
        else:
            df = self._generate_synthetic_training_data()

        feature_columns = ['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']
        X = df[feature_columns].to_numpy(dtype=float)
        y_crop = df['label']
        y_yield = df['yield'].to_numpy(dtype=float)
        y_price = df['price'].to_numpy(dtype=float)

        X_scaled = self.scaler.fit_transform(X)
        y_crop_np = y_crop.to_numpy()
        X_train, X_test, y_train, y_test = train_test_split(
            X_scaled, y_crop_np, test_size=0.2, random_state=42, stratify=y_crop_np
        )

        self.crop_model = RandomForestClassifier(
            n_estimators=200, max_depth=15, min_samples_split=5,
            min_samples_leaf=2, random_state=42
        )
        self.crop_model.fit(X_train, y_train)

        # Yield regressor takes features + encoded crop
        self.label_encoder = LabelEncoder()
        crop_encoded = self.label_encoder.fit_transform(y_crop_np)
        crop_encoded = np.asarray(crop_encoded).reshape(-1, 1)
        yield_features = np.column_stack([X_scaled, crop_encoded])
        self.yield_model = RandomForestRegressor(
            n_estimators=150, max_depth=12, random_state=42
        )
        self.yield_model.fit(yield_features, y_yield)

        # Price regressor takes features + encoded crop + yield
        y_yield_col = y_yield.reshape(-1, 1)
        price_features = np.column_stack([X_scaled, crop_encoded, y_yield_col])
        self.price_model = RandomForestRegressor(
            n_estimators=100, max_depth=10, random_state=42
        )
        self.price_model.fit(price_features, y_price)

        self._save_models()

        metrics = {
            'crop_accuracy': float(accuracy_score(y_test, self.crop_model.predict(X_test))),
            'yield_rmse': float(np.sqrt(mean_squared_error(y_yield, self.yield_model.predict(yield_features)))),
            'price_rmse': float(np.sqrt(mean_squared_error(y_price, self.price_model.predict(price_features))))
        }
        return metrics

    def predict_comprehensive(self, soil_params: Dict[str, Any], location: Optional[str] = None, farm_size: float = 1.0):
        # Ensure models are available
        if not (os.path.exists(self.crop_model_path) and os.path.exists(self.yield_model_path) and os.path.exists(self.price_model_path)):
            self.train_models()
        self._load_models()
        # Runtime guards for type checkers
        assert self.crop_model is not None
        assert self.yield_model is not None
        assert self.price_model is not None

        features = np.array([[
            soil_params.get('nitrogen'), soil_params.get('phosphorus'),
            soil_params.get('potassium'), soil_params.get('temperature', 25),
            soil_params.get('humidity', 65), soil_params.get('ph_level'),
            soil_params.get('rainfall', 200)
        ]], dtype=float)

        features_scaled = self.scaler.transform(features)
        proba = self.crop_model.predict_proba(features_scaled)[0]  # 1D
        classes = self.crop_model.classes_
        top_indices = np.argsort(proba)[::-1][:3]

        recommendations = []
        for idx in top_indices:
            crop_name = str(classes[idx])
            confidence = float(proba[idx])
            enc_arr = self.label_encoder.transform([crop_name])
            crop_enc = int(np.asarray(enc_arr)[0])

            y_features = np.column_stack([features_scaled, np.array([[crop_enc]], dtype=float)])
            pred_yield = float(self.yield_model.predict(y_features)[0])

            p_features = np.column_stack([
                features_scaled,
                np.array([[crop_enc]], dtype=float),
                np.array([[pred_yield]], dtype=float)
            ])
            pred_price = float(self.price_model.predict(p_features)[0])

            profit = self._calculate_profit(crop_name, pred_yield, pred_price, farm_size, soil_params)
            subsidies = self._get_applicable_subsidies(crop_name, farm_size)

            recommendations.append({
                'crop': crop_name,
                'confidence': confidence,
                'predicted_yield_tons_per_hectare': pred_yield,
                'predicted_price_per_kg': pred_price,
                'profit_analysis': profit,
                'applicable_subsidies': subsidies,
                'growing_season': self._get_optimal_season(crop_name),
                'market_trend': self._get_market_trend(crop_name)
            })

        return {
            'recommendations': recommendations,
            'soil_analysis': self._analyze_soil_health(soil_params),
            'timestamp': datetime.now().isoformat(),
        }

    def _calculate_profit(self, crop_name: str, yield_per_hectare: float, price_per_kg: float, farm_size: float, soil_params: dict):
        total_production_kg = max(0.0, yield_per_hectare) * farm_size * 1000.0
        gross_income = total_production_kg * max(0.0, price_per_kg)
        base_costs = {
            'rice': {'seeds': 5000, 'fertilizer': 12000, 'pesticides': 8000, 'labor': 15000, 'irrigation': 6000},
            'wheat': {'seeds': 4000, 'fertilizer': 10000, 'pesticides': 6000, 'labor': 12000, 'irrigation': 4000},
            'cotton': {'seeds': 8000, 'fertilizer': 15000, 'pesticides': 12000, 'labor': 18000, 'irrigation': 8000},
            'sugarcane': {'seeds': 25000, 'fertilizer': 20000, 'pesticides': 10000, 'labor': 30000, 'irrigation': 15000},
            'maize': {'seeds': 3500, 'fertilizer': 9000, 'pesticides': 5000, 'labor': 10000, 'irrigation': 3000},
        }
        costs = base_costs.get(crop_name, base_costs['rice']).copy()
        total_cost = sum(costs.values()) * farm_size
        if soil_params.get('ph_level', 7.0) < 6.0 or soil_params.get('ph_level', 7.0) > 8.0:
            total_cost *= 1.15
        if soil_params.get('nitrogen', 0) < 50:
            total_cost *= 1.10
        net_profit = gross_income - total_cost
        roi = (net_profit / total_cost) * 100.0 if total_cost > 0 else 0.0
        return {
            'gross_income': round(gross_income, 2),
            'total_cost': round(total_cost, 2),
            'net_profit': round(net_profit, 2),
            'roi_percentage': round(roi, 2),
            'cost_breakdown': costs,
            'profit_per_hectare': round(net_profit / max(1e-6, farm_size), 2),
        }

    def _get_applicable_subsidies(self, crop_name: str, farm_size: float):
        subs = []
        if farm_size <= 2.0:
            subs.append({
                'scheme': 'PM-KISAN',
                'amount': 6000,
                'description': '₹6,000 per year direct benefit transfer',
                'eligibility': 'Small/marginal farmers (≤ 2 hectares)'
            })
        premium_rates = {'rice': 0.02, 'wheat': 0.015, 'cotton': 0.05, 'sugarcane': 0.05, 'maize': 0.02}
        subs.append({
            'scheme': 'PMFBY (Crop Insurance)',
            'premium_rate': premium_rates.get(crop_name, 0.02),
            'description': 'Government-supported crop insurance premium',
            'eligibility': 'All farmers including sharecroppers/tenant farmers'
        })
        if crop_name == 'cotton':
            subs.append({
                'scheme': 'Cotton Technology Mission',
                'amount': 15000,
                'description': 'Support for improved cotton cultivation practices',
                'eligibility': 'Cotton farmers using improved varieties'
            })
        return subs

    def _analyze_soil_health(self, soil_params: dict):
        analysis = {'overall_health': 'Good', 'deficiencies': [], 'recommendations': []}
        if soil_params.get('nitrogen', 0) < 50:
            analysis['deficiencies'].append('Low Nitrogen')
            analysis['recommendations'].append('Apply organic manure or urea fertilizer')
        if soil_params.get('phosphorus', 0) < 20:
            analysis['deficiencies'].append('Low Phosphorus')
            analysis['recommendations'].append('Apply DAP or rock phosphate')
        if soil_params.get('potassium', 0) < 30:
            analysis['deficiencies'].append('Low Potassium')
            analysis['recommendations'].append('Apply MOP or potassium sulfate')
        ph = soil_params.get('ph_level', 7.0)
        if ph < 6.0:
            analysis['deficiencies'].append('Acidic Soil')
            analysis['recommendations'].append('Apply lime to increase pH')
        elif ph > 8.0:
            analysis['deficiencies'].append('Alkaline Soil')
            analysis['recommendations'].append('Apply gypsum or sulfur to reduce pH')
        dcount = len(analysis['deficiencies'])
        analysis['overall_health'] = 'Excellent' if dcount == 0 else 'Good' if dcount <= 2 else 'Fair' if dcount <= 3 else 'Poor'
        return analysis

    def _get_optimal_season(self, crop_name: str):
        mapping = {
            'rice': 'Kharif (Jun–Oct)',
            'wheat': 'Rabi (Nov–Apr)',
            'cotton': 'Kharif (May–Oct)',
            'sugarcane': 'Perennial (Planting Jan–Mar/Sept–Oct)',
            'maize': 'Both Kharif/Rabi'
        }
        return mapping.get(crop_name, 'Seasonal')

    def _get_market_trend(self, crop_name: str):
        # Placeholder market trend; in production, fetch from APIs
        return {
            'trend': 'stable',
            'last_30d_change_percent': 1.2,
            'commentary': f'Market for {crop_name} appears stable over the last month.'
        }
