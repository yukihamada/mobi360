import axios, { AxiosInstance, AxiosRequestConfig, AxiosError } from 'axios';
import WebSocket from 'ws';
import { EventEmitter } from 'events';
import {
  Mobi360Config,
  ApiResponse,
  ApiError,
  AuthToken,
  CompanyRegistration,
  DriverRegistration,
  LoginCredentials,
  DashboardStats,
  RecentRegistration,
  Driver,
  DriverLocation,
  NearbyDriver,
  VoiceDispatch,
  VoiceDispatchRequest,
  RealtimeDispatchRequest,
  ExportOptions,
  SystemConfig,
  SystemMetrics,
  LogEntry,
  PaginationParams,
  PaginatedResponse,
  WebSocketMessage
} from './types';

export class Mobi360Client extends EventEmitter {
  private axios: AxiosInstance;
  private config: Mobi360Config;
  private authToken?: string;
  private wsConnections: Map<string, WebSocket> = new Map();

  constructor(config: Mobi360Config = {}) {
    super();
    this.config = {
      baseUrl: config.baseUrl || 'https://mobility-ops-360-api.yukihamada.workers.dev',
      timeout: config.timeout || 30000,
      retryAttempts: config.retryAttempts || 3,
      retryDelay: config.retryDelay || 1000,
      debug: config.debug || false,
      ...config
    };

    this.axios = axios.create({
      baseURL: this.config.baseUrl,
      timeout: this.config.timeout,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    // リクエストインターセプター
    this.axios.interceptors.request.use(
      (config) => {
        if (this.authToken) {
          config.headers.Authorization = `Bearer ${this.authToken}`;
        }
        if (this.config.apiKey) {
          config.headers['X-API-Key'] = this.config.apiKey;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // レスポンスインターセプター
    this.axios.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        if (this.config.debug) {
          console.error('API Error:', error.response?.data || error.message);
        }

        // リトライロジック
        const config = error.config as AxiosRequestConfig & { _retry?: number };
        if (!config || !config._retry) {
          config._retry = 0;
        }

        if (config._retry < this.config.retryAttempts! && error.response?.status! >= 500) {
          config._retry++;
          await new Promise(resolve => setTimeout(resolve, this.config.retryDelay!));
          return this.axios(config);
        }

        return Promise.reject(error);
      }
    );
  }

  // 認証トークンの設定
  setAuthToken(token: string): void {
    this.authToken = token;
  }

  // ヘルスチェック
  async health(): Promise<ApiResponse<{ status: string; timestamp: string }>> {
    const response = await this.axios.get('/health');
    return response.data;
  }

  // 認証API
  auth = {
    registerCompany: async (data: CompanyRegistration): Promise<ApiResponse<{ companyId: string }>> => {
      const response = await this.axios.post('/auth/register/company', data);
      return response.data;
    },

    registerDriver: async (data: DriverRegistration): Promise<ApiResponse<{ driverId: string }>> => {
      const response = await this.axios.post('/auth/register/driver', data);
      return response.data;
    },

    login: async (credentials: LoginCredentials): Promise<ApiResponse<AuthToken>> => {
      const response = await this.axios.post('/auth/login', credentials);
      if (response.data.success && response.data.token) {
        this.setAuthToken(response.data.token);
      }
      return response.data;
    },

    verify: async (): Promise<ApiResponse<{ valid: boolean }>> => {
      const response = await this.axios.get('/auth/verify');
      return response.data;
    },

    refresh: async (token?: string): Promise<ApiResponse<AuthToken>> => {
      const response = await this.axios.post('/auth/refresh', { token: token || this.authToken });
      if (response.data.success && response.data.token) {
        this.setAuthToken(response.data.token);
      }
      return response.data;
    }
  };

  // ダッシュボードAPI
  dashboard = {
    stats: async (): Promise<ApiResponse<DashboardStats>> => {
      const response = await this.axios.get('/api/dashboard/stats');
      return response.data;
    },

    recentRegistrations: async (): Promise<ApiResponse<{ companies: RecentRegistration[]; drivers: RecentRegistration[] }>> => {
      const response = await this.axios.get('/api/dashboard/recent-registrations');
      return response.data;
    }
  };

  // ドライバーAPI
  drivers = {
    updateLocation: async (driverId: string, location: Omit<DriverLocation, 'driver_id'>): Promise<ApiResponse> => {
      const response = await this.axios.post('/api/drivers/location', {
        driver_id: driverId,
        ...location
      });
      return response.data;
    },

    getNearby: async (lat: number, lng: number, radius: number = 5): Promise<ApiResponse<{ drivers: NearbyDriver[] }>> => {
      const response = await this.axios.get('/api/nearby-drivers', {
        params: { lat, lng, radius }
      });
      return response.data;
    },

    getById: async (driverId: string): Promise<ApiResponse<{ driver: Driver }>> => {
      const response = await this.axios.get(`/api/drivers/${driverId}`);
      return response.data;
    },

    list: async (params?: PaginationParams): Promise<ApiResponse<PaginatedResponse<Driver>>> => {
      const response = await this.axios.get('/api/drivers', { params });
      return response.data;
    }
  };

  // AI音声配車API
  voiceDispatch = {
    create: async (data: VoiceDispatchRequest): Promise<ApiResponse<{
      dispatchId: string;
      assignedDriver?: any;
      estimatedArrival?: number;
      twimlUrl: string;
    }>> => {
      const response = await this.axios.post('/api/voice-dispatch/create', data);
      return response.data;
    },

    getById: async (dispatchId: string): Promise<ApiResponse<{ dispatch: VoiceDispatch }>> => {
      const response = await this.axios.get(`/api/voice-dispatch/${dispatchId}`);
      return response.data;
    },

    list: async (params?: PaginationParams): Promise<ApiResponse<{ dispatches: VoiceDispatch[] }>> => {
      const response = await this.axios.get('/api/voice-dispatch/list', { params });
      return response.data;
    },

    confirm: async (dispatchId: string): Promise<ApiResponse> => {
      const response = await this.axios.post(`/api/voice-dispatch/confirm/${dispatchId}`);
      return response.data;
    }
  };

  // リアルタイム配車API
  realtimeDispatch = {
    create: async (data: RealtimeDispatchRequest): Promise<ApiResponse<{
      dispatchId: string;
      matchedDriver?: any;
      estimatedArrival?: number;
    }>> => {
      const response = await this.axios.post('/api/realtime-dispatch', data);
      return response.data;
    }
  };

  // エクスポートAPI
  export = {
    drivers: async (options?: ExportOptions): Promise<Blob> => {
      const response = await this.axios.get('/api/export/drivers', {
        params: options,
        responseType: 'blob'
      });
      return response.data;
    },

    dispatches: async (options?: ExportOptions): Promise<Blob> => {
      const response = await this.axios.get('/api/export/dispatches', {
        params: options,
        responseType: 'blob'
      });
      return response.data;
    }
  };

  // 監視API
  monitoring = {
    metrics: async (): Promise<string> => {
      const response = await this.axios.get('/api/metrics', {
        responseType: 'text'
      });
      return response.data;
    },

    logs: async (level?: string, limit?: number): Promise<ApiResponse<{ logs: LogEntry[] }>> => {
      const response = await this.axios.get('/api/logs', {
        params: { level, limit }
      });
      return response.data;
    }
  };

  // 設定API
  config = {
    get: async (): Promise<ApiResponse<{ config: SystemConfig }>> => {
      const response = await this.axios.get('/api/config');
      return response.data;
    }
  };

  // WebSocket接続
  ws = {
    connect: (endpoint: 'general' | 'driver' | 'dispatch', id?: string): WebSocket => {
      let wsUrl = `${this.config.baseUrl!.replace('https:', 'wss:').replace('http:', 'ws:')}`;
      
      switch (endpoint) {
        case 'general':
          wsUrl += '/websocket';
          break;
        case 'driver':
          if (!id) throw new Error('Driver ID is required');
          wsUrl += `/ws/driver/${id}`;
          break;
        case 'dispatch':
          if (!id) throw new Error('Dispatch ID is required');
          wsUrl += `/ws/dispatch/${id}`;
          break;
      }

      const ws = new WebSocket(wsUrl, {
        headers: this.authToken ? { Authorization: `Bearer ${this.authToken}` } : {}
      });

      const connectionKey = `${endpoint}:${id || 'general'}`;
      this.wsConnections.set(connectionKey, ws);

      ws.on('open', () => {
        this.emit('ws:open', { endpoint, id });
        
        // 認証メッセージを送信
        if (endpoint === 'general' && id) {
          ws.send(JSON.stringify({
            type: 'auth',
            driver_id: id
          }));
        }
      });

      ws.on('message', (data) => {
        try {
          const message = JSON.parse(data.toString()) as WebSocketMessage;
          this.emit('ws:message', { endpoint, id, message });
          this.emit(`ws:${message.type}`, message.data);
        } catch (error) {
          this.emit('ws:error', { endpoint, id, error });
        }
      });

      ws.on('error', (error) => {
        this.emit('ws:error', { endpoint, id, error });
      });

      ws.on('close', () => {
        this.emit('ws:close', { endpoint, id });
        this.wsConnections.delete(connectionKey);
      });

      return ws;
    },

    disconnect: (endpoint: 'general' | 'driver' | 'dispatch', id?: string): void => {
      const connectionKey = `${endpoint}:${id || 'general'}`;
      const ws = this.wsConnections.get(connectionKey);
      if (ws) {
        ws.close();
        this.wsConnections.delete(connectionKey);
      }
    },

    disconnectAll: (): void => {
      this.wsConnections.forEach(ws => ws.close());
      this.wsConnections.clear();
    },

    send: (endpoint: 'general' | 'driver' | 'dispatch', message: WebSocketMessage, id?: string): void => {
      const connectionKey = `${endpoint}:${id || 'general'}`;
      const ws = this.wsConnections.get(connectionKey);
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(message));
      } else {
        throw new Error(`WebSocket connection not open for ${connectionKey}`);
      }
    }
  };

  // データベース管理
  database = {
    init: async (): Promise<ApiResponse> => {
      const response = await this.axios.post('/api/init-database');
      return response.data;
    }
  };

  // クリーンアップ
  disconnect(): void {
    this.ws.disconnectAll();
  }
}