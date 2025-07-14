import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/driver_search_card.dart';
import '../widgets/voice_dispatch_card.dart';
import '../widgets/status_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 初期データ読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return CustomScrollView(
            slivers: [
              // アプリバー
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF667EEA),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '🚖 Mobility Ops 360',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                  ),
                ),
                actions: [
                  StatusIndicator(status: appState.connectionStatus),
                  const SizedBox(width: 16),
                ],
              ),

              // エラー表示
              if (appState.lastError != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appState.lastError!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => appState.clearError(),
                          color: Colors.red.shade600,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              // KPIメトリクス
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'パフォーマンス指標',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'コールセンター\n人件費削減',
                              value: '${appState.costReduction.toInt()}%',
                              subtitle: '↑ AI音声配車',
                              color: const Color(0xFFF093FB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'ドライバー\n充足率',
                              value: '${appState.driverSufficiency.toInt()}%',
                              subtitle: '↑ ギグ活用',
                              color: const Color(0xFF4FACFE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: '車両あたり\n粗利向上',
                              value: '${appState.profitIncrease.toInt()}%',
                              subtitle: '↑ AI最適化',
                              color: const Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'システム\n稼働率',
                              value: '${appState.systemUptime}%',
                              subtitle: '↑ Edge Network',
                              color: const Color(0xFF764BA2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 機能カード
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // AI音声配車カード
                      VoiceDispatchCard(),
                      
                      const SizedBox(height: 16),
                      
                      // ドライバー検索カード
                      DriverSearchCard(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      
      // フローティングアクションボタン
      floatingActionButton: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return FloatingActionButton.extended(
            onPressed: appState.isLoading ? null : () => appState.refreshData(),
            backgroundColor: const Color(0xFF667EEA),
            icon: appState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            label: Text(appState.isLoading ? '更新中...' : 'データ更新'),
          );
        },
      ),
    );
  }
}