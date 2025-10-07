from app.init import create_app
import os

app = create_app()

if __name__ == '__main__':
	port = int(os.environ.get('PORT', 5000))
	host = os.environ.get('HOST', '0.0.0.0')  # Allow external connections
	# Force debug=True for development unless explicitly disabled
	debug = os.environ.get('FLASK_DEBUG', '1') not in ('0', 'false', 'False')
	app.run(host=host, port=port, debug=debug)