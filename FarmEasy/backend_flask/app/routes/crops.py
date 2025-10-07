
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.init import db
from app.models.user import User
from app.models.soil_test import SoilTest
from app.models.crop import Crop, Recommendation
from app.services.ml_service import ml_service
from app.services.sms_service import SMSService

crops_bp = Blueprint('crops', __name__)

@crops_bp.route('/recommend', methods=['POST'])
@jwt_required()
def recommend_crops():
	try:
		user_id = get_jwt_identity()
		user = User.query.get(user_id)
        
		if not user:
			return jsonify({'message': 'User not found'}), 404
        
		data = request.get_json()
        
		# Validate soil test data
		required_fields = ['nitrogen', 'phosphorus', 'potassium', 'ph_level', 'organic_carbon']
		for field in required_fields:
			if field not in data:
				return jsonify({'message': f'{field} is required'}), 400
        
		# Save soil test data
		soil_test = SoilTest()
		soil_test.user_id = user_id
		soil_test.nitrogen = float(data['nitrogen'])
		soil_test.phosphorus = float(data['phosphorus'])
		soil_test.potassium = float(data['potassium'])
		soil_test.ph_level = float(data['ph_level'])
		soil_test.organic_carbon = float(data['organic_carbon'])
        
		db.session.add(soil_test)
		db.session.flush()  # Get the soil_test.id
        
		# Get ML predictions
		recommendations = ml_service.get_crop_recommendations(
			soil_test.nitrogen,
			soil_test.phosphorus,
			soil_test.potassium,
			soil_test.ph_level,
			soil_test.organic_carbon
		)
        
		# Save recommendations to database
		saved_recommendations = []
		for rec in recommendations:
			crop = Crop.query.filter_by(name=rec['crop']).first()
			if not crop:
				# Create default crop if not exists
				crop = Crop()
				crop.name = rec['crop']
				crop.season = 'all'
				crop.min_temp = 15.0
				crop.max_temp = 35.0
				crop.min_rainfall = 500.0
				crop.max_rainfall = 2000.0
				crop.soil_type = 'loamy'
				crop.expected_yield = 2500.0
				crop.market_price = 25.0
				db.session.add(crop)
				db.session.flush()
            
			recommendation = Recommendation()
			recommendation.user_id = user_id
			recommendation.soil_test_id = soil_test.id
			recommendation.recommended_crop_id = crop.id
			recommendation.confidence = rec['confidence']
            
			db.session.add(recommendation)
			saved_recommendations.append({
				'crop': crop.to_dict(),
				'confidence': rec['confidence'],
				'confidence_percentage': rec['confidence_percentage']
			})
        
		db.session.commit()
        
		# Send SMS notification for top recommendation
		if saved_recommendations and user.phone:
			sms_service = SMSService()
			sms_service.send_crop_recommendation_sms(
				user.phone, 
				recommendations,
				user.username
			)
        
		return jsonify({
			'message': 'Crop recommendations generated successfully',
			'soil_test': soil_test.to_dict(),
			'recommendations': saved_recommendations
		}), 200
        
	except Exception as e:
		db.session.rollback()
		return jsonify({'message': f'Recommendation failed: {str(e)}'}), 500

@crops_bp.route('/all', methods=['GET'])
@jwt_required()
def get_all_crops():
	try:
		crops = Crop.query.all()
		return jsonify({
			'crops': [crop.to_dict() for crop in crops]
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Failed to get crops: {str(e)}'}), 500

@crops_bp.route('/history', methods=['GET'])
@jwt_required()
def get_recommendation_history():
	try:
		user_id = get_jwt_identity()
        
		recommendations = db.session.query(Recommendation, Crop, SoilTest)\
			.join(Crop, Recommendation.recommended_crop_id == Crop.id)\
			.join(SoilTest, Recommendation.soil_test_id == SoilTest.id)\
			.filter(Recommendation.user_id == user_id)\
			.order_by(Recommendation.created_at.desc())\
			.limit(10).all()
        
		history = []
		for rec, crop, soil_test in recommendations:
			history.append({
				'id': rec.id,
				'crop': crop.to_dict(),
				'confidence': rec.confidence,
				'confidence_percentage': round(rec.confidence * 100, 2),
				'soil_test': soil_test.to_dict(),
				'created_at': rec.created_at.isoformat()
			})
        
		return jsonify({
			'history': history
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Failed to get history: {str(e)}'}), 500
