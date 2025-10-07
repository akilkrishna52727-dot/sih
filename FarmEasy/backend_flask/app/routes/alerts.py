from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.init import db
from app.models.transaction import Alert
from app.services.sms_service import SMSService

alerts_bp = Blueprint('alerts', __name__)

@alerts_bp.route('/user', methods=['GET'])
@jwt_required()
def get_user_alerts():
	try:
		user_id = get_jwt_identity()
		alerts = Alert.query.filter_by(user_id=user_id).order_by(Alert.created_at.desc()).all()
		return jsonify({
			'alerts': [alert.to_dict() for alert in alerts],
			'message': 'Alerts retrieved successfully'
		}), 200
	except Exception as e:
		return jsonify({'message': f'Failed to get alerts: {str(e)}'}), 500

@alerts_bp.route('/send-weather', methods=['POST'])
@jwt_required()
def send_weather_alert():
	try:
		user_id = get_jwt_identity()
		data = db.session.query(Alert).filter_by(user_id=user_id, alert_type='weather', is_read=False).all()
		sms_service = SMSService()
		first_alert = Alert.query.filter_by(user_id=user_id).first()
		user_phone = first_alert.user.phone if first_alert and getattr(first_alert, 'user', None) else None
		if not user_phone:
			return jsonify({'message': 'No phone number on file to send alerts'}), 400
		success, sid_or_error = sms_service.send_weather_alert(user_phone, [alert.to_dict() for alert in data])
		return jsonify({'message': 'Weather alerts sent' if success else sid_or_error}), 200
	except Exception as e:
		return jsonify({'message': f'Failed to send alerts: {str(e)}'}), 500
