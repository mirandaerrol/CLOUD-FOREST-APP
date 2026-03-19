import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import 'dart:io';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/registration_provider.dart';
import '../../services/document_validator_service.dart';
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
  bool _showGetStartedButton = false;

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

    // Initialize auth state and show button after delay
    Future.microtask(() {
      context.read<AuthProvider>().initialize();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showGetStartedButton = true;
          });
        }
      });
    });
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
                        child: const CFLogo(size: 180),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'CloudForest\nIT Solutions',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          decoration: TextDecoration.none,
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
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _showGetStartedButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Transform.translate(
                    offset: _showGetStartedButton ? Offset.zero : const Offset(0, 20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _showGetStartedButton ? widget.onFinish : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            disabledBackgroundColor: AppColors.white.withOpacity(0.5),
                            disabledForegroundColor: AppColors.orange.withOpacity(0.5),
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

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Orange top banner
          Container(
            color: AppColors.orange,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
            child: Row(
              children: [
                const CFLogo(size: 80),
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
                                  color: AppColors.gray.withOpacity(0.6),
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
                        child: const Text('Apply For Installment',
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

class RegistrationFlow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const RegistrationFlow({
    super.key,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegistrationProvider(context.read<ApiService>()),
      child: _RegistrationFlowContent(onBack: onBack, onFinish: onFinish),
    );
  }
}

class _RegistrationFlowContent extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const _RegistrationFlowContent({
    required this.onBack,
    required this.onFinish,
  });

  static const _areas = [
    'ALANGILAN, ABUYOG, LEYTE', 'ANIBONGON, ABUYOG, LEYTE',
    'BAGACAY, ABUYOG, LEYTE', 'BALINSASAYAO, ABUYOG, LEYTE',
    'BAHAY, ABUYOG, LEYTE', 'BALOCAWEHAY, ABUYOG, LEYTE',
    'BARAYONG, ABUYOG, LEYTE', 'BITO, ABUYOG, LEYTE',
    'POBLACION, ABUYOG, LEYTE',
  ];

  String _stepTitle(int step) {
    const titles = ['Customer Profile', 'Installation Details', 'Requirements', 'Review & Save'];
    return titles[step - 1];
  }

  String _stepSubtitle(int step) {
    const subs = [
      'Personal Details & Location',
      'Fee, Amortization & Billing Terms',
      'Legal Documents & Agreement',
      'Review the installation summary',
    ];
    return subs[step - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrationProvider>();
    final step = provider.step;
    final totalSteps = provider.totalSteps;

    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Column(
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
                    onPressed: step > 1
                        ? provider.previousStep
                        : onBack,
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.white, size: 20),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step $step of $totalSteps',
                            style: const TextStyle(
                                color: Color(0xFFFFD5A0),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(_stepTitle(step),
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text(_stepSubtitle(step),
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
                          value: step / totalSteps,
                          backgroundColor: Colors.white30,
                          color: AppColors.white,
                          strokeWidth: 4,
                        ),
                        Text('${(step / totalSteps * 100).round()}%',
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
                child: _buildStepContent(context, provider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, RegistrationProvider provider) {
    switch (provider.step) {
      case 1: return _buildStep1(context, provider);
      case 2: return _buildStep2(context, provider);
      case 3: return _buildStep3(context, provider);
      case 4: return _buildStep4(context, provider);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(BuildContext context, RegistrationProvider provider) {
    final data = provider.formData;
    return Column(
      children: [
        const SizedBox(height: 4),
        AppDropdown(
          placeholder: 'Purpose of Installment',
          options: const ['Primary', 'Secondary'],
          value: data.purpose.isEmpty ? null : data.purpose,
          onChanged: (v) => provider.updateFormData((d) => d.purpose = v ?? ''),
        ),
        const SizedBox(height: 14),
        _field('Customer Name', Icons.person_outline,
            (v) => provider.updateFormData((d) => d.customerName = v)),
        const SizedBox(height: 14),
        _field('Contact Number', Icons.phone_outlined,
            (v) => provider.updateFormData((d) => d.contactNumber = v),
            keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _field('Facebook Account Link', Icons.link,
            (v) => provider.updateFormData((d) => d.facebookLink = v)),
        const SizedBox(height: 14),
        AppDropdown(
          placeholder: 'Select Area / Barangay',
          options: _areas,
          value: data.area.isEmpty ? null : data.area,
          onChanged: (v) => provider.updateFormData((d) => d.area = v ?? ''),
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 14),
        _field('Landmark / Directions', Icons.map_outlined,
            (v) => provider.updateFormData((d) => d.landmark = v)),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () {
            if (provider.canProceedToNextStep()) {
              provider.nextStep();
            } else {
              _showValidationErrors(context, [provider.validationError!]);
            }
          },
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
          disabled: !provider.canProceedToNextStep(),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, RegistrationProvider provider) {
    final data = provider.formData;
    final isPartial = data.installationPayment == 'Partially Paid';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const SectionLabel('Connection Type'),
        const SizedBox(height: 10),
        Row(
          children: [
            _serviceCard(context, provider, Icons.home_outlined, 'Residential', ConnectionType.residential),
            const SizedBox(width: 10),
            _serviceCard(context, provider, Icons.business, 'Business', ConnectionType.business),
            const SizedBox(width: 10),
            _serviceCard(context, provider, Icons.account_balance_outlined, 'Government', ConnectionType.government),
          ],
        ),
        const SizedBox(height: 20),
        AppDropdown(
          label: 'Installation Payment',
          placeholder: 'Payment Type',
          options: const ['Partially Paid', 'Fully Paid'],
          value: data.installationPayment.isEmpty ? null : data.installationPayment,
          onChanged: (v) => provider.updateFormData((d) => d.installationPayment = v ?? ''),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 6)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Installation Fee',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const Text('Fixed installation charge',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray)),
                ],
              ),
              const Text('₱1,500',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange)),
            ],
          ),
        ),
        if (isPartial) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.orange),
                    SizedBox(width: 6),
                    Text('Partial Payment Terms',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange)),
                  ],
                ),
                const SizedBox(height: 10),
                _field('Number of Payment Terms (e.g. 3 months)', Icons.calendar_month_outlined,
                    (v) => provider.updateFormData((d) => d.paymentTerms = v),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        AppDropdown(
          label: 'Monthly Due Date',
          placeholder: 'Select Due Date',
          options: const ['5th', '10th', '15th', '20th', '25th', 'End of Month'],
          value: data.dueDate.isEmpty ? null : data.dueDate,
          onChanged: (v) => provider.updateFormData((d) => d.dueDate = v ?? ''),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () {
            if (provider.canProceedToNextStep()) {
              provider.nextStep();
            } else {
              _showValidationErrors(context, [provider.validationError!]);
            }
          },
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
          disabled: !provider.canProceedToNextStep(),
        ),
      ],
    );
  }

  Widget _serviceCard(BuildContext context, RegistrationProvider provider, IconData icon, String label, ConnectionType type) {
    final isActive = provider.formData.connectionType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.updateFormData((d) => d.connectionType = type),
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

  Widget _buildStep3(BuildContext context, RegistrationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const SectionLabel('Required Documents'),
        const SizedBox(height: 12),
        _uploadTile(context, 'Valid ID', 'Government Issued ID with photo'),
        const SizedBox(height: 10),
        _uploadTile(context, 'Selfie with ID', 'Clear photo holding your ID'),
        const SizedBox(height: 10),
        _uploadTile(context, 'Electric Bill', 'Proof of billing address'),
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
                          color: AppColors.gray.withOpacity(0.5),
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Continue',
          onPressed: () {
            if (provider.canProceedToNextStep()) {
              provider.nextStep();
            } else {
              _showValidationErrors(context, [provider.validationError!]);
            }
          },
          backgroundColor: AppColors.orange,
          trailingIcon: Icons.arrow_forward,
          disabled: !provider.canProceedToNextStep(),
        ),
      ],
    );
  }

  Widget _uploadTile(BuildContext context, String label, String subtitle) {
    final provider = context.watch<RegistrationProvider>();
    final formData = provider.formData;
    
    // Check if document is uploaded
    bool isUploaded = false;
    switch (label) {
      case 'Valid ID':
        isUploaded = formData.validIdFile != null;
        break;
      case 'Selfie with ID':
        isUploaded = formData.selfieFile != null;
        break;
      case 'Electric Bill':
        isUploaded = formData.electricBillFile != null;
        break;
    }
    
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
              color: isUploaded ? const Color(0xFFDCFCE7) : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isUploaded
                ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22)
                : const Icon(Icons.camera_alt_outlined,
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
          if (isUploaded)
            const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20)
          else
            GestureDetector(
              onTap: () => _handleDocumentUpload(context, label),
              child: Container(
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
            ),
        ],
      ),
    );
  }

  Future<void> _handleDocumentUpload(BuildContext context, String documentType) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: image_picker.ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        // Validate document type
        final isValid = await _validateDocument(context, image, documentType);
        if (isValid) {
          // Document is valid, store in registration provider
          final provider = context.read<RegistrationProvider>();
          final file = File(image.path);
          
          switch (documentType) {
            case 'Valid ID':
              provider.updateFormData((d) => d.validIdFile = file);
              break;
            case 'Selfie with ID':
              provider.updateFormData((d) => d.selfieFile = file);
              break;
            case 'Electric Bill':
              provider.updateFormData((d) => d.electricBillFile = file);
              break;
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$documentType uploaded successfully!'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          // Document is invalid, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload a valid $documentType'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload document: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<bool> _validateDocument(BuildContext context, XFile image, String documentType) async {
    try {
      final validator = context.read<DocumentValidatorService>();
      final imageFile = File(image.path);

      switch (documentType.toLowerCase()) {
        case 'valid id':
          final result = await validator.validateGovernmentId(imageFile);
          if (!result.isValid) {
            _showValidationErrors(context, result.errors);
          }
          return result.isValid;
          
        case 'selfie with id':
          final result = await validator.validateSelfie(imageFile);
          if (!result.isValid) {
            _showValidationErrors(context, result.errors);
          }
          return result.isValid;
          
        case 'electric bill':
          // For electric bill, we no longer perform validation
          // Users can upload any document as electric bill
          return true;
          
        default:
          return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document validation failed: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    }
  }

  void _showValidationErrors(BuildContext context, List<String> errors) {
    final errorText = errors.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorText),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildStep4(BuildContext context, RegistrationProvider provider) {
    final data = provider.formData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _reviewSection('CUSTOMER INFO', {
          'Name': data.customerName.isEmpty ? 'Juan Dela Cruz' : data.customerName,
          'Contact': data.contactNumber.isEmpty ? '0912345678' : data.contactNumber,
          'Area': data.area.isEmpty ? 'Bito, Abuyog, Leyte' : data.area,
          'Purpose': data.purpose.isEmpty ? 'Primary' : data.purpose,
        }),
        const SizedBox(height: 12),
        _reviewSection('INSTALLATION INFO', {
          'Connection': data.connectionType.name.toUpperCase(),
          'Status': data.serviceStatus.isEmpty ? 'Active' : data.serviceStatus,
          'Payment': data.installationPayment.isEmpty ? 'Partially Paid' : data.installationPayment,
          'Installation Fee': data.amortizationFee.isEmpty ? '₱3,000' : '₱${data.amortizationFee}',
          if (data.installationPayment == 'Partially Paid')
            'Payment Terms': data.paymentTerms.isEmpty ? '3 months' : '${data.paymentTerms} months',
          'Due Date': data.dueDate.isEmpty ? '10th' : data.dueDate,
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
                  children: _getSubmittedDocuments(context),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Save & Submit',
          onPressed: () async {
            await provider.submit();
            onFinish();
          },
          isLoading: provider.isSubmitting,
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

  List<Widget> _getSubmittedDocuments(BuildContext context) {
    final provider = context.read<RegistrationProvider>();
    final formData = provider.formData;
    final documents = <Widget>[];
    
    if (formData.validIdFile != null) {
      documents.add(_buildDocumentChip('Valid ID'));
    }
    
    if (formData.selfieFile != null) {
      documents.add(_buildDocumentChip('Selfie with ID'));
    }
    
    if (formData.electricBillFile != null) {
      documents.add(_buildDocumentChip('Electric Bill'));
    }
    
    // Always add Signed MOA as it's a required document
    documents.add(_buildDocumentChip('Signed MOA'));
    
    return documents;
  }
  
  Widget _buildDocumentChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, 
              color: Color(0xFF16A34A), size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A))),
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
            color: AppColors.gray.withOpacity(0.6), fontSize: 14),
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
