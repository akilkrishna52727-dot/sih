from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.services.weather_service import WeatherService

weather_bp = Blueprint('weather', __name__)

@weather_bp.route('/current', methods=['GET'])
@jwt_required()
def get_current_weather():
	try:
		city = request.args.get('city')
		lat = request.args.get('lat', type=float)
		lon = request.args.get('lon', type=float)
        
		weather_service = WeatherService()
		weather_data, error = weather_service.get_current_weather(city=city, lat=lat, lon=lon)
        
		if error:
			return jsonify({'message': error}), 400
        
		return jsonify({
			'weather': weather_data,
			'message': 'Weather data retrieved successfully'
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Weather service error: {str(e)}'}), 500

@weather_bp.route('/forecast', methods=['GET'])
@jwt_required()
def get_weather_forecast():
	try:
		city = request.args.get('city')
		lat = request.args.get('lat', type=float)
		lon = request.args.get('lon', type=float)
		days = request.args.get('days', 5, type=int)
        
		weather_service = WeatherService()
		forecast_data, error = weather_service.get_weather_forecast(
			city=city, lat=lat, lon=lon, days=days
		)
        
		if error:
			return jsonify({'message': error}), 400
        
		return jsonify({
			'forecast': forecast_data,
			'message': 'Weather forecast retrieved successfully'
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Weather forecast error: {str(e)}'}), 500

@weather_bp.route('/risks', methods=['GET'])
@jwt_required()
def get_weather_risks():
	try:
		city = request.args.get('city')
		lat = request.args.get('lat', type=float)
		lon = request.args.get('lon', type=float)
        
		weather_service = WeatherService()
        
		# Get current weather and forecast
		weather_data, error1 = weather_service.get_current_weather(city=city, lat=lat, lon=lon)
		forecast_data, error2 = weather_service.get_weather_forecast(city=city, lat=lat, lon=lon)
        
		if error1 or error2:
			return jsonify({'message': error1 or error2}), 400
        
		# Analyze risks
		risks = weather_service.analyze_weather_risks(weather_data, forecast_data)
        
		return jsonify({
			'risks': risks,
			'weather': weather_data,
			'message': 'Weather risks analyzed successfully'
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Weather risk analysis error: {str(e)}'}), 500
