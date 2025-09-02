import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html show window;
import 'sslcommerz_config.dart';

/// Payment request model for better type safety
class PaymentRequest {
  final String transactionId;
  final double amount;
  final String productName;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String? customerCity;
  final String? customerState;
  final String? customerPostcode;
  final String? customerCountry;
  final Map<String, String>? additionalData;

  PaymentRequest({
    required this.transactionId,
    required this.amount,
    required this.productName,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    this.customerCity,
    this.customerState,
    this.customerPostcode,
    this.customerCountry,
    this.additionalData,
  });
}

/// Payment response model
class PaymentResponse {
  final bool isSuccess;
  final String? gatewayUrl;
  final String? sessionKey;
  final String? errorMessage;
  final Map<String, dynamic>? rawData;

  PaymentResponse({
    required this.isSuccess,
    this.gatewayUrl,
    this.sessionKey,
    this.errorMessage,
    this.rawData,
  });
}

/// Simple PaymentWebView widget for mobile platforms
class PaymentWebView extends StatelessWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: Center(
        child: Text(
          'Payment URL: $url\n\nPlease complete payment and return to app.',
        ),
      ),
    );
  }
}

/// Professional SSLCommerz Payment Service
/// Handles all payment operations, callbacks, and UI interactions
class SSLCommerzService {
  // ============================================================================
  // PAYMENT INITIATION
  // ============================================================================

  /// Initiate payment with comprehensive error handling and logging
  static Future<PaymentResponse> initiatePayment(PaymentRequest request) async {
    try {
      final url = SSLCommerzConfig.paymentInitiateUrl;

      debugPrint('🚀 Initiating SSLCommerz payment');
      debugPrint('   URL: $url');
      debugPrint('   Transaction ID: ${request.transactionId}');
      debugPrint('   Amount: ${request.amount} ${SSLCommerzConfig.currency}');
      debugPrint('   Using Proxy: ${SSLCommerzConfig.useProxy}');

      // Build comprehensive request data
      final requestData = _buildRequestData(request);

      debugPrint('📤 Sending request with ${requestData.length} parameters');
      debugPrint('📋 Request data: $requestData');

      final response = await _sendPaymentRequest(url, requestData);

      if (response.statusCode == 200) {
        return _handleSuccessResponse(response);
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return PaymentResponse(
          isSuccess: false,
          errorMessage: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          rawData: {'statusCode': response.statusCode, 'body': response.body},
        );
      }
    } catch (e) {
      debugPrint('❌ Payment initiation failed: $e');
      return PaymentResponse(
        isSuccess: false,
        errorMessage: 'Payment initiation failed: $e',
      );
    }
  }

  /// Build comprehensive request data for payment
  static Map<String, String> _buildRequestData(PaymentRequest request) {
    final data = <String, String>{
      // Store configuration
      ...SSLCommerzConfig.getStoreConfig(),

      // Transaction details
      'total_amount': request.amount.toString(),
      'tran_id': request.transactionId,

      // Customer information
      'cus_name': request.customerName,
      'cus_email': request.customerEmail,
      'cus_phone': request.customerPhone,
      'cus_fax': request.customerPhone,
      'cus_add1': request.customerAddress,
      'cus_add2': request.customerAddress,
      'cus_city': request.customerCity ?? SSLCommerzConfig.storeCity,
      'cus_state': request.customerState ?? SSLCommerzConfig.storeCity,
      'cus_postcode':
          request.customerPostcode ?? SSLCommerzConfig.storePostcode,
      'cus_country': request.customerCountry ?? SSLCommerzConfig.storeCountry,

      // Shipping information (required by SSLCommerz)
      'ship_name': request.customerName,
      'ship_add1': request.customerAddress,
      'ship_add2': request.customerAddress,
      'ship_city': request.customerCity ?? SSLCommerzConfig.storeCity,
      'ship_state': request.customerState ?? SSLCommerzConfig.storeCity,
      'ship_postcode':
          request.customerPostcode ?? SSLCommerzConfig.storePostcode,
      'ship_country': request.customerCountry ?? SSLCommerzConfig.storeCountry,

      // Product information
      'product_name': request.productName,
      'product_category': SSLCommerzConfig.productCategory,
      'product_profile': 'general',
      'num_of_item': '1',
      'product_amount': request.amount.toString(),

      // Payment configuration
      ...SSLCommerzConfig.getPaymentConfig(),

      // Additional tracking values
      'value_a': 'donation_${request.transactionId}',
      'value_b': request.customerPhone,
      'value_c': request.productName,
      'value_d': SSLCommerzConfig.storeName,

      // Environment flag
      'sandbox': SSLCommerzConfig.isSandbox.toString(),
    };

    // Add any additional data provided
    if (request.additionalData != null) {
      data.addAll(request.additionalData!);
    }

    return data;
  }

