import requests
from flask import current_app

class WeatherService:
    def __init__(self):
        self.api_key = current_app.config.get('OPENWEATHER_API_KEY')
        self.base_url = "http://api.openweathermap.org/data/2.5"
    
    def get_current_weather(self, city=None, lat=None, lon=None):
        """Get current weather data"""
        try:
            if city:
                url = f"{self.base_url}/weather"
                params = {
                    'q': city,
                    'appid': self.api_key,
                    'units': 'metric'
                }
            elif lat and lon:
                url = f"{self.base_url}/weather"
                params = {
                    'lat': lat,
                    'lon': lon,
                    'appid': self.api_key,
                    'units': 'metric'
                }
            else:
                return None, "City or coordinates required"
            
            response = requests.get(url, params=params)
            
            if response.status_code == 200:
                data = response.json()
                return self._format_weather_data(data), None
            else:
                return None, f"Weather API error: {response.status_code}"
                
        except Exception as e:
            return None, f"Weather service error: {str(e)}"
    
    def get_weather_forecast(self, city=None, lat=None, lon=None, days=5):
        """Get weather forecast"""
        try:
            if city:
                url = f"{self.base_url}/forecast"
                params = {
                    'q': city,
                    'appid': self.api_key,
                    'units': 'metric',
                    'cnt': days * 8  # 8 forecasts per day (3-hour intervals)
                }
            elif lat and lon:
                url = f"{self.base_url}/forecast"
                params = {
                    'lat': lat,
                    'lon': lon,
                    'appid': self.api_key,
                    'units': 'metric',
                    'cnt': days * 8
                }
            else:
                return None, "City or coordinates required"
            
            response = requests.get(url, params=params)
            
            if response.status_code == 200:
                data = response.json()
                return self._format_forecast_data(data), None
            else:
                return None, f"Weather API error: {response.status_code}"
                
        except Exception as e:
            return None, f"Weather service error: {str(e)}"
    
    def _format_weather_data(self, data):
        """Format current weather data"""
        return {
            'location': data.get('name', ''),
            'country': data.get('sys', {}).get('country', ''),
            'temperature': data.get('main', {}).get('temp', 0),
            'feels_like': data.get('main', {}).get('feels_like', 0),
            'humidity': data.get('main', {}).get('humidity', 0),
            'pressure': data.get('main', {}).get('pressure', 0),
            'description': data.get('weather', [{}])[0].get('description', ''),
            'icon': data.get('weather', [{}])[0].get('icon', ''),
            'wind_speed': data.get('wind', {}).get('speed', 0),
            'wind_direction': data.get('wind', {}).get('deg', 0),
            'visibility': data.get('visibility', 0) / 1000,  # Convert to km
            'uv_index': data.get('uvi', 0),
            'timestamp': data.get('dt', 0)
        }
    
    def _format_forecast_data(self, data):
        """Format forecast data"""
        forecasts = []
        
        for item in data.get('list', []):
            forecast = {
                'datetime': item.get('dt', 0),
                'temperature': item.get('main', {}).get('temp', 0),
                'humidity': item.get('main', {}).get('humidity', 0),
                'description': item.get('weather', [{}])[0].get('description', ''),
                'icon': item.get('weather', [{}])[0].get('icon', ''),
                'wind_speed': item.get('wind', {}).get('speed', 0),
                'rain': item.get('rain', {}).get('3h', 0) if item.get('rain') else 0
            }
            forecasts.append(forecast)
        
        return {
            'location': data.get('city', {}).get('name', ''),
            'country': data.get('city', {}).get('country', ''),
            'forecasts': forecasts
        }
    
    def analyze_weather_risks(self, weather_data, forecast_data):
        """Analyze weather data for agricultural risks"""
        risks = []
        
        if not weather_data or not forecast_data:
            return risks
        
        # High temperature risk
        if weather_data.get('temperature', 0) > 35:
            risks.append({
                'type': 'HIGH_TEMPERATURE',
                'severity': 'HIGH',
                'message': f"High temperature alert: {weather_data['temperature']}°C. Consider providing shade for crops.",
                'recommendation': "Increase irrigation frequency and provide shade coverage"
            })
        
        # Low humidity risk
        if weather_data.get('humidity', 0) < 30:
            risks.append({
                'type': 'LOW_HUMIDITY',
                'severity': 'MEDIUM',
                'message': f"Low humidity: {weather_data['humidity']}%. Increase irrigation.",
                'recommendation': "Increase irrigation frequency to maintain soil moisture"
            })
        
        # High wind risk
        if weather_data.get('wind_speed', 0) > 10:
            risks.append({
                'type': 'HIGH_WIND',
                'severity': 'MEDIUM',
                'message': f"High wind speed: {weather_data['wind_speed']} m/s. Protect delicate crops.",
                'recommendation': "Install windbreaks to protect crops"
            })
        
        # Rain forecast analysis
        total_rain = sum(f.get('rain', 0) for f in forecast_data.get('forecasts', [])[:8])  # Next 24 hours
        
        if total_rain > 50:
            risks.append({
                'type': 'HEAVY_RAINFALL',
                'severity': 'HIGH',
                'message': f"Heavy rainfall expected: {total_rain}mm in next 24 hours.",
                'recommendation': "Ensure proper drainage and delay fertilizer application"
            })
        elif total_rain == 0:
            risks.append({
                'type': 'NO_RAINFALL',
                'severity': 'MEDIUM',
                'message': "No rainfall expected in next 24 hours.",
                'recommendation': "Plan irrigation schedule accordingly"
            })
        
        return risks
