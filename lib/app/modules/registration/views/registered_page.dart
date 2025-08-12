import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisteredPage extends StatefulWidget {
  const RegisteredPage({super.key});

  @override
  State<RegisteredPage> createState() => _RegisteredPageState();
}

class _RegisteredPageState extends State<RegisteredPage> {
  // Cache for batch data to prevent unnecessary refetches
  Map<String, dynamic>? _cachedBatchData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBatchData();
  }

  // Load batch data once when page loads
  Future<void> _loadBatchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get all registrations once
      final registrationsSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      // Group registrations by batchId (parent.id)
      final Map<String, List<QueryDocumentSnapshot>> batchMap = {};
      for (var doc in registrationsSnapshot.docs) {
        final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
        batchMap.putIfAbsent(batchId, () => []).add(doc);
      }

      // Process batch data
      final batchIds = batchMap.keys.toList();
      final runningClassBatches =
          batchIds.where((id) => id.endsWith('শ্রেণি')).toList();
      final yearBatches =
          batchIds.where((id) => int.tryParse(id) != null).toList();
      yearBatches.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      final otherBatches =
          batchIds
              .where((id) => !id.endsWith('শ্রেণি') && int.tryParse(id) == null)
              .toList();

      // Compose final batch list
      final filteredOtherBatches =
          otherBatches.where((id) => id != 'running').toList();
      final displayBatchIds = [
        '__running_batch__',
        ...yearBatches,
        ...filteredOtherBatches,
      ];

      // Calculate statistics for each batch
      final Map<String, Map<String, int>> batchStats = {};
      for (var batchId in batchIds) {
        final registrations = batchMap[batchId] ?? [];
        int totalCount = registrations.length;
        int approvedCount = 0;

        for (var doc in registrations) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['paymentStatus'] == 'approved') {
            approvedCount++;
          }
        }

        batchStats[batchId] = {'total': totalCount, 'approved': approvedCount};
      }

      // Calculate running batch totals
      int totalRunning = 0;
      int totalRunningApproved = 0;
      for (var classId in runningClassBatches) {
        final stats = batchStats[classId];
        if (stats != null) {
          totalRunning += stats['total']!;
          totalRunningApproved += stats['approved']!;
        }
      }

      setState(() {
        _cachedBatchData = {
          'batchMap': batchMap,
          'batchIds': batchIds,
          'runningClassBatches': runningClassBatches,
          'yearBatches': yearBatches,
          'otherBatches': otherBatches,
          'displayBatchIds': displayBatchIds,
          'batchStats': batchStats,
          'totalRunning': totalRunning,
          'totalRunningApproved': totalRunningApproved,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading batch data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Refresh batch data manually
  Future<void> _refreshBatchData() async {
    await _loadBatchData();
  }

  @override
  Widget build(BuildContext context) {
    print('Building RegisteredPage');
    try {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'নিবন্ধিত ব্যাচসমূহ',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD4AF37),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: _refreshBatchData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cachedBatchData == null
                ? const Center(child: Text('No data available'))
                : _buildBatchGrid(),
      );
    } catch (e, st) {
      print('Error building RegisteredPage: $e\n$st');
      return const Center(child: Text('Error loading page'));
    }
  }

  Widget _buildBatchGrid() {
    final data = _cachedBatchData!;
    final displayBatchIds = data['displayBatchIds'] as List<String>;
    final batchStats = data['batchStats'] as Map<String, Map<String, int>>;
    final runningClassBatches = data['runningClassBatches'] as List<String>;
    final totalRunning = data['totalRunning'] as int;
    final totalRunningApproved = data['totalRunningApproved'] as int;

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
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => RunningBatchPage(
                          runningClassBatches: runningClassBatches,
                          batchMap:
                              data['batchMap']
                                  as Map<String, List<QueryDocumentSnapshot>>,
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
                          const SizedBox(height: 8),
                          // Total registrations
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
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
                                  '$totalRunning',
                                  style: const TextStyle(
                                    fontSize: 12,
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
                          const SizedBox(height: 4),
                          // Approved count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$totalRunningApproved',
                                  style: const TextStyle(
                                    fontSize: 12,
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
              final stats = batchStats[batchId];
              final regCount = stats?['total'] ?? 0;
              final approvedCount = stats?['approved'] ?? 0;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => BatchDetailsPage(batchId: batchId));
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
                        const SizedBox(height: 8),
                        // Total registrations
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$regCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Approved count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$approvedCount',
                                style: const TextStyle(
                                  fontSize: 10,
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
  }
}

class BatchDetailsPage extends StatelessWidget {
  final String batchId;
  const BatchDetailsPage({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    print('Building BatchDetailsPage for batch $batchId');
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'ব্যাচ $batchId নিবন্ধনসমূহ',
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
                final paymentStatus = data['paymentStatus'] ?? 'pending';
                final totalPayable = data['totalPayable'] ?? 0;

                // Determine color based on payment status
                Color statusColor;
                IconData statusIcon;
                String statusText;

                switch (paymentStatus) {
                  case 'approved':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    statusText = 'অনুমোদিত';
                    break;
                  case 'pending':
                    statusColor = Colors.orange;
                    statusIcon = Icons.pending;
                    statusText = 'অপেক্ষমান';
                    break;
                  case 'rejected':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    statusText = 'প্রত্যাখ্যাত';
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.help;
                    statusText = 'অজানা';
                }
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '৳$totalPayable',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD4AF37),
                                fontSize: 12,
                              ),
                            ),
                          ],
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
      print('Error building BatchDetailsPage: $e\n$st');
      return const Center(child: Text('Error loading page'));
    }
  }
}

String _obscureMobile(String mobile) {
  if (mobile.length <= 4) return mobile;
  final last4 = mobile.substring(mobile.length - 4);
  return '*' * (mobile.length - 4) + last4;
}

class RunningBatchPage extends StatelessWidget {
  final List<String> runningClassBatches;
  final Map<String, List<QueryDocumentSnapshot>> batchMap;
  const RunningBatchPage({
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
          'বর্তমানে অধ্যয়নরত শ্রেণিসমূহ',
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
                // Calculate approved count for this class
                int approvedCount = 0;
                if (batchMap[classId] != null) {
                  for (var doc in batchMap[classId]!) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['paymentStatus'] == 'approved') {
                      approvedCount++;
                    }
                  }
                }
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => BatchDetailsPage(batchId: classId));
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
                          const SizedBox(height: 8),
                          // Total registrations
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$regCount',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Approved count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$approvedCount',
                                  style: const TextStyle(
                                    fontSize: 10,
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
