from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
import uuid
import json

from app.init import db
from app.models.virtual_farm import VirtualFarm

virtual_farm_bp = Blueprint('virtual_farm', __name__)


@virtual_farm_bp.route('/create', methods=['POST'])
@jwt_required()
def create_virtual_farm():
    user_id = get_jwt_identity()
    try:
        user_id = int(user_id)
    except Exception:
        pass

    data = request.get_json(silent=True) or {}
    try:
        land_size = data.get('land_size')
        crop_type = data.get('crop_type')
        location = data.get('location')
        planting_date_str = data.get('planting_date')
        if land_size is None or crop_type is None or location is None or not planting_date_str:
            return jsonify({'error': 'Missing required fields'}), 400

        vf = VirtualFarm()
        vf.id = str(uuid.uuid4())
        vf.user_id = user_id
        vf.land_size = float(land_size)
        vf.crop_type = str(crop_type)
        vf.location = str(location)
        vf.planting_date = datetime.fromisoformat(planting_date_str)
        vf.soil_data = json.dumps(data.get('soil_data') or {})
        vf.growth_stages = json.dumps(data.get('growth_stages') or [])
        vf.expected_yield = float(data.get('expected_yield') or 0.0)
        vf.expected_profit = float(data.get('expected_profit') or 0.0)
        vf.climate_risks = json.dumps(data.get('climate_risks') or [])

        db.session.add(vf)
        db.session.commit()
        return jsonify(vf.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@virtual_farm_bp.route('/user-farms', methods=['GET'])
@jwt_required()
def get_user_farms():
    user_id = get_jwt_identity()
    try:
        user_id = int(user_id)
    except Exception:
        pass
    farms = VirtualFarm.query.filter_by(user_id=user_id).all()
    return jsonify({'farms': [farm.to_dict() for farm in farms]}), 200


@virtual_farm_bp.route('/update-progress', methods=['POST'])
@jwt_required()
def update_farm_progress():
    data = request.get_json(silent=True) or {}
    farm_id = data.get('farm_id')
    if not farm_id:
        return jsonify({'error': 'farm_id is required'}), 400
    farm = VirtualFarm.query.get(farm_id)
    if not farm:
        return jsonify({'error': 'Farm not found'}), 404

    try:
        stages = json.loads(farm.growth_stages or '[]')
        now_days = (datetime.utcnow() - farm.planting_date).days
        updated = []
        for s in stages:
            # Expect keys: stage, days_from_planting, progress, description, is_completed
            days = int(s.get('days_from_planting', 0))
            # progress increases as days pass
            progress = s.get('progress', 0)
            if now_days >= days:
                progress = min(100, max(progress, 20 + (now_days - days) * 5))
            s['progress'] = progress
            s['is_completed'] = bool(progress >= 100)
            updated.append(s)

        farm.growth_stages = json.dumps(updated)
        db.session.commit()
        return jsonify(farm.to_dict()), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
