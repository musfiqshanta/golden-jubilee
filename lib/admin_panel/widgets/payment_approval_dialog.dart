import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentApprovalDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback? onApproved;

  const PaymentApprovalDialog({
    super.key,
    required this.userData,
    this.onApproved,
  });

  @override
  State<PaymentApprovalDialog> createState() => _PaymentApprovalDialogState();
}

class _PaymentApprovalDialogState extends State<PaymentApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  String _approvalType = 'manual'; // 'manual' or 'online'
  bool _isLoading = false;

  // Manual approval fields
  final _referenceNameController = TextEditingController();

  // Online approval fields
  final _referenceNumberController = TextEditingController();
  final _walletNameController = TextEditingController();
  final _referenceNameOnlineController = TextEditingController();

  @override
  void dispose() {
    _referenceNameController.dispose();
    _referenceNumberController.dispose();
    _walletNameController.dispose();
    _referenceNameOnlineController.dispose();
    super.dispose();
  }

  Future<void> _approvePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final userData = widget.userData;
      final batch = userData['batch'] ?? '';
      final phone = userData['mobile'] ?? '';

      if (batch.isEmpty || phone.isEmpty) {
        throw Exception('Invalid user data');
      }

      // Prepare payment data based on approval type
      Map<String, dynamic> paymentData = {
        'amount': userData['totalPayable']?.toString() ?? '0',
        'approvedAt': now.toIso8601String(),
        'approvedBy': 'admin',
      };

      if (_approvalType == 'manual') {
        paymentData['reference_name'] = _referenceNameController.text.trim();
        paymentData['payment_method'] = 'manual';
      } else {
        paymentData['reference_number'] =
            _referenceNumberController.text.trim();
        paymentData['wallet_name'] = _walletNameController.text.trim();
        paymentData['reference_name'] =
            _referenceNameOnlineController.text.trim();
        paymentData['payment_method'] = 'online';
      }

      // Update the registration document
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(batch)
          .collection('registrations')
          .doc(phone)
          .update({
            'paymentStatus': 'approved',
            'paymentMethod': _approvalType,
            'paymentData': paymentData,
            'paymentDate': now.toIso8601String(),
            'payment_date': now.toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment approved successfully as $_approvalType payment',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Close dialog and call callback
        Navigator.of(context).pop();
        widget.onApproved?.call();
      }
    } catch (e) {
      print('Error approving payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving payment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixed)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Color(0xFF1976D2), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payment Approval',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: ${widget.userData['name'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Phone: ${widget.userData['mobile'] ?? 'N/A'}',
                            ),
                            Text(
                              'Amount: ৳${widget.userData['totalPayable'] ?? '0'}',
                            ),
                            if (widget.userData['formSerialNumber'] != null)
                              Text(
                                'Form #: ${widget.userData['formSerialNumber']}',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Approval Type Selector
                      Text(
                        'Approval Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Manual'),
                              value: 'manual',
                              groupValue: _approvalType,
                              onChanged: (value) {
                                setState(() {
                                  _approvalType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Online'),
                              value: 'online',
                              groupValue: _approvalType,
                              onChanged: (value) {
                                setState(() {
                                  _approvalType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Manual Approval Fields
                      if (_approvalType == 'manual') ...[
                        TextFormField(
                          controller: _referenceNameController,
                          decoration: const InputDecoration(
                            labelText: 'Reference Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.receipt_long),
                            hintText: 'Enter reference name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter reference name';
                            }
                            return null;
                          },
                        ),
                      ],

                      // Online Approval Fields
                      if (_approvalType == 'online') ...[
                        TextFormField(
                          controller: _referenceNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Reference Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                            hintText: 'Enter reference number',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter reference number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _walletNameController,
                          decoration: const InputDecoration(
                            labelText: 'Wallet Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance_wallet),
                            hintText: 'e.g., BKASH, Rocket, Nagad',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter wallet name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _referenceNameOnlineController,
                          decoration: const InputDecoration(
                            labelText: 'Reference Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.receipt_long),
                            hintText: 'Enter reference name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter reference name';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed action buttons at bottom
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _approvePayment,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.check),
                      label: Text(
                        _isLoading ? 'Approving...' : 'Approve Payment',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
