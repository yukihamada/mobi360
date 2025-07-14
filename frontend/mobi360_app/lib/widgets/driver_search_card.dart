import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class DriverSearchCard extends StatelessWidget {
  const DriverSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FACFE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Color(0xFF4FACFE),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ドライバー管理システム',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 現在位置情報
                if (appState.currentPosition != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '現在位置: ${appState.currentPosition!.latitude.toStringAsFixed(4)}, ${appState.currentPosition!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A5568),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // ボタン
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.isLoading 
                            ? null 
                            : () => appState.searchNearbyDrivers(),
                        icon: appState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(appState.isLoading ? '検索中...' : 'ドライバー検索'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FACFE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: appState.nearbyDrivers.isEmpty
                            ? null
                            : () => _showMatchingDialog(context, appState),
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('マッチング'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 検索結果
                if (appState.nearbyDrivers.isNotEmpty) ...[
                  const Text(
                    '近くのドライバー:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      itemCount: appState.nearbyDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = appState.nearbyDrivers[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${driver['vehicle_type'] ?? 'standard'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${driver['rating'] ?? 0.0}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '${(driver['distance'] ?? 0.0).toStringAsFixed(1)}km',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMatchingDialog(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ドライバーマッチング'),
        content: const Text('選択されたドライバーと配車をマッチングしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performMatching(context, appState);
            },
            child: const Text('マッチング実行'),
          ),
        ],
      ),
    );
  }

  void _performMatching(BuildContext context, AppStateProvider appState) async {
    // サンプルのマッチング処理
    final sampleDispatchRequest = {
      'id': 'dispatch-mobile-${DateTime.now().millisecondsSinceEpoch}',
      'pickup_location': '東京駅',
      'destination': '羽田空港',
      'vehicle_type': 'standard',
    };

    try {
      // API経由でマッチング実行（実際のアプリでは）
      // final result = await appState._apiService.matchDriver(
      //   dispatchRequest: sampleDispatchRequest,
      //   availableDrivers: appState.nearbyDrivers,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('マッチングが完了しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('マッチングに失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}