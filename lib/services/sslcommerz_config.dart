import 'dart:convert';
import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:suborno_joyonti/app/modules/registration/controllers/registration_controller.dart';

import '../services/env_service.dart';

/// Professional SSLCommerz Configuration
/// Handles all SSLCommerz payment gateway configuration and settings
class SSLCommerzConfig extends GetxController {
  // ============================================================================
  // REACTIVE VARIABLES
  // ============================================================================

  /// Loading state
  var isLoading = false.obs;

  /// Payment status
  var paymentStatus = ''.obs;

  /// Transaction ID
  var transactionId = ''.obs;

  /// Payment URL
  var paymentUrl = ''.obs;

  /// Timer for polling
  Timer? _pollingTimer;

  // ============================================================================
  // STATIC CONFIGURATION
  // ============================================================================

  /// SSLCommerz Store ID (Dynamic: Sandbox or Production based on config.env)
  static String get storeId => EnvService.sslcommerzStoreId;

  /// SSLCommerz Store Password (Dynamic: Sandbox or Production based on config.env)
  static String get storePassword => EnvService.sslcommerzStorePassword;

  /// Environment flag - false for production, true for sandbox
  static bool get isSandbox => EnvService.sslcommerzIsSandbox;

  /// Currency code for transactions
  static const String currency = "BDT";

  // ============================================================================
  // API ENDPOINTS CONFIGURATION
  // ============================================================================

  /// Get SSL Commerz API endpoint based on environment
  static String get apiEndpoint {
    if (isSandbox) {
      return "https://sandbox.sslcommerz.com/gwprocess/v4/api.php";
    } else {
      return "https://securepay.sslcommerz.com/gwprocess/v4/api.php";
    }
  }

  /// Your custom proxy API endpoint (current setup)
  static String get proxyApiEndpoint {
    return "https://jubilee.jahajmarahighschool.com/api/ssl/index.php";
  }

  /// Use proxy API (true) or direct SSL Commerz API (false)
  static bool get useProxyApi =>
      true; // Set to false to use direct SSL Commerz API

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================

