import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import 'package:provider/provider.dart';

// ============================================================
// STAFF SHELL (Bottom Nav)
// ============================================================

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _selectedIndex = 0;

  final _pages = const [
    StaffDashboardPage(),
    StaffBillingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: AppColors.shadow12, blurRadius: 16, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(Icons.dashboard_rounded, 'Dashboard', 0),
                _navItem(Icons.credit_card_rounded, 'Billing', 1),
                _logoutItem(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isActive ? AppColors.orange : AppColors.gray),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.orange : AppColors.gray,
              )),
        ],
      ),
    );
  }

  Widget _logoutItem() {
    return GestureDetector(
      onTap: () => context.read<AuthProvider>().logout(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.logout_rounded, size: 24, color: AppColors.red),
          SizedBox(height: 4),
          Text('Exit',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.red)),
        ],
      ),
    );
  }
}

// ============================================================
// STAFF DASHBOARD
// ============================================================

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _api = MockApiService();

  List<Applicant> _applicants = [];
  List<RepairTicket> _tickets = [];
  bool _isLoading = true;

  Applicant? _selectedApplicant;
  RepairTicket? _selectedTicket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final applicants = await _api.getApplicants();
    final tickets = await _api.getAllTickets();
    if (mounted) {
      setState(() {
        _applicants = applicants;
        _tickets = tickets;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveApplicant(String id) async {
    await _api.approveApplicant(id);
    setState(() {
      _applicants.removeWhere((a) => a.id == id);
      _selectedApplicant = null;
    });
  }

  Future<void> _declineApplicant(String id) async {
    await _api.declineApplicant(id);
    setState(() {
      _applicants.removeWhere((a) => a.id == id);
      _selectedApplicant = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Dashboard',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    Text('Requests & Tickets',
                        style: TextStyle(fontSize: 13, color: AppColors.gray)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      _tabBtn('Installment (${_applicants.length})', 0),
                      _tabBtn('Repairs (${_tickets.length})', 1),
                      _tabBtn('On-Site', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
                    : TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildInstallmentTab(),
                          _buildRepairsTab(),
                          const _OnSiteTab(),
                        ],
                      ),
              ),
            ],
          ),
          if (_selectedApplicant != null)
            _ApplicantDetailModal(
              applicant: _selectedApplicant!,
              onClose: () => setState(() => _selectedApplicant = null),
              onApprove: () => _approveApplicant(_selectedApplicant!.id),
              onDecline: () => _declineApplicant(_selectedApplicant!.id),
            ),
          if (_selectedTicket != null)
            _TicketDetailModal(
              ticket: _selectedTicket!,
              onClose: () => setState(() => _selectedTicket = null),
              onSave: (status, notes) async {
                await _api.updateTicket(TicketUpdateRequest(
                  ticketId: _selectedTicket!.id,
                  status: status,
                  technicianNotes: notes,
                ));
                setState(() => _selectedTicket = null);
              },
            ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final isActive = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.index = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.white : AppColors.gray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentTab() {
    if (_applicants.isEmpty) {
      return const Center(
          child: Text('No pending applications', style: TextStyle(color: AppColors.gray)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _applicants.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ApplicantCard(
          applicant: _applicants[i],
          onTap: () => setState(() => _selectedApplicant = _applicants[i]),
        ),
      ),
    );
  }

  Widget _buildRepairsTab() {
    if (_tickets.isEmpty) {
      return const Center(
          child: Text('No repair tickets', style: TextStyle(color: AppColors.gray)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _tickets.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _RepairTicketCard(
          ticket: _tickets[i],
          onViewDetails: () => setState(() => _selectedTicket = _tickets[i]),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final VoidCallback onTap;

  const _ApplicantCard({required this.applicant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, size: 20, color: AppColors.gray),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(applicant.address,
                          style: const TextStyle(fontSize: 11, color: AppColors.gray)),
                    ],
                  ),
                ],
              ),
              StatusBadge.pending(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Plan: ', style: TextStyle(fontSize: 11, color: AppColors.gray)),
                Text(applicant.plan,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                Text('Date: ', style: TextStyle(fontSize: 11, color: AppColors.gray)),
                Text(applicant.date,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grayLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Approve',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepairTicketCard extends StatelessWidget {
  final RepairTicket ticket;
  final VoidCallback onViewDetails;

  const _RepairTicketCard({required this.ticket, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.red, width: 4)),
        boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.build, size: 12, color: AppColors.red),
                  const SizedBox(width: 4),
                  Text('Ticket #${ticket.id}',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.red)),
                ],
              ),
              Text(ticket.date,
                  style: const TextStyle(fontSize: 10, color: AppColors.gray)),
            ],
          ),
          const SizedBox(height: 6),
          Text(ticket.issue,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppColors.grayLight, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        ticket.customerName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(ticket.customerName,
                      style: const TextStyle(fontSize: 12, color: AppColors.gray)),
                ],
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Row(
                  children: const [
                    Text('View Details',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orange)),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Applicant Detail Modal ----
class _ApplicantDetailModal extends StatelessWidget {
  final Applicant applicant;
  final VoidCallback onClose;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const _ApplicantDetailModal({
    required this.applicant,
    required this.onClose,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Application Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.creamDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Customer Information'),
                      const Divider(height: 12),
                      SummaryRow(label: 'Name', value: applicant.name),
                      SummaryRow(label: 'Address', value: applicant.address),
                      SummaryRow(label: 'Contact', value: applicant.contactNumber),
                      SummaryRow(label: 'Type', value: applicant.connectionType.name.toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('Plan Details'),
                      const Divider(height: 12),
                      SummaryRow(label: 'Plan', value: applicant.plan),
                      SummaryRow(label: 'Applied Date', value: applicant.date),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SectionLabel('Submitted Documents'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Valid ID', 'Selfie', 'Electric Bill', 'Location'].map((doc) {
                    return OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: AppColors.grayLight),
                      ),
                      child: Text(doc,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Decline',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirm Approval',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Ticket Detail Modal ----
class _TicketDetailModal extends StatefulWidget {
  final RepairTicket ticket;
  final VoidCallback onClose;
  final Function(TicketStatus, String?) onSave;

  const _TicketDetailModal({
    required this.ticket,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_TicketDetailModal> createState() => _TicketDetailModalState();
}

class _TicketDetailModalState extends State<_TicketDetailModal> {
  TicketStatus _selectedStatus = TicketStatus.resolved;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(20),
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
                  const Text('Ticket Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
                ],
              ),
              AppCard(
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: AppColors.black,
                          child: Text('ID: #${widget.ticket.id}',
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Text(widget.ticket.date,
                            style: const TextStyle(fontSize: 11, color: AppColors.gray)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.ticket.issue,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(widget.ticket.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.gray, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Update Status',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<TicketStatus>(
                      value: _selectedStatus,
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                      items: [
                        DropdownMenuItem(
                            value: TicketStatus.resolved, child: const Text('Resolve')),
                        DropdownMenuItem(
                            value: TicketStatus.pending, child: const Text('Pending')),
                        DropdownMenuItem(
                            value: TicketStatus.onHold, child: const Text('On Hold')),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.grayLight)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SectionLabel('Technician Notes'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Internal notes...',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.grayLight)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.grayLight)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Save Updates',
                      onPressed: () =>
                          widget.onSave(_selectedStatus, _notesController.text),
                      backgroundColor: AppColors.orange,
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
}

// ============================================================
// ON-SITE TAB
// ============================================================

class _OnSiteTab extends StatefulWidget {
  const _OnSiteTab();

  @override
  State<_OnSiteTab> createState() => _OnSiteTabState();
}

class _OnSiteTabState extends State<_OnSiteTab> {
  final _api = MockApiService();
  final _searchController = TextEditingController();
  CustomerLookupResult? _result;
  bool _isSearching = false;
  int _step = 1;

  Future<void> _search() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await _api.lookupCustomer(_searchController.text.trim());
    setState(() {
      _result = result;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step progress
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: _step >= i + 1 ? AppColors.orange : AppColors.grayLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Search Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.creamDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Customer Lookup'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter customer name',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSearching ? null : _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white))
                          : const Text('Check',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Result
          if (_result != null) _buildResult(_result!),
        ],
      ),
    );
  }

  Widget _buildResult(CustomerLookupResult result) {
    final isActive = result.status == CustomerLookupStatus.active;
    final isNotUpdated = result.status == CustomerLookupStatus.notUpdated;

    if (isNotUpdated) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: AppColors.redLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline, size: 32, color: AppColors.red),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppColors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber, size: 16, color: AppColors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Profile Not Updated',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'This customer account has missing info or is inactive. Update the profile to proceed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.gray, height: 1.5),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Update Customer Profile',
              onPressed: () {},
              backgroundColor: AppColors.red,
              trailingIcon: Icons.edit,
            ),
          ],
        ),
      );
    }

    if (isActive) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: AppColors.greenLight, shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline,
                      color: Color(0xFF16A34A), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(result.address,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                StatusBadge(
                  label: 'ACTIVE',
                  backgroundColor: AppColors.greenLight,
                  textColor: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_step == 1) _buildRepairForm(),
          if (_step == 2) _buildDocumentationStep(),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildRepairForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Repair Findings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const Divider(height: 16),
          const SectionLabel('Technician Notes'),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe findings and action taken...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.grayLight)),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            hint: const Text('Status Update'),
            items: ['Resolve', 'Monitor'].map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (_) {},
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.grayLight)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Next: Documentation',
            onPressed: () => setState(() => _step = 2),
            backgroundColor: AppColors.orange,
            trailingIcon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentationStep() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo Documentation',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _photoUploadBox('Before')),
              const SizedBox(width: 12),
              Expanded(child: _photoUploadBox('After')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Signatures',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          _signaturePad('Tap to sign (Customer)'),
          const SizedBox(height: 10),
          _signaturePad('Tap to sign (Staff)'),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Complete Job',
            onPressed: () => setState(() { _step = 1; _result = null; }),
            backgroundColor: AppColors.orange,
            trailingIcon: Icons.check,
          ),
        ],
      ),
    );
  }

  Widget _photoUploadBox(String label) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayLight, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.gray),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray)),
          ],
        ),
      ),
    );
  }

  Widget _signaturePad(String hint) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Center(
        child: Text(hint,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray.withValues(alpha: 0.7))),
      ),
    );
  }
}

