import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html;

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

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Listen for payment completion messages from popup window
      html.window.onMessage.listen(_handlePaymentMessage);
    }
  }

  void _handlePaymentMessage(html.MessageEvent event) {
    final data = event.data;
    if (data != null) {
      // Convert to Map if it's a JavaScript object
      Map<String, dynamic> messageData;
      if (data is Map) {
        messageData = Map<String, dynamic>.from(data);
      } else {
        return; // Skip if not a valid message
      }

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

  void _onPaymentSuccess(Map<String, dynamic> paymentData) {
    print('Payment completed successfully!');
    print('Payment data: $paymentData');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Payment Successful!'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.payment,
                          color: Colors.green,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'BDT ${paymentData['amount'] ?? paymentData['store_amount'] ?? '0'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Payment Completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [_buildPaymentDetailsList(paymentData)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
    );

    // TODO: Update your app state, save transaction, etc.
    // Example:
    // await saveTransaction(paymentData);
    // navigateToSuccessPage();
  }

  Widget _buildPaymentDetailsList(Map<String, dynamic> paymentData) {
    final details = <MapEntry<String, String>>[];

    // Add payment details in a structured way
    if (paymentData['status'] != null) {
      details.add(MapEntry('Status', paymentData['status'].toString()));
    }
    if (paymentData['tran_id'] != null) {
      details.add(
        MapEntry('Transaction ID', paymentData['tran_id'].toString()),
      );
    }
    if (paymentData['val_id'] != null) {
      details.add(MapEntry('Validation ID', paymentData['val_id'].toString()));
    }
    if (paymentData['amount'] != null) {
      details.add(MapEntry('Amount', '${paymentData['amount']} BDT'));
    }
    if (paymentData['store_amount'] != null) {
      details.add(
        MapEntry('Store Amount', '${paymentData['store_amount']} BDT'),
      );
    }
    if (paymentData['bank_tran_id'] != null) {
      details.add(
        MapEntry('Bank Transaction ID', paymentData['bank_tran_id'].toString()),
      );
    }
    if (paymentData['card_type'] != null) {
      details.add(MapEntry('Card Type', paymentData['card_type'].toString()));
    }
    if (paymentData['card_brand'] != null) {
      details.add(MapEntry('Card Brand', paymentData['card_brand'].toString()));
    }
    if (paymentData['card_sub_brand'] != null) {
      details.add(
        MapEntry('Card Sub Brand', paymentData['card_sub_brand'].toString()),
      );
    }
    if (paymentData['card_issuer'] != null) {
      details.add(
        MapEntry('Card Issuer', paymentData['card_issuer'].toString()),
      );
    }
    if (paymentData['currency'] != null) {
      details.add(MapEntry('Currency', paymentData['currency'].toString()));
    }

    // Add any other fields that might be present
    paymentData.forEach((key, value) {
      if (value != null &&
          !details.any(
            (entry) => entry.key.toLowerCase().replaceAll(' ', '_') == key,
          )) {
        details.add(
          MapEntry(
            key
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                  (word) =>
                      word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '',
                )
                .join(' '),
            value.toString(),
          ),
        );
      }
    });

    return Card(
      elevation: 2,
      child: Column(
        children:
            details
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.black54),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  void _onPaymentFailed(Map<String, dynamic> errorData) {
    print('Payment failed!');
    print('Error data: $errorData');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('❌ Payment Failed'),
            content: Text(
              'Payment could not be completed.\nReason: ${errorData['error'] ?? 'Unknown error'}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _onPaymentCancelled(Map<String, dynamic> cancelData) {
    print('Payment cancelled!');
    print('Cancel data: $cancelData');

    showSnack('Payment was cancelled');
  }

  Future<void> makePaymentRequest() async {
    setState(() => isLoading = true);

    final url = Uri.parse("http://localhost:3001/api/sslcommerz/initiate");
    // var url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
    //   'q': '{http}',
    // });

    try {
      // Prepare form data as URL encoded string
      final formData = {
        "store_id": "teamx68b12058b6036",
        "store_passwd": "teamx68b12058b6036@ssl",
        "total_amount": "100",
        "currency": "BDT",
        "tran_id": "REF123",
        "success_url": "http://localhost:3001/payment/success",
        "fail_url": "http://localhost:3001/payment/fail",
        "cancel_url": "http://localhost:3001/payment/cancel",
        // Customer information (required)
        'cus_name': "Md. Karim Ahmed",
        'cus_email': 'karim@example.com',
        'cus_add1': 'House-75, Road-8/A, Dhanmondi',
        'cus_add2': 'Dhaka',
        'cus_city': "Dhaka",
        'cus_state': "Dhaka",
        'cus_postcode': '1209',
        'cus_country': 'Bangladesh',
        'cus_phone': '01711111111',
        'cus_fax': '01711111111',

        // Shipping information (required)
        'ship_name': "Md. Karim Ahmed",
        'ship_add1': 'House-715, Road-8/A, Dhanmondi',
        'ship_add2': 'House-75, Road-8/A, Dhanmondi',
        'ship_city': 'Dhaka',
        'ship_state': 'Dhaka',
        'ship_postcode': '1209',
        'ship_country': 'Bangladesh',

        // Product information (required)
        'product_name': 'Test Product',
        'product_category': 'Electronic',
        'product_profile': 'general',
        'num_of_item': '1',
        'product_amount': '100',

        // Payment gateway options
        'multi_card_name': 'mastercard,visacard,amexcard',
        'shipping_method': 'YES',
      };

      // Convert to URL encoded string
      final encodedData = formData.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      print('Sending data: $encodedData');
      print('URL: $url');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: encodedData,
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["GatewayPageURL"] != null) {
          String paymentUrl = data["GatewayPageURL"];
          if (!mounted) return;

          if (kIsWeb) {
            // For web, open payment URL in a new tab
            html.window.open(paymentUrl, '_blank');
            showSnack("Payment opened in new tab");
          } else {
            // For mobile, use WebView
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
        child:
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: makePaymentRequest,
                  child: const Text("Test Payment"),
                ),
      ),
    );
  }
}

class PaymentWebView extends StatelessWidget {
  final String url;
  const PaymentWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: WebViewWidget(
        controller:
            WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
