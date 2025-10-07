from app.init import db
from datetime import datetime

class Transaction(db.Model):
	__tablename__ = 'transactions'
    
	id = db.Column(db.Integer, primary_key=True)
	farmer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
	buyer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
	crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
	quantity = db.Column(db.Float, nullable=False)
	price = db.Column(db.Float, nullable=False)
	status = db.Column(db.Enum('pending', 'completed', 'cancelled', name='transaction_status'), 
					  default='pending')
	blockchain_hash = db.Column(db.String(255), nullable=True)
	created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
	def to_dict(self):
		return {
			'id': self.id,
			'farmer_id': self.farmer_id,
			'buyer_id': self.buyer_id,
			'crop_id': self.crop_id,
			'quantity': self.quantity,
			'price': self.price,
			'status': self.status,
			'blockchain_hash': self.blockchain_hash,
			'total_amount': self.quantity * self.price,
			'created_at': self.created_at.isoformat() if self.created_at else None
		}

class Alert(db.Model):
	__tablename__ = 'alerts'
    
	id = db.Column(db.Integer, primary_key=True)
	user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
	message = db.Column(db.Text, nullable=False)
	alert_type = db.Column(db.Enum('weather', 'crop', 'market', 'general', name='alert_type'), 
						  nullable=False)
	severity = db.Column(db.Enum('low', 'medium', 'high', name='alert_severity'), 
						default='medium')
	is_read = db.Column(db.Boolean, default=False)
	created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
	def to_dict(self):
		return {
			'id': self.id,
			'user_id': self.user_id,
			'message': self.message,
			'alert_type': self.alert_type,
			'severity': self.severity,
			'is_read': self.is_read,
			'created_at': self.created_at.isoformat() if self.created_at else None
		}