// ============================================================
// STAFF BILLING PAGE
// ============================================================

class StaffBillingPage extends StatefulWidget {
  const StaffBillingPage({super.key});

  @override
  State<StaffBillingPage> createState() => _StaffBillingPageState();
}

class _StaffBillingPageState extends State<StaffBillingPage> {
  final _api = MockApiService();
  List<BillingRecord> _records = [];
  bool _isLoading = true;
  String _filter = 'All';
  String _searchQuery = '';
  BillingRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _loadBilling();
  }

  Future<void> _loadBilling() async {
    final records = await _api.getAllBillingRecords();
    if (mounted) setState(() { _records = records; _isLoading = false; });
  }

  List<BillingRecord> get _filtered {
    return _records.where((r) {
      final matchFilter = _filter == 'All' ||
          (_filter == 'Unpaid' && r.status == BillingStatus.unpaid) ||
          (_filter == 'Partial' && r.status == BillingStatus.partial) ||
          (_filter == 'Remitted' && r.status == BillingStatus.remitted);
      final matchSearch = _searchQuery.isEmpty ||
          r.customerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Billing',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    const Text('Payments & SOA',
                        style: TextStyle(fontSize: 13, color: AppColors.gray)),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search customer...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.grayLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.grayLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Unpaid', 'Partial', 'Remitted'].map((f) {
                          final isActive = _filter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.black : AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.grayLight),
                                ),
                                child: Text(f,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isActive ? AppColors.white : AppColors.gray)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _BillingRecordCard(
                            record: _filtered[i],
                            onProcessPayment: () =>
                                setState(() => _selectedRecord = _filtered[i]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (_selectedRecord != null)
            _PaymentModal(
              record: _selectedRecord!,
              onClose: () => setState(() => _selectedRecord = null),
              onConfirm: (request) async {
                await _api.processPayment(request);
                setState(() => _selectedRecord = null);
                await _loadBilling();
              },
            ),
        ],
      ),
    );
  }
}

