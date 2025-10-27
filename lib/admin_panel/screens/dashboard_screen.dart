import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_drawer.dart';
import '../services/user_service.dart';
import '../services/payment_service.dart';
import '../services/donation_service.dart';
import '../services/counter_service.dart';
import '../views/admin_registered_page.dart';
import '../views/admin_approved_users_page.dart';
import 'donations_screen.dart';
import 'online_payment_users_screen.dart';
import 'manual_approval_users_screen.dart';
import 'date_filter_screen.dart';
import 'admin_registration_screen.dart';
import '../../config/app_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cache for dashboard data to prevent unnecessary refetches
  Map<String, dynamic> _cachedData = {};
  bool _isLoading = false;

  // Payment breakdown expansion state
  bool _isPaymentBreakdownExpanded = false;

  // Payment breakdown data
  int _onlinePaymentUsers = 0;
  int _manualApprovalUsers = 0;
  double _onlinePaymentAmount = 0.0;
  double _manualApprovalAmount = 0.0;
  bool _isUsingEstimatedData = false;

  // Initialize data once when widget is created
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Load dashboard data
  Future<void> _loadDashboardData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use optimized method to get all statistics in one query
      final stats = await CounterService().getAllStatistics();

      // Load donation data separately (since it's from different collection)
      final donationFutures = await Future.wait([
        DonationService().getTotalDonationRequests(),
        DonationService().getTotalApprovedDonations(),
      ]);

      // Load payment breakdown data
      await _loadPaymentBreakdownData();

      setState(() {
        _cachedData = {
          'totalRegistrations': stats['totalRegistrations'],
          'totalGuests': stats['totalGuests'],
          'totalDonationRequests': donationFutures[0],
          'totalApprovedDonations': donationFutures[1],
          'totalCollections': stats['totalCollections'],
          'totalApprovedUsers': stats['totalApprovedUsers'],
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load payment breakdown data
  Future<void> _loadPaymentBreakdownData() async {
    try {
      print('💳 Loading payment breakdown data...');

      // Get all registrations to analyze payment methods
      final snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      int onlinePaymentUsers = 0;
      int manualApprovalUsers = 0;
      double onlinePaymentAmount = 0.0;
      double manualApprovalAmount = 0.0;

      print('🔍 Analyzing ${snapshot.docs.length} registration documents...');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final paymentStatus = data['paymentStatus'] ?? '';
        final totalPayable = (data['totalPayable'] ?? 0) as num;

        if (paymentStatus == 'approved') {
          // Use the exact same logic as the detail screens
          bool isOnlinePayment = _isOnlinePayment(data);

          if (isOnlinePayment) {
            onlinePaymentUsers++;
            onlinePaymentAmount += totalPayable.toDouble();
          } else {
            manualApprovalUsers++;
            manualApprovalAmount += totalPayable.toDouble();
          }
        }
      }

      setState(() {
        _onlinePaymentUsers = onlinePaymentUsers;
        _manualApprovalUsers = manualApprovalUsers;
        _onlinePaymentAmount = onlinePaymentAmount;
        _manualApprovalAmount = manualApprovalAmount;
        _isUsingEstimatedData = false;
      });

      print('✅ Payment breakdown loaded:');
      print(
        '   Online Payment Users: $onlinePaymentUsers (৳$onlinePaymentAmount)',
      );
      print(
        '   Manual Approval Users: $manualApprovalUsers (৳$manualApprovalAmount)',
      );
    } catch (e) {
      print('Error loading payment breakdown data: $e');
    }
  }

  // Check if a payment is online payment - MUST match the logic in detail screens
  bool _isOnlinePayment(Map<String, dynamic> data) {
    // Check if paymentData exists and contains online payment indicators
    final paymentData = data['paymentData'];
    if (paymentData != null && paymentData is Map<String, dynamic>) {
      // Check for SSLCommerz indicators in paymentData
      final paymentMethod =
          paymentData['payment_method'] ?? paymentData['paymentMethod'] ?? '';
      final tranId = paymentData['tran_id'] ?? '';
      final valId = paymentData['val_id'] ?? '';
      final status = paymentData['status'] ?? '';
      final storeId = paymentData['store_id'] ?? '';

      // If any of these SSLCommerz fields exist, it's an online payment
      if (paymentMethod.toLowerCase().contains('sslcommerz') ||
          paymentMethod.toLowerCase().contains('bkash') ||
          paymentMethod.toLowerCase().contains('mobilebanking') ||
          tranId.isNotEmpty ||
          valId.isNotEmpty ||
          status.toLowerCase() == 'valid' ||
          storeId.isNotEmpty) {
        return true;
      }
    }

    // Fallback to original logic for backward compatibility
    final paymentMethod = data['paymentMethod'] ?? data['payment_method'] ?? '';
    final paymentType = data['paymentType'] ?? data['payment_type'] ?? '';
    final sslcommerz = data['sslcommerz'] ?? '';
    final isOnlinePaymentField =
        data['isOnlinePayment'] ?? data['is_online_payment'] ?? false;
    final gateway = data['gateway'] ?? '';

    // Check if it's an online payment
    if (paymentMethod.toLowerCase().contains('sslcommerz') ||
        paymentMethod.toLowerCase().contains('online') ||
        paymentMethod.toLowerCase().contains('bkash') ||
        paymentType.toLowerCase().contains('sslcommerz') ||
        paymentType.toLowerCase().contains('online') ||
        sslcommerz.toString().toLowerCase().contains('true') ||
        isOnlinePaymentField == true ||
        gateway.toLowerCase().contains('sslcommerz') ||
        gateway.toLowerCase().contains('online')) {
      return true;
    }

    // Check for transaction IDs
    final transactionId =
        data['transactionId'] ??
        data['transaction_id'] ??
        data['sslcommerzTransactionId'] ??
        '';
    final paymentId = data['paymentId'] ?? data['payment_id'] ?? '';
    if (transactionId.isNotEmpty || paymentId.isNotEmpty) {
      return true;
    }

    // Check for SSLCommerz specific fields
    final sslcommerzStatus = data['sslcommerzStatus'] ?? '';
    final sslcommerzTranId = data['sslcommerzTranId'] ?? '';
    final sslcommerzValId = data['sslcommerzValId'] ?? '';
    final sslcommerzAmount = data['sslcommerzAmount'] ?? '';

    if (sslcommerzStatus.isNotEmpty ||
        sslcommerzTranId.isNotEmpty ||
        sslcommerzValId.isNotEmpty ||
        sslcommerzAmount.isNotEmpty) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Admin Dashboard'),
            if (AppConfig.showDevModeIndicator) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEV MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConfig.useTestData ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppConfig.useTestData ? 'TEST DATA' : 'REAL DATA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppConfig.showDevModeIndicator) _buildDevModeBanner(),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 900) {
                  crossAxisCount = 4;
                }

                if (_isLoading) {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading dashboard data...'),
                      ],
                    ),
                  );
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: _buildStatCards(context),
                );
              },
            ),
            const SizedBox(height: 32),

            // Payment Breakdown Section
            _buildPaymentBreakdownSection(),

            const SizedBox(height: 32),

            // Quick Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const AdminRegistrationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Register User'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B6914),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/admin/search-user'),
                            icon: const Icon(Icons.search),
                            label: const Text('Search User'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/admin/countdown-settings'),
                            icon: const Icon(Icons.timer),
                            label: const Text('Countdown Settings'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(), // Empty container for spacing
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => const DateFilterScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Filter by Date'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const OnlinePaymentUsersScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.credit_card),
                            label: const Text('Online Payments'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const ManualApprovalUsersScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Manual Approvals'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DonationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite),
                            label: const Text('Donations'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Recent Users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: UserService().fetchAllUsers(),
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                final recent = users.reversed.take(5).toList();
                return _recentList(
                  recent,
                  (u) =>
                      u['displayName'] ?? u['email'] ?? u['uid'] ?? 'Unknown',
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Payments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: PaymentService().fetchAllPayments(),
              builder: (context, snapshot) {
                final payments = snapshot.data ?? [];
                final recent = payments.reversed.take(5).toList();
                return _recentList(
                  recent,
                  (p) =>
                      (p['payer'] ?? p['userId'] ?? p['id'] ?? 'Unknown') +
                      ' - ' +
                      (p['amount']?.toString() ?? 'N/A'),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Donations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DonationService().fetchAllDonations(),
              builder: (context, snapshot) {
                final donations = snapshot.data ?? [];
                final recent = donations.reversed.take(5).toList();
                return _recentList(
                  recent,
                  (d) =>
                      (d['donorName'] ?? 'Unknown') +
                      ' - ' +
                      (d['amount']?.toString() ?? 'N/A'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatCards(BuildContext context) {
    return [
      // Total Register (clickable)
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminRegisteredPage()),
          );
        },
        child: _statCard(
          'Total Register',
          (_cachedData['totalRegistrations'] ?? 0).toString(),
          Icons.app_registration,
          isClickable: true,
        ),
      ),
      // Total Guest
      _statCard(
        'Total Guest',
        (_cachedData['totalGuests'] ?? 0).toString(),
        Icons.group_add,
      ),
      // Total Donation Requests (clickable)
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DonationsScreen(),
              settings: const RouteSettings(name: '/admin/donations'),
            ),
          );
        },
        child: _statCard(
          'Total Donation Requests',
          (_cachedData['totalDonationRequests'] ?? 0).toString(),
          Icons.request_page,
          isClickable: true,
        ),
      ),
      // Approved Donations Amount (clickable)
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DonationsScreen(),
              settings: const RouteSettings(name: '/admin/donations'),
            ),
          );
        },
        child: _statCard(
          'Approved Donations',
          '৳${_cachedData['totalApprovedDonations'] ?? 0}',
          Icons.volunteer_activism,
          isClickable: true,
        ),
      ),
      // Collections
      _statCard(
        'Collections',
        '৳${_cachedData['totalCollections'] ?? 0}',
        Icons.account_balance_wallet,
      ),
      // Approved Users Card
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminApprovedUsersPage()),
          );
        },
        child: _statCard(
          'Approved',
          (_cachedData['totalApprovedUsers'] ?? 0).toString(),
          Icons.verified_user,
          isClickable: true,
        ),
      ),
    ];
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon, {
    bool isClickable = false,
  }) {
    return Card(
      elevation: isClickable ? 4 : 2,
      child: Container(
        decoration:
            isClickable
                ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
                : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isClickable ? const Color(0xFF1976D2) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isClickable ? FontWeight.bold : FontWeight.normal,
                        color: isClickable ? const Color(0xFF1976D2) : null,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isClickable ? const Color(0xFF1976D2) : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (isClickable) ...[
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF1976D2),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentList(
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) getTitle,
  ) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No data.'),
      );
    }
    return Column(
      children:
          items.map((item) => ListTile(title: Text(getTitle(item)))).toList(),
    );
  }

  /// Build development mode banner
  Widget _buildDevModeBanner() {
    final isUsingTestData = AppConfig.useTestData;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUsingTestData ? Colors.orange.shade100 : Colors.green.shade100,
        border: Border.all(
          color:
              isUsingTestData ? Colors.orange.shade300 : Colors.green.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isUsingTestData ? Icons.developer_mode : Icons.data_usage,
            color:
                isUsingTestData
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUsingTestData
                  ? 'Development Mode: Showing test data instead of real Firebase data'
                  : 'Development Mode: Showing real Firebase data',
              style: TextStyle(
                color:
                    isUsingTestData
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build payment breakdown section with expandable cards
  Widget _buildPaymentBreakdownSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with expand/collapse button
            Row(
              children: [
                const Icon(Icons.payment, color: Color(0xFF1976D2), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Payment Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isPaymentBreakdownExpanded =
                          !_isPaymentBreakdownExpanded;
                    });
                  },
                  icon: Icon(
                    _isPaymentBreakdownExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ],
            ),

            // Expandable content
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isPaymentBreakdownExpanded ? null : 0,
              child:
                  _isPaymentBreakdownExpanded
                      ? Column(
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Sub-cards row
                          Row(
                            children: [
                              // Online Payment Card
                              Expanded(
                                child: _buildPaymentSubCard(
                                  'Online Payment (SSLCommerz)',
                                  '$_onlinePaymentUsers Users',
                                  '৳$_onlinePaymentAmount',
                                  Icons.credit_card,
                                  const Color(0xFF4CAF50),
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const OnlinePaymentUsersScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Manual Approval Card
                              Expanded(
                                child: _buildPaymentSubCard(
                                  'Manual Approval',
                                  '$_manualApprovalUsers Users',
                                  '৳$_manualApprovalAmount',
                                  Icons.person_add,
                                  const Color(0xFFFF9800),
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ManualApprovalUsersScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Summary row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                if (_isUsingEstimatedData)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.orange.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.orange.shade700,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Using estimated data - payment method detection needs improvement',
                                          style: TextStyle(
                                            color: Colors.orange.shade800,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSummaryItem(
                                      'Total Users',
                                      '${_onlinePaymentUsers + _manualApprovalUsers}',
                                      Icons.people,
                                    ),
                                    _buildSummaryItem(
                                      'Total Amount',
                                      '৳${_onlinePaymentAmount + _manualApprovalAmount}',
                                      Icons.account_balance_wallet,
                                    ),
                                    _buildSummaryItem(
                                      'Online %',
                                      '${_onlinePaymentUsers > 0 ? ((_onlinePaymentUsers / (_onlinePaymentUsers + _manualApprovalUsers)) * 100).toStringAsFixed(1) : '0.0'}%',
                                      Icons.trending_up,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment sub-card
  Widget _buildPaymentSubCard(
    String title,
    String userCount,
    String amount,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userCount,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward_ios, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
