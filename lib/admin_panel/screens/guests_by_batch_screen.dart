import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/modules/registration/views/update_registration_page.dart';

class GuestsByBatchScreen extends StatelessWidget {
  const GuestsByBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guests by Batch',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
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

          // Filter users with guests and group by batch
          final Map<String, List<QueryDocumentSnapshot>> batchMap = {};
          final Map<String, int> batchGuestCounts = {};
          
          for (var doc in regSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final spouseCount = (data['spouseCount'] ?? 0) as num;
            final childCount = (data['childCount'] ?? 0) as num;
            final totalGuests = spouseCount.toInt() + childCount.toInt();
            
            // Only include users with guests
            if (totalGuests > 0) {
              final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
              batchMap.putIfAbsent(batchId, () => []).add(doc);
              
              // Count total guests per batch
              batchGuestCounts[batchId] = 
                  (batchGuestCounts[batchId] ?? 0) + totalGuests;
            }
          }

          if (batchMap.isEmpty) {
            return const Center(
              child: Text('No guests found in any batch.'),
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
                    final guestCount = batchGuestCounts[batchId] ?? 0;
                    final userCount = batchMap[batchId]?.length ?? 0;
                    
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _GuestsBatchDetailsPage(
                                batchId: batchId,
                                registrations: batchMap[batchId] ?? [],
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                          '$guestCount',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                          Icons.person,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$userCount',
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

class _GuestsBatchDetailsPage extends StatelessWidget {
  final String batchId;
  final List<QueryDocumentSnapshot> registrations;
  
  const _GuestsBatchDetailsPage({
    required this.batchId,
    required this.registrations,
  });

  @override
  Widget build(BuildContext context) {
    // Collect all guests from all registrations in this batch
    final List<Map<String, dynamic>> allGuests = [];
    
    for (var regDoc in registrations) {
      final regData = regDoc.data() as Map<String, dynamic>;
      final userName = regData['name']?.toString() ?? 'Unknown';
      final userMobile = regData['mobile']?.toString() ?? '';
      final formNumber = regData['formSerialNumber']?.toString() ?? '';
      
      // Safely extract guest names and relationships
      List<String> guestNames = [];
      List<String> guestRelationships = [];
      
      if (regData['guestNames'] is List) {
        final namesList = regData['guestNames'] as List;
        guestNames = namesList.map((e) => e?.toString() ?? '').toList();
      }
      
      if (regData['guestRelationships'] is List) {
        final relationshipsList = regData['guestRelationships'] as List;
        guestRelationships = relationshipsList.map((e) => e?.toString() ?? '').toList();
      }
      
      // Add each guest with their user info
      for (int i = 0; i < guestNames.length; i++) {
        final guestName = guestNames[i].trim();
        if (guestName.isNotEmpty) {
          final relationship = i < guestRelationships.length 
              ? guestRelationships[i].trim()
              : 'Guest';
          allGuests.add({
            'name': guestName,
            'relationship': relationship.isNotEmpty ? relationship : 'Guest',
            'userName': userName,
            'userMobile': userMobile,
            'formNumber': formNumber,
            'registrationId': regDoc.id,
            'registrationData': regData, // Store full registration data for editing
          });
        }
      }
    }

    if (allGuests.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Batch $batchId - Guests',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1976D2),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('No guests found in this batch.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Batch $batchId - Guests (${allGuests.length})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allGuests.length,
        itemBuilder: (context, index) {
          final guest = allGuests[index];
          final guestName = guest['name'] as String;
          final relationship = guest['relationship'] as String;
          final userName = guest['userName'] as String;
          final userMobile = guest['userMobile'] as String;
          final formNumber = guest['formNumber'] as String;
          final regData = guest['registrationData'] as Map<String, dynamic>?;
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1976D2).withOpacity(0.2),
                radius: 25,
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1976D2),
                  size: 30,
                ),
              ),
              title: Text(
                guestName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Relationship: $relationship'),
                  const Divider(height: 16),
                  Text(
                    'User: $userName',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Mobile: $userMobile'),
                  Text('Form: $formNumber'),
                  if (regData != null) ...[
                    const SizedBox(height: 4),
                    _buildRegistrationTypeBadge(regData),
                  ],
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1976D2),
              ),
              onTap: () async {
                // Get registration data from stored data
                final regDataForNavigation = guest['registrationData'] as Map<String, dynamic>?;
                
                if (regDataForNavigation == null) {
                  // Fallback: find the registration document
                  final foundDoc = registrations.firstWhere(
                    (doc) => doc.id == guest['registrationId'],
                    orElse: () => registrations.first,
                  );
                  final foundData = foundDoc.data() as Map<String, dynamic>;
                  final phone = foundData['mobile']?.toString() ?? userMobile;
                  
                  // Navigate to UpdateRegistrationPage
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UpdateRegistrationPage(
                        batchId: batchId,
                        phone: phone,
                        registrationData: foundData,
                      ),
                    ),
                  );
                  
                  // Refresh the list if registration was updated
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  // Use stored data - phone is used as document ID
                  final phone = regDataForNavigation['mobile']?.toString() ?? userMobile;
                  
                  // Navigate to UpdateRegistrationPage to show/edit full user details
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UpdateRegistrationPage(
                        batchId: batchId,
                        phone: phone,
                        registrationData: regDataForNavigation,
                      ),
                    ),
                  );
                  
                  // Refresh the list if registration was updated
                  if (result == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Check if registration is online or offline
  bool _isOnlineRegistration(Map<String, dynamic> data) {
    final paymentData = data['paymentData'];
    if (paymentData != null && paymentData is Map<String, dynamic>) {
      final paymentMethod =
          paymentData['payment_method'] ?? paymentData['paymentMethod'] ?? '';
      final tranId = paymentData['tran_id'] ?? '';
      final valId = paymentData['val_id'] ?? '';
      final status = paymentData['status'] ?? '';
      final storeId = paymentData['store_id'] ?? '';

      if (paymentMethod.toLowerCase().contains('sslcommerz') ||
          paymentMethod.toLowerCase().contains('bkash') ||
          paymentMethod.toLowerCase().contains('mobilebanking') ||
          tranId.isNotEmpty ||
          valId.isNotEmpty ||
          status.toLowerCase() == 'valid' ||
          storeId.isNotEmpty) {
        return true;
      }
    }

    final paymentMethod = data['paymentMethod'] ?? data['payment_method'] ?? '';
    final paymentType = data['paymentType'] ?? data['payment_type'] ?? '';
    final sslcommerz = data['sslcommerz'] ?? '';
    final isOnlinePaymentField =
        data['isOnlinePayment'] ?? data['is_online_payment'] ?? false;
    final gateway = data['gateway'] ?? '';

    if (paymentMethod.toLowerCase().contains('sslcommerz') ||
        paymentMethod.toLowerCase().contains('online') ||
        paymentMethod.toLowerCase().contains('bkash') ||
        paymentType.toLowerCase().contains('sslcommerz') ||
        paymentType.toLowerCase().contains('online') ||
        sslcommerz.toString().toLowerCase().contains('true') ||
        isOnlinePaymentField == true ||
        gateway.toLowerCase().contains('sslcommerz') ||
        gateway.toLowerCase().contains('online')) {
      return true;
    }

    final transactionId =
        data['transactionId'] ??
        data['transaction_id'] ??
        data['sslcommerzTransactionId'] ??
        '';
    final paymentId = data['paymentId'] ?? data['payment_id'] ?? '';
    if (transactionId.isNotEmpty || paymentId.isNotEmpty) {
      return true;
    }

    final sslcommerzStatus = data['sslcommerzStatus'] ?? '';
    final sslcommerzTranId = data['sslcommerzTranId'] ?? '';
    final sslcommerzValId = data['sslcommerzValId'] ?? '';
    final sslcommerzAmount = data['sslcommerzAmount'] ?? '';

    if (sslcommerzStatus.isNotEmpty ||
        sslcommerzTranId.isNotEmpty ||
        sslcommerzValId.isNotEmpty ||
        sslcommerzAmount.isNotEmpty) {
      return true;
    }

    return false;
  }

  // Build registration type badge
  Widget _buildRegistrationTypeBadge(Map<String, dynamic> regData) {
    final isOnline = _isOnlineRegistration(regData);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.person_add,
            size: 14,
            color: isOnline ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOnline ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

