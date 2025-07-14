import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/company_registration_screen.dart';
import '../screens/driver_registration_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: '🚖',
      title: 'Mobility Ops 360へようこそ',
      subtitle: 'タクシー業界のDXを革新するプラットフォーム',
      description: 'コールセンター人件費75%削減\nドライバー充足率95%改善\n車両あたり粗利12%向上',
    ),
    OnboardingPageData(
      icon: '🎤',
      title: 'AI音声配車システム',
      subtitle: '自動音声応答で効率化',
      description: 'Twilioを活用した日本語AI音声システムで\n顧客からの配車依頼を自動処理\n24時間365日対応可能',
    ),
    OnboardingPageData(
      icon: '👥',
      title: 'ギグドライバー管理',
      subtitle: 'スマートマッチングで最適化',
      description: 'リアルタイム位置追跡\nAIによる最適ドライバーマッチング\n収益・評価管理システム',
    ),
    OnboardingPageData(
      icon: '🔒',
      title: 'セキュア運用',
      subtitle: 'ゼロトラストで安心・安全',
      description: 'ゼロトラストIAM\nリアルタイム監査ログ\n完全暗号化通信',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentPage + 1}/${_pages.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToUserSelection(),
                      child: const Text(
                        'スキップ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ページビュー
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // インジケーターとボタン
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ページインジケーター
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ボタン
                    if (_currentPage == _pages.length - 1)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _navigateToUserSelection(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667EEA),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'はじめる',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => _showROICalculator(context),
                            child: const Text(
                              'ROI計算機で効果を確認',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Text(
                                '戻る',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667EEA),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '次へ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アイコン
          Text(
            page.icon,
            style: const TextStyle(fontSize: 100),
          ),
          
          const SizedBox(height: 48),
          
          // タイトル
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // サブタイトル
          Text(
            page.subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 説明
          Text(
            page.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToUserSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildUserSelectionSheet(),
    );
  }

  Widget _buildUserSelectionSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'ご利用方法を選択してください',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // タクシー会社として登録
          _buildSelectionCard(
            icon: '🏢',
            title: 'タクシー会社として登録',
            subtitle: '会社全体でシステムを導入',
            description: '• ドライバー管理\n• 配車システム運用\n• 収益分析',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CompanyRegistrationScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // ドライバーとして登録
          _buildSelectionCard(
            icon: '👤',
            title: 'ドライバーとして登録',
            subtitle: 'ギグワーカーとして参加',
            description: '• 配車リクエスト受信\n• 収益管理\n• 評価システム',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DriverRegistrationScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 既存アカウントでログイン
          _buildSelectionCard(
            icon: '🔑',
            title: '既存アカウントでログイン',
            subtitle: '登録済みの場合はこちら',
            description: '• 会社アカウント\n• ドライバーアカウント\n• 管理者アカウント',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // デモ体験
          _buildSelectionCard(
            icon: '🎮',
            title: 'デモ体験',
            subtitle: 'システムを試してみる',
            description: '• 全機能体験可能\n• 登録不要\n• 7日間無料',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // アプリアクセスボタン
          const Divider(),
          const SizedBox(height: 16),
          
          const Text(
            'アプリ体験',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/dashboard');
            },
            icon: const Icon(Icons.dashboard),
            label: const Text('管理ダッシュボード'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          
          const SizedBox(height: 12),
          
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/customer-dispatch');
            },
            icon: const Icon(Icons.taxi_alert),
            label: const Text('顧客配車アプリ'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          
          const SizedBox(height: 12),
          
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/driver-app');
            },
            icon: const Icon(Icons.directions_car),
            label: const Text('ドライバーアプリ'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          
          const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showROICalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ROICalculatorDialog(),
    );
  }
}

class OnboardingPageData {
  final String icon;
  final String title;
  final String subtitle;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class ROICalculatorDialog extends StatefulWidget {
  const ROICalculatorDialog({super.key});

  @override
  State<ROICalculatorDialog> createState() => _ROICalculatorDialogState();
}

class _ROICalculatorDialogState extends State<ROICalculatorDialog> {
  final _vehicleCountController = TextEditingController(text: '50');
  final _operatorCountController = TextEditingController(text: '5');
  final _monthlyCallsController = TextEditingController(text: '10000');

  double _calculateMonthlySavings() {
    final vehicleCount = int.tryParse(_vehicleCountController.text) ?? 0;
    final operatorCount = int.tryParse(_operatorCountController.text) ?? 0;
    final monthlyCalls = int.tryParse(_monthlyCallsController.text) ?? 0;

    // コールセンター人件費削減（75%削減）
    final operatorCostSavings = operatorCount * 300000 * 0.75; // 月30万円/人 × 75%削減
    
    // 配車効率向上による収益増加（12%向上）
    final revenueIncrease = vehicleCount * 800000 * 0.12; // 月80万円/台 × 12%向上
    
    // 通話コスト削減
    final callCostSavings = monthlyCalls * 50 * 0.8; // 1通話50円 × 80%削減

    return operatorCostSavings + revenueIncrease + callCostSavings;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💰 ROI計算機',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            TextField(
              controller: _vehicleCountController,
              decoration: const InputDecoration(
                labelText: '車両台数',
                suffix: Text('台'),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _operatorCountController,
              decoration: const InputDecoration(
                labelText: 'オペレーター数',
                suffix: Text('人'),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _monthlyCallsController,
              decoration: const InputDecoration(
                labelText: '月間通話数',
                suffix: Text('件'),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '月間コスト削減効果',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥${_calculateMonthlySavings().toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '年間: ¥${(_calculateMonthlySavings() * 12).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('閉じる'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 無料トライアル申し込みへ
                    },
                    child: const Text('無料トライアル'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}