class _BillingRecordCard extends StatelessWidget {
  final BillingRecord record;
  final VoidCallback onProcessPayment;

  const _BillingRecordCard({required this.record, required this.onProcessPayment});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeLabel;
    switch (record.status) {
      case BillingStatus.remitted:
        badgeColor = AppColors.green;
        badgeLabel = 'REMITTED';
        break;
      case BillingStatus.partial:
        badgeColor = AppColors.orangeLight;
        badgeLabel = 'PARTIAL';
        break;
      default:
        badgeColor = AppColors.red;
        badgeLabel = 'UNPAID';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grayLight.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, size: 20, color: AppColors.gray),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(record.address,
                        style: const TextStyle(fontSize: 11, color: AppColors.gray)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(badgeLabel,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _amountCol('Monthly', '₱${record.currentCharges.toStringAsFixed(0)}', AppColors.gray),
                _amountCol('Prev Bal',
                    '₱${record.previousBalance.toStringAsFixed(0)}',
                    record.previousBalance > 0 ? AppColors.red : AppColors.gray),
                _amountCol('Total Due', '₱${record.totalBalance.toStringAsFixed(0)}',
                    AppColors.orange, isLarge: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due: ${record.dueDateDay}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gray)),
              ElevatedButton(
                onPressed: record.status == BillingStatus.remitted ? null : onProcessPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: record.status == BillingStatus.remitted
                      ? AppColors.grayLight
                      : AppColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  record.status == BillingStatus.remitted ? 'Paid' : 'Process Payment',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: record.status == BillingStatus.remitted
                          ? AppColors.gray
                          : AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountCol(String label, String value, Color valueColor, {bool isLarge = false}) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: AppColors.gray, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: isLarge ? 18 : 13,
                fontWeight: FontWeight.w800,
                color: valueColor)),
      ],
    );
  }
}

