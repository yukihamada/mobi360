import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/dashboard_screen.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // 会社基本情報
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _representativeEmailController = TextEditingController();

  // サービス設定
  final _serviceAreaController = TextEditingController();
  final _vehicleCountController = TextEditingController();
  final _driverCountController = TextEditingController();
  final _operatorPhoneController = TextEditingController();
  
  String _selectedPlan = 'standard';
  bool _isLoading = false;
  bool _aiRoutingEnabled = true;

  final List<RegistrationStep> _steps = [
    RegistrationStep(
      title: '会社基本情報',
      subtitle: 'タクシー会社の基本情報を入力してください',
      icon: Icons.business,
    ),
    RegistrationStep(
      title: 'サービス設定',
      subtitle: '運用エリアと規模を設定してください',
      icon: Icons.settings,
    ),
    RegistrationStep(
      title: 'プラン選択',
      subtitle: '最適なプランを選択してください',
      icon: Icons.monetization_on,
    ),
    RegistrationStep(
      title: '確認・完了',
      subtitle: '入力内容を確認して登録を完了してください',
      icon: Icons.check_circle,
    ),
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _licenseNumberController.dispose();
    _representativeNameController.dispose();
    _representativeEmailController.dispose();
    _serviceAreaController.dispose();
    _vehicleCountController.dispose();
    _driverCountController.dispose();
    _operatorPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タクシー会社登録'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // プログレスインジケーター
          _buildProgressIndicator(),
          
          // フォームコンテンツ
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _buildBasicInfoStep();
                  case 1:
                    return _buildServiceSettingsStep();
                  case 2:
                    return _buildPlanSelectionStep();
                  case 3:
                    return _buildConfirmationStep();
                  default:
                    return Container();
                }
              },
            ),
          ),
          
          // ナビゲーションボタン
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isActive
                                ? const Color(0xFF667EEA)
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : _steps[index].icon,
                        color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                    if (index < _steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < _currentStep ? Colors.green : Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _steps[_currentStep].title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            _steps[_currentStep].subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('会社情報'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: '会社名',
                hintText: '例：東京タクシー株式会社',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '会社名を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _companyAddressController,
              decoration: const InputDecoration(
                labelText: '本社住所',
                hintText: '例：東京都新宿区西新宿1-1-1',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '本社住所を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _companyPhoneController,
              decoration: const InputDecoration(
                labelText: '会社電話番号',
                hintText: '例：03-1234-5678',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '電話番号を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: '一般乗用旅客自動車運送事業許可番号',
                hintText: '例：関自旅二第1234号',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '許可番号を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('代表者情報'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _representativeNameController,
              decoration: const InputDecoration(
                labelText: '代表者氏名',
                hintText: '例：田中太郎',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '代表者氏名を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _representativeEmailController,
              decoration: const InputDecoration(
                labelText: '代表者メールアドレス',
                hintText: '例：president@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!value.contains('@')) {
                  return '有効なメールアドレスを入力してください';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('サービス運用設定'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _serviceAreaController,
            decoration: const InputDecoration(
              labelText: 'サービス提供エリア',
              hintText: '例：東京都23区内',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _vehicleCountController,
            decoration: const InputDecoration(
              labelText: '保有車両台数',
              suffix: Text('台'),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _driverCountController,
            decoration: const InputDecoration(
              labelText: '所属ドライバー数',
              suffix: Text('人'),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionTitle('運用時間設定'),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '営業時間',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('24時間営業'),
                        leading: Radio<String>(
                          value: '24h',
                          groupValue: '24h',
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'AI音声配車システムにより24時間365日自動対応可能',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('料金プラン選択'),
          const SizedBox(height: 16),
          
          _buildPlanCard(
            planId: 'standard',
            title: 'スタンダードプラン',
            price: '¥29,800',
            period: '/月（税別）',
            features: [
              'AI音声配車システム',
              'ドライバー管理（50名まで）',
              '基本分析レポート',
              'メールサポート',
            ],
            isRecommended: true,
          ),
          
          const SizedBox(height: 16),
          
          _buildPlanCard(
            planId: 'premium',
            title: 'プレミアムプラン',
            price: '¥49,800',
            period: '/月（税別）',
            features: [
              'AI音声配車システム',
              'ドライバー管理（無制限）',
              '高度な分析・予測機能',
              'リアルタイム監視',
              '24時間電話サポート',
              'カスタマイズ対応',
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildPlanCard(
            planId: 'enterprise',
            title: 'エンタープライズプラン',
            price: 'お見積り',
            period: '',
            features: [
              '全機能利用可能',
              '専用サーバー環境',
              'カスタム開発対応',
              '導入コンサルティング',
              '専任サポート担当',
              'SLA保証',
            ],
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
                const Icon(
                  Icons.celebration,
                  color: Colors.green,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  '初回限定キャンペーン',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '7日間無料トライアル + 初月50%OFF',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPlan == planId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '推奨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF667EEA),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('登録内容確認'),
          const SizedBox(height: 16),
          
          _buildConfirmationSection('会社基本情報', [
            '会社名: ${_companyNameController.text}',
            '住所: ${_companyAddressController.text}',
            '電話番号: ${_companyPhoneController.text}',
            '許可番号: ${_licenseNumberController.text}',
          ]),
          
          _buildConfirmationSection('代表者情報', [
            '氏名: ${_representativeNameController.text}',
            'メール: ${_representativeEmailController.text}',
          ]),
          
          _buildConfirmationSection('サービス設定', [
            'サービスエリア: ${_serviceAreaController.text}',
            '車両台数: ${_vehicleCountController.text}台',
            'ドライバー数: ${_driverCountController.text}人',
          ]),
          
          _buildConfirmationSection('選択プラン', [
            _getSelectedPlanName(),
          ]),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '登録完了後の流れ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStepItem('1', '審査（1-2営業日）'),
                _buildStepItem('2', 'アカウント発行・初期設定'),
                _buildStepItem('3', 'ドライバー登録・研修'),
                _buildStepItem('4', 'サービス開始'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection(String title, List<String> items) {
    return Column(
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getSelectedPlanName() {
    switch (_selectedPlan) {
      case 'standard':
        return 'スタンダードプラン（¥29,800/月）';
      case 'premium':
        return 'プレミアムプラン（¥49,800/月）';
      case 'enterprise':
        return 'エンタープライズプラン（お見積り）';
      default:
        return 'プラン未選択';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('戻る'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == _steps.length - 1 ? '登録完了' : '次へ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNextStep() async {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == _steps.length - 1) {
      await _submitRegistration();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 実際のAPI呼び出し
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final result = await appState.registerCompany(
        companyName: _companyNameController.text,
        companyAddress: _companyAddressController.text,
        companyPhone: _companyPhoneController.text,
        licenseNumber: _licenseNumberController.text,
        representativeName: _representativeNameController.text,
        representativeEmail: _representativeEmailController.text,
        serviceArea: _serviceAreaController.text,
        vehicleCount: _vehicleCountController.text,
        driverCount: _driverCountController.text,
        selectedPlan: _selectedPlan,
      );

      if (mounted) {
        if (result['success'] == true) {
          _showRegistrationSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登録に失敗しました: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('登録完了'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('タクシー会社の登録が完了しました。'),
            const SizedBox(height: 12),
            const Text('審査完了後、登録されたメールアドレスに\nアカウント情報をお送りします。'),
            const SizedBox(height: 12),
            const Text('7日間の無料トライアルをお楽しみください！'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text('システムを体験する'),
          ),
        ],
      ),
    );
  }
}

class RegistrationStep {
  final String title;
  final String subtitle;
  final IconData icon;

  RegistrationStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}