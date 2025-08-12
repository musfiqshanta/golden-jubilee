import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Get total guests count directly from collections
  Future<int> getTotalGuestsCount() async {
    try {
      final spouseCountQuery =
          _firestore
              .collectionGroup('registrations')
              .aggregate(sum('spouseCount'))
              .get();

      final childCountQuery =
          _firestore
              .collectionGroup('registrations')
              .aggregate(sum('childCount'))
              .get();

      final results = await Future.wait([spouseCountQuery, childCountQuery]);

      final spouseCount = results[0].getSum('spouseCount');
      final childCount = results[1].getSum('childCount');

      final totalGuests =
          (spouseCount ?? 0).toInt() + (childCount ?? 0).toInt();

      print('Total guests from efficient filtering: $totalGuests');
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
      print('📊 Getting all statistics in optimized way...');

      // Get all registrations once and calculate everything
      final snapshot = await _firestore.collectionGroup('registrations').get();

      int totalRegistrations = snapshot.docs.length;
      int totalGuests = 0;
      int totalApprovedUsers = 0;
      double totalCollections = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Count guests
        totalGuests +=
            ((data['spouseCount'] ?? 0) as num).toInt() +
            ((data['childCount'] ?? 0) as num).toInt();

        // Count approved users and collections
        if (data['paymentStatus'] == 'approved') {
          totalApprovedUsers++;
          totalCollections += (data['totalPayable'] ?? 0) as num;
        }
      }

      print('✅ All statistics calculated:');
      print('   Total Registrations: $totalRegistrations');
      print('   Total Guests: $totalGuests');
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

      int totalGuests = 0;
      int totalApprovedUsers = 0;
      double totalCollections = 0;

      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();
        totalGuests +=
            ((data['spouseCount'] ?? 0) as num).toInt() +
            ((data['childCount'] ?? 0) as num).toInt();

        if (data['paymentStatus'] == 'approved') {
          totalApprovedUsers++;
          totalCollections += (data['totalPayable'] ?? 0) as num;
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
