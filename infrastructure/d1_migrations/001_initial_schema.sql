-- Mobility Ops 360 Database Schema
-- Created: 2024-01-01

-- ドライバー管理テーブル
CREATE TABLE IF NOT EXISTS drivers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT NOT NULL,
    license_number TEXT NOT NULL,
    vehicle_type TEXT NOT NULL CHECK (vehicle_type IN ('standard', 'premium', 'wheelchair')),
    vehicle_number TEXT NOT NULL,
    vehicle_model TEXT NOT NULL,
    vehicle_color TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending_verification' CHECK (status IN ('pending_verification', 'available', 'busy', 'offline', 'suspended')),
    rating REAL DEFAULT 0,
    total_rides INTEGER DEFAULT 0,
    total_earnings REAL DEFAULT 0,
    total_ratings INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- ドライバー位置情報テーブル
CREATE TABLE IF NOT EXISTS driver_locations (
    driver_id TEXT PRIMARY KEY,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    heading REAL DEFAULT 0,
    speed REAL DEFAULT 0,
    accuracy REAL DEFAULT 0,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- ドライバー位置履歴テーブル
CREATE TABLE IF NOT EXISTS driver_location_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    heading REAL DEFAULT 0,
    speed REAL DEFAULT 0,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- ドライバー稼働状況履歴テーブル
CREATE TABLE IF NOT EXISTS driver_status_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id TEXT NOT NULL,
    status TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- ドライバー評価テーブル
CREATE TABLE IF NOT EXISTS driver_ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id TEXT NOT NULL,
    customer_id TEXT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- ドライバー収益テーブル
CREATE TABLE IF NOT EXISTS driver_earnings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id TEXT NOT NULL,
    ride_id TEXT NOT NULL,
    amount REAL NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- ドライバーシフト管理テーブル
CREATE TABLE IF NOT EXISTS driver_shifts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id TEXT NOT NULL,
    shift_date TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'active', 'completed', 'cancelled')),
    created_at TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- 配車リクエストテーブル
CREATE TABLE IF NOT EXISTS dispatch_requests (
    id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    pickup_location TEXT NOT NULL,
    destination TEXT NOT NULL,
    vehicle_type TEXT NOT NULL DEFAULT 'standard' CHECK (vehicle_type IN ('standard', 'premium', 'wheelchair')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'calling', 'confirmed', 'assigned', 'in_progress', 'completed', 'cancelled')),
    driver_id TEXT,
    estimated_arrival INTEGER,
    vehicle_number TEXT,
    driver_name TEXT,
    call_sid TEXT,
    call_status TEXT,
    call_updated_at TEXT,
    confirmed_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT,
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- 音声対話履歴テーブル
CREATE TABLE IF NOT EXISTS voice_interactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dispatch_id TEXT NOT NULL,
    speech_result TEXT,
    confidence REAL,
    call_sid TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (dispatch_id) REFERENCES dispatch_requests(id)
);

-- マッチング結果テーブル
CREATE TABLE IF NOT EXISTS matching_results (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dispatch_id TEXT NOT NULL,
    driver_id TEXT NOT NULL,
    matching_score REAL NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (dispatch_id) REFERENCES dispatch_requests(id),
    FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_drivers_status ON drivers(status);
CREATE INDEX IF NOT EXISTS idx_drivers_email ON drivers(email);
CREATE INDEX IF NOT EXISTS idx_driver_locations_timestamp ON driver_locations(timestamp);
CREATE INDEX IF NOT EXISTS idx_driver_location_history_driver_timestamp ON driver_location_history(driver_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_dispatch_requests_status ON dispatch_requests(status);
CREATE INDEX IF NOT EXISTS idx_dispatch_requests_created_at ON dispatch_requests(created_at);
CREATE INDEX IF NOT EXISTS idx_voice_interactions_dispatch_id ON voice_interactions(dispatch_id);
CREATE INDEX IF NOT EXISTS idx_matching_results_dispatch_id ON matching_results(dispatch_id);
CREATE INDEX IF NOT EXISTS idx_driver_earnings_driver_timestamp ON driver_earnings(driver_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_driver_shifts_driver_date ON driver_shifts(driver_id, shift_date);