from app.init import db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime

class User(db.Model):
	__tablename__ = 'users'
    
	id = db.Column(db.Integer, primary_key=True)
	username = db.Column(db.String(80), unique=True, nullable=False)
	email = db.Column(db.String(120), unique=True, nullable=False)
	password_hash = db.Column(db.String(255), nullable=False)
	phone = db.Column(db.String(20), nullable=False)
	created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
	# Relationships
	soil_tests = db.relationship('SoilTest', backref='user', lazy=True)
	transactions = db.relationship('Transaction', backref='farmer', lazy=True, foreign_keys='Transaction.farmer_id')
	alerts = db.relationship('Alert', backref='user', lazy=True)
    
	def set_password(self, password):
		self.password_hash = generate_password_hash(password)
    
	def check_password(self, password):
		return check_password_hash(self.password_hash, password)
    
	def to_dict(self):
		return {
			'id': self.id,
			'username': self.username,
			'email': self.email,
			'phone': self.phone,
			'created_at': self.created_at.isoformat() if self.created_at else None
		}
