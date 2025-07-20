import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDrawer extends StatelessWidget {
  final String selectedRoute;
  const AdminDrawer({super.key, required this.selectedRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Admin Panel',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildNavItem(
            context,
            'Dashboard',
            '/admin/dashboard',
            Icons.dashboard,
          ),

          _buildNavItem(context, 'Payments', '/admin/payments', Icons.payment),
          _buildNavItem(
            context,
            'Donations',
            '/admin/donations',
            Icons.volunteer_activism,
          ),
          const Divider(),
          _buildNavItem(
            context,
            'Search User',
            '/admin/search-user',
            Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    String route,
    IconData icon,
  ) {
    final isSelected = selectedRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.blue : null),
      ),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          Get.offAllNamed(route);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
