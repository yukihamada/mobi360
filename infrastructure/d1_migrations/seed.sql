-- Mobility Ops 360 - Sample Data for Testing
-- サンプルドライバーデータ

INSERT OR REPLACE INTO drivers (
    id, name, email, phone, license_number, vehicle_type, vehicle_number,
    vehicle_model, vehicle_color, status, rating, total_rides, total_earnings,
    created_at, updated_at
) VALUES 
(
    'driver-001',
    '田中太郎',
    'tanaka@mobi360.app',
    '+81-90-1234-5678',
    'TK123456789',
    'standard',
    'TK-001',
    'Toyota Prius',
    'White',
    'available',
    4.8,
    150,
    245000.0,
    '2024-01-01T00:00:00Z',
    '2024-01-01T00:00:00Z'
),
(
    'driver-002',
    '佐藤花子',
    'sato@mobi360.app',
    '+81-90-2345-6789',
    'ST987654321',
    'premium',
    'TK-002',
    'Toyota Alphard',
    'Black',
    'available',
    4.9,
    200,
    380000.0,
    '2024-01-01T00:00:00Z',
    '2024-01-01T00:00:00Z'
),
(
    'driver-003',
    '山田次郎',
    'yamada@mobi360.app',
    '+81-90-3456-7890',
    'YM456789012',
    'wheelchair',
    'TK-003',
    'Toyota Hiace',
    'Blue',
    'offline',
    4.7,
    98,
    156000.0,
    '2024-01-01T00:00:00Z',
    '2024-01-01T00:00:00Z'
);

-- サンプル位置情報
INSERT OR REPLACE INTO driver_locations (
    driver_id, latitude, longitude, heading, speed, accuracy, timestamp
) VALUES 
(
    'driver-001',
    35.6762,
    139.6503,
    180.0,
    0.0,
    5.0,
    '2024-01-01T09:00:00Z'
),
(
    'driver-002',
    35.6584,
    139.7016,
    90.0,
    0.0,
    3.0,
    '2024-01-01T09:00:00Z'
);

-- サンプル配車リクエスト
INSERT OR REPLACE INTO dispatch_requests (
    id, customer_name, customer_phone, pickup_location, destination,
    vehicle_type, status, estimated_arrival, vehicle_number, driver_name,
    created_at
) VALUES 
(
    'dispatch-001',
    '鈴木一郎',
    '+81-90-9876-5432',
    '東京駅',
    '羽田空港',
    'standard',
    'pending',
    15,
    'TK-001',
    '田中太郎',
    '2024-01-01T09:00:00Z'
),
(
    'dispatch-002',
    '高橋美子',
    '+81-90-8765-4321',
    '新宿駅',
    '渋谷駅',
    'premium',
    'confirmed',
    12,
    'TK-002',
    '佐藤花子',
    '2024-01-01T09:15:00Z'
);