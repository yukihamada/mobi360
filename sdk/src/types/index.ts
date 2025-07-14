// 基本レスポンス型
export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: string;
}

// 認証関連
export interface CompanyRegistration {
  companyName: string;
  companyAddress: string;
  companyPhone: string;
  licenseNumber: string;
  representativeName: string;
  representativeEmail: string;
  serviceArea: string;
  vehicleCount: string;
  driverCount: string;
  selectedPlan: 'basic' | 'standard' | 'premium';
}

export interface DriverRegistration {
  name: string;
  phone: string;
  email: string;
  address: string;
  birthdate: string;
  licenseNumber: string;
  licenseExpiry: string;
  taxiLicenseNumber: string;
  hasOwnVehicle: boolean;
  isFullTime: boolean;
  workingArea: string;
  vehicleModel?: string;
  vehicleYear?: string;
  vehiclePlate?: string;
  insuranceNumber?: string;
  bankName: string;
  branchName: string;
  accountNumber: string;
  accountHolder: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthToken {
  token: string;
  expiresAt?: string;
  userType?: 'company' | 'driver' | 'admin';
}

// ダッシュボード
export interface DashboardStats {
  companies: number;
  drivers: number;
  todayDispatches: number;
  activeDrivers: number;
  costReduction: number;
  driverSufficiency: number;
  profitIncrease: number;
  systemUptime: number;
}

export interface RecentRegistration {
  id: string;
  name?: string;
  company_name?: string;
  status: string;
  created_at: string;
}

// ドライバー管理
export interface DriverLocation {
  driver_id?: string;
  latitude: number;
  longitude: number;
  heading?: number;
  speed?: number;
  accuracy?: number;
  timestamp?: string;
}

export interface Driver {
  id: string;
  name: string;
  phone: string;
  email: string;
  status: 'available' | 'busy' | 'offline';
  location?: DriverLocation;
  vehicle_model?: string;
  vehicle_plate?: string;
  rating?: number;
  created_at: string;
  updated_at?: string;
}

export interface NearbyDriver extends Driver {
  distance: number;
  estimated_arrival?: number;
}

// AI音声配車
export interface VoiceDispatchRequest {
  customerName: string;
  customerPhone: string;
  pickupLocation: string;
  destination: string;
  vehicleType: 'standard' | 'premium' | 'large';
}

export interface VoiceDispatch {
  id: string;
  customer_name: string;
  customer_phone: string;
  pickup_location: string;
  destination: string;
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  driver_name?: string;
  vehicle_model?: string;
  vehicle_plate?: string;
  estimated_arrival?: number;
  created_at: string;
  updated_at?: string;
}

// リアルタイム配車
export interface Location {
  latitude: number;
  longitude: number;
  address?: string;
}

export interface RealtimeDispatchRequest {
  pickup_location: Location;
  destination: Location;
  customer_phone: string;
  vehicle_type?: 'standard' | 'premium' | 'large';
  notes?: string;
}

// WebSocket メッセージ
export interface WebSocketMessage<T = any> {
  type: string;
  data?: T;
  timestamp?: string;
}

export interface LocationUpdateMessage {
  type: 'location_update';
  location: DriverLocation;
}

export interface StatusUpdateMessage {
  type: 'status_update';
  status: 'available' | 'busy' | 'offline';
}

export interface DispatchRequestMessage {
  type: 'dispatch_request';
  data: {
    dispatch_id: string;
    customer_name: string;
    pickup_location: string;
    destination: string;
  };
}

// エクスポート
export interface ExportOptions {
  format: 'csv' | 'json' | 'pdf';
  startDate?: string;
  endDate?: string;
  status?: string;
  limit?: number;
}

// 設定
export interface SystemConfig {
  max_dispatch_radius: number;
  default_eta_buffer: number;
  surge_pricing_enabled: boolean;
  ai_voice_enabled: boolean;
  realtime_tracking_enabled: boolean;
  maintenance_mode: boolean;
}

// メトリクス
export interface SystemMetrics {
  http_requests_total: Record<string, number>;
  active_websocket_connections: number;
  database_query_duration_ms: number;
  ai_processing_duration_ms: number;
  error_rate_percentage: number;
}

// ログ
export interface LogEntry {
  timestamp: string;
  level: 'debug' | 'info' | 'warn' | 'error';
  message: string;
  context?: Record<string, any>;
}

// ページネーション
export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// エラー
export interface ApiError {
  code: string;
  message: string;
  details?: any;
}

// SDK設定
export interface Mobi360Config {
  apiKey?: string;
  baseUrl?: string;
  timeout?: number;
  retryAttempts?: number;
  retryDelay?: number;
  debug?: boolean;
}