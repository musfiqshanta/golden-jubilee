import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_drawer.dart';

class EditDonationScreen extends StatefulWidget {
  const EditDonationScreen({super.key});

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorEmailController = TextEditingController();
  final _donorAddressController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _notesController = TextEditingController();

  String _donationType = 'Cash';
  String _paymentMethod = 'Cash';
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _donationId;

  @override
  void initState() {
    super.initState();
    _loadDonationData();
  }

  void _loadDonationData() {
    final donation = Get.arguments as Map<String, dynamic>;
    _donationId = donation['id'];

    _donorNameController.text = donation['donorName'] ?? '';
    _donorPhoneController.text = donation['donorPhone'] ?? '';
    _donorEmailController.text = donation['donorEmail'] ?? '';
    _donorAddressController.text = donation['donorAddress'] ?? '';
    _amountController.text = donation['amount']?.toString() ?? '';
    _purposeController.text = donation['purpose'] ?? '';
    _notesController.text = donation['notes'] ?? '';

    setState(() {
      _donationType = donation['donationType'] ?? 'Cash';
      _paymentMethod = donation['paymentMethod'] ?? 'Cash';
      _isAnonymous = donation['isAnonymous'] == true;
    });
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _donorEmailController.dispose();
    _donorAddressController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateDonation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_donationId == null) {
      Get.snackbar('Error', 'Donation ID not found');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final donationData = {
        'donorName':
            _isAnonymous ? 'Anonymous Donor' : _donorNameController.text.trim(),
        'donorPhone': _donorPhoneController.text.trim(),
        'donorEmail': _donorEmailController.text.trim(),
        'donorAddress': _donorAddressController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'donationType': _donationType,
        'paymentMethod': _paymentMethod,
        'purpose': _purposeController.text.trim(),
        'notes': _notesController.text.trim(),
        'isAnonymous': _isAnonymous,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedBy': 'admin', // You can replace this with actual admin ID
      };

      await FirebaseFirestore.instance
          .collection('donations')
          .doc(_donationId)
          .update(donationData);

      setState(() => _isLoading = false);

      Get.snackbar(
        'Success',
        'Donation updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(); // Go back to donations list
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to update donation: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/donations'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Donor Information Section
              _buildSectionHeader('Donor Information'),

              // Anonymous Donation Toggle
              CheckboxListTile(
                title: const Text('Anonymous Donation'),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value!),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),

              if (!_isAnonymous) ...[
                TextFormField(
                  controller: _donorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Donor Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty == true
                              ? 'Donor name is required'
                              : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _donorPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _donorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _donorAddressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Donation Details Section
              _buildSectionHeader('Donation Details'),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (৳) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Amount is required';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _donationType,
                      decoration: const InputDecoration(
                        labelText: 'Donation Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'Mobile Banking',
                          child: Text('Mobile Banking'),
                        ),
                        DropdownMenuItem(value: 'Check', child: Text('Check')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged:
                          (value) => setState(() => _donationType = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'bKash', child: Text('bKash')),
                        DropdownMenuItem(value: 'Nagad', child: Text('Nagad')),
                        DropdownMenuItem(
                          value: 'Rocket',
                          child: Text('Rocket'),
                        ),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(value: 'Check', child: Text('Check')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged:
                          (value) => setState(() => _paymentMethod = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Donation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Additional Information Section
              _buildSectionHeader('Additional Information'),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes/Remarks',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Donation Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Updated Donation Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Donor: ${_isAnonymous ? 'Anonymous' : (_donorNameController.text.isEmpty ? 'Not specified' : _donorNameController.text)}',
                    ),
                    Text(
                      'Amount: ৳${_amountController.text.isEmpty ? '0' : _amountController.text}',
                    ),
                    Text('Type: $_donationType'),
                    Text('Method: $_paymentMethod'),
                    Text(
                      'Last Updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Update Donation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }
}
