from app.init import db
from datetime import datetime

class Subsidy(db.Model):
    __tablename__ = 'subsidies'
    
    id = db.Column(db.Integer, primary_key=True)
    crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=True)
    scheme_name = db.Column(db.String(200), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    eligibility = db.Column(db.Text, nullable=False)
    region = db.Column(db.String(100), nullable=False)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'crop_id': self.crop_id,
            'scheme_name': self.scheme_name,
            'amount': self.amount,
            'eligibility': self.eligibility,
            'region': self.region,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
