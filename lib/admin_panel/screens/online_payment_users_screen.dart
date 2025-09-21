import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details_screen.dart';

class OnlinePaymentUsersScreen extends StatefulWidget {
  const OnlinePaymentUsersScreen({super.key});

  @override
  State<OnlinePaymentUsersScreen> createState() =>
      _OnlinePaymentUsersScreenState();
}

class _OnlinePaymentUsersScreenState extends State<OnlinePaymentUsersScreen> {
  List<Map<String, dynamic>> _onlinePaymentUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOnlinePaymentUsers();
  }

  Future<void> _loadOnlinePaymentUsers() async {
    try {
      print('💳 Loading online payment users...');

      final snapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      List<Map<String, dynamic>> onlineUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final paymentStatus = data['paymentStatus'] ?? '';

        if (paymentStatus == 'approved') {
          // Check if it's an online payment using the same logic as dashboard
          bool isOnlinePayment = _isOnlinePayment(data);

          if (isOnlinePayment) {
            data['id'] = doc.id;
            data['documentPath'] = doc.reference.path;
            onlineUsers.add(data);
          }
        }
      }

      setState(() {
        _onlinePaymentUsers = onlineUsers;
        _isLoading = false;
      });

      print('✅ Loaded ${onlineUsers.length} online payment users');
    } catch (e) {
      print('Error loading online payment users: $e');
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
    if (_searchQuery.isEmpty) return _onlinePaymentUsers;

    return _onlinePaymentUsers.where((user) {
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
        title: const Text('Online Payment Users'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _loadOnlinePaymentUsers();
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
            color: Colors.green.shade50,
            child: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Online Payment Users: ${_onlinePaymentUsers.length}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Filtered: ${_filteredUsers.length}',
                    style: TextStyle(
                      color: Colors.green.shade600,
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
                            Icons.credit_card_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No online payment users found'
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
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.credit_card, color: Colors.green.shade700),
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
                  (context) =>
                      UserDetailsScreen(user: user, userType: 'Online Payment'),
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