  /// Make payment request to SSLCommerz
  Future<void> makePaymentRequest({
    required String amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
    String? customerCity,
    String? customerState,
    String? customerPostcode,
    String? customerCountry,
    String? productName,
    String? productCategory,
  }) async {
    try {
      isLoading.value = true;
      paymentStatus.value = 'processing';

      final url = Uri.parse(useProxyApi ? proxyApiEndpoint : apiEndpoint);

      // Generate unique transaction ID
      final tranId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      transactionId.value = tranId;

      final formData = {
        "store_id": storeId,
        "store_passwd": storePassword,
        "total_amount": amount,
        "currency": currency,
        "tran_id": tranId,
        "success_url":
            "https://jubilee.jahajmarahighschool.com/api/ssl/payment-success.php",
        "fail_url":
            "https://jubilee.jahajmarahighschool.com/api/ssl/payment-fail.php",
        "cancel_url":
            "https://jubilee.jahajmarahighschool.com/api/ssl/payment-cancel.php",
        // Customer info
        'cus_name': customerName,
        'cus_email': customerEmail,
        'cus_add1': customerAddress,
        'cus_add2': customerCity ?? "Dhaka", // Additional address line
        'cus_city': customerCity ?? "Dhaka",
        'cus_state': customerState ?? "Dhaka",
        'cus_postcode': customerPostcode ?? '1209',
        'cus_country': customerCountry ?? 'Bangladesh',
        'cus_phone': customerPhone,
        'cus_fax': customerPhone, // Using phone as fax (required field)
        // Shipping info
        'ship_name': customerName,
        'ship_add1': customerAddress,
        'ship_add2':
            customerCity ?? "Dhaka", // Additional shipping address line
        'ship_city': customerCity ?? 'Dhaka',
        'ship_state': customerState ?? 'Dhaka',
        'ship_postcode': customerPostcode ?? '1209',
        'ship_country': customerCountry ?? 'Bangladesh',
        // Product info
        'product_name': productName ?? 'Payment',
        'product_category': productCategory ?? 'Service',
        'product_profile': 'general',
        'num_of_item': '1',
        'product_amount': amount,
        // Gateway options - All payment methods (based on SSL Commerz documentation)
        'multi_card_name':
            'mastercard,visacard,amexcard,mobilebank&internetbank',

        // 'multi_card_name':
        //     'mobilebank,internetbank,mastercard,visacard,amexcard,',
        'shipping_method': 'NO',
        // Optional value parameters for tracking
        'value_a': tranId, // Transaction reference
        'value_b': customerEmail, // Customer email reference
        'value_c': productName ?? 'Payment', // Product reference
        'value_d': DateTime.now().toIso8601String(), // Timestamp reference
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["GatewayPageURL"] != null) {
          paymentUrl.value = data["GatewayPageURL"];

          if (kIsWeb) {
            // For web → open payment in new tab and listen for success
            _openPaymentAndListen(paymentUrl.value);
          } else {
            // For mobile → navigate to WebView
            _navigateToPaymentWebView(paymentUrl.value);
          }
        } else {
          _showError("Gateway URL not found!");
          paymentStatus.value = 'failed';
        }
      } else {
        _showError("Request failed: ${response.statusCode}");
        paymentStatus.value = 'failed';
      }
    } catch (e) {
      _showError("Error: $e");
      paymentStatus.value = 'failed';
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to payment WebView (for mobile)
  void _navigateToPaymentWebView(String url) {
    // This should be handled in the UI layer
    Get.snackbar(
      'Payment',
      'Opening payment page...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    // The UI layer should handle navigation to WebView
  }

  final registrationController = Get.put(RegistrationController());

  /// Open payment in new tab and listen for completion (for web)
  void _openPaymentAndListen(String paymentUrl) {
    // Open payment in new tab
    html.window.open(paymentUrl, '_blank');
    _showSuccess("Payment page opened in new tab");

    // Listen for payment completion messages
    html.window.addEventListener('message', (event) async {
      final messageEvent = event as html.MessageEvent;
      final data = messageEvent.data;

      // Debug logging
      print('🔔 Received message: $data');
      print('🔔 Message type: ${data is Map ? data['type'] : 'Not a map'}');

      if (data is Map && data['type'] != null) {
        print('✅ Processing message type: ${data['type']}');
        switch (data['type']) {
          case 'PAYMENT_SUCCESS':
            print('🎉 Payment successful');
            //   paymentStatus.value = 'success';
            // await _handlePaymentSuccess(data['data'] ?? {});
            // _showPaymentSuccessDialog(data['data']);
            break;
          case 'PAYMENT_FAILED':
            print('❌ Payment failed');
            paymentStatus.value = 'failed';
            _showPaymentFailedDialog(data['data']);
            break;
          case 'PAYMENT_CANCELLED':
            print('⚠️ Payment cancelled');
            paymentStatus.value = 'cancelled';
            _showPaymentCancelledDialog();
            break;
          default:
            print('❓ Unknown message type: ${data['type']}');
        }
      } else {
        print('❌ Message data is not valid: $data');
      }
    });

    // Also show success dialog after a delay as fallback
    Future.delayed(const Duration(seconds: 3), () {
      _showInfo("Check the payment tab for completion status");
    });

    // Alternative: Poll for payment completion (fallback method)
    _startPaymentStatusPolling();
  }

  /// Start polling for payment status
  void _startPaymentStatusPolling() {
    print('🚀 Starting payment status polling...');

    // Cancel any existing timer
    _pollingTimer?.cancel();

    // Poll every 2 seconds to check for payment completion
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      print('🔄 Polling for payment status... (attempt ${timer.tick})');

      // Check with server for payment status
      _checkPaymentStatus(timer);

      // Cancel after 10 minutes (300 attempts * 2 seconds = 10 minutes)
      if (timer.tick > 300) {
        timer.cancel();
        print('⏰ Payment polling timeout after 10 minutes');
        _showInfo(
          "Payment check timeout. Please verify payment status manually.",
        );
      }
    });
  }

