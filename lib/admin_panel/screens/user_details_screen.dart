import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final String userType;

  const UserDetailsScreen({
    super.key,
    required this.user,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? 'No email';
    final mobile = user['mobile'] ?? 'No mobile';
    final totalPayable = user['totalPayable'] ?? 0;
    final paymentStatus = user['paymentStatus'] ?? 'Unknown';
    final registrationDate =
        user['registrationDate'] ?? user['registration_date'] ?? '';
    final paymentDate = user['paymentDate'] ?? user['payment_date'] ?? '';
    final spouseCount = user['spouseCount'] ?? 0;
    final childCount = user['childCount'] ?? 0;
    final batch = user['batch'] ?? 'Not specified';
    final address = user['address'] ?? 'Not provided';
    final occupation = user['occupation'] ?? 'Not provided';

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details - $name'),
        backgroundColor:
            userType == 'Online Payment'
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Type Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    userType == 'Online Payment'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      userType == 'Online Payment'
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    userType == 'Online Payment'
                        ? Icons.credit_card
                        : Icons.person_add,
                    color:
                        userType == 'Online Payment'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userType,
                    style: TextStyle(
                      color:
                          userType == 'Online Payment'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Information
            _buildSection('Personal Information', Icons.person, [
              _buildInfoRow('Name', name),
              _buildInfoRow('Email', email),
              _buildInfoRow('Mobile', mobile),
              _buildInfoRow('Address', address),
              _buildInfoRow('Occupation', occupation),
            ]),

            const SizedBox(height: 20),

            // Registration Information
            _buildSection('Registration Information', Icons.app_registration, [
              _buildInfoRow('Batch', batch),
              _buildInfoRow('Registration Date', _formatDate(registrationDate)),
              _buildInfoRow('Spouse Count', spouseCount.toString()),
              _buildInfoRow('Child Count', childCount.toString()),
              _buildInfoRow(
                'Total Guests',
                (spouseCount + childCount).toString(),
              ),
            ]),

            const SizedBox(height: 20),

            // Payment Information
            _buildSection('Payment Information', Icons.payment, [
              _buildInfoRow(
                'Payment Status',
                paymentStatus,
                valueColor: _getPaymentStatusColor(paymentStatus),
              ),
              _buildInfoRow(
                'Total Payable',
                '৳$totalPayable',
                valueColor: Colors.green.shade700,
              ),
              _buildInfoRow('Payment Date', _formatDate(paymentDate)),
            ]),

            const SizedBox(height: 20),

            // Payment Method Details (if available)
            if (userType == 'Online Payment') ...[
              _buildSection(
                'Online Payment Details',
                Icons.credit_card,
                _buildOnlinePaymentDetails(),
              ),
              const SizedBox(height: 20),
            ],

            // Additional Information
            _buildSection('Additional Information', Icons.info, [
              _buildInfoRow('Document ID', user['id'] ?? 'N/A'),
              _buildInfoRow('Document Path', user['documentPath'] ?? 'N/A'),
            ]),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement edit functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement print functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Print functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
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
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOnlinePaymentDetails() {
    // First check if paymentData exists
    final paymentData = user['paymentData'];
    if (paymentData != null && paymentData is Map<String, dynamic>) {
      // Extract details from paymentData
      final paymentMethod =
          paymentData['payment_method'] ??
          paymentData['paymentMethod'] ??
          'N/A';
      final transactionId = paymentData['tran_id'] ?? 'N/A';
      final valId = paymentData['val_id'] ?? 'N/A';
      final status = paymentData['status'] ?? 'N/A';
      final storeId = paymentData['store_id'] ?? 'N/A';
      final cardBrand = paymentData['card_brand'] ?? 'N/A';
      final cardIssuer = paymentData['card_issuer'] ?? 'N/A';
      final cardType = paymentData['card_type'] ?? 'N/A';
      final amount = paymentData['amount'] ?? 'N/A';
      final currency = paymentData['currency'] ?? 'N/A';
      final tranDate = paymentData['tran_date'] ?? 'N/A';
      final bankTranId = paymentData['bank_tran_id'] ?? 'N/A';

      return [
        _buildInfoRow('Payment Method', paymentMethod),
        _buildInfoRow('Transaction ID', transactionId),
        _buildInfoRow('Validation ID', valId),
        _buildInfoRow('Status', status),
        _buildInfoRow('Store ID', storeId),
        _buildInfoRow('Card Brand', cardBrand),
        _buildInfoRow('Card Issuer', cardIssuer),
        _buildInfoRow('Card Type', cardType),
        _buildInfoRow('Amount', '৳$amount'),
        _buildInfoRow('Currency', currency),
        _buildInfoRow('Transaction Date', tranDate),
        _buildInfoRow('Bank Transaction ID', bankTranId),
      ];
    }

    // Fallback to original fields for backward compatibility
    final paymentMethod =
        user['paymentMethod'] ?? user['payment_method'] ?? 'N/A';
    final transactionId =
        user['transactionId'] ??
        user['transaction_id'] ??
        user['sslcommerzTransactionId'] ??
        'N/A';
    final paymentId = user['paymentId'] ?? user['payment_id'] ?? 'N/A';
    final sslcommerzStatus = user['sslcommerzStatus'] ?? 'N/A';
    final sslcommerzTranId = user['sslcommerzTranId'] ?? 'N/A';
    final sslcommerzValId = user['sslcommerzValId'] ?? 'N/A';
    final gateway = user['gateway'] ?? 'N/A';

    return [
      _buildInfoRow('Payment Method', paymentMethod),
      _buildInfoRow('Transaction ID', transactionId),
      _buildInfoRow('Payment ID', paymentId),
      _buildInfoRow('SSLCommerz Status', sslcommerzStatus),
      _buildInfoRow('SSLCommerz Tran ID', sslcommerzTranId),
      _buildInfoRow('SSLCommerz Val ID', sslcommerzValId),
      _buildInfoRow('Gateway', gateway),
    ];
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not provided';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
