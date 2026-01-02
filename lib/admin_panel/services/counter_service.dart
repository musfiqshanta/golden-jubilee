import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_config.dart';

class CounterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get total registrations count directly from collections
  Future<int> getTotalRegistrationsCount() async {
    try {
      print('📊 Counting total registrations from collections...');
      final snapshot =
          await _firestore.collectionGroup('registrations').count().get();
      final count = snapshot.count ?? 0;
      print('Total registrations from collection: $count');
      return count;
    } catch (e) {
      print('Error getting total registrations count: $e');
      return 0;
    }
  }

  // Get total guests count directly from collections (only approved users)
  Future<int> getTotalGuestsCount() async {
    try {
      // Only count guests from approved users
      final snapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('paymentStatus', isEqualTo: 'approved')
              .get();

      int totalGuests = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalGuests +=
            ((data['spouseCount'] ?? 0) as num).toInt() +
            ((data['childCount'] ?? 0) as num).toInt();
      }

      print('Total guests from approved users: $totalGuests');
      return totalGuests;
    } catch (e) {
      print('Error getting total guests count: $e');
      return 0;
    }
  }

  // Get total collections amount directly from collections
  Future<double> getTotalCollectionsAmount() async {
    try {
      print('💰 Counting total collections using smart filtering...');

      // Smart approach: Only fetch approved registrations instead of all
      // This is much more efficient than fetching all documents

      final snapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('paymentStatus', isEqualTo: 'approved')
              .get();

      double totalCollection = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCollection += (data['totalPayable'] ?? 0) as num;
      }

      print('Total collections from smart filtering: $totalCollection');
      return totalCollection;
    } catch (e) {
      print('Error getting total collections amount: $e');
      return 0.0;
    }
  }

  // Get total approved users count directly from collections
  Future<int> getTotalApprovedUsersCount() async {
    try {
      print('✅ Counting total approved users from collections...');

      // Use count query for approved users
      final snapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('paymentStatus', isEqualTo: 'approved')
              .count()
              .get();

      final count = snapshot.count ?? 0;
      print('Total approved users from collection: $count');
      return count;
    } catch (e) {
      print('Error getting total approved users count: $e');
      return 0;
    }
  }

  // Optimized method to get all statistics in one query
  Future<Map<String, dynamic>> getAllStatistics() async {
    try {
      print('🔍 Checking development mode...');
      AppConfig.testConfig();

      // Check if we should use test data in development mode
      if (AppConfig.useTestData) {
        print('🧪 Using test data for development mode');
        AppConfig.printConfig();

        final testData = AppConfig.getAllTestData();
        print('✅ Test statistics loaded:');
        print('   Total Registrations: ${testData['totalRegistrations']}');
        print('   Total Guests: ${testData['totalGuests']}');
        print('   Total Approved Users: ${testData['totalApprovedUsers']}');
        print('   Total Collections: ৳${testData['totalCollections']}');

        return testData;
      }

      print('📊 Getting all statistics from Firebase...');

      // Get all registrations once and calculate everything
      final snapshot = await _firestore.collectionGroup('registrations').get();

      int totalRegistrations = snapshot.docs.length;
      int totalGuests = 0; // Only count guests from approved users
      int totalApprovedUsers = 0;
      double totalCollections = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Count approved users and collections
        if (data['paymentStatus'] == 'approved') {
          totalApprovedUsers++;
          totalCollections += (data['totalPayable'] ?? 0) as num;
          
          // Only count guests from approved users
          totalGuests +=
              ((data['spouseCount'] ?? 0) as num).toInt() +
              ((data['childCount'] ?? 0) as num).toInt();
        }
      }

      print('✅ All statistics calculated from Firebase:');
      print('   Total Registrations: $totalRegistrations');
      print('   Total Guests (Approved Users Only): $totalGuests');
      print('   Total Approved Users: $totalApprovedUsers');
      print('   Total Collections: ৳$totalCollections');

      return {
        'totalRegistrations': totalRegistrations,
        'totalGuests': totalGuests,
        'totalApprovedUsers': totalApprovedUsers,
        'totalCollections': totalCollections,
      };
    } catch (e) {
      print('❌ Error getting all statistics: $e');
      return {
        'totalRegistrations': 0,
        'totalGuests': 0,
        'totalApprovedUsers': 0,
        'totalCollections': 0.0,
      };
    }
  }

  // Get t-shirt size statistics (only from approved users)
  Future<Map<String, int>> getTshirtSizeStatistics() async {
    try {
      print('👕 Getting t-shirt size statistics from approved users...');

      // Get only approved registrations
      final snapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('paymentStatus', isEqualTo: 'approved')
              .get();

      // Initialize size counts
      final sizeCounts = <String, int>{
        'S': 0,
        'M': 0,
        'L': 0,
        'XL': 0,
        'XXL': 0,
      };

      // Count t-shirt sizes
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final tshirtSize = data['tshirtSize']?.toString().toUpperCase() ?? '';
        
        // Handle variations (e.g., 'XL', 'xl', 'Xl')
        if (sizeCounts.containsKey(tshirtSize)) {
          sizeCounts[tshirtSize] = (sizeCounts[tshirtSize] ?? 0) + 1;
        } else if (tshirtSize.isNotEmpty) {
          // Handle any other sizes that might exist
          sizeCounts[tshirtSize] = (sizeCounts[tshirtSize] ?? 0) + 1;
        }
      }

      print('✅ T-shirt size statistics:');
      sizeCounts.forEach((size, count) {
        if (count > 0 || ['S', 'M', 'L', 'XL', 'XXL'].contains(size)) {
          print('   $size: $count');
        }
      });

      return sizeCounts;
    } catch (e) {
      print('Error getting t-shirt size statistics: $e');
      return {
        'S': 0,
        'M': 0,
        'L': 0,
        'XL': 0,
        'XXL': 0,
      };
    }
  }

  // Update total registrations count (called when new registration is added)
  Future<void> incrementTotalRegistrations() async {
    try {
      await _firestore.collection('counters').doc('totalRegistrations').set({
        'count': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Total registrations counter incremented');
    } catch (e) {
      print('Error incrementing total registrations count: $e');
    }
  }

  // Update total guests count (called when new registration is added)
  Future<void> updateTotalGuests(int guestCount) async {
    try {
      await _firestore.collection('counters').doc('totalGuests').set({
        'count': FieldValue.increment(guestCount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Total guests counter updated by $guestCount');
    } catch (e) {
      print('Error updating total guests count: $e');
    }
  }

  // Update total collections amount (called when payment is approved)
  Future<void> updateTotalCollections(double amount) async {
    try {
      await _firestore.collection('counters').doc('totalCollections').set({
        'amount': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Total collections counter updated by $amount');
    } catch (e) {
      print('Error updating total collections amount: $e');
    }
  }

  // Update total approved users count (called when payment is approved)
  Future<void> incrementTotalApprovedUsers() async {
    try {
      await _firestore.collection('counters').doc('totalApprovedUsers').set({
        'count': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Total approved users counter incremented');
    } catch (e) {
      print('Error updating total approved users count: $e');
    }
  }

  // Check if counters are initialized
  Future<bool> areCountersInitialized() async {
    try {
      final doc =
          await _firestore
              .collection('counters')
              .doc('totalRegistrations')
              .get();
      return doc.exists;
    } catch (e) {
      print('Error checking counter status: $e');
      return false;
    }
  }

  // Get counter status information
  Future<Map<String, dynamic>> getCounterStatus() async {
    try {
      final counters = [
        'totalRegistrations',
        'totalGuests',
        'totalCollections',
        'totalApprovedUsers',
      ];
      final status = <String, dynamic>{};

      for (final counterName in counters) {
        final doc =
            await _firestore.collection('counters').doc(counterName).get();
        status[counterName] = {
          'exists': doc.exists,
          'lastUpdated': doc.data()?['lastUpdated'],
          'value': doc.data()?['count'] ?? doc.data()?['amount'] ?? 0,
        };
      }

      return status;
    } catch (e) {
      print('Error getting counter status: $e');
      return {};
    }
  }

  // Force refresh all counters from actual data
  Future<void> forceRefreshCounters() async {
    try {
      print('🔄 Force refreshing all counters...');

      // Get actual data
      final registrationsSnapshot =
          await _firestore.collectionGroup('registrations').get();
      final totalRegistrations = registrationsSnapshot.docs.length;

      int totalGuests = 0; // Only count guests from approved users
      int totalApprovedUsers = 0;
      double totalCollections = 0;

      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();

        if (data['paymentStatus'] == 'approved') {
          totalApprovedUsers++;
          totalCollections += (data['totalPayable'] ?? 0) as num;
          
          // Only count guests from approved users
          totalGuests +=
              ((data['spouseCount'] ?? 0) as num).toInt() +
              ((data['childCount'] ?? 0) as num).toInt();
        }
      }

      // Update all counters
      await Future.wait([
        _firestore.collection('counters').doc('totalRegistrations').set({
          'count': totalRegistrations,
          'lastUpdated': FieldValue.serverTimestamp(),
        }),
        _firestore.collection('counters').doc('totalGuests').set({
          'count': totalGuests,
          'lastUpdated': FieldValue.serverTimestamp(),
        }),
        _firestore.collection('counters').doc('totalCollections').set({
          'amount': totalCollections,
          'lastUpdated': FieldValue.serverTimestamp(),
        }),
        _firestore.collection('counters').doc('totalApprovedUsers').set({
          'count': totalApprovedUsers,
          'lastUpdated': FieldValue.serverTimestamp(),
        }),
      ]);

      print('✅ Counters refreshed successfully:');
      print('   Total Registrations: $totalRegistrations');
      print('   Total Guests: $totalGuests');
      print('   Total Collections: ৳$totalCollections');
      print('   Total Approved Users: $totalApprovedUsers');
    } catch (e) {
      print('❌ Error refreshing counters: $e');
      rethrow;
    }
  }

  // Debug method to show actual data structure
  Future<void> debugDataStructure() async {
    try {
      print('🔍 Debugging data structure...');

      // Get all registrations
      final registrationsSnapshot =
          await _firestore.collectionGroup('registrations').get();
      print('📊 Total documents found: ${registrationsSnapshot.docs.length}');

      if (registrationsSnapshot.docs.isEmpty) {
        print('❌ No registration documents found!');
        print('🔍 Checking if collections exist...');

        // Check if any batches exist
        final batchesSnapshot = await _firestore.collection('batches').get();
        print(
          '📁 Batches collection: ${batchesSnapshot.docs.length} documents',
        );

        for (var batchDoc in batchesSnapshot.docs) {
          print('   Batch: ${batchDoc.id}');
          final registrationsInBatch =
              await batchDoc.reference.collection('registrations').get();
          print(
            '     Registrations in this batch: ${registrationsInBatch.docs.length}',
          );
        }
        return;
      }

      // Show first few documents for debugging
      print('📋 First 3 registration documents:');
      for (int i = 0; i < registrationsSnapshot.docs.length && i < 3; i++) {
        final doc = registrationsSnapshot.docs[i];
        final data = doc.data();
        print('   Document ${i + 1}:');
        print('     ID: ${doc.id}');
        print('     Path: ${doc.reference.path}');
        print('     Name: ${data['name'] ?? 'N/A'}');
        print('     Mobile: ${data['mobile'] ?? 'N/A'}');
        print('     Batch: ${data['batch'] ?? 'N/A'}');
        print('     Payment Status: ${data['paymentStatus'] ?? 'N/A'}');
        print('     Total Payable: ${data['totalPayable'] ?? 'N/A'}');
        print('     Spouse Count: ${data['spouseCount'] ?? 'N/A'}');
        print('     Child Count: ${data['childCount'] ?? 'N/A'}');
      }

      // Show collection paths
      print('📂 Collection paths found:');
      final paths = <String>{};
      for (var doc in registrationsSnapshot.docs) {
        paths.add(doc.reference.parent.parent?.path ?? 'Unknown');
      }
      for (var path in paths) {
        print('   $path');
      }
    } catch (e) {
      print('❌ Error debugging data structure: $e');
    }
  }
}
