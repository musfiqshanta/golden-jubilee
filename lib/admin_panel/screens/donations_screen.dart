import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_drawer.dart';
import '../services/donation_service.dart';
import 'package:get/get.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  void _editDonation(Map<String, dynamic> donation) {
    Get.toNamed('/admin/edit-donation', arguments: donation);
  }

  void _showDeleteConfirmation(Map<String, dynamic> donation) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Donation'),
        content: Text(
          'Are you sure you want to delete the donation from ${donation['donorName']}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await DonationService().deleteDonation(donation['id']);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Donation deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete donation: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDonationDetails(Map<String, dynamic> donation) {
    final date =
        donation['date'] != null
            ? DateTime.parse(donation['date']).toString().split(' ')[0]
            : 'N/A';

    Get.dialog(
      AlertDialog(
        title: Text('Donation Details - ${donation['donorName']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Donor Name', donation['donorName'] ?? 'N/A'),
              _buildDetailRow('Phone', donation['donorPhone'] ?? 'N/A'),
              _buildDetailRow('Email', donation['donorEmail'] ?? 'N/A'),
              _buildDetailRow('Address', donation['donorAddress'] ?? 'N/A'),
              _buildDetailRow(
                'Amount',
                '৳${donation['amount']?.toString() ?? 'N/A'}',
              ),
              _buildDetailRow(
                'Donation Type',
                donation['donationType'] ?? 'N/A',
              ),
              _buildDetailRow(
                'Payment Method',
                donation['paymentMethod'] ?? 'N/A',
              ),
              _buildDetailRow('Purpose', donation['purpose'] ?? 'N/A'),
              _buildDetailRow('Notes', donation['notes'] ?? 'N/A'),
              _buildDetailRow('Date', date),
              _buildDetailRow('Status', donation['status'] ?? 'N/A'),
              _buildDetailRow(
                'Anonymous',
                donation['isAnonymous'] == true ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      drawer: const AdminDrawer(selectedRoute: '/admin/donations'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final donations = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList() ?? [];
          if (donations.isEmpty) {
            return const Center(child: Text('No donations found.'));
          }
          return ListView.separated(
            itemCount: donations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final donation = donations[index];
              final amount = donation['amount']?.toString() ?? 'N/A';
              final date =
                  donation['date'] != null
                      ? DateTime.parse(
                        donation['date'],
                      ).toString().split(' ')[0]
                      : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1976D2),
                    child: Icon(Icons.volunteer_activism, color: Colors.white),
                  ),
                  title: Text(
                    donation['donorName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ৳$amount'),
                      Text('Type: ${donation['donationType'] ?? 'N/A'}'),
                      Text('Method: ${donation['paymentMethod'] ?? 'N/A'}'),
                      Text('Date: $date'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editDonation(donation);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(donation);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                  onTap: () {
                    _showDonationDetails(donation);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/admin/add-donation');
        },
        tooltip: 'Add Donation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