  /// Send HTTP request to SSLCommerz API
  static Future<http.Response> _sendPaymentRequest(
    String url,
    Map<String, String> requestData,
  ) async {
    // Always use form data format since SSLCommerz expects it
    final encodedData = requestData.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    debugPrint('📋 Encoded form data: $encodedData');

    return await http
        .post(
          Uri.parse(url),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: encodedData,
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Request timeout'),
        );
  }

  /// Handle successful API response
  static PaymentResponse _handleSuccessResponse(http.Response response) {
    try {
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      debugPrint('✅ SSLCommerz API Response received');
      debugPrint('   Status: ${responseData['status']}');
      debugPrint('   Full Response: $responseData');

      if (responseData['GatewayPageURL'] != null) {
        debugPrint('   Gateway URL: ${responseData['GatewayPageURL']}');
        debugPrint('   Session Key: ${responseData['sessionkey']}');

        // Log available payment methods
        _logPaymentMethods(responseData);

        return PaymentResponse(
          isSuccess: true,
          gatewayUrl: responseData['GatewayPageURL'],
          sessionKey: responseData['sessionkey'],
          rawData: responseData,
        );
      } else {
        final error = responseData['failedreason'] ?? 'Gateway URL not found';
        debugPrint('❌ Payment initiation failed: $error');

        return PaymentResponse(
          isSuccess: false,
          errorMessage: error,
          rawData: responseData,
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to parse response: $e');
      return PaymentResponse(
        isSuccess: false,
        errorMessage: 'Failed to parse response: $e',
        rawData: {'raw_response': response.body},
      );
    }
  }

  /// Log available payment methods for debugging
  static void _logPaymentMethods(Map<String, dynamic> responseData) {
    if (responseData['gw'] != null) {
      final gateways = responseData['gw'] as Map<String, dynamic>;
      debugPrint('💳 Available Payment Methods:');

      final methods = [
        'visa',
        'master',
        'amex',
        'mobilebanking',
        'internetbanking',
      ];
      for (final method in methods) {
        if (gateways[method] != null) {
          debugPrint('   - ${method.toUpperCase()}: ${gateways[method]}');
        }
      }
    }

    if (responseData['desc'] != null) {
      final paymentOptions = responseData['desc'] as List;
      debugPrint('🏦 Payment Options Available: ${paymentOptions.length}');
      for (var option in paymentOptions) {
        if (option is Map) {
          debugPrint('   - ${option['name']} (${option['type']})');
        }
      }
    }
  }

  // ============================================================================
  // PAYMENT FLOW MANAGEMENT
  // ============================================================================

  /// Launch payment flow with proper platform handling
  static Future<void> launchPayment({
    required BuildContext context,
    required PaymentRequest request,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onFailure,
    required Function(Map<String, dynamic>) onCancel,
  }) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Initiate payment
      final response = await initiatePayment(request);

      // Hide loading
      Navigator.of(context).pop();

      if (response.isSuccess && response.gatewayUrl != null) {
        if (kIsWeb) {
          // Web: Open in popup and listen for messages
          _launchWebPayment(
            context,
            response.gatewayUrl!,
            onSuccess,
            onFailure,
            onCancel,
          );
        } else {
          // Mobile: Use WebView
          _launchMobilePayment(context, response.gatewayUrl!);
        }
      } else {
        // Show error
        _showErrorDialog(
          context,
          response.errorMessage ?? 'Payment initiation failed',
        );
      }
    } catch (e) {
      // Hide loading if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      _showErrorDialog(context, 'Error: $e');
    }
  }

