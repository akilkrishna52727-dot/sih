USE farmeasy_db;

-- Insert Sample Crops Data
INSERT INTO crops (name, season, min_temp, max_temp, min_rainfall, max_rainfall, soil_type, expected_yield, market_price) VALUES
('Rice', 'Kharif', 20, 35, 1000, 2500, 'Clay', 3000, 30),
('Wheat', 'Rabi', 15, 25, 400, 800, 'Loamy', 2500, 25),
('Cotton', 'Kharif', 18, 32, 600, 1200, 'Sandy', 1500, 45),
('Sugarcane', 'Annual', 20, 35, 1200, 2000, 'Clay', 5000, 35),
('Maize', 'Kharif', 18, 30, 600, 1200, 'Loamy', 2800, 22),
('Barley', 'Rabi', 12, 25, 300, 600, 'Sandy', 2000, 20),
('Soybean', 'Kharif', 20, 32, 800, 1500, 'Loamy', 1800, 40),
('Mustard', 'Rabi', 15, 28, 400, 700, 'Sandy', 1200, 55),
('Groundnut', 'Kharif', 22, 35, 500, 1000, 'Sandy', 2200, 60),
('Sunflower', 'Rabi', 18, 30, 400, 800, 'Loamy', 1500, 50);

-- Insert Sample Subsidies Data
INSERT INTO subsidies (crop_id, scheme_name, amount, eligibility, region, is_active) VALUES
(1, 'PM-KISAN Rice Support', 6000, 'Small and marginal farmers with landholding up to 2 hectares', 'All India', TRUE),
(2, 'Wheat Production Incentive', 4500, 'Farmers adopting modern farming techniques', 'North India', TRUE),
(3, 'Cotton Technology Mission', 8000, 'Farmers using certified cotton seeds', 'Central India', TRUE),
(4, 'Sugarcane Development Scheme', 10000, 'Farmers with irrigation facilities', 'North & West India', TRUE),
(5, 'Maize Mission Scheme', 5000, 'Small farmers in tribal areas', 'All India', TRUE),
(7, 'Soybean Cluster Development', 7000, 'Farmers forming FPOs (Farmer Producer Organizations)', 'Central India', TRUE),
(9, 'Groundnut Development Program', 6500, 'Farmers in drought-prone areas', 'South & West India', TRUE),
(10, 'Oilseed Mission Support', 5500, 'Farmers growing oilseed crops', 'All India', TRUE);

-- Insert Sample Test User (Password: 'farmer123')
INSERT INTO users (username, email, password_hash, phone) VALUES
('test_farmer', 'farmer@test.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBVdciCzIUz8Nq', '+919876543210');

-- Insert Sample Weather Data
INSERT INTO weather_data (location, temperature, humidity, rainfall, wind_speed, forecast_date) VALUES
('Delhi', 28.5, 65, 0, 5.2, CURDATE()),
('Mumbai', 32.1, 78, 5.2, 8.1, CURDATE()),
('Bangalore', 26.8, 72, 2.1, 3.5, CURDATE()),
('Chennai', 31.2, 82, 8.5, 12.3, CURDATE()),
('Kolkata', 29.6, 75, 1.2, 6.8, CURDATE());
