import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

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
          _onPaymentCancelled();
          break;
      }
    }
  }

  /// Handle successful payment
  void _onPaymentSuccess(Map<String, dynamic> paymentData) {
    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Handle failed payment
  void _onPaymentFailed(Map<String, dynamic> errorData) {
    if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${errorData['error'] ?? 'Unknown error'}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle cancelled payment
  void _onPaymentCancelled() {
    if (mounted) {
      // Show cancelled message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
