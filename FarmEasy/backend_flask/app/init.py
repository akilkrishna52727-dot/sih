from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from config import Config

db = SQLAlchemy()
jwt = JWTManager()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    CORS(app)
    
    # Register blueprints
    from app.routes.auth import auth_bp
    from app.routes.soil import soil_bp
    from app.routes.crops import crops_bp
    from app.routes.weather import weather_bp
    from app.routes.marketplace import marketplace_bp
    from app.routes.alerts import alerts_bp
    from app.routes.subsidies import subsidies_bp
    from app.routes.health import health_bp
    from app.routes.virtual_farm import virtual_farm_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(soil_bp, url_prefix='/api/soil')
    app.register_blueprint(crops_bp, url_prefix='/api/crops')
    app.register_blueprint(weather_bp, url_prefix='/api/weather')
    app.register_blueprint(marketplace_bp, url_prefix='/api/marketplace')
    app.register_blueprint(alerts_bp, url_prefix='/api/alerts')
    app.register_blueprint(subsidies_bp, url_prefix='/api/subsidies')
    app.register_blueprint(health_bp, url_prefix='/api')
    app.register_blueprint(virtual_farm_bp, url_prefix='/api/virtual-farm')
    
    # Create tables
    with app.app_context():
        db.create_all()
    
    return app
