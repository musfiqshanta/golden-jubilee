import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/admin_registered_page.dart';

class TshirtSizeUsersScreen extends StatelessWidget {
  final String tshirtSize;
  
  const TshirtSizeUsersScreen({
    super.key,
    required this.tshirtSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'T-shirt Size: $tshirtSize',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('registrations')
            .where('paymentStatus', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, regSnapshot) {
          if (regSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!regSnapshot.hasData || regSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No approved users found.'));
          }

          // Filter users by t-shirt size and group by batch
          final Map<String, List<QueryDocumentSnapshot>> batchMap = {};
          for (var doc in regSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userTshirtSize = data['tshirtSize']?.toString().toUpperCase() ?? '';
            
            // Match t-shirt size (case-insensitive)
            if (userTshirtSize == tshirtSize.toUpperCase()) {
              final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
              batchMap.putIfAbsent(batchId, () => []).add(doc);
            }
          }

          if (batchMap.isEmpty) {
            return Center(
              child: Text('No users found with t-shirt size: $tshirtSize'),
            );
          }

          final batchIds = batchMap.keys.toList();
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
          final filteredOtherBatches =
              otherBatches.where((id) => id != 'running').toList();
          final displayBatchIds = [
            ...runningClassBatches,
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
                    final regCount = batchMap[batchId]?.length ?? 0;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _TshirtSizeBatchDetailsPage(
                                batchId: batchId,
                                tshirtSize: tshirtSize,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getTshirtSizeColor(tshirtSize),
                                _getTshirtSizeColor(tshirtSize).withOpacity(0.7),
                              ],
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
                                'Batch $batchId',
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
          );
        },
      ),
    );
  }

  Color _getTshirtSizeColor(String size) {
    switch (size.toUpperCase()) {
      case 'S':
        return Colors.blue;
      case 'M':
        return Colors.green;
      case 'L':
        return Colors.orange;
      case 'XL':
        return Colors.purple;
      case 'XXL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _TshirtSizeBatchDetailsPage extends StatelessWidget {
  final String batchId;
  final String tshirtSize;
  
  const _TshirtSizeBatchDetailsPage({
    required this.batchId,
    required this.tshirtSize,
  });

  @override
  Widget build(BuildContext context) {
    final stream =
        FirebaseFirestore.instance
            .collection('batches')
            .doc(batchId)
            .collection('registrations')
            .where('paymentStatus', isEqualTo: 'approved')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Batch $batchId - Size $tshirtSize',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _getTshirtSizeColor(tshirtSize),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No approved users in this batch.'),
            );
          }
          
          // Filter by t-shirt size
          final allRegs = snapshot.data!.docs;
          final filteredRegs = allRegs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final userTshirtSize = data['tshirtSize']?.toString().toUpperCase() ?? '';
            return userTshirtSize == tshirtSize.toUpperCase();
          }).toList();

          if (filteredRegs.isEmpty) {
            return Center(
              child: Text('No users with size $tshirtSize in this batch.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRegs.length,
            itemBuilder: (context, index) {
              final reg = filteredRegs[index];
              final data = reg.data() as Map<String, dynamic>;
              final photoUrl = data['photoUrl'] as String?;
              final name = data['name'] ?? '';
              final mobile = data['mobile'] ?? '';
              final formNumber = data['formSerialNumber'] ?? '';
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: 25,
                    child: ClipOval(
                      child:
                          photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                photoUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 30,
                                  );
                                },
                              )
                              : const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 30,
                              ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Mobile: $mobile'),
                      Text('Form: $formNumber'),
                      Text(
                        'Size: $tshirtSize',
                        style: TextStyle(
                          color: _getTshirtSizeColor(tshirtSize),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: _getTshirtSizeColor(tshirtSize),
                  ),
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

  Color _getTshirtSizeColor(String size) {
    switch (size.toUpperCase()) {
      case 'S':
        return Colors.blue;
      case 'M':
        return Colors.green;
      case 'L':
        return Colors.orange;
      case 'XL':
        return Colors.purple;
      case 'XXL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

