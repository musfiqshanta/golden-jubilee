import 'package:cloud_firestore/cloud_firestore.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllDonations() async {
    final snapshot = await _firestore.collection('donations').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> addDonation(Map<String, dynamic> donation) async {
    await _firestore.collection('donations').add(donation);
  }

  Future<void> updateDonation(
    String donationId,
    Map<String, dynamic> donation,
  ) async {
    await _firestore.collection('donations').doc(donationId).update(donation);
  }

  Future<void> updateDonationStatus(String donationId, String status) async {
    await _firestore.collection('donations').doc(donationId).update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<double> getTotalApprovedDonations() async {
    final snapshot =
        await _firestore
            .collection('donations')
            .where('status', isEqualTo: 'approved')
            .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] ?? 0) as num;
    }
    return total;
  }

  Future<int> getTotalDonationRequests() async {
    final snapshot = await _firestore.collection('donations').get();
    return snapshot.docs.length;
  }

  Future<void> deleteDonation(String donationId) async {
    await _firestore.collection('donations').doc(donationId).delete();
  }
}
