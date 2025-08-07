import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/donation_controller.dart';

class VerifyUserPage extends StatelessWidget {
  const VerifyUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DonationController>();

    // Fetch batches when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAvailableBatches();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ব্যবহারকারী যাচাই করুন',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_search,
                    size: 50,
                    color: const Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'নিবন্ধিত সদস্য যাচাইকরণ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'আপনার নিবন্ধন তথ্য দিয়ে যাচাই করুন',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Batch Dropdown with Refresh Button
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => DropdownButtonFormField<String>(
                                value:
                                    controller.selectedBatch.value.isEmpty
                                        ? null
                                        : controller.selectedBatch.value,
                                decoration: InputDecoration(
                                  labelText: 'ব্যাচ / শ্রেণি নির্বাচন করুন',
                                  prefixIcon: const Icon(Icons.school),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD4AF37),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items:
                                    controller.availableBatches.isEmpty
                                        ? [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('লোড হচ্ছে...'),
                                          ),
                                        ]
                                        : controller.availableBatches.map((
                                          String batch,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: batch,
                                            child: Text(batch),
                                          );
                                        }).toList(),
                                onChanged:
                                    controller.availableBatches.isEmpty
                                        ? null
                                        : (String? newValue) {
                                          if (newValue != null) {
                                            controller.selectedBatch.value =
                                                newValue;
                                          }
                                        },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ব্যাচ নির্বাচন করুন';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => IconButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : () => controller.refreshBatches(),
                              icon:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFD4AF37),
                                              ),
                                        ),
                                      )
                                      : const Icon(Icons.refresh),
                              tooltip: 'ব্যাচ তালিকা রিফ্রেশ করুন',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mobile Field
                      TextFormField(
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'মোবাইল নম্বর',
                          hintText: '01XXXXXXXXX',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD4AF37),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // User Found Display
                      Obx(
                        () =>
                            controller.isUserFound.value
                                ? Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green[700],
                                            size: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'ব্যবহারকারী পাওয়া গেছে!',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      // User Photo
                                      if (controller
                                              .foundUserData['photoUrl'] !=
                                          null)
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            border: Border.all(
                                              color: Color(0xFFD4AF37),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              48,
                                            ),
                                            child: Image.network(
                                              controller
                                                  .foundUserData['photoUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'নাম: ${controller.foundUserData['name'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'মোবাইল: ${controller.foundUserData['mobile'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      ElevatedButton(
                                        onPressed:
                                            () => Get.toNamed('/donation/form'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'অনুদানের ফরমে যান',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // Verify Button
                      Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () => controller.verifyUser(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              controller.isLoading.value
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('যাচাই করা হচ্ছে...'),
                                    ],
                                  )
                                  : const Text(
                                    'যাচাই করুন',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Help Text
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'সাহায্য',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• ব্যাচ: ড্রপডাউন থেকে আপনার ব্যাচ/শ্রেণি নির্বাচন করুন\n'
                              '• মোবাইল: নিবন্ধনে ব্যবহৃত মোবাইল নম্বর\n'
                              '• যাচাইকরণ সফল হলে অনুদানের ফরমে নিয়ে যাওয়া হবে',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
