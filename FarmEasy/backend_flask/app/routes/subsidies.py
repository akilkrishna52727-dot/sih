from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required
from app.models.subsidies import Subsidy

subsidies_bp = Blueprint('subsidies', __name__)

@subsidies_bp.route('/available', methods=['GET'])
@jwt_required()
def get_subsidies():
	try:
		crop_id = request.args.get('crop_id', type=int)
		query = Subsidy.query.filter_by(is_active=True)
		if crop_id:
			query = query.filter_by(crop_id=crop_id)
		subsidies = query.all()
		return jsonify({
			'subsidies': [subsidy.to_dict() for subsidy in subsidies],
			'message': 'Subsidies retrieved successfully'
		}), 200
	except Exception as e:
		return jsonify({'message': f'Failed to get subsidies: {str(e)}'}), 500
