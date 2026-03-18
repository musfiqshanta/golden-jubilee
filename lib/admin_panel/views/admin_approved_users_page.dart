import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  String _sanitizeCellValue(Object? value) {
    final raw = (value ?? '').toString();
    // Keep TSV/Excel paste safe: no tabs/newlines inside cells.
    return raw
        .replaceAll('\t', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ');
  }

  String _guestNamesText(Map<String, dynamic> data) {
    final guestNamesRaw = data['guestNames'];
    if (guestNamesRaw is List) {
      final names =
          guestNamesRaw
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
      return names.join(', ');
    }
    return '';
  }

  Future<void> _copyUserDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final int guestCount =
        (data['spouseCount'] ?? 0) + (data['childCount'] ?? 0);
    final guestNames = _guestNamesText(data);

    // Excel-friendly TSV (header + single row)
    final header = [
      'Name',
      'Phone',
      'Tshirt Size',
      'Guest',
      'Guest Names',
    ].join('\t');
    final row = [
      _sanitizeCellValue(data['name'] ?? 'N/A'),
      _sanitizeCellValue(data['mobile'] ?? 'N/A'),
      _sanitizeCellValue(data['tshirtSize'] ?? 'N/A'),
      _sanitizeCellValue(guestCount),
      _sanitizeCellValue(guestNames),
    ].join('\t');
    final textToCopy = '$header\n$row';

    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['name'] ?? 'User'} details copied!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _downloadImage(
    BuildContext context,
    String? photoUrl,
    String userName,
  ) async {
    if (photoUrl == null || photoUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image available for this user'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading image...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 1),
          ),
        );
      }

      if (kIsWeb) {
        // For web platform - open image in new tab for easy download
        final uri = Uri.parse(photoUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image opened in new tab. Right-click to save.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception('Could not open image URL');
        }
      } else {
        // For mobile/desktop platforms
        final response = await http.get(Uri.parse(photoUrl));
        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              '${userName.replaceAll(RegExp(r'[^\w\s-]'), '_')}_photo.jpg';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image saved to: ${file.path}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception('Failed to download image: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _copyAllDetails(
    BuildContext context,
    List<QueryDocumentSnapshot> regs,
  ) async {
    final buffer = StringBuffer();
    // Excel-friendly TSV: header row + one row per user
    buffer.writeln(
      ['Name', 'Phone', 'Tshirt Size', 'Guest', 'Guest Names'].join('\t'),
    );

    for (int i = 0; i < regs.length; i++) {
      final reg = regs[i];
      final data = reg.data() as Map<String, dynamic>;
      final int guestCount =
          (data['spouseCount'] ?? 0) + (data['childCount'] ?? 0);
      final guestNames = _guestNamesText(data);

      buffer.writeln(
        [
          _sanitizeCellValue(data['name'] ?? 'N/A'),
          _sanitizeCellValue(data['mobile'] ?? 'N/A'),
          _sanitizeCellValue(data['tshirtSize'] ?? 'N/A'),
          _sanitizeCellValue(guestCount),
          _sanitizeCellValue(guestNames),
        ].join('\t'),
      );
    }

    final textToCopy = buffer.toString();
    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All user details copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
          'Approved Users - Batch $batchId',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        tooltip: 'Download image',
                        onPressed:
                            () => _downloadImage(context, photoUrl, name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        tooltip: 'Copy user details',
                        onPressed: () => _copyUserDetails(context, data),
                      ),
                    ],
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
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }
          final regs = snapshot.data!.docs;
          return FloatingActionButton.extended(
            onPressed: () => _copyAllDetails(context, regs),
            icon: const Icon(Icons.copy, color: Colors.white),
            label: const Text(
              'Copy Details',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1976D2),
            tooltip: 'Copy all user details to clipboard',
          );
        },
      ),
    );
  }
}
