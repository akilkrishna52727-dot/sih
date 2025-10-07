from app.init import db
from datetime import datetime

class SoilTest(db.Model):
    __tablename__ = 'soil_tests'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    nitrogen = db.Column(db.Float, nullable=False)
    phosphorus = db.Column(db.Float, nullable=False)
    potassium = db.Column(db.Float, nullable=False)
    ph_level = db.Column(db.Float, nullable=False)
    organic_carbon = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships: Recommendation model defines backrefs; no duplicates here
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'nitrogen': self.nitrogen,
            'phosphorus': self.phosphorus,
            'potassium': self.potassium,
            'ph_level': self.ph_level,
            'organic_carbon': self.organic_carbon,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
