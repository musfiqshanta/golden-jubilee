import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:suborno_joyonti/app/modules/donation/controllers/donation_controller.dart';

void main() {
  group('Donation Controller Dropdown Tests', () {
    late DonationController controller;

    setUp(() {
      controller = DonationController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with correct default values', () {
      expect(controller.selectedDonationType.value, 'সাধারণ অনুদান');
      expect(controller.selectedPaymentMethod.value, 'নগদ');
      expect(controller.selectedBatch.value, '');
    });

    test('should have correct donation types', () {
      expect(controller.donationTypes, contains('সাধারণ অনুদান'));
      expect(controller.donationTypes, contains('নির্মাণ কাজ'));
      expect(controller.donationTypes, contains('শিক্ষা উপকরণ'));
      expect(controller.donationTypes, contains('খেলাধুলার সরঞ্জাম'));
      expect(controller.donationTypes, contains('অন্যান্য'));
    });

    test('should have correct payment methods', () {
      expect(controller.paymentMethods, contains('নগদ'));
      expect(controller.paymentMethods, contains('মোবাইল ব্যাংকিং'));
      expect(controller.paymentMethods, contains('ব্যাংক ট্রান্সফার'));
      expect(controller.paymentMethods, contains('চেক'));
    });

    test('should update selected donation type', () {
      controller.selectedDonationType.value = 'নির্মাণ কাজ';
      expect(controller.selectedDonationType.value, 'নির্মাণ কাজ');
    });

    test('should update selected payment method', () {
      controller.selectedPaymentMethod.value = 'মোবাইল ব্যাংকিং';
      expect(controller.selectedPaymentMethod.value, 'মোবাইল ব্যাংকিং');
    });

    test('should update selected batch', () {
      controller.selectedBatch.value = '2020';
      expect(controller.selectedBatch.value, '2020');
    });
  });
}
