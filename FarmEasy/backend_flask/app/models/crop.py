from app.init import db
__all__ = ['Crop', 'Recommendation']
from datetime import datetime

class Crop(db.Model):
    __tablename__ = 'crops'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    season = db.Column(db.String(50))
    min_temp = db.Column(db.Float)
    max_temp = db.Column(db.Float)
    min_rainfall = db.Column(db.Float)
    max_rainfall = db.Column(db.Float)
    soil_type = db.Column(db.String(50))
    expected_yield = db.Column(db.Float)
    market_price = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'season': self.season,
            'min_temp': self.min_temp,
            'max_temp': self.max_temp,
            'min_rainfall': self.min_rainfall,
            'max_rainfall': self.max_rainfall,
            'soil_type': self.soil_type,
            'expected_yield': self.expected_yield,
            'market_price': self.market_price,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class Recommendation(db.Model):
    __tablename__ = 'recommendations'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    soil_test_id = db.Column(db.Integer, db.ForeignKey('soil_tests.id'), nullable=False)
    recommended_crop_id = db.Column(db.Integer, db.ForeignKey('crops.id'), nullable=False)
    confidence = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship('User', backref='recommendations')
    soil_test = db.relationship('SoilTest', backref='recommendations')
    crop = db.relationship('Crop', backref='recommendations')

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'soil_test_id': self.soil_test_id,
            'recommended_crop_id': self.recommended_crop_id,
            'confidence': self.confidence,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
