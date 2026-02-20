import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.orange,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 32,
                                offset: Offset(0, 8)),
                          ],
                        ),
                        child: const CFLogo(size: 180, fontSize: 80),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'CloudForest\nIT Solutions',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Seamless connectivity & premium tech support for homes and businesses.',
                          style: TextStyle(
                            color: Color(0xFFFFD5A0),
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Get Started',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.orange)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: AppColors.orange, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegister;
  const LoginScreen({super.key, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid credentials'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      color: AppColors.cream,
      child: Column(
        children: [
          // Orange top banner
          Container(
            color: AppColors.orange,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
            child: Row(
              children: [
                const CFLogo(size: 80, fontSize: 32),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CloudForest',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                    Text('IT Solutions',
                        style: TextStyle(
                            color: Color(0xFFFFD5A0), fontSize: 15)),
                    SizedBox(height: 4),
                    Text('Login to your account',
                        style: TextStyle(
                            color: Color(0xFFFFD5A0), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // White login card
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Welcome Back',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                    const Text('Sign in to continue',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.gray)),
                    const SizedBox(height: 28),
                    AppTextField(
                      placeholder: 'Username',
                      controller: _usernameController,
                      suffixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      placeholder: 'Password',
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      suffixIcon: _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixTap: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: AppColors.orange,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.gray)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'LOGIN',
                      onPressed: _handleLogin,
                      isLoading: auth.isLoading,
                      backgroundColor: AppColors.orange,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or',
                              style: TextStyle(
                                  color: AppColors.gray.withValues(alpha: 0.6),
                                  fontSize: 12)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onRegister,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                              color: AppColors.orange, width: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply For Installation',
                            style: TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Demo: client / 123  or  staff / 123',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.gray),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REGISTRATION FLOW
// ============================================================

class RegistrationFlow extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;
  const RegistrationFlow(
      {super.key, required this.onBack, required this.onFinish});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  int _step = 1;
  final _formData = RegistrationFormData();
  bool _isSubmitting = false;
  static const _totalSteps = 4;

  final _areas = const [
    'ALANGILAN, ABUYOG, LEYTE', 'ANIBONGON, ABUYOG, LEYTE',
    'BAGACAY, ABUYOG, LEYTE', 'BALINSASAYAO, ABUYOG, LEYTE',
    'BAHAY, ABUYOG, LEYTE', 'BALOCAWEHAY, ABUYOG, LEYTE',
    'BARAYONG, ABUYOG, LEYTE', 'BITO, ABUYOG, LEYTE',
    'POBLACION, ABUYOG, LEYTE',
  ];

  String _stepTitle() {
    const titles = ['Customer Profile', 'Service Details', 'Requirements', 'Review & Save'];
    return titles[_step - 1];
  }

  String _stepSubtitle() {
    const subs = [
      'Personal Details & Location',
      'Plan Configuration & Billing',
      'Legal Documents & Agreement',
      'Review the installation summary',
    ];
    return subs[_step - 1];
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    await MockApiService().submitRegistration(_formData);
    setState(() => _isSubmitting = false);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.orange,
      child: Column(
        children: [
          // Orange Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: _step > 1
                        ? () => setState(() => _step--)
                        : widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.white, size: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step $_step of $_totalSteps',
                            style: const TextStyle(
                                color: Color(0xFFFFD5A0),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(_stepTitle(),
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text(_stepSubtitle(),
                            style: const TextStyle(
                                color: Color(0xFFFFD5A0), fontSize: 11)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _step / _totalSteps,
                          backgroundColor: Colors.white30,
                          color: AppColors.white,
                          strokeWidth: 4,
                        ),
                        Text('${(_step / _totalSteps * 100).round()}%',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Step content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      case 4: return _buildStep4();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const SizedBox(height: 4),
        AppDropdown(
          placeholder: 'Purpose of Installment',
          options: const ['Primary', 'Secondary'],
          value: _formData.purpose.isEmpty ? null : _formData.purpose,
          onChanged: (v) => setState(() => _formData.purpose = v ?? ''),
        ),
        const SizedBox(height: 14),
        _field('Customer Name', Icons.person_outline,
            (v) => _formData.customerName = v),
        const SizedBox(height: 14),
        _field('Contact Number', Icons.phone_outlined,
            (v) => _formData.contactNumber = v,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _field('Facebook Account Link', Icons.link,
            (v) => _formData.facebookLink = v),
        const SizedBox(height: 14),
        AppDropdown(
          placeholder: 'Select Area / Barangay',
          options: _areas,
          value: _formData.area.isEmpty ? null : _formData.area,
          onChanged: (v) => setState(() => _formData.area = v ?? ''),
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _field('Landmark / Directions', Icons.map_outlined,
            (v) => _formData.landmark = v),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step++),
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const SectionLabel('Connection Type'),
        const SizedBox(height: 10),
        Row(
          children: [
            _serviceCard(Icons.home_outlined, 'Residential', ConnectionType.residential),
            const SizedBox(width: 10),
            _serviceCard(Icons.business, 'Business', ConnectionType.business),
            const SizedBox(width: 10),
            _serviceCard(Icons.account_balance_outlined, 'Government', ConnectionType.government),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppDropdown(
                label: 'Status',
                placeholder: 'Select Status',
                options: const ['Active', 'Inactive'],
                value: _formData.serviceStatus.isEmpty ? null : _formData.serviceStatus,
                onChanged: (v) => setState(() => _formData.serviceStatus = v ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppDropdown(
                label: 'Installation Payment',
                placeholder: 'Payment Type',
                options: const ['Partially Paid', 'Fully Paid'],
                value: _formData.installationPayment.isEmpty ? null : _formData.installationPayment,
                onChanged: (v) => setState(() => _formData.installationPayment = v ?? ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _field('Installation Plan (e.g. Fiber 799)', Icons.wifi,
            (v) => _formData.installationPlan = v),
        const SizedBox(height: 14),
        AppDropdown(
          label: 'Due Date',
          placeholder: 'Select Due Date',
          options: const ['5th', '10th', '15th', '20th', '25th', 'End of Month'],
          value: _formData.dueDate.isEmpty ? null : _formData.dueDate,
          onChanged: (v) => setState(() => _formData.dueDate = v ?? ''),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step++),
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _serviceCard(IconData icon, String label, ConnectionType type) {
    final isActive = _formData.connectionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _formData.connectionType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 88,
          decoration: BoxDecoration(
            color: isActive ? AppColors.orange : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? AppColors.orange : AppColors.grayLight,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isActive ? AppColors.white : AppColors.gray,
                  size: 24),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.white : AppColors.gray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const SectionLabel('Required Documents'),
        const SizedBox(height: 12),
        _uploadTile('Valid ID', 'Government Issued ID with photo'),
        const SizedBox(height: 10),
        _uploadTile('Selfie with ID', 'Clear photo holding your ID'),
        const SizedBox(height: 10),
        _uploadTile('Electric Bill', 'Proof of billing address'),
        const SizedBox(height: 20),
        const SectionLabel('Memorandum Agreement'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('View PDF Contract'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Customer Signature',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray)),
              const SizedBox(height: 8),
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grayLight),
                ),
                child: Center(
                  child: Text('Sign here',
                      style: TextStyle(
                          color: AppColors.gray.withValues(alpha: 0.5),
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () => setState(() => _step++),
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _uploadTile(String label, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.camera_alt_outlined,
                color: AppColors.gray, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.gray)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Upload',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _reviewSection('CUSTOMER INFO', {
          'Name': _formData.customerName.isEmpty ? 'Juan Dela Cruz' : _formData.customerName,
          'Contact': _formData.contactNumber.isEmpty ? '0912345678' : _formData.contactNumber,
          'Area': _formData.area.isEmpty ? 'Bito, Abuyog, Leyte' : _formData.area,
          'Purpose': _formData.purpose.isEmpty ? 'Primary' : _formData.purpose,
        }),
        const SizedBox(height: 12),
        _reviewSection('INSTALLATION INFO', {
          'Connection': _formData.connectionType.name.toUpperCase(),
          'Status': _formData.serviceStatus.isEmpty ? 'Active' : _formData.serviceStatus,
          'Payment': _formData.installationPayment.isEmpty ? 'Partially Paid' : _formData.installationPayment,
          'Plan': _formData.installationPlan.isEmpty ? 'Fiber 799' : _formData.installationPlan,
          'Due Date': _formData.dueDate.isEmpty ? '10th' : _formData.dueDate,
        }),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Documents Submitted'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Valid ID', 'Selfie', 'Electric Bill', 'Signed MOA']
                    .map((d) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A))),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Save & Submit',
          onPressed: _handleSubmit,
          isLoading: _isSubmitting,
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.check_rounded,
        ),
      ],
    );
  }

  Widget _reviewSection(String title, Map<String, String> data) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(title),
          const Divider(height: 14),
          ...data.entries.map((e) => SummaryRow(label: e.key, value: e.value)),
        ],
      ),
    );
  }

  Widget _field(String hint, IconData icon, Function(String) onChange,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      onChanged: onChange,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: AppColors.gray.withValues(alpha: 0.6), fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.gray, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
