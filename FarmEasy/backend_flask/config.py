import os
from datetime import timedelta

class Config:
	# Database (default to SQLite for local emulator-friendly setup; can override via env)
	MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')
	MYSQL_USER = os.getenv('MYSQL_USER', 'root')
	MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
	MYSQL_DB = os.getenv('MYSQL_DB', 'farmeasy_db')

	# Default to SQLite; allow overriding with SQLALCHEMY_DATABASE_URI env var
	SQLALCHEMY_DATABASE_URI = os.getenv(
		'SQLALCHEMY_DATABASE_URI',
		'sqlite:///farmeasy.db'
	)
	SQLALCHEMY_TRACK_MODIFICATIONS = False
    
	# JWT Configuration
	JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'your-secret-key-change-in-production')
	JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=7)
    
	# External APIs (set via environment for security)
	TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID', '')
	TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN', '')
	TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER', '')  # Your Twilio phone number
    
	OPENWEATHER_API_KEY = '46d0507895618287e17644cfee55e054'
    
	# Flask Settings
	SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key')
	DEBUG = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'