  /// Launch payment in web browser with message handling
  static void _launchWebPayment(
    BuildContext context,
    String paymentUrl,
    Function(Map<String, dynamic>) onSuccess,
    Function(Map<String, dynamic>) onFailure,
    Function(Map<String, dynamic>) onCancel,
  ) {
    // Set up message listener for web
    _setupWebMessageListener(context, onSuccess, onFailure, onCancel);

    // Open payment URL in new tab
    html.window.open(paymentUrl, '_blank');

    // Show info to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment opened in new tab. Complete the payment and return to this page.',
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// Launch payment in mobile WebView
  static void _launchMobilePayment(BuildContext context, String paymentUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentWebView(url: paymentUrl)),
    );
  }

  /// Show loading dialog during payment initiation
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Initiating payment...'),
              ],
            ),
          ),
    );
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  // ============================================================================
  // WEB MESSAGE HANDLING
  // ============================================================================

  /// Set up message listener for web payment callbacks
  static void _setupWebMessageListener(
    BuildContext context,
    Function(Map<String, dynamic>) onSuccess,
    Function(Map<String, dynamic>) onFailure,
    Function(Map<String, dynamic>) onCancel,
  ) {
    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        final data = event.data;
        if (data is Map) {
          final messageData = Map<String, dynamic>.from(data);

          switch (messageData['type']) {
            case 'PAYMENT_SUCCESS':
              onSuccess(Map<String, dynamic>.from(messageData['data'] ?? {}));
              break;
            case 'PAYMENT_FAILED':
              onFailure(Map<String, dynamic>.from(messageData['data'] ?? {}));
              break;
            case 'PAYMENT_CANCELLED':
              onCancel(Map<String, dynamic>.from(messageData['data'] ?? {}));
              break;
          }
        }
      });
    }
  }

  // ============================================================================
  // PAYMENT VALIDATION
  // ============================================================================

  /// Validate payment with SSLCommerz (for server-side verification)
  static Future<Map<String, dynamic>?> validatePayment({
    required String validationId,
    required String transactionId,
  }) async {
    try {
      final url = SSLCommerzConfig.paymentValidateUrl;

      final requestData = {
        ...SSLCommerzConfig.getStoreConfig(),
        'val_id': validationId,
        'tran_id': transactionId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestData.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
            )
            .join('&'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        debugPrint('✅ Payment validation response received');
        debugPrint('   Status: ${responseData['status']}');
        debugPrint('   Transaction ID: ${responseData['tran_id']}');

        return responseData;
      } else {
        debugPrint('❌ Validation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Payment validation error: $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Generate unique transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN_$timestamp';
  }

  /// Create test payment request for development
  static PaymentRequest createTestPayment({double amount = 100.0}) {
    return PaymentRequest(
      transactionId: generateTransactionId(),
      amount: amount,
      productName: 'Test Product - সুবর্ণজয়ন্তী অনুদান',
      customerName: 'Test Customer',
      customerEmail: 'test@example.com',
      customerPhone: '01711111111',
      customerAddress: 'Test Address, Dhaka',
      customerCity: 'Dhaka',
      customerCountry: 'Bangladesh',
    );
  }

  /// Create dynamic payment request from registration form data
  static PaymentRequest createRegistrationPayment({
    required Map<String, dynamic> registrationData,
    required double amount,
  }) {
    return PaymentRequest(
      transactionId: generateTransactionId(),
      amount: amount,
      productName: 'জাহাজমারা উচ্চ বিদ্যালয় সুবর্ণজয়ন্তী - রেজিস্ট্রেশন ফি',
      customerName: registrationData['name'] ?? 'Unknown',
      customerEmail: registrationData['email'] ?? 'noemail@example.com',
      customerPhone: registrationData['mobile'] ?? '01700000000',
      customerAddress:
          registrationData['presentAddress'] ??
          registrationData['permanentAddress'] ??
          'Address not provided',
      customerCity: 'নোয়াখালী',
      customerState: 'নোয়াখালী',
      customerPostcode: '3800',
      customerCountry: 'Bangladesh',
      additionalData: {
        'father_name': registrationData['fatherName'] ?? '',
        'mother_name': registrationData['motherName'] ?? '',
        'national_id': registrationData['nationalId'] ?? '',
        'occupation': registrationData['occupation'] ?? '',
        'designation': registrationData['designation'] ?? '',
        'final_class': registrationData['finalClass'] ?? '',
        'year': registrationData['year'] ?? '',
        'ssc_passing_year': registrationData['sscPassingYear'] ?? '',
        'gender': registrationData['gender'] ?? '',
        'blood_group': registrationData['bloodGroup'] ?? '',
        'religion': registrationData['religion'] ?? '',
        'nationality': registrationData['nationality'] ?? '',
        'spouse_count': registrationData['spouseCount']?.toString() ?? '0',
        'child_count': registrationData['childCount']?.toString() ?? '0',
        'parent_count': registrationData['parentCount']?.toString() ?? '0',
        'tshirt_size': registrationData['tshirtSize'] ?? '',
        'is_running_student':
            registrationData['isRunningStudent']?.toString() ?? 'false',
        'is_still_studying':
            registrationData['isStillStudying']?.toString() ?? 'false',
        'batch': registrationData['batch'] ?? '',
        'guest_names':
            (registrationData['guestNames'] as List?)?.join(', ') ?? '',
        'guest_relationships':
            (registrationData['guestRelationships'] as List?)?.join(', ') ?? '',
      },
    );
  }

  // ============================================================================
  // UI HELPER METHODS
  // ============================================================================

  /// Show payment success dialog with amazing Bengali design
  static void showPaymentSuccessDialog(
    BuildContext context,
    Map<String, dynamic> paymentData,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 20,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with celebration animation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Success icon with animation
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Success title in Bengali
                        const Text(
                          '🎉 পেমেন্ট সফল হয়েছে! 🎉',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        const Text(
                          'জাহাজমারা উচ্চ বিদ্যালয় সুবর্ণজয়ন্তী',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Payment details card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Amount display
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50).withOpacity(0.1),
                                const Color(0xFF2E7D32).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Color(0xFF4CAF50),
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'পেমেন্ট পরিমাণ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '৳ ${paymentData['amount'] ?? paymentData['store_amount'] ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'সফলভাবে পরিশোধিত',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment details
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: _buildBengaliPaymentDetails(paymentData),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text(
                              'ঠিক আছে',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF4CAF50),
                                  width: 2,
                                ),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Build Bengali payment details widget
  static Widget _buildBengaliPaymentDetails(Map<String, dynamic> paymentData) {
    final details = <MapEntry<String, String>>[];

    // Add payment details in Bengali
    final fields = [
      {'key': 'status', 'label': 'অবস্থা'},
      {'key': 'tran_id', 'label': 'লেনদেন আইডি'},
      {'key': 'val_id', 'label': 'যাচাইকরণ আইডি'},
      {'key': 'amount', 'label': 'পরিমাণ'},
      {'key': 'store_amount', 'label': 'দোকান পরিমাণ'},
      {'key': 'bank_tran_id', 'label': 'ব্যাংক লেনদেন আইডি'},
      {'key': 'card_type', 'label': 'কার্ডের ধরন'},
      {'key': 'card_brand', 'label': 'কার্ড ব্র্যান্ড'},
      {'key': 'currency', 'label': 'মুদ্রা'},
    ];

    for (final field in fields) {
      if (paymentData[field['key']] != null) {
        String value = paymentData[field['key']].toString();
        if (field['key'] == 'amount' || field['key'] == 'store_amount') {
          value += ' ৳';
        }
        details.add(MapEntry(field['label']!, value));
      }
    }

    return Column(
      children:
          details
              .map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  /// Show payment failure dialog with Bengali design
  static void showPaymentFailureDialog(
    BuildContext context,
    Map<String, dynamic> errorData,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 20,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE57373),
                    Color(0xFFD32F2F),
                    Color(0xFFB71C1C),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Error icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Color(0xFFD32F2F),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Error title in Bengali
                        const Text(
                          'পেমেন্ট ব্যর্থ হয়েছে',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Error details card
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD32F2F),
                          size: 40,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'দুঃখিত, পেমেন্ট সম্পন্ন করা যায়নি।',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'কারণ: ${errorData['error'] ?? errorData['failedreason'] ?? 'অজানা ত্রুটি'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        'আবার চেষ্টা করুন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFD32F2F),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFD32F2F),
                            width: 2,
                          ),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
