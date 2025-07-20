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

  Future<void> deleteDonation(String donationId) async {
    await _firestore.collection('donations').doc(donationId).delete();
  }
}
