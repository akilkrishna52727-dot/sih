from datetime import datetime
import json
from app.init import db


class VirtualFarm(db.Model):
    __tablename__ = 'virtual_farms'

    id = db.Column(db.String(36), primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    land_size = db.Column(db.Float, nullable=False)
    crop_type = db.Column(db.String(50), nullable=False)
    location = db.Column(db.String(100), nullable=False)
    planting_date = db.Column(db.DateTime, nullable=False)
    soil_data = db.Column(db.Text)  # JSON string
    growth_stages = db.Column(db.Text)  # JSON string
    expected_yield = db.Column(db.Float, nullable=False)
    expected_profit = db.Column(db.Float, nullable=False)
    climate_risks = db.Column(db.Text)  # JSON string
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'land_size': self.land_size,
            'crop_type': self.crop_type,
            'location': self.location,
            'planting_date': self.planting_date.isoformat(),
            'soil_data': json.loads(self.soil_data) if self.soil_data else {},
            'growth_stages': json.loads(self.growth_stages) if self.growth_stages else [],
            'expected_yield': self.expected_yield,
            'expected_profit': self.expected_profit,
            'climate_risks': json.loads(self.climate_risks) if self.climate_risks else [],
            'created_at': self.created_at.isoformat() if self.created_at else None,
        }
