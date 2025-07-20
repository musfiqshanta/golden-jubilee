import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_registered_page.dart';

class AdminApprovedUsersPage extends StatelessWidget {
  const AdminApprovedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Approved Users by Batch',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
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
          // Group approved users by batchId
          final Map<String, List<QueryDocumentSnapshot>> batchMap = {};
          for (var doc in regSnapshot.data!.docs) {
            final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
            batchMap.putIfAbsent(batchId, () => []).add(doc);
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
                              builder:
                                  (_) => _ApprovedBatchDetailsPage(
                                    batchId: batchId,
                                  ),
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
}

class _ApprovedBatchDetailsPage extends StatelessWidget {
  final String batchId;
  const _ApprovedBatchDetailsPage({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Approved Users - Batch $batchId',
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
                .where('paymentStatus', isEqualTo: 'approved')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No approved users in this batch.'),
            );
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
              return Card(
                color: Colors.green,
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
                    'Mobile: $mobile',
                    style: const TextStyle(letterSpacing: 1.2),
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
}
