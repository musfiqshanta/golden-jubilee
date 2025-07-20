import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_drawer.dart';
import '../views/admin_registered_page.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _searchResult;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a phone number';
        _searchResult = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResult = null;
    });

    try {
      print('Searching for phone: $phone');

      // Search across all batches using collectionGroup query
      final registrationsSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .where('mobile', isEqualTo: phone)
              .get();

      print('Found ${registrationsSnapshot.docs.length} registrations');

      if (registrationsSnapshot.docs.isNotEmpty) {
        final registrationDoc = registrationsSnapshot.docs.first;
        final userData = registrationDoc.data();

        // Get the batch ID from the document path
        final batchId = registrationDoc.reference.parent.parent?.id;
        userData['batch'] = batchId;
        userData['id'] = registrationDoc.id;

        print('Found user: ${userData['name']} in batch: $batchId');

        setState(() {
          _searchResult = userData;
          _isLoading = false;
        });
      } else {
        // If not found, try alternative search methods
        print('No exact match found, trying alternative search...');

        // Search by partial phone number match
        final allRegistrations =
            await FirebaseFirestore.instance
                .collectionGroup('registrations')
                .get();

        for (var doc in allRegistrations.docs) {
          final data = doc.data();
          final userPhone = data['mobile']?.toString() ?? '';

          if (userPhone.contains(phone) || phone.contains(userPhone)) {
            final batchId = doc.reference.parent.parent?.id;
            data['batch'] = batchId;
            data['id'] = doc.id;

            print(
              'Found partial match: ${data['name']} with phone: $userPhone',
            );

            setState(() {
              _searchResult = data;
              _isLoading = false;
            });
            return;
          }
        }

        // If still not found
        setState(() {
          _errorMessage = 'No user found with this phone number';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _errorMessage = 'Error searching for user: $e';
        _isLoading = false;
      });
    }
  }

  void _viewUserDetails() {
    if (_searchResult != null) {
      showDialog(
        context: context,
        builder: (context) => AdminUserDetailsDialog(userData: _searchResult!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/search-user'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search User by Phone Number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            onFieldSubmitted: (_) => _searchUser(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _searchUser,
                          icon:
                              _isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.search),
                          label: Text(_isLoading ? 'Searching...' : 'Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Search Results
            if (_searchResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'User Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _viewUserDetails,
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Name', _searchResult!['name'] ?? 'N/A'),
                      _buildInfoRow(
                        'Mobile',
                        _searchResult!['mobile'] ?? 'N/A',
                      ),
                      _buildInfoRow('Email', _searchResult!['email'] ?? 'N/A'),
                      _buildInfoRow('Batch', _searchResult!['batch'] ?? 'N/A'),
                      _buildInfoRow(
                        'Student Type',
                        _searchResult!['isRunningStudent'] == true
                            ? 'Running Student'
                            : 'Former Student',
                      ),
                      _buildInfoRow(
                        'Payment Status',
                        _searchResult!['paymentStatus']
                                ?.toString()
                                .toUpperCase() ??
                            'PENDING',
                      ),
                      _buildInfoRow(
                        'Total Payable',
                        '৳${_searchResult!['totalPayable']?.toString() ?? 'N/A'}',
                      ),
                      _buildInfoRow(
                        'Registration Date',
                        _formatDate(_searchResult!['registrationTimestamp']),
                      ),
                      _buildInfoRow(
                        'Form Serial',
                        _searchResult!['formSerialNumber']?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updatePaymentStatus('approved'),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text('Approve Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updatePaymentStatus('rejected'),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text('Reject Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Empty State
            if (!_isLoading && _searchResult == null && _errorMessage == null)
              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for a user by phone number',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Show recent registrations for reference
                    Expanded(child: _buildRecentRegistrations()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> _updatePaymentStatus(String status) async {
    if (_searchResult == null) return;

    try {
      final batch = _searchResult!['batch']?.toString();
      final phone = _searchResult!['mobile']?.toString();

      if (batch != null && phone != null) {
        await FirebaseFirestore.instance
            .collection('batches')
            .doc(batch)
            .collection('registrations')
            .doc(phone)
            .update({'paymentStatus': status});

        setState(() {
          _searchResult!['paymentStatus'] = status;
        });

        Get.snackbar(
          'Success',
          'Payment status updated to ${status.toUpperCase()}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update payment status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildRecentRegistrations() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collectionGroup('registrations')
              .limit(10)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final registrations = snapshot.data?.docs ?? [];

        if (registrations.isEmpty) {
          return const Center(child: Text('No registrations found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Registrations (for reference)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: registrations.length,
                itemBuilder: (context, index) {
                  final data =
                      registrations[index].data() as Map<String, dynamic>;
                  final batchId =
                      registrations[index].reference.parent.parent?.id ??
                      'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(data['name'] ?? 'Unknown'),
                      subtitle: Text(
                        '${data['mobile'] ?? 'No phone'} • Batch: $batchId',
                      ),
                      trailing: Chip(
                        label: Text(
                          data['paymentStatus']?.toString().toUpperCase() ??
                              'PENDING',
                        ),
                        backgroundColor:
                            data['paymentStatus'] == 'approved'
                                ? Colors.green
                                : data['paymentStatus'] == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        data['batch'] = batchId;
                        data['id'] = registrations[index].id;
                        showDialog(
                          context: context,
                          builder:
                              (context) =>
                                  AdminUserDetailsDialog(userData: data),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
