import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/pdf_service.dart';

class DonationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers for user verification
  final TextEditingController batchController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  // Form controllers for donation
  final TextEditingController donorNameController = TextEditingController();
  final TextEditingController donorPhoneController = TextEditingController();
  final TextEditingController donorEmailController = TextEditingController();
  final TextEditingController donorAddressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Reactive variables
  var isLoading = false.obs;
  var isUserFound = false.obs;
  var foundUserData = <String, dynamic>{}.obs;
  var selectedDonationType = 'সুবর্ণজয়ন্তী'.obs;
  var selectedPaymentMethod = 'নগদ'.obs;
  var isAnonymous = false.obs;
  var selectedBatch = ''.obs;
  var availableBatches = <String>[].obs;
  var donationsList = <Map<String, dynamic>>[].obs;

  // Lists for dropdowns
  final List<String> donationTypes = ['সুবর্ণজয়ন্তী'];

  final List<String> paymentMethods = [
    'নগদ',
    'মোবাইল ব্যাংকিং',
    'ব্যাংক ট্রান্সফার',
    'চেক',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAvailableBatches();
  }

  // Fetch available batches
  Future<void> fetchAvailableBatches() async {
    try {
      isLoading.value = true;
      final querySnapshot =
          await _firestore.collectionGroup('registrations').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Group registrations by batchId (parent.id)
        final Set<String> batchSet = {};
        for (var doc in querySnapshot.docs) {
          final batchId = doc.reference.parent.parent?.id ?? 'Unknown';
          if (batchId != 'Unknown') {
            batchSet.add(batchId);
          }
        }

        final batchIds = batchSet.toList();

        // Separate running class batches (Bangla names ending with 'শ্রেণি') and year batches (numeric)
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

        // Compose final batch list: Running classes, then years, then others
        final allBatches = [
          ...runningClassBatches,
          ...yearBatches,
          ...otherBatches,
        ];

        availableBatches.value = allBatches;
      } else {
        availableBatches.value = [];
      }
    } catch (e) {
      print('Error fetching batches: $e');
      Get.snackbar(
        'ত্রুটি',
        'ব্যাচ তালিকা লোড করতে সমস্যা হয়েছে',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      availableBatches.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh batches
  Future<void> refreshBatches() async {
    await fetchAvailableBatches();
  }

  // User verification method
  Future<void> verifyUser() async {
    if (selectedBatch.value.isEmpty || mobileController.text.isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'ব্যাচ এবং মোবাইল নম্বর দিন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    isUserFound.value = false;

    try {
      // Search in all batches
      final querySnapshot =
          await _firestore
              .collectionGroup('registrations')
              .where('mobile', isEqualTo: mobileController.text.trim())
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Check if user belongs to the specified batch
        for (var doc in querySnapshot.docs) {
          final batchId = doc.reference.parent.parent?.id;
          if (batchId == selectedBatch.value) {
            foundUserData.value = doc.data();
            foundUserData['id'] = doc.id;
            foundUserData['batchId'] = batchId;
            isUserFound.value = true;

            // Pre-fill donation form with user data
            donorNameController.text = foundUserData['name'] ?? '';
            donorPhoneController.text = foundUserData['mobile'] ?? '';
            donorEmailController.text = foundUserData['email'] ?? '';
            donorAddressController.text = foundUserData['presentAddress'] ?? '';

            Get.snackbar(
              'সফল',
              'ব্যবহারকারী পাওয়া গেছে',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            break;
          }
        }

        if (!isUserFound.value) {
          Get.snackbar(
            'ত্রুটি',
            'এই মোবাইল নম্বরটি উক্ত ব্যাচে পাওয়া যায়নি',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'ত্রুটি',
          'কোন নিবন্ধিত ব্যবহারকারী পাওয়া যায়নি',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'যাচাইকরণে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get next receipt number
  Future<int> getNextReceiptNumber() async {
    try {
      final querySnapshot = await _firestore.collection('donations').get();
      return querySnapshot.docs.length + 1;
    } catch (e) {
      print('Error getting next receipt number: $e');
      // Fallback to timestamp if there's an error
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  // Submit donation method
  Future<void> submitDonation() async {
    if (amountController.text.isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'অনুদানের পরিমাণ দিন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'ত্রুটি',
        'সঠিক অনুদানের পরিমাণ দিন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Get the next sequential receipt number
      final receiptNumber = await getNextReceiptNumber();

      final donationData = {
        'donorName': donorNameController.text.trim(),
        'donorPhone': donorPhoneController.text.trim(),
        'donorEmail': donorEmailController.text.trim(),
        'donorAddress': donorAddressController.text.trim(),
        'amount': amount,
        'donationType': selectedDonationType.value,
        'paymentMethod': selectedPaymentMethod.value,
        'purpose': purposeController.text.trim(),
        'notes': notesController.text.trim(),
        'isAnonymous': isAnonymous.value,
        'status': 'pending',
        'date': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'receiptNumber': receiptNumber,
      };

      // If user is verified, add user reference
      if (isUserFound.value && foundUserData.isNotEmpty) {
        donationData['userId'] = foundUserData['id'];
        donationData['userBatchId'] = foundUserData['batchId'];
        donationData['userName'] = foundUserData['name'];
        donationData['userMobile'] = foundUserData['mobile'];
      }

      await _firestore.collection('donations').add(donationData);

      Get.snackbar(
        'সফল',
        'আপনার অনুদান সফলভাবে জমা হয়েছে। ধন্যবাদ!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Generate PDF receipt
      await generateDonationReceipt(donationData);

      // Reset form
      resetForm();

      // Navigate back to home
      Get.until((route) => route.settings.name == '/');
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'অনুদান জমা দিতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Generate donation receipt PDF
  Future<void> generateDonationReceipt(
    Map<String, dynamic> donationData,
  ) async {
    try {
      final receiptData = {
        'donorName': donationData['donorName'],
        'donorPhone': donationData['donorPhone'],
        'donorEmail': donationData['donorEmail'],
        'donorAddress': donationData['donorAddress'],
        'amount': donationData['amount'],
        'donationType': donationData['donationType'],
        'paymentMethod': donationData['paymentMethod'],
        'purpose': donationData['purpose'],
        'notes': donationData['notes'],
        'date': donationData['date'],
        'receiptNumber': donationData['receiptNumber'].toString(),
        'donorPhotoUrl':
            isUserFound.value && foundUserData['photoUrl'] != null
                ? foundUserData['photoUrl']
                : null,
      };

      await PdfService.generateDonationReceiptPdf(receiptData);
    } catch (e) {
      print('Error generating donation receipt: $e');
      Get.snackbar(
        'সতর্কতা',
        'রসিদ তৈরি করতে সমস্যা হয়েছে, তবে অনুদান সফলভাবে জমা হয়েছে',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // Search donations by phone number
  Future<void> searchDonations() async {
    if (donorPhoneController.text.isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'মোবাইল নম্বর দিন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    donationsList.clear();

    try {
      final querySnapshot =
          await _firestore
              .collection('donations')
              .where('donorPhone', isEqualTo: donorPhoneController.text.trim())
              .orderBy('timestamp', descending: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          donationsList.add(data);
        }

        Get.snackbar(
          'সফল',
          '${donationsList.length}টি অনুদান পাওয়া গেছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'তথ্য',
          'এই মোবাইল নম্বরে কোন অনুদান পাওয়া যায়নি',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error searching donations: $e');
      Get.snackbar(
        'ত্রুটি',
        'অনুদান খুঁজতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form method
  void resetForm() {
    batchController.clear();
    mobileController.clear();
    donorNameController.clear();
    donorPhoneController.clear();
    donorEmailController.clear();
    donorAddressController.clear();
    amountController.clear();
    purposeController.clear();
    notesController.clear();
    selectedDonationType.value = 'সুবর্ণজয়ন্তী';
    selectedPaymentMethod.value = 'নগদ';
    isAnonymous.value = false;
    isUserFound.value = false;
    foundUserData.clear();
    selectedBatch.value = '';
    donationsList.clear();
  }

  @override
  void onClose() {
    batchController.dispose();
    mobileController.dispose();
    donorNameController.dispose();
    donorPhoneController.dispose();
    donorEmailController.dispose();
    donorAddressController.dispose();
    amountController.dispose();
    purposeController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
