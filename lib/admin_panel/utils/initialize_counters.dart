import 'package:cloud_firestore/cloud_firestore.dart';

class CounterInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize counter documents if they don't exist
  static Future<void> initializeCounters() async {
    try {
      print('🔄 Initializing counters...');

      // Initialize total registrations counter
      await _firestore.collection('counters').doc('totalRegistrations').set({
        'count': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Initialize total guests counter
      await _firestore.collection('counters').doc('totalGuests').set({
        'count': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Initialize total collections counter
      await _firestore.collection('counters').doc('totalCollections').set({
        'amount': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Initialize total approved users counter
      await _firestore.collection('counters').doc('totalApprovedUsers').set({
        'count': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Counters initialized successfully');
    } catch (e) {
      print('❌ Error initializing counters: $e');
      rethrow;
    }
  }

  /// Sync existing data to counters (run once to populate counters)
  static Future<void> syncExistingDataToCounters() async {
    try {
      print('🔄 Starting data sync to counters...');
      print('📁 Using collectionGroup: registrations');

      // Count total registrations
      final registrationsSnapshot =
          await _firestore.collectionGroup('registrations').get();
      final totalRegistrations = registrationsSnapshot.docs.length;
      print('📊 Found $totalRegistrations registrations');

      // Count total guests (only from approved users)
      int totalGuests = 0;
      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();
        // Only count guests from approved users
        if (data['paymentStatus'] == 'approved') {
          final spouseCount = (data['spouseCount'] ?? 0) as num;
          final childCount = (data['childCount'] ?? 0) as num;
          totalGuests += spouseCount.toInt() + childCount.toInt();
        }
      }
      print('👥 Total guests calculated (approved users only): $totalGuests');

      // Count total collections and approved users
      double totalCollections = 0;
      int totalApprovedUsers = 0;
      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();
        if (data['paymentStatus'] == 'approved') {
          totalApprovedUsers++;
          final totalPayable = (data['totalPayable'] ?? 0) as num;
          totalCollections += totalPayable;
        }
      }
      print('💰 Total collections: ৳$totalCollections');
      print('✅ Total approved users: $totalApprovedUsers');

      // Update counters with existing data
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

      print('✅ Data sync completed successfully:');
      print('   Total Registrations: $totalRegistrations');
      print('   Total Guests: $totalGuests');
      print('   Total Collections: ৳$totalCollections');
      print('   Total Approved Users: $totalApprovedUsers');
    } catch (e) {
      print('❌ Error syncing data to counters: $e');
      rethrow;
    }
  }

  /// Show current data state for debugging
  static Future<void> showCurrentDataState() async {
    try {
      print('📊 Current Data State:');
      print('📁 Using collectionGroup: registrations');

      // Check if counters exist
      final countersSnapshot = await _firestore.collection('counters').get();
      print(
        '   Counters collection exists: ${countersSnapshot.docs.isNotEmpty}',
      );

      if (countersSnapshot.docs.isNotEmpty) {
        for (var doc in countersSnapshot.docs) {
          final data = doc.data();
          final value = data['count'] ?? data['amount'] ?? 'N/A';
          final lastUpdated = data['lastUpdated'];
          print('   ${doc.id}: $value (last updated: $lastUpdated)');
        }
      }

      // Show actual data counts
      final registrationsSnapshot =
          await _firestore.collectionGroup('registrations').get();
      print(
        '   Actual total registrations: ${registrationsSnapshot.docs.length}',
      );

      int actualGuests = 0; // Only count guests from approved users
      int actualApproved = 0;
      double actualCollections = 0;

      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data();

        if (data['paymentStatus'] == 'approved') {
          actualApproved++;
          actualCollections += (data['totalPayable'] ?? 0) as num;
          
          // Only count guests from approved users
          actualGuests +=
              ((data['spouseCount'] ?? 0) as num).toInt() +
              ((data['childCount'] ?? 0) as num).toInt();
        }
      }

      print('   Actual total guests (approved users only): $actualGuests');
      print('   Actual total approved: $actualApproved');
      print('   Actual total collections: ৳$actualCollections');
    } catch (e) {
      print('❌ Error showing current data state: $e');
    }
  }
}
