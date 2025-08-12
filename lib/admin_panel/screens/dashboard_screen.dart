import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../services/user_service.dart';
import '../services/payment_service.dart';
import '../services/donation_service.dart';
import '../services/counter_service.dart';
import '../utils/initialize_counters.dart';
import '../views/admin_registered_page.dart';
import '../views/admin_approved_users_page.dart';
import 'donations_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Cache for dashboard data to prevent unnecessary refetches
  Map<String, dynamic> _cachedData = {};
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: const AdminDrawer(selectedRoute: '/admin/dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        const SizedBox(width: 16),
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
}
