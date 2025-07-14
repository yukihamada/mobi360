-- Mobility Ops 360 データベーススキーマ
-- 初期テーブル作成

-- 会社テーブル
CREATE TABLE IF NOT EXISTS companies (
    id TEXT PRIMARY KEY,
    company_name TEXT NOT NULL,
    company_address TEXT NOT NULL,
    company_phone TEXT NOT NULL,
    license_number TEXT NOT NULL,
    representative_name TEXT NOT NULL,
    representative_email TEXT NOT NULL UNIQUE,
    service_area TEXT,
    vehicle_count INTEGER DEFAULT 0,
    driver_count INTEGER DEFAULT 0,
    selected_plan TEXT DEFAULT 'standard',
    status TEXT DEFAULT 'pending', -- pending, approved, active, suspended
    created_at TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- ドライバーテーブル
CREATE TABLE IF NOT EXISTS drivers (
    id TEXT PRIMARY KEY,
    company_id TEXT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    birthdate TEXT NOT NULL,
    license_number TEXT,
    license_expiry TEXT,
    taxi_license_number TEXT,
    has_own_vehicle INTEGER DEFAULT 0,
    is_full_time INTEGER DEFAULT 1,
    working_area TEXT,
    vehicle_model TEXT,
    vehicle_year TEXT,
    vehicle_plate TEXT,
    insurance_number TEXT,
    bank_name TEXT,
    branch_name TEXT,
    account_number TEXT,
    account_holder TEXT,
    status TEXT DEFAULT 'pending', -- pending, approved, active, suspended, offline
    latitude REAL,
    longitude REAL,
    heading REAL,
    speed REAL,
    accuracy REAL,
    location_updated_at TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies (id)
);

-- 配車リクエストテーブル
CREATE TABLE IF NOT EXISTS dispatch_requests (
    id TEXT PRIMARY KEY,
    company_id TEXT,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    pickup_location TEXT NOT NULL,
    pickup_latitude REAL,
    pickup_longitude REAL,
    destination TEXT NOT NULL,
    destination_latitude REAL,
    destination_longitude REAL,
    vehicle_type TEXT DEFAULT 'standard',
    status TEXT DEFAULT 'pending', -- pending, assigned, picked_up, in_progress, completed, cancelled
    assigned_driver_id TEXT,
    pickup_time TEXT,
    estimated_arrival TEXT,
    actual_arrival TEXT,
    completion_time TEXT,
    fare_amount REAL,
    distance_km REAL,
    duration_minutes INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies (id),
    FOREIGN KEY (assigned_driver_id) REFERENCES drivers (id)
);

-- AI音声配車ログテーブル
CREATE TABLE IF NOT EXISTS voice_dispatch_logs (
    id TEXT PRIMARY KEY,
    dispatch_request_id TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    call_sid TEXT,
    recording_url TEXT,
    transcription TEXT,
    ai_response TEXT,
    call_duration INTEGER,
    call_status TEXT, -- ringing, in-progress, completed, busy, failed, no-answer
    created_at TEXT NOT NULL,
    FOREIGN KEY (dispatch_request_id) REFERENCES dispatch_requests (id)
);

-- ドライバーの稼働履歴テーブル
CREATE TABLE IF NOT EXISTS driver_work_sessions (
    id TEXT PRIMARY KEY,
    driver_id TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    total_trips INTEGER DEFAULT 0,
    total_distance_km REAL DEFAULT 0,
    total_earnings REAL DEFAULT 0,
    status TEXT DEFAULT 'active', -- active, ended
    created_at TEXT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers (id)
);

-- 車両テーブル
CREATE TABLE IF NOT EXISTS vehicles (
    id TEXT PRIMARY KEY,
    company_id TEXT,
    driver_id TEXT,
    model TEXT NOT NULL,
    year TEXT NOT NULL,
    plate_number TEXT NOT NULL UNIQUE,
    vehicle_type TEXT DEFAULT 'standard', -- standard, premium, accessible
    insurance_number TEXT,
    inspection_expiry TEXT,
    status TEXT DEFAULT 'active', -- active, maintenance, inactive
    created_at TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies (id),
    FOREIGN KEY (driver_id) REFERENCES drivers (id)
);

-- システム設定テーブル
CREATE TABLE IF NOT EXISTS system_settings (
    id TEXT PRIMARY KEY,
    company_id TEXT,
    setting_key TEXT NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies (id)
);

-- 会社テーブルに電話番号関連カラムを追加
ALTER TABLE companies ADD COLUMN twilio_phone_number TEXT;
ALTER TABLE companies ADD COLUMN operator_phone TEXT;
ALTER TABLE companies ADD COLUMN ai_routing_enabled INTEGER DEFAULT 1;

-- メトリクス・分析データテーブル
CREATE TABLE IF NOT EXISTS analytics_metrics (
    id TEXT PRIMARY KEY,
    company_id TEXT,
    metric_type TEXT NOT NULL, -- cost_reduction, driver_efficiency, revenue, etc.
    metric_value REAL NOT NULL,
    metric_date TEXT NOT NULL,
    additional_data TEXT, -- JSON format for extra details
    created_at TEXT NOT NULL,
    FOREIGN KEY (company_id) REFERENCES companies (id)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_companies_email ON companies(representative_email);
CREATE INDEX IF NOT EXISTS idx_drivers_email ON drivers(email);
CREATE INDEX IF NOT EXISTS idx_drivers_company ON drivers(company_id);
CREATE INDEX IF NOT EXISTS idx_drivers_status ON drivers(status);
CREATE INDEX IF NOT EXISTS idx_drivers_location ON drivers(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_dispatch_status ON dispatch_requests(status);
CREATE INDEX IF NOT EXISTS idx_dispatch_company ON dispatch_requests(company_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_driver ON dispatch_requests(assigned_driver_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_created ON dispatch_requests(created_at);
CREATE INDEX IF NOT EXISTS idx_voice_logs_dispatch ON voice_dispatch_logs(dispatch_request_id);
CREATE INDEX IF NOT EXISTS idx_work_sessions_driver ON driver_work_sessions(driver_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_company ON vehicles(company_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_driver ON vehicles(driver_id);
CREATE INDEX IF NOT EXISTS idx_analytics_company_date ON analytics_metrics(company_id, metric_date);

-- 初期データ挿入
INSERT OR IGNORE INTO system_settings (id, setting_key, setting_value, description, created_at) VALUES
('sys_001', 'max_search_radius_km', '10', 'ドライバー検索の最大半径（km）', datetime('now')),
('sys_002', 'default_matching_timeout_sec', '30', 'ドライバーマッチングのタイムアウト（秒）', datetime('now')),
('sys_003', 'location_update_interval_sec', '5', '位置情報更新間隔（秒）', datetime('now')),
('sys_004', 'ai_voice_language', 'ja-JP', 'AI音声の言語設定', datetime('now')),
('sys_005', 'twilio_voice_webhook_url', '', 'Twilio音声Webhook URL', datetime('now'));

-- サンプルデータ（テスト用）
INSERT OR IGNORE INTO companies (
    id, company_name, company_address, company_phone, license_number,
    representative_name, representative_email, service_area, vehicle_count,
    driver_count, selected_plan, status, created_at
) VALUES (
    'company_demo_001',
    'デモタクシー株式会社',
    '東京都新宿区西新宿1-1-1',
    '03-1234-5678',
    '関自旅二第1234号',
    'デモ太郎',
    'demo@example.com',
    '東京都23区内',
    50,
    25,
    'standard',
    'active',
    datetime('now')
);

INSERT OR IGNORE INTO drivers (
    id, company_id, name, phone, email, address, birthdate,
    license_number, license_expiry, taxi_license_number, has_own_vehicle,
    is_full_time, working_area, status, created_at
) VALUES (
    'driver_demo_001',
    'company_demo_001',
    'ドライバー太郎',
    '090-1234-5678',
    'driver@example.com',
    '東京都渋谷区渋谷1-1-1',
    '1985-01-01',
    '123456789012',
    '2028-01-01',
    '第12345号',
    1,
    1,
    '東京都23区内',
    'active',
    datetime('now')
);