import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/dashboard_screen.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // 個人基本情報
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdateController = TextEditingController();

  // 免許・資格情報
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _taxiLicenseNumberController = TextEditingController();

  // 車両情報
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _insuranceNumberController = TextEditingController();

  // 銀行口座情報
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  bool _hasOwnVehicle = true;
  bool _isFullTime = true;
  String _workingArea = '東京都23区内';
  bool _isLoading = false;

  final List<RegistrationStep> _steps = [
    RegistrationStep(
      title: '個人基本情報',
      subtitle: 'ドライバーの基本情報を入力してください',
      icon: Icons.person,
    ),
    RegistrationStep(
      title: '免許・資格',
      subtitle: '運転免許証とタクシー資格の情報を入力してください',
      icon: Icons.credit_card,
    ),
    RegistrationStep(
      title: '車両情報',
      subtitle: '使用予定の車両情報を入力してください',
      icon: Icons.directions_car,
    ),
    RegistrationStep(
      title: '銀行口座',
      subtitle: '報酬振込用の口座情報を入力してください',
      icon: Icons.account_balance,
    ),
    RegistrationStep(
      title: '確認・完了',
      subtitle: '入力内容を確認して登録を完了してください',
      icon: Icons.check_circle,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _taxiLicenseNumberController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehiclePlateController.dispose();
    _insuranceNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ドライバー登録'),
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
                    return _buildLicenseStep();
                  case 2:
                    return _buildVehicleStep();
                  case 3:
                    return _buildBankAccountStep();
                  case 4:
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
            _buildSectionTitle('個人情報'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '氏名',
                hintText: '例：田中太郎',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '氏名を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                hintText: '例：090-1234-5678',
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
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                hintText: '例：driver@example.com',
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
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                hintText: '例：東京都新宿区西新宿1-1-1',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '住所を入力してください';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _birthdateController,
              decoration: const InputDecoration(
                labelText: '生年月日',
                hintText: '例：1985-03-15',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '生年月日を入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),
            
            _buildSectionTitle('勤務形態'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('フルタイム'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _isFullTime,
                      onChanged: (value) {
                        setState(() {
                          _isFullTime = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('パートタイム'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _isFullTime,
                      onChanged: (value) {
                        setState(() {
                          _isFullTime = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _workingArea,
              decoration: const InputDecoration(
                labelText: '希望勤務エリア',
              ),
              items: const [
                DropdownMenuItem(value: '東京都23区内', child: Text('東京都23区内')),
                DropdownMenuItem(value: '東京都全域', child: Text('東京都全域')),
                DropdownMenuItem(value: '神奈川県内', child: Text('神奈川県内')),
                DropdownMenuItem(value: '埼玉県内', child: Text('埼玉県内')),
                DropdownMenuItem(value: '千葉県内', child: Text('千葉県内')),
              ],
              onChanged: (value) {
                setState(() {
                  _workingArea = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('運転免許証'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _licenseNumberController,
            decoration: const InputDecoration(
              labelText: '運転免許証番号',
              hintText: '例：123456789012',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _licenseExpiryController,
            decoration: const InputDecoration(
              labelText: '免許証有効期限',
              hintText: '例：2028-03-15',
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionTitle('タクシー運転資格'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _taxiLicenseNumberController,
            decoration: const InputDecoration(
              labelText: '地理試験合格証番号',
              hintText: '例：第12345号',
            ),
          ),
          
          const SizedBox(height: 24),
          
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
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'タクシー運転資格について',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• 地理試験合格証をお持ちでない場合は、当社でサポートいたします',
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  '• 未取得でも研修プログラムにより取得可能です',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // 研修プログラム詳細表示
                  },
                  child: const Text('研修プログラムの詳細'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('車両保有状況'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('自家用車あり'),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: _hasOwnVehicle,
                    onChanged: (value) {
                      setState(() {
                        _hasOwnVehicle = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('リース希望'),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: _hasOwnVehicle,
                    onChanged: (value) {
                      setState(() {
                        _hasOwnVehicle = value!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          
          if (_hasOwnVehicle) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('車両詳細'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehicleModelController,
              decoration: const InputDecoration(
                labelText: '車種・型式',
                hintText: '例：トヨタ プリウス',
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehicleYearController,
              decoration: const InputDecoration(
                labelText: '年式',
                hintText: '例：2020',
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehiclePlateController,
              decoration: const InputDecoration(
                labelText: 'ナンバープレート',
                hintText: '例：品川 500 あ 12-34',
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _insuranceNumberController,
              decoration: const InputDecoration(
                labelText: '自動車保険証券番号',
                hintText: '例：ABC-1234567890',
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '車両リースプログラム',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• 月額リース料: ¥45,000〜'),
                  const Text('• 車検・メンテナンス込み'),
                  const Text('• 任意保険込み'),
                  const Text('• GPS・ドライブレコーダー標準装備'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // リースプラン詳細表示
                    },
                    child: const Text('リースプランの詳細'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('銀行口座情報'),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: '銀行名',
              hintText: '例：三菱UFJ銀行',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _branchNameController,
            decoration: const InputDecoration(
              labelText: '支店名',
              hintText: '例：新宿支店',
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: '口座番号',
              hintText: '例：1234567',
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _accountHolderController,
            decoration: const InputDecoration(
              labelText: '口座名義',
              hintText: '例：タナカタロウ',
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '報酬支払いについて',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('• 週次支払い（毎週金曜日）'),
                Text('• 手数料無料'),
                Text('• 最低支払額: ¥1,000'),
                Text('• 配車実績に応じたボーナス制度あり'),
              ],
            ),
          ),
        ],
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
          
          _buildConfirmationSection('個人基本情報', [
            '氏名: ${_nameController.text}',
            '電話番号: ${_phoneController.text}',
            'メール: ${_emailController.text}',
            '住所: ${_addressController.text}',
            '生年月日: ${_birthdateController.text}',
          ]),
          
          _buildConfirmationSection('勤務情報', [
            '勤務形態: ${_isFullTime ? "フルタイム" : "パートタイム"}',
            '希望勤務エリア: $_workingArea',
          ]),
          
          _buildConfirmationSection('免許・資格', [
            '運転免許証番号: ${_licenseNumberController.text}',
            '免許証有効期限: ${_licenseExpiryController.text}',
            'タクシー運転資格: ${_taxiLicenseNumberController.text.isEmpty ? "未取得（研修予定）" : _taxiLicenseNumberController.text}',
          ]),
          
          _buildConfirmationSection('車両情報', [
            if (_hasOwnVehicle) ...[
              '車両保有: 自家用車あり',
              '車種: ${_vehicleModelController.text}',
              '年式: ${_vehicleYearController.text}',
              'ナンバー: ${_vehiclePlateController.text}',
            ] else
              '車両保有: リース希望',
          ]),
          
          _buildConfirmationSection('銀行口座', [
            '銀行: ${_bankNameController.text}',
            '支店: ${_branchNameController.text}',
            '口座番号: ${_accountNumberController.text}',
            '口座名義: ${_accountHolderController.text}',
          ]),
          
          const SizedBox(height: 24),
          
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
                const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue),
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
                _buildStepItem('1', '書類審査（1-2営業日）'),
                _buildStepItem('2', 'オンライン研修（3-5日）'),
                _buildStepItem('3', '実地研修・試験（1日）'),
                _buildStepItem('4', '勤務開始'),
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
            decoration: const BoxDecoration(
              color: Color(0xFF667EEA),
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
      final result = await appState.registerDriver(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        birthdate: _birthdateController.text,
        licenseNumber: _licenseNumberController.text,
        licenseExpiry: _licenseExpiryController.text,
        taxiLicenseNumber: _taxiLicenseNumberController.text,
        hasOwnVehicle: _hasOwnVehicle,
        isFullTime: _isFullTime,
        workingArea: _workingArea,
        vehicleModel: _vehicleModelController.text,
        vehicleYear: _vehicleYearController.text,
        vehiclePlate: _vehiclePlateController.text,
        insuranceNumber: _insuranceNumberController.text,
        bankName: _bankNameController.text,
        branchName: _branchNameController.text,
        accountNumber: _accountNumberController.text,
        accountHolder: _accountHolderController.text,
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ドライバー登録が完了しました。'),
            SizedBox(height: 12),
            Text('審査完了後、登録されたメールアドレスに\\n詳細な研修スケジュールをお送りします。'),
            SizedBox(height: 12),
            Text('まずはシステムをご体験ください！'),
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