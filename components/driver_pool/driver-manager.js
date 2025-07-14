export class DriverManager {
  constructor(env) {
    this.db = env.D1_MOBI360_DB;
    this.env = env;
  }

  /**
   * ドライバーを登録
   * @param {Object} driverData - ドライバー情報
   */
  async registerDriver(driverData) {
    try {
      const driverId = crypto.randomUUID();
      const driver = {
        id: driverId,
        ...driverData,
        status: 'pending_verification',
        rating: 0,
        total_rides: 0,
        total_earnings: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      await this.db.prepare(`
        INSERT INTO drivers (
          id, name, email, phone, license_number, vehicle_type, vehicle_number,
          vehicle_model, vehicle_color, status, rating, total_rides, total_earnings,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `).bind(
        driver.id,
        driver.name,
        driver.email,
        driver.phone,
        driver.license_number,
        driver.vehicle_type,
        driver.vehicle_number,
        driver.vehicle_model,
        driver.vehicle_color,
        driver.status,
        driver.rating,
        driver.total_rides,
        driver.total_earnings,
        driver.created_at,
        driver.updated_at
      ).run();

      return {
        success: true,
        driverId: driverId,
        message: 'ドライバー登録が完了しました'
      };
    } catch (error) {
      console.error('Driver registration error:', error);
      throw new Error('ドライバー登録に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーの位置情報を更新
   * @param {string} driverId - ドライバーID
   * @param {Object} location - 位置情報
   */
  async updateDriverLocation(driverId, location) {
    try {
      const timestamp = new Date().toISOString();
      
      // 現在の位置情報を更新
      await this.db.prepare(`
        INSERT OR REPLACE INTO driver_locations (
          driver_id, latitude, longitude, heading, speed, accuracy, timestamp
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
      `).bind(
        driverId,
        location.latitude,
        location.longitude,
        location.heading || 0,
        location.speed || 0,
        location.accuracy || 0,
        timestamp
      ).run();

      // 位置履歴を保存
      await this.db.prepare(`
        INSERT INTO driver_location_history (
          driver_id, latitude, longitude, heading, speed, timestamp
        ) VALUES (?, ?, ?, ?, ?, ?)
      `).bind(
        driverId,
        location.latitude,
        location.longitude,
        location.heading || 0,
        location.speed || 0,
        timestamp
      ).run();

      return {
        success: true,
        message: '位置情報を更新しました'
      };
    } catch (error) {
      console.error('Location update error:', error);
      throw new Error('位置情報の更新に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーの稼働状況を更新
   * @param {string} driverId - ドライバーID
   * @param {string} status - 稼働状況 (available, busy, offline)
   */
  async updateDriverStatus(driverId, status) {
    try {
      const timestamp = new Date().toISOString();
      
      await this.db.prepare(`
        UPDATE drivers 
        SET status = ?, updated_at = ? 
        WHERE id = ?
      `).bind(status, timestamp, driverId).run();

      // 稼働状況履歴を記録
      await this.db.prepare(`
        INSERT INTO driver_status_history (
          driver_id, status, timestamp
        ) VALUES (?, ?, ?)
      `).bind(driverId, status, timestamp).run();

      return {
        success: true,
        message: '稼働状況を更新しました'
      };
    } catch (error) {
      console.error('Status update error:', error);
      throw new Error('稼働状況の更新に失敗しました: ' + error.message);
    }
  }

  /**
   * 指定範囲内の利用可能なドライバーを検索
   * @param {number} latitude - 緯度
   * @param {number} longitude - 経度
   * @param {number} radius - 検索半径（km）
   * @param {string} vehicleType - 車種指定（オプション）
   */
  async findAvailableDrivers(latitude, longitude, radius = 5, vehicleType = null) {
    try {
      let query = `
        SELECT 
          d.id, d.name, d.phone, d.vehicle_type, d.vehicle_number,
          d.vehicle_model, d.vehicle_color, d.rating, d.total_rides,
          dl.latitude, dl.longitude, dl.timestamp as last_location_update,
          (
            6371 * acos(
              cos(radians(?)) * cos(radians(dl.latitude)) * 
              cos(radians(dl.longitude) - radians(?)) + 
              sin(radians(?)) * sin(radians(dl.latitude))
            )
          ) as distance
        FROM drivers d
        JOIN driver_locations dl ON d.id = dl.driver_id
        WHERE d.status = 'available'
        AND dl.timestamp > datetime('now', '-10 minutes')
        AND (
          6371 * acos(
            cos(radians(?)) * cos(radians(dl.latitude)) * 
            cos(radians(dl.longitude) - radians(?)) + 
            sin(radians(?)) * sin(radians(dl.latitude))
          )
        ) <= ?
      `;

      let params = [latitude, longitude, latitude, latitude, longitude, latitude, radius];

      if (vehicleType) {
        query += ` AND d.vehicle_type = ?`;
        params.push(vehicleType);
      }

      query += ` ORDER BY distance ASC, d.rating DESC LIMIT 10`;

      const results = await this.db.prepare(query).bind(...params).all();

      return {
        success: true,
        drivers: results.results || [],
        count: results.results?.length || 0
      };
    } catch (error) {
      console.error('Driver search error:', error);
      throw new Error('ドライバー検索に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーの評価を更新
   * @param {string} driverId - ドライバーID
   * @param {number} rating - 評価（1-5）
   * @param {string} comment - コメント
   * @param {string} customerId - 顧客ID
   */
  async updateDriverRating(driverId, rating, comment, customerId) {
    try {
      const timestamp = new Date().toISOString();

      // 評価を記録
      await this.db.prepare(`
        INSERT INTO driver_ratings (
          driver_id, customer_id, rating, comment, timestamp
        ) VALUES (?, ?, ?, ?, ?)
      `).bind(driverId, customerId, rating, comment, timestamp).run();

      // ドライバーの平均評価を再計算
      const avgRating = await this.db.prepare(`
        SELECT AVG(rating) as avg_rating, COUNT(*) as total_ratings
        FROM driver_ratings
        WHERE driver_id = ?
      `).bind(driverId).first();

      if (avgRating) {
        await this.db.prepare(`
          UPDATE drivers 
          SET rating = ?, total_ratings = ?, updated_at = ?
          WHERE id = ?
        `).bind(
          Math.round(avgRating.avg_rating * 10) / 10,
          avgRating.total_ratings,
          timestamp,
          driverId
        ).run();
      }

      return {
        success: true,
        message: 'ドライバーの評価を更新しました'
      };
    } catch (error) {
      console.error('Rating update error:', error);
      throw new Error('評価の更新に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーの収益を更新
   * @param {string} driverId - ドライバーID
   * @param {number} amount - 収益金額
   * @param {string} rideId - 配車ID
   */
  async updateDriverEarnings(driverId, amount, rideId) {
    try {
      const timestamp = new Date().toISOString();

      // 収益記録を追加
      await this.db.prepare(`
        INSERT INTO driver_earnings (
          driver_id, ride_id, amount, timestamp
        ) VALUES (?, ?, ?, ?)
      `).bind(driverId, rideId, amount, timestamp).run();

      // 累計収益を更新
      await this.db.prepare(`
        UPDATE drivers 
        SET total_earnings = total_earnings + ?, 
            total_rides = total_rides + 1,
            updated_at = ?
        WHERE id = ?
      `).bind(amount, timestamp, driverId).run();

      return {
        success: true,
        message: 'ドライバーの収益を更新しました'
      };
    } catch (error) {
      console.error('Earnings update error:', error);
      throw new Error('収益の更新に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーの詳細情報を取得
   * @param {string} driverId - ドライバーID
   */
  async getDriverDetails(driverId) {
    try {
      const driver = await this.db.prepare(`
        SELECT 
          d.*,
          dl.latitude, dl.longitude, dl.timestamp as last_location_update
        FROM drivers d
        LEFT JOIN driver_locations dl ON d.id = dl.driver_id
        WHERE d.id = ?
      `).bind(driverId).first();

      if (!driver) {
        throw new Error('ドライバーが見つかりません');
      }

      // 最近の収益情報を取得
      const recentEarnings = await this.db.prepare(`
        SELECT SUM(amount) as daily_earnings
        FROM driver_earnings
        WHERE driver_id = ? AND date(timestamp) = date('now')
      `).bind(driverId).first();

      // 今日の配車回数を取得
      const todayRides = await this.db.prepare(`
        SELECT COUNT(*) as today_rides
        FROM dispatch_requests
        WHERE driver_id = ? AND date(created_at) = date('now')
      `).bind(driverId).first();

      return {
        success: true,
        driver: {
          ...driver,
          daily_earnings: recentEarnings?.daily_earnings || 0,
          today_rides: todayRides?.today_rides || 0
        }
      };
    } catch (error) {
      console.error('Get driver details error:', error);
      throw new Error('ドライバー情報の取得に失敗しました: ' + error.message);
    }
  }

  /**
   * ドライバーのシフト管理
   * @param {string} driverId - ドライバーID
   * @param {Object} shiftData - シフト情報
   */
  async updateDriverShift(driverId, shiftData) {
    try {
      const timestamp = new Date().toISOString();

      await this.db.prepare(`
        INSERT OR REPLACE INTO driver_shifts (
          driver_id, shift_date, start_time, end_time, status, created_at
        ) VALUES (?, ?, ?, ?, ?, ?)
      `).bind(
        driverId,
        shiftData.date,
        shiftData.start_time,
        shiftData.end_time,
        shiftData.status || 'scheduled',
        timestamp
      ).run();

      return {
        success: true,
        message: 'シフト情報を更新しました'
      };
    } catch (error) {
      console.error('Shift update error:', error);
      throw new Error('シフト情報の更新に失敗しました: ' + error.message);
    }
  }
}