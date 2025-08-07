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
  String _selectedStatus = 'all'; // 'all', 'pending', 'approved', 'rejected'

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

  void _showStatusUpdateDialog(Map<String, dynamic> donation) {
    String currentStatus = donation['status'] ?? 'pending';

    Get.dialog(
      AlertDialog(
        title: const Text('Update Donation Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Donor: ${donation['donorName']}'),
            Text('Amount: ৳${donation['amount']}'),
            const SizedBox(height: 16),
            const Text('Select new status:'),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Pending'),
                      value: 'pending',
                      groupValue: currentStatus,
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Approved'),
                      value: 'approved',
                      groupValue: currentStatus,
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Rejected'),
                      value: 'rejected',
                      groupValue: currentStatus,
                      onChanged: (value) {
                        setState(() {
                          currentStatus = value!;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await DonationService().updateDonationStatus(
                  donation['id'],
                  currentStatus,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Donation status updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update donation status: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Update'),
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
              _buildDetailRow('Amount', '৳${donation['amount']}'),
              _buildDetailRow('Type', donation['donationType'] ?? 'N/A'),
              _buildDetailRow(
                'Payment Method',
                donation['paymentMethod'] ?? 'N/A',
              ),
              _buildDetailRow('Purpose', donation['purpose'] ?? 'N/A'),
              _buildDetailRow('Notes', donation['notes'] ?? 'N/A'),
              _buildDetailRow('Date', date),
              _buildDetailRow(
                'Status',
                _getStatusText(donation['status'] ?? 'pending'),
              ),
              if (donation['receiptNumber'] != null)
                _buildDetailRow(
                  'Receipt #',
                  donation['receiptNumber'].toString(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawer: const AdminDrawer(selectedRoute: '/admin/donations'),
      body: Column(
        children: [
          // Statistics Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('donations')
                      .snapshots(),
              builder: (context, snapshot) {
                int totalRequests = 0;
                int pendingCount = 0;
                int approvedCount = 0;
                int rejectedCount = 0;
                double totalAmount = 0;

                if (snapshot.hasData) {
                  totalRequests = snapshot.data!.docs.length;

                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final amount = (data['amount'] ?? 0) as num;

                    switch (status) {
                      case 'pending':
                        pendingCount++;
                        break;
                      case 'approved':
                        approvedCount++;
                        totalAmount += amount;
                        break;
                      case 'rejected':
                        rejectedCount++;
                        break;
                    }
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total Requests',
                        totalRequests.toString(),
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Pending',
                        pendingCount.toString(),
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Approved',
                        approvedCount.toString(),
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Rejected',
                        rejectedCount.toString(),
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Total Amount',
                        '৳$totalAmount',
                        Colors.purple,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter by Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All')),
                    const DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    const DropdownMenuItem(
                      value: 'approved',
                      child: Text('Approved'),
                    ),
                    const DropdownMenuItem(
                      value: 'rejected',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _selectedStatus == 'all'
                      ? FirebaseFirestore.instance
                          .collection('donations')
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('donations')
                          .where('status', isEqualTo: _selectedStatus)
                          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final donations =
                    snapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return data;
                    }).toList() ??
                    [];
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1976D2),
                          child: Icon(
                            Icons.volunteer_activism,
                            color: Colors.white,
                          ),
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
                            Text(
                              'Method: ${donation['paymentMethod'] ?? 'N/A'}',
                            ),
                            Text('Date: $date'),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  donation['status'] ?? 'pending',
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(donation['status'] ?? 'pending'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editDonation(donation);
                            } else if (value == 'status') {
                              _showStatusUpdateDialog(donation);
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
                                  value: 'status',
                                  child: Row(
                                    children: [
                                      Icon(Icons.update, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text(
                                        'Update Status',
                                        style: TextStyle(color: Colors.blue),
                                      ),
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
          ),
        ],
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
