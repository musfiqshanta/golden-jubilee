import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details_screen.dart';

class ManualApprovalUsersScreen extends StatefulWidget {
  const ManualApprovalUsersScreen({super.key});

  @override
  State<ManualApprovalUsersScreen> createState() =>
      _ManualApprovalUsersScreenState();
}

class _ManualApprovalUsersScreenState extends State<ManualApprovalUsersScreen> {
  List<Map<String, dynamic>> _manualApprovalUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadManualApprovalUsers();
  }

  Future<void> _loadManualApprovalUsers() async {
    try {
      print('📝 Loading manual approval users...');

      final snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      List<Map<String, dynamic>> manualUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final paymentStatus = data['paymentStatus'] ?? '';

        if (paymentStatus == 'approved') {
          // Check if it's NOT an online payment (so it's manual approval)
          bool isOnlinePayment = _isOnlinePayment(data);

          if (!isOnlinePayment) {
            data['id'] = doc.id;
            data['documentPath'] = doc.reference.path;
            manualUsers.add(data);
          }
        }
      }

      setState(() {
        _manualApprovalUsers = manualUsers;
        _isLoading = false;
      });

      print('✅ Loaded ${manualUsers.length} manual approval users');
    } catch (e) {
      print('Error loading manual approval users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _manualApprovalUsers;

    return _manualApprovalUsers.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final mobile = (user['mobile'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          mobile.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Approval Users'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _loadManualApprovalUsers();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email, or mobile...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.person_add, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Manual Approval Users: ${_manualApprovalUsers.length}',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Filtered: ${_filteredUsers.length}',
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_disabled,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No manual approval users found'
                                : 'No users match your search',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? 'No email';
    final mobile = user['mobile'] ?? 'No mobile';
    final totalPayable = user['totalPayable'] ?? 0;
    final paymentDate = user['paymentDate'] ?? user['payment_date'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.person_add, color: Colors.orange.shade700),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Mobile: $mobile'),
            Text('Amount: ৳$totalPayable'),
            if (paymentDate.isNotEmpty)
              Text('Payment Date: ${_formatDate(paymentDate)}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => UserDetailsScreen(
                    user: user,
                    userType: 'Manual Approval',
                  ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
