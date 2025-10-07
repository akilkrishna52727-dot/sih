
-- Create FarmEasy Database
CREATE DATABASE IF NOT EXISTS farmeasy_db;
USE farmeasy_db;

-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Soil Tests Table
CREATE TABLE soil_tests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nitrogen FLOAT NOT NULL,
    phosphorus FLOAT NOT NULL,
    potassium FLOAT NOT NULL,
    ph_level FLOAT NOT NULL,
    organic_carbon FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Crops Table
CREATE TABLE crops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    season VARCHAR(50) NOT NULL,
    min_temp FLOAT NOT NULL,
    max_temp FLOAT NOT NULL,
    min_rainfall FLOAT NOT NULL,
    max_rainfall FLOAT NOT NULL,
    soil_type VARCHAR(100) NOT NULL,
    expected_yield FLOAT NOT NULL,
    market_price FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recommendations Table
CREATE TABLE recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    soil_test_id INT NOT NULL,
    recommended_crop_id INT NOT NULL,
    confidence FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (soil_test_id) REFERENCES soil_tests(id) ON DELETE CASCADE,
    FOREIGN KEY (recommended_crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

-- Transactions Table (Marketplace)
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    buyer_id INT,
    crop_id INT NOT NULL,
    quantity FLOAT NOT NULL,
    price FLOAT NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    blockchain_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE
);

-- Weather Data Table
CREATE TABLE weather_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100) NOT NULL,
    temperature FLOAT NOT NULL,
    humidity FLOAT NOT NULL,
    rainfall FLOAT DEFAULT 0,
    wind_speed FLOAT DEFAULT 0,
    forecast_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alerts Table
CREATE TABLE alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    alert_type ENUM('weather', 'crop', 'market', 'general') NOT NULL,
    severity ENUM('low', 'medium', 'high') DEFAULT 'medium',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Subsidies Table
CREATE TABLE subsidies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT,
    scheme_name VARCHAR(200) NOT NULL,
    amount FLOAT NOT NULL,
    eligibility TEXT NOT NULL,
    region VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE SET NULL
);

-- Create Indexes for Better Performance
CREATE INDEX idx_soil_tests_user_id ON soil_tests(user_id);
CREATE INDEX idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX idx_transactions_farmer_id ON transactions(farmer_id);
CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_weather_location_date ON weather_data(location, forecast_date);
