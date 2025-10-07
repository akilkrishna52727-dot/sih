from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.init import db
from app.models.transaction import Transaction
from app.models.crop import Crop
from app.models.user import User
from app.services.blockchain_service import BlockchainService

marketplace_bp = Blueprint('marketplace', __name__)

@marketplace_bp.route('/products', methods=['GET'])
@jwt_required()
def get_marketplace_products():
	try:
		# Get available products (pending transactions)
		products = db.session.query(Transaction, Crop, User)\
			.join(Crop, Transaction.crop_id == Crop.id)\
			.join(User, Transaction.farmer_id == User.id)\
			.filter(Transaction.status == 'pending')\
			.filter(Transaction.buyer_id.is_(None))\
			.all()
        
		product_list = []
		for transaction, crop, farmer in products:
			product_list.append({
				'id': transaction.id,
				'crop_name': crop.name,
				'farmer_name': farmer.username,
				'farmer_id': farmer.id,
				'quantity': transaction.quantity,
				'price': transaction.price,
				'total_amount': transaction.quantity * transaction.price,
				'quality': 'Grade A',  # Default quality
				'location': 'India',  # Default location
				'harvest_date': transaction.created_at.strftime('%Y-%m-%d'),
				'created_at': transaction.created_at.isoformat()
			})
        
		return jsonify({
			'products': product_list,
			'message': 'Products retrieved successfully'
		}), 200
        
	except Exception as e:
		return jsonify({'message': f'Failed to get products: {str(e)}'}), 500

@marketplace_bp.route('/sell', methods=['POST'])
@jwt_required()
def list_product_for_sale():
	try:
		user_id = get_jwt_identity()
		data = request.get_json()
        
		# Validate input
		required_fields = ['crop_id', 'quantity', 'price']
		for field in required_fields:
			if field not in data:
				return jsonify({'message': f'{field} is required'}), 400
        
		# Create transaction
		transaction = Transaction()
		transaction.farmer_id = user_id
		transaction.crop_id = data['crop_id']
		transaction.quantity = float(data['quantity'])
		transaction.price = float(data['price'])
		transaction.status = 'pending'
        
		db.session.add(transaction)
		db.session.commit()
        
		return jsonify({
			'message': 'Product listed successfully',
			'transaction': transaction.to_dict()
		}), 201
        
	except Exception as e:
		db.session.rollback()
		return jsonify({'message': f'Failed to list product: {str(e)}'}), 500

@marketplace_bp.route('/buy/<int:transaction_id>', methods=['POST'])
@jwt_required()
def buy_product(transaction_id):
	try:
		user_id = get_jwt_identity()
        
		# Find the transaction
		transaction = Transaction.query.get(transaction_id)
		if not transaction:
			return jsonify({'message': 'Product not found'}), 404
        
		if transaction.status != 'pending':
			return jsonify({'message': 'Product not available'}), 400
        
		if transaction.farmer_id == user_id:
			return jsonify({'message': 'Cannot buy your own product'}), 400
        
		# Update transaction
		transaction.buyer_id = user_id
		transaction.status = 'completed'
        
		# Create blockchain record
		blockchain_service = BlockchainService()
		blockchain_hash = blockchain_service.create_transaction_block(
			farmer_id=transaction.farmer_id,
			buyer_id=user_id,
			crop_id=transaction.crop_id,
			quantity=transaction.quantity,
			price=transaction.price
		)
        
		transaction.blockchain_hash = blockchain_hash
        
		db.session.commit()
        
		return jsonify({
			'message': 'Purchase completed successfully',
			'transaction': transaction.to_dict()
		}), 200
        
	except Exception as e:
		db.session.rollback()
		return jsonify({'message': f'Purchase failed: {str(e)}'}), 500

@marketplace_bp.route('/my-orders', methods=['GET'])
@jwt_required()
def get_my_orders():
	try:
		user_id = get_jwt_identity()
        
		# Get user's purchases and sales
		purchases = db.session.query(Transaction, Crop, User)\
			.join(Crop, Transaction.crop_id == Crop.id)\
			.join(User, Transaction.farmer_id == User.id)\
			.filter(Transaction.buyer_id == user_id)\
			.all()
        
		sales = db.session.query(Transaction, Crop, User)\
			.join(Crop, Transaction.crop_id == Crop.id)\
			.outerjoin(User, Transaction.buyer_id == User.id)\
			.filter(Transaction.farmer_id == user_id)\
			.all()
        
		purchase_list = []
		for transaction, crop, farmer in purchases:
			purchase_list.append({
				'type': 'purchase',
				'transaction': transaction.to_dict(),
				'crop': crop.to_dict(),
				'farmer': farmer.to_dict()
			})
        
		sales_list = []
		for transaction, crop, buyer in sales:
			sales_list.append({
				'type': 'sale',
				'transaction': transaction.to_dict(),
				'crop': crop.to_dict(),
				'buyer': buyer.to_dict() if buyer else None
			})
        
		return jsonify({
			'purchases': purchase_list,
			'sales': sales_list,
			'message': 'Orders retrieved successfully'
		}), 200
    
	except Exception as e:
		return jsonify({'message': f'Failed to get orders: {str(e)}'}), 500
