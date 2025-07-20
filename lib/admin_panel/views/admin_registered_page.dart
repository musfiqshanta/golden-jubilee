import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';

class AdminRegisteredPage extends StatelessWidget {
  const AdminRegisteredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Batch Registrations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup('registrations')
                .snapshots(),
        builder: (context, regSnapshot) {
          if (regSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!regSnapshot.hasData || regSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No registrations found.'));
          }
          // Group registrations by batchId (parent.id)
          final Map<String, List<QueryDocumentSnapshot>> batchMap = {};
          for (var doc in regSnapshot.data!.docs) {
            final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
            batchMap.putIfAbsent(batchId, () => []).add(doc);
          }
          final batchIds = batchMap.keys.toList();

          // Separate running class batches (Bangla names ending with 'শ্রেণি') and year batches (numeric)
          final runningClassBatches =
              batchIds.where((id) => id.endsWith('শ্রেণি')).toList();
          final yearBatches =
              batchIds.where((id) => int.tryParse(id) != null).toList();
          yearBatches.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
          final otherBatches =
              batchIds
                  .where(
                    (id) => !id.endsWith('শ্রেণি') && int.tryParse(id) == null,
                  )
                  .toList();

          // Compose final batch list: Running Batch (virtual), then years, then others
          final filteredOtherBatches =
              otherBatches.where((id) => id != 'running').toList();
          final displayBatchIds = [
            '__running_batch__',
            ...yearBatches,
            ...filteredOtherBatches,
          ];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 2;
                if (width > 1200) {
                  crossAxisCount = 6;
                } else if (width > 900) {
                  crossAxisCount = 4;
                } else if (width > 600) {
                  crossAxisCount = 3;
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2,
                  ),
                  itemCount: displayBatchIds.length,
                  itemBuilder: (context, index) {
                    final batchId = displayBatchIds[index];
                    if (batchId == '__running_batch__') {
                      int totalRunning = 0;
                      for (var classId in runningClassBatches) {
                        totalRunning += batchMap[classId]?.length ?? 0;
                      }
                      return _adminBatchCard(
                        context,
                        'Running Students',
                        totalRunning,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => AdminRunningBatchPage(
                                    runningClassBatches: runningClassBatches,
                                    batchMap: batchMap,
                                  ),
                            ),
                          );
                        },
                        color: Colors.blueAccent,
                      );
                    }
                    final regCount = batchMap[batchId]?.length ?? 0;
                    return _adminBatchCard(
                      context,
                      'Batch $batchId',
                      regCount,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => AdminBatchDetailsPage(batchId: batchId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _adminBatchCard(
    BuildContext context,
    String title,
    int count,
    VoidCallback onTap, {
    Color? color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color ?? Color(0xFF1976D2), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminBatchDetailsPage extends StatelessWidget {
  final String batchId;
  const AdminBatchDetailsPage({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Batch $batchId Registrations',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('batches')
                .doc(batchId)
                .collection('registrations')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No registrations found.'));
          }
          final regs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: regs.length,
            itemBuilder: (context, index) {
              final reg = regs[index];
              final data = reg.data() as Map<String, dynamic>;
              final photoUrl = data['photoUrl'] as String?;
              final name = data['name'] ?? '';
              final mobile = data['mobile'] ?? '';
              final paymentStatus =
                  data['paymentStatus']?.toString() ?? 'pending';
              Color cardColor;
              switch (paymentStatus) {
                case 'approved':
                  cardColor = Colors.green;
                  break;
                case 'rejected':
                  cardColor = Colors.red;
                  break;
                case 'pending':
                default:
                  cardColor = Colors.orange;
                  break;
              }
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: 20,
                    child: ClipOval(
                      child:
                          photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                photoUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  );
                                },
                              )
                              : const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Mobile: ${_obscureMobile(mobile)}',
                    style: const TextStyle(letterSpacing: 1.2),
                  ),
                  trailing: PaymentStatusDropdown(userData: data),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AdminUserDetailsDialog(userData: data),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminUserDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AdminUserDetailsDialog({super.key, required this.userData});

  @override
  State<AdminUserDetailsDialog> createState() => _AdminUserDetailsDialogState();
}

class _AdminUserDetailsDialogState extends State<AdminUserDetailsDialog> {
  Map<String, dynamic>? payment;
  bool isLoading = true;
  bool isEditing = false;
  late Map<String, dynamic> editedUser;

  @override
  void initState() {
    super.initState();
    editedUser = Map<String, dynamic>.from(widget.userData);
    _fetchPayment();
  }

  Future<void> _fetchPayment() async {
    final allPayments = await PaymentService().fetchAllPayments();
    // Try to match by phone or userId
    final userPhone = widget.userData['mobile']?.toString();
    final userId = widget.userData['uid']?.toString();
    final match = allPayments.firstWhere(
      (p) =>
          (p['userId']?.toString() == userId) ||
          (p['phone']?.toString() == userPhone) ||
          (p['payer']?.toString() == userPhone),
      orElse: () => {},
    );
    setState(() {
      payment = match.isNotEmpty ? match : null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = isEditing ? editedUser : widget.userData;
    final photoUrl = userData['photoUrl'] as String?;
    final spouseCount = userData['spouseCount'] ?? 0;
    final childCount = userData['childCount'] ?? 0;
    final totalGuests = spouseCount + childCount;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(isEditing ? Icons.save : Icons.edit),
                      tooltip: isEditing ? 'Save' : 'Edit',
                      onPressed: () async {
                        if (isEditing) {
                          final oldBatch = widget.userData['batch']?.toString();
                          final oldPhone =
                              widget.userData['mobile']?.toString();
                          final newBatch = editedUser['batch']?.toString();
                          final newPhone = editedUser['mobile']?.toString();
                          if (newBatch != null &&
                              newPhone != null &&
                              oldBatch != null &&
                              oldPhone != null) {
                            try {
                              // Ensure totalPayable is recalculated before saving
                              _updateTotalPayable();

                              // Debug print to see what's being saved
                              print('Saving to Firebase:');
                              print(
                                '  totalPayable: ${editedUser['totalPayable']}',
                              );
                              print(
                                '  isRunningStudent: ${editedUser['isRunningStudent']}',
                              );
                              print(
                                '  spouseCount: ${editedUser['spouseCount']}',
                              );
                              print(
                                '  childCount: ${editedUser['childCount']}',
                              );

                              if (oldPhone != newPhone) {
                                // Create new doc with new phone as ID
                                await FirebaseFirestore.instance
                                    .collection('batches')
                                    .doc(newBatch)
                                    .collection('registrations')
                                    .doc(newPhone)
                                    .set(editedUser);
                                // Delete old doc
                                await FirebaseFirestore.instance
                                    .collection('batches')
                                    .doc(oldBatch)
                                    .collection('registrations')
                                    .doc(oldPhone)
                                    .delete();
                              } else {
                                // Just update existing doc
                                await FirebaseFirestore.instance
                                    .collection('batches')
                                    .doc(newBatch)
                                    .collection('registrations')
                                    .doc(newPhone)
                                    .update(editedUser);
                              }
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'User details updated successfully!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          }
                          setState(() => isEditing = false);
                        } else {
                          setState(() => isEditing = true);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child:
                  photoUrl != null && photoUrl.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                      : Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
            ),
            const SizedBox(height: 15),
            _infoRow(
              'Name',
              userData['name'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['name'] = v),
            ),
            _infoRow(
              'Father Name',
              userData['fatherName'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['fatherName'] = v),
            ),
            _infoRow(
              'Mother Name',
              userData['motherName'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['motherName'] = v),
            ),
            _infoRow('Mobile', userData['mobile'] ?? '', editable: false),
            _infoRow(
              'Email',
              userData['email'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['email'] = v),
            ),
            _infoRow(
              'Gender',
              userData['gender'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['gender'] = v),
            ),
            _infoRow(
              'Date of Birth',
              _formatDate(userData['dateOfBirth']),
              editable: false,
            ),
            _infoRow(
              'Occupation',
              userData['occupation'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['occupation'] = v),
            ),
            _infoRow(
              'Designation',
              userData['designation'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['designation'] = v),
            ),
            _infoRow(
              'Nationality',
              userData['nationality'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['nationality'] = v),
            ),
            _infoRow(
              'Religion',
              userData['religion'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['religion'] = v),
            ),
            _infoRow(
              'Permanent Address',
              userData['permanentAddress'] ?? '',
              editable: isEditing,
              onChanged:
                  (v) => setState(() => editedUser['permanentAddress'] = v),
            ),
            _infoRow(
              'Present Address',
              userData['presentAddress'] ?? '',
              editable: isEditing,
              onChanged:
                  (v) => setState(() => editedUser['presentAddress'] = v),
            ),
            _infoRow(
              'Tshirt Size',
              userData['tshirtSize'] ?? '',
              editable: isEditing,
              onChanged: (v) => setState(() => editedUser['tshirtSize'] = v),
            ),
            _infoRow('Batch', userData['batch'] ?? '', editable: false),
            if (isEditing) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        'Student Type:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        value: editedUser['isRunningStudent'] ?? false,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Running Student'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Former Student'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            editedUser['isRunningStudent'] = value ?? false;
                            // Recalculate total payable when student type changes
                            _updateTotalPayable();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _infoRow(
                'Student Type',
                userData['isRunningStudent'] == true
                    ? 'Running Student'
                    : 'Former Student',
                editable: false,
              ),
            ],
            if (editedUser['isRunningStudent'] == true) ...[
              _infoRow(
                'Current Class',
                userData['finalClass'] ?? '',
                editable: isEditing,
                onChanged: (v) => setState(() => editedUser['finalClass'] = v),
              ),
              _infoRow(
                'Year',
                userData['year'] ?? '',
                editable: isEditing,
                onChanged: (v) => setState(() => editedUser['year'] = v),
              ),
            ] else ...[
              _infoRow(
                'SSC Passing Year',
                userData['sscPassingYear'] ?? '',
                editable: isEditing,
                onChanged:
                    (v) => setState(() => editedUser['sscPassingYear'] = v),
              ),
            ],
            _infoRow(
              'Registration Date',
              _formatDate(userData['registrationTimestamp']),
              editable: false,
            ),
            const Divider(),
            const Text(
              'Guest Info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            _infoRow(
              'Spouse',
              spouseCount.toString(),
              editable: isEditing,
              onChanged: (v) {
                setState(() {
                  editedUser['spouseCount'] = int.tryParse(v) ?? 0;
                  // Recalculate total payable when guest count changes
                  _updateTotalPayable();
                });
              },
            ),
            _infoRow(
              'Child',
              childCount.toString(),
              editable: isEditing,
              onChanged: (v) {
                setState(() {
                  editedUser['childCount'] = int.tryParse(v) ?? 0;
                  // Recalculate total payable when guest count changes
                  _updateTotalPayable();
                });
              },
            ),
            _infoRow('Total Guest', totalGuests.toString(), editable: false),
            const Divider(),
            const Text(
              'Payment Info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            _infoRow(
              'Status',
              userData['paymentStatus']?.toString() ?? 'pending',
              editable: false,
            ),
            _infoRow(
              'Total Payable',
              '৳${_calculateTotalPayable(editedUser).toString()}',
              editable: false,
            ),
            if (isEditing) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        'Breakdown:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Fee: ৳${editedUser['isRunningStudent'] == true ? '700' : '1200'} (${editedUser['isRunningStudent'] == true ? 'Running' : 'Former'} Student)',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Guest Fee: ৳${((editedUser['spouseCount'] ?? 0) + (editedUser['childCount'] ?? 0)) * 500} (${(editedUser['spouseCount'] ?? 0) + (editedUser['childCount'] ?? 0)} guests × ৳500)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              )
            else if (payment != null) ...[
              _infoRow(
                'Amount',
                payment!['amount']?.toString() ?? 'N/A',
                editable: false,
              ),
              _infoRow(
                'Status',
                payment!['status']?.toString() ?? 'pending',
                editable: false,
              ),
              Row(
                children: [
                  if (payment!['status'] == 'pending') ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        await PaymentService().updatePaymentStatus(
                          payment!['id'],
                          'approved',
                        );
                        setState(() {
                          payment!['status'] = 'approved';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await PaymentService().updatePaymentStatus(
                          payment!['id'],
                          'rejected',
                        );
                        setState(() {
                          payment!['status'] = 'rejected';
                        });
                      },
                    ),
                  ],
                  if (payment!['status'] != 'pending') ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Set Pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () async {
                        await PaymentService().updatePaymentStatus(
                          payment!['id'],
                          'pending',
                        );
                        setState(() {
                          payment!['status'] = 'pending';
                        });
                      },
                    ),
                  ],
                ],
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No payment found.'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool editable = false,
    ValueChanged<String>? onChanged,
  }) {
    if (editable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: value,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  int _calculateTotalPayable(Map<String, dynamic> userData) {
    // Use stored totalPayable if available, otherwise calculate
    if (userData['totalPayable'] != null) {
      return (userData['totalPayable'] as num).toInt();
    }

    // Fallback calculation for existing data
    final bool isRunning = userData['isRunningStudent'] == true;
    final int baseFee = isRunning ? 700 : 1200;
    final int guestCount =
        (userData['spouseCount'] ?? 0) + (userData['childCount'] ?? 0);
    final int guestFee = guestCount * 500;
    return baseFee + guestFee;
  }

  void _updateTotalPayable() {
    // Calculate total payable amount based on current editedUser data
    final bool isRunning = editedUser['isRunningStudent'] == true;
    final int baseFee = isRunning ? 700 : 1200;
    final int guestCount =
        (editedUser['spouseCount'] ?? 0) + (editedUser['childCount'] ?? 0);
    final int guestFee = guestCount * 500;
    final int totalPayable = baseFee + guestFee;

    // Update the editedUser with new totalPayable
    editedUser['totalPayable'] = totalPayable;

    // Debug print to track calculation
    print('Total Payable Calculation:');
    print('  isRunningStudent: ${editedUser['isRunningStudent']}');
    print('  baseFee: $baseFee');
    print('  spouseCount: ${editedUser['spouseCount']}');
    print('  childCount: ${editedUser['childCount']}');
    print('  guestCount: $guestCount');
    print('  guestFee: $guestFee');
    print('  totalPayable: $totalPayable');
  }
}

String _obscureMobile(String mobile) {
  if (mobile.length <= 4) return mobile;
  final last4 = mobile.substring(mobile.length - 4);
  return '*' * (mobile.length - 4) + last4;
}

// Add AdminRunningBatchPage
class AdminRunningBatchPage extends StatelessWidget {
  final List<String> runningClassBatches;
  final Map<String, List<QueryDocumentSnapshot>> batchMap;
  const AdminRunningBatchPage({
    super.key,
    required this.runningClassBatches,
    required this.batchMap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedClasses = List<String>.from(runningClassBatches);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Running Student Batches',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount = 2;
            if (width > 1200) {
              crossAxisCount = 6;
            } else if (width > 900) {
              crossAxisCount = 4;
            } else if (width > 600) {
              crossAxisCount = 3;
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: sortedClasses.length,
              itemBuilder: (context, index) {
                final classId = sortedClasses[index];
                final regCount = batchMap[classId]?.length ?? 0;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => AdminBatchDetailsPage(batchId: classId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            classId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$regCount',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Update PaymentStatusDropdown to always use and update 'paymentStatus' on registration
class PaymentStatusDropdown extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PaymentStatusDropdown({super.key, required this.userData});

  @override
  State<PaymentStatusDropdown> createState() => _PaymentStatusDropdownState();
}

class _PaymentStatusDropdownState extends State<PaymentStatusDropdown> {
  String? paymentStatus;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    paymentStatus = widget.userData['paymentStatus']?.toString() ?? 'pending';
  }

  Future<void> _updateStatus(String status) async {
    setState(() => isLoading = true);
    final batch = widget.userData['batch']?.toString();
    final phone = widget.userData['mobile']?.toString();
    if (batch != null && phone != null) {
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(batch)
          .collection('registrations')
          .doc(phone)
          .update({'paymentStatus': status});
      setState(() {
        paymentStatus = status;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    Color statusColor;
    switch (paymentStatus) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: DropdownButton<String>(
        value: paymentStatus,
        items: const [
          DropdownMenuItem(value: 'approved', child: Text('Approved')),
          DropdownMenuItem(value: 'pending', child: Text('Pending')),
          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
        ],
        onChanged: (value) async {
          if (value != null) {
            await _updateStatus(value);
          }
        },
        underline: Container(),
        style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
        icon: Icon(Icons.arrow_drop_down, color: statusColor),
        dropdownColor: Colors.white,
      ),
    );
  }
}
