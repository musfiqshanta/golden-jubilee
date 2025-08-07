import 'package:cloud_firestore/cloud_firestore.dart';

class CountdownService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get countdown dates
  Future<Map<String, dynamic>> getCountdownDates() async {
    try {
      final doc = await _firestore.collection('settings').doc('countdown').get();
      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching countdown dates: $e');
      return {};
    }
  }

  // Update countdown dates
  Future<bool> updateCountdownDates({
    required DateTime registrationDeadline,
    required DateTime jubileeDate,
  }) async {
    try {
      await _firestore.collection('settings').doc('countdown').set({
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'jubileeDate': Timestamp.fromDate(jubileeDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating countdown dates: $e');
      return false;
    }
  }

  // Stream for real-time updates
  Stream<Map<String, dynamic>> getCountdownDatesStream() {
    return _firestore
        .collection('settings')
        .doc('countdown')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }
}
