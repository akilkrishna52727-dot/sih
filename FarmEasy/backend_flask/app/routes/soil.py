from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from app.init import db
from app.models.user import User
from app.models.soil_test import SoilTest
from app.models.crop import Crop, Recommendation
from app.services.enhanced_ml_service import EnhancedMLService

soil_bp = Blueprint('soil', __name__)

# Singleton service instance for enhanced predictions
_enhanced_service = EnhancedMLService()


@soil_bp.route('/analyze-enhanced', methods=['POST'])
@jwt_required()
def analyze_enhanced():
	try:
		user_id = get_jwt_identity()
		user = User.query.get(user_id)
		if not user:
			return jsonify({'message': 'User not found'}), 404

		data = request.get_json() or {}

		# Validate core soil metrics
		required = ['nitrogen', 'phosphorus', 'potassium', 'ph_level', 'organic_carbon']
		missing = [f for f in required if f not in data]
		if missing:
			return jsonify({'message': f"Missing required fields: {', '.join(missing)}"}), 400

		# Persist soil test
		soil_test = SoilTest()
		soil_test.user_id = user_id
		soil_test.nitrogen = float(data['nitrogen'])
		soil_test.phosphorus = float(data['phosphorus'])
		soil_test.potassium = float(data['potassium'])
		soil_test.ph_level = float(data['ph_level'])
		soil_test.organic_carbon = float(data['organic_carbon'])
		db.session.add(soil_test)
		db.session.flush()  # get soil_test.id

		# Prepare inputs for enhanced model
		soil_params = {
			'nitrogen': float(data['nitrogen']),
			'phosphorus': float(data['phosphorus']),
			'potassium': float(data['potassium']),
			'ph_level': float(data['ph_level']),
			'organic_carbon': float(data['organic_carbon']),
			'temperature': float(data.get('temperature', 25)),
			'humidity': float(data.get('humidity', 65)),
			'rainfall': float(data.get('rainfall', 200)),
		}
		farm_size = float(data.get('farm_size', 1.0))
		location = data.get('location')

		enhanced = _enhanced_service.predict_comprehensive(
			soil_params=soil_params, location=location, farm_size=farm_size
		)

		# Save recommendations to DB (top 3) and ensure Crop rows exist
		saved_recs = []
		for rec in enhanced.get('recommendations', [])[:3]:
			crop_name = rec.get('crop')
			confidence = float(rec.get('confidence', 0.0))
			crop = Crop.query.filter_by(name=crop_name).first()
			if not crop:
				crop = Crop()
				crop.name = crop_name
				crop.season = rec.get('growing_season', 'all')
				crop.expected_yield = rec.get('predicted_yield_tons_per_hectare')
				crop.market_price = rec.get('predicted_price_per_kg')
				db.session.add(crop)
				db.session.flush()

			recommendation = Recommendation()
			recommendation.user_id = user_id
			recommendation.soil_test_id = soil_test.id
			recommendation.recommended_crop_id = crop.id
			recommendation.confidence = confidence
			db.session.add(recommendation)
			saved_recs.append({
				'crop': crop.to_dict(),
				'confidence': confidence,
				'confidence_percentage': round(confidence * 100.0, 2),
				'profit_analysis': rec.get('profit_analysis'),
				'applicable_subsidies': rec.get('applicable_subsidies'),
				'growing_season': rec.get('growing_season'),
				'market_trend': rec.get('market_trend'),
			})

		db.session.commit()

		return jsonify({
			'message': 'Enhanced soil analysis completed',
			'soil_test': soil_test.to_dict(),
			'enhanced': enhanced,
			'saved_recommendations': saved_recs
		}), 200
	except Exception as e:
		db.session.rollback()
		return jsonify({'message': f'Enhanced analysis failed: {str(e)}'}), 500
