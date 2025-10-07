from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app.init import db
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.utils.validators import validate_email, validate_password

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/health', methods=['GET'])
def auth_health():
    # Basic health for auth blueprint; DB touch avoided for speed
    return jsonify({'status': 'healthy'}), 200

@auth_bp.route('/register', methods=['POST'])
def register():
    """Register a new user.
    Compatibility notes:
    - Accepts either 'username' or 'name' (maps to username in DB).
    - 'phone' is optional; defaults to empty string to satisfy NOT NULL column.
    - Returns both 'token' and 'access_token' for client compatibility.
    """
    try:
        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            return jsonify({'message': 'Invalid JSON payload'}), 400

        email = (data.get('email') or '').strip()
        password = data.get('password') or ''
        # Prefer explicit username, else fall back to provided name, else derive from email local-part
        raw_name = (data.get('username') or data.get('name') or '').strip()
        username = raw_name or (email.split('@')[0] if '@' in email else '')
        phone = (data.get('phone') or '').strip()  # optional

        # Validate required fields
        if not email:
            return jsonify({'message': 'email is required'}), 400
        if not password:
            return jsonify({'message': 'password is required'}), 400
        if not username:
            return jsonify({'message': 'username or name is required'}), 400

        # Validate email format
        if not validate_email(email):
            return jsonify({'message': 'Invalid email format'}), 400
        # Validate password strength
        password_error = validate_password(password)
        if password_error:
            return jsonify({'message': password_error}), 400

        # Uniqueness checks
        if User.query.filter_by(email=email).first():
            return jsonify({'message': 'Email already registered'}), 409
        if User.query.filter_by(username=username).first():
            return jsonify({'message': 'Username already taken'}), 409

        # Create new user (explicit assignments)
        user = User()
        user.username = username
        user.email = email
        user.phone = phone or ''  # DB column is NOT NULL in current schema
        user.set_password(password)

        db.session.add(user)
        db.session.commit()

        access_token = create_access_token(identity=str(user.id))
        return jsonify({
            'message': 'User registered successfully',
            'token': access_token,               # backward compatibility
            'access_token': access_token,        # preferred key
            'user': user.to_dict()
        }), 201
    except IntegrityError:
        db.session.rollback()
        current_app.logger.exception('Integrity error during registration')
        return jsonify({'message': 'User already exists or invalid data'}), 400
    except Exception as e:
        db.session.rollback()
        current_app.logger.exception('Registration failed')
        return jsonify({'message': f'Registration failed: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json(silent=True)
        if not isinstance(data, dict):
            return jsonify({'message': 'Invalid JSON payload'}), 400
        if not data.get('email') or not data.get('password'):
            return jsonify({'message': 'Email and password are required'}), 400
        user = User.query.filter_by(email=data['email']).first()
        if not user or not user.check_password(data['password']):
            return jsonify({'message': 'Invalid credentials'}), 401
        access_token = create_access_token(identity=str(user.id))
        return jsonify({
            'message': 'Login successful',
            'token': access_token,
            'access_token': access_token,
            'user': user.to_dict()
        }), 200
    except Exception as e:
        current_app.logger.exception('Login failed')
        return jsonify({'message': f'Login failed: {str(e)}'}), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    try:
        user_id = get_jwt_identity()
        try:
            user_id = int(user_id)
        except Exception:
            pass
        user = User.query.get(user_id)
        if not user:
            return jsonify({'message': 'User not found'}), 404
        return jsonify({'user': user.to_dict()}), 200
    except Exception as e:
        return jsonify({'message': f'Failed to get profile: {str(e)}'}), 500

@auth_bp.route('/verify', methods=['GET'])
@jwt_required()
def verify_token():
    """Verify JWT token validity and return user details if valid."""
    try:
        user_id = get_jwt_identity()
        try:
            user_id = int(user_id)
        except Exception:
            pass
        user = User.query.get(user_id)
        if user:
            return jsonify({'valid': True, 'user': user.to_dict()}), 200
        return jsonify({'valid': False}), 401
    except Exception as e:
        return jsonify({'valid': False, 'error': str(e)}), 401
