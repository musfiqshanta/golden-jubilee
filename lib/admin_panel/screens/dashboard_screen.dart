import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../services/user_service.dart';
import '../services/payment_service.dart';
import '../services/donation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/admin_registered_page.dart';
import '../views/admin_approved_users_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collectionGroup('registrations')
                  .snapshots(),
          builder: (context, snapshot) {
            int totalRegister = 0;
            if (snapshot.hasData) {
              totalRegister = snapshot.data!.docs.length;
            }
            return _statCard(
              'Total Register',
              totalRegister.toString(),
              Icons.app_registration,
              isClickable: true,
            );
          },
        ),
      ),
      // Total Guest
      StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup('registrations')
                .snapshots(),
        builder: (context, snapshot) {
          double totalGuest = 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalGuest +=
                  (data['spouseCount'] ?? 0) + (data['childCount'] ?? 0);
            }
          }
          return _statCard(
            'Total Guest',
            totalGuest.toInt().toString(),
            Icons.group_add,
          );
        },
      ),
      // Donation (clickable)
      GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/admin/donations');
        },
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('donations').snapshots(),
          builder: (context, snapshot) {
            double totalDonation = 0;
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                totalDonation += (data['amount'] ?? 0) as num;
              }
            }
            return _statCard(
              'Donation',
              '৳$totalDonation',
              Icons.volunteer_activism,
              isClickable: true,
            );
          },
        ),
      ),
      // Collections
      StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup('registrations')
                .where('paymentStatus', isEqualTo: 'approved')
                .snapshots(),
        builder: (context, snapshot) {
          double totalCollection = 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              // Use stored totalPayable amount
              totalCollection += (data['totalPayable'] ?? 0) as num;
            }
          }
          return _statCard(
            'Collections',
            '৳$totalCollection',
            Icons.account_balance_wallet,
          );
        },
      ),
      // Approved Users Card
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminApprovedUsersPage()),
          );
        },
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collectionGroup('registrations')
                  .where('paymentStatus', isEqualTo: 'approved')
                  .snapshots(),
          builder: (context, snapshot) {
            int approvedCount = 0;
            if (snapshot.hasData) {
              approvedCount = snapshot.data!.docs.length;
            }
            return _statCard(
              'Approved',
              approvedCount.toString(),
              Icons.verified_user,
              isClickable: true,
            );
          },
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
              Column(
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
              if (isClickable) ...[
                const Spacer(),
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
