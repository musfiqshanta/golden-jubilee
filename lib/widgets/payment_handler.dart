import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/sslcommerz_service.dart';

/// Professional Payment Handler Widget
/// Manages payment flow and callbacks for the application
class PaymentHandler extends StatefulWidget {
  final Widget child;

  const PaymentHandler({super.key, required this.child});

  @override
  State<PaymentHandler> createState() => _PaymentHandlerState();
}

class _PaymentHandlerState extends State<PaymentHandler> {
  @override
  void initState() {
    super.initState();

    // Set up payment message listener for web platform
    if (kIsWeb) {
      _setupPaymentMessageListener();
    }
  }

  /// Set up message listener for web payment callbacks
  void _setupPaymentMessageListener() {
    html.window.onMessage.listen(_handlePaymentMessage);
  }

  /// Handle payment messages from popup window
  void _handlePaymentMessage(html.MessageEvent event) {
    final data = event.data;
    if (data != null && data is Map) {
      final messageData = Map<String, dynamic>.from(data);

      switch (messageData['type']) {
        case 'PAYMENT_SUCCESS':
          _onPaymentSuccess(
            Map<String, dynamic>.from(messageData['data'] ?? {}),
          );
          break;
        case 'PAYMENT_FAILED':
          _onPaymentFailed(
            Map<String, dynamic>.from(messageData['data'] ?? {}),
          );
          break;
        case 'PAYMENT_CANCELLED':
          _onPaymentCancelled(
            Map<String, dynamic>.from(messageData['data'] ?? {}),
          );
          break;
      }
    }
  }

  /// Handle successful payment
  void _onPaymentSuccess(Map<String, dynamic> paymentData) {
    debugPrint('💚 Payment completed successfully!');
    debugPrint('Payment data: $paymentData');

    // Show success dialog
    SSLCommerzService.showPaymentSuccessDialog(context, paymentData);

    // TODO: Add your business logic here
    // Examples:
    // - Save transaction to database
    // - Update user account balance
    // - Send confirmation email
    // - Navigate to success page
    // - Refresh UI data
  }

  /// Handle failed payment
  void _onPaymentFailed(Map<String, dynamic> errorData) {
    debugPrint('❌ Payment failed!');
    debugPrint('Error data: $errorData');

    // Show failure dialog
    SSLCommerzService.showPaymentFailureDialog(context, errorData);

    // TODO: Add your business logic here
    // Examples:
    // - Log error for analytics
    // - Show retry option
    // - Navigate back to payment form
  }

  /// Handle cancelled payment
  void _onPaymentCancelled(Map<String, dynamic> cancelData) {
    debugPrint('⚠️ Payment cancelled!');
    debugPrint('Cancel data: $cancelData');

    // Show simple snackbar for cancellation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment was cancelled'),
        backgroundColor: Colors.orange,
      ),
    );

    // TODO: Add your business logic here
    // Examples:
    // - Log cancellation for analytics
    // - Show alternative payment options
    // - Navigate back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Helper methods for easy payment integration
class PaymentHelper {
  /// Launch a test payment (for development/testing)
  static Future<void> launchTestPayment(
    BuildContext context, {
    double amount = 100.0,
  }) async {
    final request = SSLCommerzService.createTestPayment(amount: amount);

    await SSLCommerzService.launchPayment(
      context: context,
      request: request,
      onSuccess: (data) {
        debugPrint('Test payment succeeded: $data');
        SSLCommerzService.showPaymentSuccessDialog(context, data);
      },
      onFailure: (data) {
        debugPrint('Test payment failed: $data');
        SSLCommerzService.showPaymentFailureDialog(context, data);
      },
      onCancel: (data) {
        debugPrint('Test payment cancelled: $data');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
      },
    );
  }

  /// Launch donation payment
  static Future<void> launchDonationPayment(
    BuildContext context, {
    required double amount,
    required String donorName,
    required String donorEmail,
    required String donorPhone,
    String? donorAddress,
  }) async {
    final request = PaymentRequest(
      transactionId: SSLCommerzService.generateTransactionId(),
      amount: amount,
      productName: 'সুবর্ণজয়ন্তী অনুদান - Golden Jubilee Donation',
      customerName: donorName,
      customerEmail: donorEmail,
      customerPhone: donorPhone,
      customerAddress: donorAddress ?? 'Bangladesh',
      customerCity: 'Dhaka',
      customerCountry: 'Bangladesh',
    );

    await SSLCommerzService.launchPayment(
      context: context,
      request: request,
      onSuccess: (data) {
        debugPrint('Donation payment succeeded: $data');
        SSLCommerzService.showPaymentSuccessDialog(context, data);
        // TODO: Save donation to database
      },
      onFailure: (data) {
        debugPrint('Donation payment failed: $data');
        SSLCommerzService.showPaymentFailureDialog(context, data);
      },
      onCancel: (data) {
        debugPrint('Donation payment cancelled: $data');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Donation cancelled')));
      },
    );
  }
}
