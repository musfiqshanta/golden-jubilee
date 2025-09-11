import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html; // Only used for Flutter Web

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSLCommerz Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;

  Future<void> makePaymentRequest() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://jubilee.jahajmarahighschool.com/api/index.php",
    );

    try {
      final formData = {
        "store_id": "teamx68b12058b6036",
        "store_passwd": "teamx68b12058b6036@ssl",
        "total_amount": "1000",
        "currency": "BDT",
        "tran_id": "REF123",
        "success_url":
            "https://jubilee.jahajmarahighschool.com/api/payment-success.php",
        "fail_url":
            "https://jubilee.jahajmarahighschool.com/api/payment-fail.php",
        "cancel_url":
            "https://jubilee.jahajmarahighschool.com/api/payment-cancel.php",
        'cus_name': "Md. Karim Ahmed",
        'cus_email': 'karim@example.com',
        'cus_add1': 'House-75, Road-8/A, Dhanmondi',
        'cus_city': "Dhaka",
        'cus_state': "Dhaka",
        'cus_postcode': '1209',
        'cus_country': 'Bangladesh',
        'cus_phone': '01711111111',
        // Shipping info
        'ship_name': "Md. Karim Ahmed",
        'ship_add1': 'House-715, Road-8/A, Dhanmondi',
        'ship_city': 'Dhaka',
        'ship_state': 'Dhaka',
        'ship_postcode': '1209',
        'ship_country': 'Bangladesh',
        // Product info
        'product_name': 'Test Product',
        'product_category': 'Electronic',
        'product_profile': 'general',
        'num_of_item': '1',
        'product_amount': '100',
        // Gateway options
        'multi_card_name': 'mastercard,visacard,amexcard',
        'shipping_method': 'YES',
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: formData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["GatewayPageURL"] != null) {
          String paymentUrl = data["GatewayPageURL"];
          if (!mounted) return;

          if (kIsWeb) {
            // For web → open payment in new tab and listen for success
            _openPaymentAndListen(paymentUrl);
          } else {
            // For mobile → open WebView
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentWebView(url: paymentUrl),
              ),
            );
          }
        } else {
          showSnack("Gateway URL not found!");
        }
      } else {
        showSnack("Request failed: ${response.statusCode}");
      }
    } catch (e) {
      showSnack("Error: $e");
    }

    setState(() => isLoading = false);
  }

  void _openPaymentAndListen(String paymentUrl) {
    // Open payment in new tab
    html.window.open(paymentUrl, '_blank');
    showSnack("Payment page opened in new tab");

    // Listen for payment completion messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      final data = messageEvent.data;

      // Debug logging
      print('🔔 Received message: $data');
      print('🔔 Message type: ${data is Map ? data['type'] : 'Not a map'}');

      if (data is Map && data['type'] != null) {
        print('✅ Processing message type: ${data['type']}');
        switch (data['type']) {
          case 'PAYMENT_SUCCESS':
            print('🎉 Showing success dialog');
            _showPaymentSuccessDialog(data['data']);
            break;
          case 'PAYMENT_FAILED':
            print('❌ Showing failed dialog');
            _showPaymentFailedDialog(data['data']);
            break;
          case 'PAYMENT_CANCELLED':
            print('⚠️ Showing cancelled dialog');
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
      if (mounted) {
        showSnack("Check the payment tab for completion status");
      }
    });

    // Alternative: Poll for payment completion (fallback method)
    _startPaymentStatusPolling();
  }

  void _startPaymentStatusPolling() {
    print('🚀 Starting payment status polling...');

    // Poll every 2 seconds to check for payment completion
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        print('❌ Widget not mounted, stopping polling');
        timer.cancel();
        return;
      }

      print('🔄 Polling for payment status... (attempt ${timer.tick})');

      // Check with server for payment status
      _checkPaymentStatus(timer);

      // Cancel after 10 minutes (300 attempts * 2 seconds = 10 minutes)
      if (timer.tick > 300) {
        timer.cancel();
        print('⏰ Payment polling timeout after 10 minutes');
        if (mounted) {
          showSnack(
            "Payment check timeout. Please verify payment status manually.",
          );
        }
      }
    });
  }

  Future<void> _checkPaymentStatus(Timer timer) async {
    try {
      // Check if there are any recent successful payments
      // This is a simple approach - in production you'd check with your specific transaction ID
      final response = await http.get(
        Uri.parse(
          'https://jubilee.jahajmarahighschool.com/api/payment-status.php?tran_id=REF123',
        ),
      );

      print('💬 Payment status check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Payment status data: $data');

        if (data['status'] == 'COMPLETED') {
          print('🎉 Payment completed! Showing success dialog');
          timer.cancel();
          _showPaymentSuccessDialog(data['payment_data']);
        }
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
    }
  }

  void _testSuccessDialog() {
    // Test method to manually trigger success dialog
    final testData = {
      'tran_id': 'TEST123',
      'amount': '1000.00',
      'currency': 'BDT',
      'card_type': 'TEST-Payment',
      'status': 'VALID',
      'bank_tran_id': 'TEST_BANK_123',
    };
    _showPaymentSuccessDialog(testData);
  }

  void _showPaymentSuccessDialog(Map<String, dynamic>? paymentData) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
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
                _buildPaymentDetail(
                  'Payment Method:',
                  paymentData['card_type'],
                ),
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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentFailedDialog(Map<String, dynamic>? paymentData) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Navigator.of(context).pop();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentCancelledDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SSLCommerz Payment")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: makePaymentRequest,
                    child: const Text("Test Payment"),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _testSuccessDialog,
                    child: const Text("Test Success Dialog"),
                  ),
                ],
              ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint("Page loaded: $url");

            if (url.contains("success.php")) {
              Navigator.pop(context); // Close WebView
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Payment Successful"),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (url.contains("fail.php")) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("❌ Payment Failed"),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (url.contains("cancel.php")) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("⚠️ Payment Cancelled"),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
