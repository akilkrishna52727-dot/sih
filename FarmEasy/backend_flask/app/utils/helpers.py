import re

def validate_email(email: str) -> bool:
    return re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email) is not None

def validate_password(password: str) -> str:
    if len(password) < 6:
        return 'Password must be at least 6 characters'
    if not re.search(r'[A-Z]', password):
        return 'Password must contain an uppercase letter'
    if not re.search(r'[a-z]', password):
        return 'Password must contain a lowercase letter'
    if not re.search(r'\d', password):
        return 'Password must contain a number'
    return ''
