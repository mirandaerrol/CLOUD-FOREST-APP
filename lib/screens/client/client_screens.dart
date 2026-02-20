import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../widgets/common_widgets.dart';

// ============================================================
// CLIENT SHELL (Bottom Nav)
// ============================================================

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});
  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _selectedIndex = 0;

  final _pages = const [
    ClientHomePage(),
    ClientBillingPage(),
    ClientRepairPage(),
    ClientProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: AppColors.shadow12, blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'Home', 0),
                _navItem(Icons.credit_card_rounded, 'Billing', 1),
                _navItem(Icons.build_rounded, 'Repair', 2),
                _navItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: isActive ? AppColors.white : AppColors.gray),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white)),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CLIENT HOME
// ============================================================

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Column(
        children: [
          // Orange Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.name.split(' ').first ?? 'User'}! 👋',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Welcome to CloudForest',
                          style: TextStyle(color: Color(0xFFFFD5A0), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/client/settings'),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // White body with rounded top
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _PaymentReminderCard(
                      amount: user?.monthlyBill ?? 1500,
                      dueDay: user?.dueDateDay ?? '10th',
                    ),
                    const SizedBox(height: 16),
                    // Referral Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C00), Color(0xFFCA6400)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.campaign_outlined,
                                color: AppColors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Get a Referral Reward!',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                Text('Refer a neighbor and earn rewards',
                                    style: TextStyle(
                                        color: Color(0xFFFFD5A0), fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppColors.white, size: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Quick Actions',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.credit_card_rounded,
                            label: 'View Bill',
                            subtitle: 'Check balance & SOA',
                            iconBg: const Color(0xFFFFF0DC),
                            iconColor: AppColors.orange,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.build_rounded,
                            label: 'Report Issue',
                            subtitle: 'Open a repair ticket',
                            iconBg: const Color(0xFFE8F4FF),
                            iconColor: const Color(0xFF2563EB),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.receipt_long_rounded,
                            label: 'Receipt',
                            subtitle: 'Download history',
                            iconBg: const Color(0xFFE8FFE8),
                            iconColor: const Color(0xFF16A34A),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.support_agent,
                            label: 'Support',
                            subtitle: 'Contact us',
                            iconBg: const Color(0xFFF3E8FF),
                            iconColor: const Color(0xFF7C3AED),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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

class _PaymentReminderCard extends StatelessWidget {
  final double amount;
  final String dueDay;
  const _PaymentReminderCard({required this.amount, required this.dueDay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow08, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.red, size: 12),
                    SizedBox(width: 4),
                    Text('PAYMENT DUE',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.red)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Every $dueDay',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₱ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.black),
          ),
          const Text('Monthly Subscription Fee',
              style: TextStyle(fontSize: 12, color: AppColors.gray)),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              _feeChip('Grace Period', '5 Days', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              _feeChip('Late Fee', '+₱100', AppColors.redLight, AppColors.red),
              const SizedBox(width: 8),
              _feeChip('Contemplate', '2 Days', const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeChip(String label, String value, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: textColor)),
            Text(label,
                style: const TextStyle(fontSize: 8, color: AppColors.gray),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow06, blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle,
                style: const TextStyle(fontSize: 10, color: AppColors.gray)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CLIENT BILLING
// ============================================================

class ClientBillingPage extends StatefulWidget {
  const ClientBillingPage({super.key});
  @override
  State<ClientBillingPage> createState() => _ClientBillingPageState();
}

class _ClientBillingPageState extends State<ClientBillingPage> {
  final _api = MockApiService();
  BillingRecord? _billing;
  List<PaymentHistory> _history = [];
  bool _isLoading = true;
  PaymentHistory? _selectedItem;
  bool _showSOA = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final billing = await _api.getClientBilling(user.id);
    final history = await _api.getPaymentHistory(user.id);
    if (mounted) setState(() { _billing = billing; _history = history; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Billing',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            Text('Account & Payments',
                                style: TextStyle(
                                    color: Color(0xFFFFD5A0), fontSize: 13)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showSOA = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('SOA',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (_billing != null)
                                _buildBillingSummary(_billing!),
                              const SizedBox(height: 20),
                              const Text('Payment History',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              ..._history.map((item) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _HistoryItem(
                                      item: item,
                                      onTap: () => setState(
                                          () => _selectedItem = item),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
          if (_selectedItem != null)
            _ReceiptModal(
                item: _selectedItem!,
                onClose: () => setState(() => _selectedItem = null)),
          if (_showSOA)
            _SOAModal(onClose: () => setState(() => _showSOA = false)),
        ],
      ),
    );
  }

  Widget _buildBillingSummary(BillingRecord billing) {
    Color statusColor;
    Color statusBg;
    String statusLabel;
    switch (billing.status) {
      case BillingStatus.remitted:
        statusColor = const Color(0xFF16A34A);
        statusBg = const Color(0xFFDCFCE7);
        statusLabel = 'REMITTED';
        break;
      case BillingStatus.partial:
        statusColor = const Color(0xFFEA580C);
        statusBg = const Color(0xFFFFF7ED);
        statusLabel = 'PARTIAL';
        break;
      default:
        statusColor = AppColors.red;
        statusBg = AppColors.redLight;
        statusLabel = 'UNPAID';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow08, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(billing.planName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₱ ${billing.totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.black)),
          const Text('Total Amount Due',
              style: TextStyle(fontSize: 11, color: AppColors.gray)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryCol('Previous Balance',
                  '₱${billing.previousBalance.toStringAsFixed(0)}',
                  billing.previousBalance > 0 ? AppColors.red : AppColors.green),
              _summaryCol('Current Charges',
                  '₱${billing.currentCharges.toStringAsFixed(0)}', AppColors.black),
              _summaryCol('Due', billing.dueDateDay, AppColors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: valueColor)),
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.gray),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final PaymentHistory item;
  final VoidCallback onTap;
  const _HistoryItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow06, blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF16A34A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.month,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(item.date,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.gray)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₱ ${item.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15,
                        color: AppColors.black)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.method,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.gray)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Receipt Modal ---
class _ReceiptModal extends StatelessWidget {
  final PaymentHistory item;
  final VoidCallback onClose;
  const _ReceiptModal({required this.item, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 320,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const CFLogo(size: 64, fontSize: 24),
                        const SizedBox(height: 12),
                        const Text('Acknowledgement Receipt',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('Ref: ${item.referenceNumber}',
                            style: const TextStyle(
                                color: Color(0xFFFFD5A0), fontSize: 11)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _receiptRow('Payment Method', item.method),
                        _receiptRow('Billing Month', item.month),
                        _receiptRow('Payment Date', item.date),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount Paid',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('₱ ${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: AppColors.orange)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Save Receipt',
                          onPressed: onClose,
                          backgroundColor: AppColors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.gray, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

// --- SOA Modal ---
class _SOAModal extends StatelessWidget {
  final VoidCallback onClose;
  const _SOAModal({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 340,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CFLogo(size: 56, fontSize: 20),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STATEMENT OF ACCOUNT',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                            SizedBox(height: 4),
                            Text('CloudForest IT Solutions',
                                style: TextStyle(
                                    color: Color(0xFFFFD5A0), fontSize: 11)),
                            Text('Date: February 2026',
                                style: TextStyle(
                                    color: Color(0xFFFFD5A0), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CUSTOMER DETAILS',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.gray,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1)),
                              SizedBox(height: 6),
                              Text('Errol Miranda',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text('Bito, Abuyog, Leyte',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.gray)),
                              Text('Plan: Fiber 1500',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.gray)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const SummaryRow(
                            label: 'Billing Period',
                            value: 'Feb 1 – Feb 28, 2026'),
                        const SummaryRow(
                            label: 'Previous Balance', value: '₱ 0.00'),
                        const SummaryRow(
                            label: 'Current Charges', value: '₱ 1,500.00'),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Total Amount Due',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('₱ 1,500.00',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: AppColors.orange)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: AppColors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pay on or before Feb 10, 2026 to avoid disconnection.',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'DOWNLOAD PDF',
                          onPressed: onClose,
                          backgroundColor: AppColors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CLIENT REPAIR
// ============================================================

class ClientRepairPage extends StatefulWidget {
  const ClientRepairPage({super.key});
  @override
  State<ClientRepairPage> createState() => _ClientRepairPageState();
}

class _ClientRepairPageState extends State<ClientRepairPage> {
  final _api = MockApiService();
  List<RepairTicket> _tickets = [];
  bool _isLoading = true;
  bool _showForm = false;
  final _issueController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _issueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final tickets = await _api.getClientTickets(user.id);
    if (mounted) setState(() { _tickets = tickets; _isLoading = false; });
  }

  Future<void> _submitTicket() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    await _api.createRepairTicket(user.id, _issueController.text, _descController.text);
    _issueController.clear();
    _descController.clear();
    await _loadTickets();
    setState(() => _showForm = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Repair',
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                            Text('Support Tickets',
                                style: TextStyle(
                                    color: Color(0xFFFFD5A0), fontSize: 13)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showForm = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add,
                                  color: AppColors.white, size: 18),
                              SizedBox(width: 4),
                              Text('Report',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange))
                      : _tickets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 72,
                                      color: AppColors.green.withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  const Text('No active tickets',
                                      style: TextStyle(color: AppColors.gray)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: _tickets.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _TicketCard(ticket: _tickets[i]),
                            ),
                ),
              ),
            ],
          ),
          if (_showForm) _buildTicketForm(),
        ],
      ),
    );
  }

  Widget _buildTicketForm() {
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Report an Issue',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => setState(() => _showForm = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                  placeholder: 'Issue Summary',
                  controller: _issueController),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the problem in detail...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.grayLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.grayLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.orange, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                  label: 'Submit Ticket',
                  onPressed: _submitTicket,
                  backgroundColor: AppColors.orange),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final RepairTicket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isPending = ticket.status == TicketStatus.pending;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow06, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.red : AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Ticket #${ticket.id}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray)),
                ],
              ),
              Text(ticket.date,
                  style: const TextStyle(fontSize: 10, color: AppColors.gray)),
            ],
          ),
          const SizedBox(height: 8),
          Text(ticket.issue,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          if (ticket.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(ticket.description,
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket.customerName,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.gray)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? AppColors.redLight : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPending ? 'PENDING' : 'RESOLVED',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isPending ? AppColors.red : const Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CLIENT PROFILE
// ============================================================

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  const Text('Profile',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        (user?.name.isNotEmpty == true)
                            ? user!.name.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? 'User',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  Text(user?.username ?? '',
                      style: const TextStyle(
                          color: Color(0xFFFFD5A0), fontSize: 13)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('Account Info'),
                          const Divider(height: 16),
                          SummaryRow(label: 'Plan', value: user?.planName ?? 'N/A'),
                          SummaryRow(
                              label: 'Monthly Bill',
                              value:
                                  '₱ ${user?.monthlyBill?.toStringAsFixed(2) ?? '0.00'}'),
                          SummaryRow(
                              label: 'Due Date',
                              value: 'Every ${user?.dueDateDay ?? 'N/A'}'),
                          SummaryRow(
                              label: 'Address', value: user?.address ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      onTap: () => Navigator.pushNamed(
                          context, '/client/settings'),
                      child: const Row(
                        children: [
                          Icon(Icons.settings_outlined,
                              color: AppColors.gray, size: 20),
                          SizedBox(width: 12),
                          Text('Settings',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Spacer(),
                          Icon(Icons.chevron_right, color: AppColors.grayLight),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Log Out',
                      onPressed: () => context.read<AuthProvider>().logout(),
                      backgroundColor: AppColors.redLight,
                      textColor: AppColors.red,
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
// CLIENT SETTINGS
// ============================================================

class ClientSettingsPage extends StatelessWidget {
  const ClientSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SettingsGroup(
              title: 'Account',
              items: [
                _SettingsItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.shield_outlined,
                    label: 'Security & Privacy',
                    onTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Preferences',
              items: [
                _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Push Notifications',
                    hasToggle: true,
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.volume_up_outlined,
                    label: 'Sounds & Haptics',
                    onTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Support',
              items: [
                _SettingsItem(
                    icon: Icons.help_outline, label: 'Help Center', onTap: () {}),
                _SettingsItem(
                    icon: Icons.error_outline,
                    label: 'Report a Problem',
                    onTap: () {}),
                _SettingsItem(
                    icon: Icons.info_outline,
                    label: 'About CloudForest',
                    onTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Log Out',
              onPressed: () => context.read<AuthProvider>().logout(),
              backgroundColor: AppColors.redLight,
              textColor: AppColors.red,
            ),
            const SizedBox(height: 20),
            const Text('Version 1.0.0 · CloudForest IT Solutions',
                style: TextStyle(fontSize: 11, color: AppColors.gray)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: SectionLabel(title),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow06, blurRadius: 8),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool hasToggle;
  final VoidCallback onTap;
  const _SettingsItem({
    required this.icon,
    required this.label,
    this.hasToggle = false,
    required this.onTap,
  });
  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem> {
  bool _toggled = true;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(widget.icon, size: 18, color: AppColors.gray),
      ),
      title: Text(widget.label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black)),
      trailing: widget.hasToggle
          ? Switch(
              value: _toggled,
              onChanged: (v) => setState(() => _toggled = v),
              activeTrackColor: AppColors.orange,
            )
          : const Icon(Icons.chevron_right, color: AppColors.grayLight),
    );
  }
}