  /// Check payment status with server
  Future<void> _checkPaymentStatus(Timer timer) async {
    try {
      // Check if there are any recent successful payments
      // This is a simple approach - in production you'd check with your specific transaction ID
      final response = await http.get(
        Uri.parse(
          'https://jubilee.jahajmarahighschool.com/api/ssl/payment-status.php?tran_id=${transactionId.value}',
        ),
      );

      print('💬 Payment status check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Payment status data: $data');

        if (data['status'] == 'COMPLETED') {
          print('🎉 Payment completed! Showing success dialog');
          timer.cancel();
          paymentStatus.value = 'success';
          await _handlePaymentSuccess(data['payment_data'] ?? {});
          //_showPaymentSuccessDialog(data['payment_data']);
        }
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
    }
  }

  // ============================================================================
  // PAYMENT SUCCESS HANDLER
  // ============================================================================

  /// Handle payment success - works for both new registrations and existing payments
  Future<void> _handlePaymentSuccess(Map<String, dynamic> paymentData) async {
    try {
      // Try to find registration controller (for new registrations)
      try {
        final registrationController = Get.find<RegistrationController>();
        await registrationController.saveRegistrationWithPayment(
          paymentData,
          isQuickRegistration: registrationController.isQuickRegistration.value,
        );
        print('✅ New registration with payment saved successfully');
        return;
      } catch (e) {
        print(
          'ℹ️ Registration controller not found - this might be an existing registration payment',
        );
      }

      // For existing registration payments, the check registration page
      // will handle the success via the paymentStatus observable
      print('✅ Payment successful - notifying listeners via paymentStatus');
    } catch (e) {
      print('❌ Error in payment success handler: $e');
      _showError('পেমেন্ট প্রক্রিয়াকরণে সমস্যা হয়েছে');
    }
  }

  // ============================================================================
  // DIALOG METHODS
  // ============================================================================

  /// Show payment success dialog
  void _showPaymentSuccessDialogs(Map<String, dynamic>? paymentData) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your payment has been processed successfully.'),
            const SizedBox(height: 16),
            if (paymentData != null) ...[
              _buildPaymentDetail('Transaction ID:', paymentData['tran_id']),
              _buildPaymentDetail(
                'Amount:',
                '${paymentData['amount']} ${paymentData['currency']}',
              ),
              _buildPaymentDetail('Payment Method:', paymentData['card_type']),
              _buildPaymentDetail('Status:', paymentData['status']),
              if (paymentData['bank_tran_id'] != null)
                _buildPaymentDetail(
                  'Bank Transaction ID:',
                  paymentData['bank_tran_id'],
                ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show payment failed dialog
  void _showPaymentFailedDialog(Map<String, dynamic>? paymentData) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Payment Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unfortunately, your payment could not be processed.'),
            const SizedBox(height: 16),
            if (paymentData != null && paymentData['error'] != null)
              Text('Reason: ${paymentData['error']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Show payment cancelled dialog
  void _showPaymentCancelledDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('Payment Cancelled'),
          ],
        ),
        content: const Text('You have cancelled the payment process.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Build payment detail widget
  Widget _buildPaymentDetail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show info message
  void _showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Test success dialog (for testing purposes)
  void testSuccessDialog() {
    final testData = {
      'tran_id': 'TEST123',
      'amount': '1000.00',
      'currency': 'BDT',
      'card_type': 'TEST-Payment',
      'status': 'VALID',
      'bank_tran_id': 'TEST_BANK_123',
    };
    //_showPaymentSuccessDialog(testData);
  }

  /// Reset payment state
  void resetPaymentState() {
    isLoading.value = false;
    paymentStatus.value = '';
    transactionId.value = '';
    paymentUrl.value = '';
    _pollingTimer?.cancel();
  }

  /// Get current environment configuration for verification
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'storeId': storeId,
      'isSandbox': isSandbox,
      'isProduction': !isSandbox,
      'currency': currency,
      'environmentStatus': isSandbox ? 'SANDBOX/TEST' : 'PRODUCTION/LIVE',
    };
  }

  /// Print environment configuration (for debugging)
  static void printEnvironmentInfo() {
    final info = getEnvironmentInfo();
    print('🔧 SSL Commerz Configuration:');
    print('   Environment: ${info['environmentStatus']}');
    print('   Store ID: ${info['storeId']}');
    print('   Is Sandbox: ${info['isSandbox']}');
    print('   Currency: ${info['currency']}');
  }
}
