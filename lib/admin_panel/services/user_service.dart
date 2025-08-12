import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    // You can either delete or block the user. Here, we delete:
    await _firestore.collection('users').doc(uid).delete();
    // Or, to block instead of delete, use:
    // await _firestore.collection('users').doc(uid).update({'blocked': true});
  }

  // New methods for dashboard statistics (one-time reads instead of streams)
  Future<int> getTotalRegistrations() async {
    final snapshot = await _firestore.collectionGroup('registrations').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalGuests() async {
    final snapshot = await _firestore.collectionGroup('registrations').get();
    int totalGuests = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalGuests +=
          ((data['spouseCount'] ?? 0) as num).toInt() +
          ((data['childCount'] ?? 0) as num).toInt();
    }
    return totalGuests;
  }

  Future<int> getTotalApprovedUsers() async {
    final snapshot =
        await _firestore
            .collectionGroup('registrations')
            .where('paymentStatus', isEqualTo: 'approved')
            .get();
    return snapshot.docs.length;
  }
}
