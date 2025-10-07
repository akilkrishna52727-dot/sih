from twilio.rest import Client
from flask import current_app

class SMSService:
    def __init__(self):
        self.account_sid = current_app.config.get('TWILIO_ACCOUNT_SID')
        self.auth_token = current_app.config.get('TWILIO_AUTH_TOKEN')
        self.phone_number = current_app.config.get('TWILIO_PHONE_NUMBER')
        
        if self.account_sid and self.auth_token:
            self.client = Client(self.account_sid, self.auth_token)
        else:
            self.client = None
    
    def send_sms(self, to_number, message):
        """Send SMS to a phone number"""
        try:
            if not self.client:
                return False, "SMS service not configured"
            
            message = self.client.messages.create(
                body=message,
                from_=self.phone_number,
                to=to_number
            )
            
            return True, message.sid
            
        except Exception as e:
            return False, f"SMS sending failed: {str(e)}"
    
    def send_weather_alert(self, to_number, weather_risks):
        """Send weather-based agricultural alerts"""
        if not weather_risks:
            return True, "No alerts to send"
        
        high_priority_risks = [risk for risk in weather_risks if risk['severity'] == 'HIGH']
        
        if high_priority_risks:
            alert_messages = []
            for risk in high_priority_risks[:2]:  # Send max 2 high priority alerts
                alert_messages.append(f"🚨 {risk['message']}")
            
            message = f"FarmEasy Alert:\n" + "\n".join(alert_messages)
            return self.send_sms(to_number, message)
        
        return True, "No high priority alerts"
    
    def send_crop_recommendation_sms(self, to_number, recommendations, farmer_name):
        """Send crop recommendation via SMS"""
        if not recommendations:
            return False, "No recommendations available"
        
        top_recommendation = recommendations[0]
        message = (
            f"Hi {farmer_name}! 🌾\n"
            f"Based on your soil test, we recommend: {top_recommendation['crop'].title()}\n"
            f"Confidence: {top_recommendation['confidence_percentage']}%\n"
            f"Check the app for detailed information.\n"
            f"- FarmEasy Team"
        )
        
        return self.send_sms(to_number, message)
    
    def send_irrigation_reminder(self, to_number, farmer_name):
        """Send irrigation reminder"""
        message = (
            f"Hi {farmer_name}! 💧\n"
            f"Reminder: It's time to check your crop irrigation.\n"
            f"Weather conditions suggest watering may be needed.\n"
            f"- FarmEasy Team"
        )
        
        return self.send_sms(to_number, message)
    
    def send_fertilizer_alert(self, to_number, farmer_name, delay_hours):
        """Send fertilizer application delay alert"""
        message = (
            f"Hi {farmer_name}! ⚠️\n"
            f"Weather Alert: Heavy rainfall expected.\n"
            f"Delay fertilizer application by {delay_hours} hours.\n"
            f"- FarmEasy Team"
        )
        
        return self.send_sms(to_number, message)
