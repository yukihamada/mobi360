export class MatchingEngine {
  constructor(env) {
    this.db = env.D1_MOBI360_DB;
    this.env = env;
  }

  /**
   * 最適なドライバーを配車リクエストにマッチング
   * @param {Object} dispatchRequest - 配車リクエスト
   * @param {Array} availableDrivers - 利用可能なドライバー一覧
   */
  async findBestMatch(dispatchRequest, availableDrivers) {
    try {
      if (!availableDrivers || availableDrivers.length === 0) {
        return {
          success: false,
          message: 'マッチング可能なドライバーが見つかりません'
        };
      }

      // マッチングスコアを計算
      const scoredDrivers = await Promise.all(
        availableDrivers.map(async (driver) => {
          const score = await this.calculateMatchingScore(dispatchRequest, driver);
          return {
            ...driver,
            matching_score: score
          };
        })
      );

      // スコアでソート（降順）
      scoredDrivers.sort((a, b) => b.matching_score - a.matching_score);

      const bestMatch = scoredDrivers[0];

      // マッチング結果を記録
      await this.recordMatchingResult(dispatchRequest.id, bestMatch.id, bestMatch.matching_score);

      return {
        success: true,
        matched_driver: bestMatch,
        alternative_drivers: scoredDrivers.slice(1, 3), // 代替候補
        message: '最適なドライバーをマッチングしました'
      };
    } catch (error) {
      console.error('Matching error:', error);
      throw new Error('マッチング処理に失敗しました: ' + error.message);
    }
  }

  /**
   * マッチングスコアを計算
   * @param {Object} dispatchRequest - 配車リクエスト
   * @param {Object} driver - ドライバー情報
   */
  async calculateMatchingScore(dispatchRequest, driver) {
    try {
      let score = 0;

      // 1. 距離スコア（最大30点）
      const distanceScore = Math.max(0, 30 - (driver.distance * 2));
      score += distanceScore;

      // 2. 評価スコア（最大25点）
      const ratingScore = (driver.rating / 5) * 25;
      score += ratingScore;

      // 3. 経験値スコア（最大20点）
      const experienceScore = Math.min(20, driver.total_rides * 0.1);
      score += experienceScore;

      // 4. 車種マッチスコア（最大15点）
      const vehicleMatchScore = this.calculateVehicleMatchScore(
        dispatchRequest.vehicle_type,
        driver.vehicle_type
      );
      score += vehicleMatchScore;

      // 5. 時間効率スコア（最大10点）
      const timeEfficiencyScore = await this.calculateTimeEfficiencyScore(driver.id);
      score += timeEfficiencyScore;

      // 6. 需要予測ボーナス（最大10点）
      const demandBonus = await this.calculateDemandBonus(
        dispatchRequest.pickup_location,
        dispatchRequest.destination
      );
      score += demandBonus;

      // 7. 連続稼働ペナルティ（最大-5点）
      const continuousWorkPenalty = await this.calculateContinuousWorkPenalty(driver.id);
      score -= continuousWorkPenalty;

      return Math.max(0, Math.min(100, score));
    } catch (error) {
      console.error('Score calculation error:', error);
      return 0;
    }
  }

  /**
   * 車種マッチスコアを計算
   * @param {string} requestedType - リクエストされた車種
   * @param {string} driverType - ドライバーの車種
   */
  calculateVehicleMatchScore(requestedType, driverType) {
    const scoreMap = {
      'standard': { 'standard': 15, 'premium': 10, 'wheelchair': 5 },
      'premium': { 'premium': 15, 'standard': 5, 'wheelchair': 3 },
      'wheelchair': { 'wheelchair': 15, 'standard': 0, 'premium': 0 }
    };

    return scoreMap[requestedType]?.[driverType] || 0;
  }

  /**
   * 時間効率スコアを計算
   * @param {string} driverId - ドライバーID
   */
  async calculateTimeEfficiencyScore(driverId) {
    try {
      // 過去7日間の平均配車完了時間を取得
      const avgTime = await this.db.prepare(`
        SELECT AVG(
          julianday(completed_at) - julianday(created_at)
        ) * 24 * 60 as avg_completion_minutes
        FROM dispatch_requests
        WHERE driver_id = ? 
        AND status = 'completed'
        AND created_at > datetime('now', '-7 days')
      `).bind(driverId).first();

      if (!avgTime || !avgTime.avg_completion_minutes) {
        return 5; // デフォルトスコア
      }

      // 平均完了時間が短いほど高得点
      const minutes = avgTime.avg_completion_minutes;
      if (minutes <= 15) return 10;
      if (minutes <= 20) return 8;
      if (minutes <= 25) return 6;
      if (minutes <= 30) return 4;
      return 2;
    } catch (error) {
      console.error('Time efficiency calculation error:', error);
      return 5;
    }
  }

  /**
   * 需要予測ボーナスを計算
   * @param {string} pickupLocation - 乗車地点
   * @param {string} destination - 目的地
   */
  async calculateDemandBonus(pickupLocation, destination) {
    try {
      // 過去の需要パターンを分析
      const currentHour = new Date().getHours();
      const dayOfWeek = new Date().getDay();

      const demandData = await this.db.prepare(`
        SELECT COUNT(*) as request_count
        FROM dispatch_requests
        WHERE pickup_location LIKE ? OR destination LIKE ?
        AND CAST(strftime('%H', created_at) AS INTEGER) = ?
        AND CAST(strftime('%w', created_at) AS INTEGER) = ?
        AND created_at > datetime('now', '-30 days')
      `).bind(
        `%${pickupLocation}%`,
        `%${destination}%`,
        currentHour,
        dayOfWeek
      ).first();

      const requestCount = demandData?.request_count || 0;

      // 需要が高い時間帯・エリアにボーナス
      if (requestCount >= 20) return 10;
      if (requestCount >= 15) return 8;
      if (requestCount >= 10) return 6;
      if (requestCount >= 5) return 4;
      return 2;
    } catch (error) {
      console.error('Demand bonus calculation error:', error);
      return 2;
    }
  }

  /**
   * 連続稼働ペナルティを計算
   * @param {string} driverId - ドライバーID
   */
  async calculateContinuousWorkPenalty(driverId) {
    try {
      // 過去4時間の連続稼働時間を確認
      const workingHours = await this.db.prepare(`
        SELECT COUNT(*) as rides_count
        FROM dispatch_requests
        WHERE driver_id = ?
        AND created_at > datetime('now', '-4 hours')
        AND status IN ('completed', 'in_progress')
      `).bind(driverId).first();

      const rideCount = workingHours?.rides_count || 0;

      // 連続稼働が多い場合はペナルティ
      if (rideCount >= 8) return 5;
      if (rideCount >= 6) return 3;
      if (rideCount >= 4) return 1;
      return 0;
    } catch (error) {
      console.error('Continuous work penalty calculation error:', error);
      return 0;
    }
  }

  /**
   * マッチング結果を記録
   * @param {string} dispatchId - 配車ID
   * @param {string} driverId - ドライバーID
   * @param {number} score - マッチングスコア
   */
  async recordMatchingResult(dispatchId, driverId, score) {
    try {
      await this.db.prepare(`
        INSERT INTO matching_results (
          dispatch_id, driver_id, matching_score, created_at
        ) VALUES (?, ?, ?, ?)
      `).bind(
        dispatchId,
        driverId,
        score,
        new Date().toISOString()
      ).run();
    } catch (error) {
      console.error('Matching result recording error:', error);
    }
  }

  /**
   * 需要予測に基づくドライバー配置の最適化
   * @param {Object} demandForecast - 需要予測データ
   */
  async optimizeDriverPlacement(demandForecast) {
    try {
      const recommendations = [];

      for (const area of demandForecast.high_demand_areas) {
        // 該当エリアの現在のドライバー数を確認
        const currentDrivers = await this.db.prepare(`
          SELECT COUNT(*) as driver_count
          FROM drivers d
          JOIN driver_locations dl ON d.id = dl.driver_id
          WHERE d.status = 'available'
          AND dl.latitude BETWEEN ? AND ?
          AND dl.longitude BETWEEN ? AND ?
        `).bind(
          area.lat_min,
          area.lat_max,
          area.lng_min,
          area.lng_max
        ).first();

        const shortage = area.predicted_demand - (currentDrivers?.driver_count || 0);

        if (shortage > 0) {
          recommendations.push({
            area: area.name,
            shortage: shortage,
            priority: area.priority,
            suggested_actions: [
              `${shortage}人のドライバーを${area.name}エリアに配置`,
              `インセンティブ提供による誘導を検討`
            ]
          });
        }
      }

      return {
        success: true,
        recommendations: recommendations,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Driver placement optimization error:', error);
      throw new Error('ドライバー配置最適化に失敗しました: ' + error.message);
    }
  }

  /**
   * マッチング成功率の分析
   * @param {Object} filters - 分析フィルター
   */
  async analyzeMatchingPerformance(filters = {}) {
    try {
      const timeFilter = filters.days || 7;
      
      const stats = await this.db.prepare(`
        SELECT 
          COUNT(DISTINCT dr.id) as total_requests,
          COUNT(DISTINCT CASE WHEN dr.status != 'cancelled' THEN dr.id END) as successful_matches,
          AVG(mr.matching_score) as avg_matching_score,
          AVG(julianday(dr.confirmed_at) - julianday(dr.created_at)) * 24 * 60 as avg_match_time_minutes
        FROM dispatch_requests dr
        LEFT JOIN matching_results mr ON dr.id = mr.dispatch_id
        WHERE dr.created_at > datetime('now', '-${timeFilter} days')
      `).first();

      const successRate = stats.total_requests > 0 
        ? (stats.successful_matches / stats.total_requests) * 100 
        : 0;

      return {
        success: true,
        performance: {
          total_requests: stats.total_requests || 0,
          successful_matches: stats.successful_matches || 0,
          success_rate: Math.round(successRate * 100) / 100,
          average_matching_score: Math.round((stats.avg_matching_score || 0) * 100) / 100,
          average_match_time_minutes: Math.round((stats.avg_match_time_minutes || 0) * 100) / 100
        },
        period: `${timeFilter} days`,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Matching performance analysis error:', error);
      throw new Error('マッチング性能分析に失敗しました: ' + error.message);
    }
  }
}