// ---- Payment Modal ----
class _PaymentModal extends StatefulWidget {
  final BillingRecord record;
  final VoidCallback onClose;
  final Function(PaymentRequest) onConfirm;

  const _PaymentModal({
    required this.record,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  State<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<_PaymentModal> {
  String _settlementType = 'Full Payment';
  String _method = 'Cash';
  final _amountController = TextEditingController();
  final _discountController = TextEditingController(text: '0.00');
  final _coverageController = TextEditingController();
  final _refController = TextEditingController();
  final _remarksController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.record.totalBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _discountController.dispose();
    _coverageController.dispose();
    _refController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => _isSubmitting = true);
    final request = PaymentRequest(
      customerId: widget.record.customerId,
      settlementType: _settlementType,
      amount: double.tryParse(_amountController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      coveragePeriod: _coverageController.text,
      method: _method,
      referenceNumber: _refController.text,
      remarks: _remarksController.text,
      paymentDate: _paymentDate,
    );
    await widget.onConfirm(request);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACCOUNT NAME',
                            style: TextStyle(fontSize: 9, color: AppColors.gray, fontWeight: FontWeight.w700)),
                        Text(widget.record.customerName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TOTAL DUE',
                            style: TextStyle(fontSize: 9, color: AppColors.gray, fontWeight: FontWeight.w700)),
                        Text('₱${widget.record.totalBalance.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.red)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Payment form
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grayLight),
                    boxShadow: const [BoxShadow(color: AppColors.shadow06, blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.credit_card_outlined, size: 16, color: AppColors.gray),
                          SizedBox(width: 6),
                          SectionLabel('Payment Entry'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown(
                              label: 'Settlement',
                              placeholder: 'Settlement Type',
                              options: ['Full Payment', 'Partial Payment'],
                              value: _settlementType,
                              onChanged: (v) => setState(() {
                                _settlementType = v ?? 'Full Payment';
                                if (_settlementType == 'Full Payment') {
                                  _amountController.text =
                                      widget.record.totalBalance.toStringAsFixed(2);
                                } else {
                                  _amountController.clear();
                                }
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionLabel('Date'),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _paymentDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) setState(() => _paymentDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.grayLight),
                                    ),
                                    child: Text(
                                      '${_paymentDate.month}/${_paymentDate.day}/${_paymentDate.year}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('Amount Paid'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = double.tryParse(v) ?? 0;
                              if (val > widget.record.totalBalance) {
                                _amountController.text =
                                    widget.record.totalBalance.toStringAsFixed(2);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: '0.00',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.grayLight)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.grayLight)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              helperText: 'Max: ₱${widget.record.totalBalance.toStringAsFixed(0)}',
                              helperStyle: const TextStyle(fontSize: 9, color: AppColors.gray),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _formField('Discount', _discountController, hint: '0.00'),
                      const SizedBox(height: 12),
                      _formField('Coverage Period', _coverageController, hint: 'e.g. Oct - Nov'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown(
                              label: 'Method',
                              placeholder: 'Method',
                              options: ['Cash', 'GCash'],
                              value: _method,
                              onChanged: (v) => setState(() => _method = v ?? 'Cash'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: _formField('Ref / OR No.', _refController, hint: 'X123-456')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionLabel('Remarks'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _remarksController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Optional notes...',
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.grayLight)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.grayLight)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onClose,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white))
                            : const Text('Confirm Payment',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController controller, {String hint = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayLight)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grayLight)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
