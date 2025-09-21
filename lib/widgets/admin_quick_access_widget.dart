import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_panel/services/counter_service.dart';
import '../config/collection_names.dart';

class AdminQuickAccessWidget extends StatefulWidget {
  const AdminQuickAccessWidget({super.key});

  @override
  State<AdminQuickAccessWidget> createState() => _AdminQuickAccessWidgetState();
}

class _AdminQuickAccessWidgetState extends State<AdminQuickAccessWidget> {
  final CounterService _counterService = CounterService();

  // Statistics data
  int _totalRegistrations = 0;
  double _totalCollections = 0.0;
  int _totalApprovedUsers = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final futures = await Future.wait([
        _counterService.getTotalRegistrationsCount(),
        _counterService.getTotalCollectionsAmount(),
        _counterService.getTotalApprovedUsersCount(),
      ]);

      setState(() {
        _totalRegistrations = futures[0] as int;
        _totalCollections = futures[1] as double;
        _totalApprovedUsers = futures[2] as int;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading admin statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!CollectionConfig.isDevelopment) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B6914), Color(0xFFD4AF37)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed('/admin');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Full Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Registrations',
                  _isLoadingStats ? '...' : '$_totalRegistrations',
                  Icons.app_registration,
                  () => Get.toNamed('/registered'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Collections',
                  _isLoadingStats ? '...' : '৳$_totalCollections',
                  Icons.account_balance_wallet,
                  () => Get.toNamed('/approved-users'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Approved',
                  _isLoadingStats ? '...' : '$_totalApprovedUsers',
                  Icons.verified_user,
                  () => Get.toNamed('/approved-users'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Manage Users',
                  Icons.people,
                  () => Get.toNamed('/admin/dashboard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Donations',
                  Icons.volunteer_activism,
                  () => Get.toNamed('/admin/donations'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Settings',
                  Icons.settings,
                  () => Get.toNamed('/admin/countdown-settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
