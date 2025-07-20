import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../services/payment_service.dart';
import 'package:get/get.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      drawer: const AdminDrawer(selectedRoute: '/admin/payments'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: PaymentService().fetchAllPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final payments = snapshot.data ?? [];
          if (payments.isEmpty) {
            return const Center(child: Text('No payments found.'));
          }
          return ListView.separated(
            itemCount: payments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return ListTile(
                leading: const Icon(Icons.payment),
                title: Text(
                  payment['payer'] ??
                      payment['userId'] ??
                      payment['id'] ??
                      'Unknown',
                ),
                subtitle: Text('Amount: ${payment['amount'] ?? 'N/A'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(label: Text(payment['status'] ?? 'pending')),
                    if (payment['status'] == 'pending') ...[
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Approve',
                        onPressed: () async {
                          await PaymentService().updatePaymentStatus(
                            payment['id'],
                            'approved',
                          );
                          Get.snackbar(
                            'Payment Approved',
                            'Payment has been approved.',
                          );
                          (context as Element).reassemble();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Reject',
                        onPressed: () async {
                          await PaymentService().updatePaymentStatus(
                            payment['id'],
                            'rejected',
                          );
                          Get.snackbar(
                            'Payment Rejected',
                            'Payment has been rejected.',
                          );
                          (context as Element).reassemble();
                        },
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => PaymentDetailsDialog(payment: payment),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PaymentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> payment;
  const PaymentDetailsDialog({required this.payment, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment Details'),
      content: SizedBox(
        width: 350,
        child: ListView(
          shrinkWrap: true,
          children:
              payment.entries
                  .map(
                    (entry) => ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.toString()),
                    ),
                  )
                  .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
