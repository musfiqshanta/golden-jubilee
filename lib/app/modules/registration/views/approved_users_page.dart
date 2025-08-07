import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedUsersPage extends StatelessWidget {
  const ApprovedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building ApprovedUsersPage');
    try {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'অনুমোদিত ব্যাচসমূহ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD4AF37),
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
              return const Center(
                child: Text('No approved registrations found.'),
              );
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
                      (id) =>
                          !id.endsWith('শ্রেণি') && int.tryParse(id) == null,
                    )
                    .toList();

            // Compose final batch list: Running Batch (virtual), then years, then others
            // Remove 'running' from otherBatches if present
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
                        // Virtual card for Running Batch
                        int totalRunning = 0;
                        for (var classId in runningClassBatches) {
                          totalRunning += batchMap[classId]?.length ?? 0;
                        }
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(
                                () => ApprovedRunningBatchPage(
                                  runningClassBatches: runningClassBatches,
                                  batchMap: batchMap,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF145A32), // Deep Green
                                    Color(0xFFFFD700), // Golden
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
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
                                  const Text(
                                    'বর্তমানে অধ্যয়নরত',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
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
                                          size: 15,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$totalRunning',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
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
                      // Normal batch card
                      final regCount = batchMap[batchId]?.length ?? 0;
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              () => ApprovedBatchDetailsPage(batchId: batchId),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
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
                                  'ব্যাচ $batchId',
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
    } catch (e, st) {
      print('Error building ApprovedUsersPage: $e\n$st');
      return const Center(child: Text('Error loading page'));
    }
  }
}

class ApprovedBatchDetailsPage extends StatelessWidget {
  final String batchId;
  const ApprovedBatchDetailsPage({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    print('Building ApprovedBatchDetailsPage for batch $batchId');
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'ব্যাচ $batchId অনুমোদিত নিবন্ধনসমূহ',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD4AF37),
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
                child: Text('No approved registrations found.'),
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
                final totalPayable = data['totalPayable'] ?? 0;
                print(photoUrl);
                return Card(
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
                        child: Image.network(
                          photoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, color: Colors.grey);
                          },
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
                        Text(
                          'Mobile: ${_obscureMobile(mobile)}',
                          style: const TextStyle(letterSpacing: 1.2),
                        ),
                        Text(
                          'Amount: ৳$totalPayable',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } catch (e, st) {
      print('Error building ApprovedBatchDetailsPage: $e\n$st');
      return const Center(child: Text('Error loading page'));
    }
  }
}

String _obscureMobile(String mobile) {
  if (mobile.length <= 4) return mobile;
  final last4 = mobile.substring(mobile.length - 4);
  return '*' * (mobile.length - 4) + last4;
}

class ApprovedRunningBatchPage extends StatelessWidget {
  final List<String> runningClassBatches;
  final Map<String, List<QueryDocumentSnapshot>> batchMap;
  const ApprovedRunningBatchPage({
    super.key,
    required this.runningClassBatches,
    required this.batchMap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort running class batches by class order (if needed)
    final sortedClasses = List<String>.from(runningClassBatches);
    // Optionally, sort by your preferred class order
    // sortedClasses.sort();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'বর্তমানে অধ্যয়নরত শ্রেণিসমূহ (অনুমোদিত)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4AF37),
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
                      Get.to(() => ApprovedBatchDetailsPage(batchId: classId));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
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
