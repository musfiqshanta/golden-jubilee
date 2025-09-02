import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/donation_controller.dart';

class DonationFormPage extends StatelessWidget {
  const DonationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DonationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('দানের ফরম', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                )
                : SingleChildScrollView(
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
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 50,
                              color: const Color(0xFFD4AF37),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'অনুদানের তথ্য দিন',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD4AF37),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'আপনার অনুদানের তথ্য সঠিকভাবে পূরণ করুন',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Form
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Donor Name
                              Obx(
                                () => TextFormField(
                                  controller: controller.donorNameController,
                                  enabled: !controller.isUserFound.value,
                                  decoration: InputDecoration(
                                    labelText: 'দাতার নাম *',
                                    hintText: 'আপনার নাম লিখুন',
                                    prefixIcon: const Icon(Icons.person),
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
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1,
                                      ),
                                    ),
                                    filled:
                                        !controller.isUserFound.value
                                            ? false
                                            : true,
                                    fillColor:
                                        !controller.isUserFound.value
                                            ? null
                                            : Colors.grey[100],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Phone
                              Obx(
                                () => TextFormField(
                                  controller: controller.donorPhoneController,
                                  keyboardType: TextInputType.phone,
                                  enabled: !controller.isUserFound.value,
                                  decoration: InputDecoration(
                                    labelText: 'মোবাইল নম্বর *',
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
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[400]!,
                                        width: 1,
                                      ),
                                    ),
                                    filled:
                                        !controller.isUserFound.value
                                            ? false
                                            : true,
                                    fillColor:
                                        !controller.isUserFound.value
                                            ? null
                                            : Colors.grey[100],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email
                              TextFormField(
                                controller: controller.donorEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'ইমেইল (ঐচ্ছিক)',
                                  hintText: 'example@email.com',
                                  prefixIcon: const Icon(Icons.email),
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
                              const SizedBox(height: 20),

                              // Address
                              TextFormField(
                                controller: controller.donorAddressController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'ঠিকানা (ঐচ্ছিক)',
                                  hintText: 'বাংলায় সম্পূর্ণ ঠিকানা লিখুন',
                                  prefixIcon: const Icon(Icons.location_on),
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
                              const SizedBox(height: 20),

                              // Amount
                              TextFormField(
                                controller: controller.amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'অনুদানের পরিমাণ (টাকা) *',
                                  prefixIcon: const Icon(Icons.attach_money),
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
                              const SizedBox(height: 20),

                              // Donation Type
                              DropdownButtonFormField<String>(
                                value: controller.selectedDonationType.value,
                                decoration: InputDecoration(
                                  labelText: 'অনুদানের ধরন',
                                  prefixIcon: const Icon(Icons.category),
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
                                    controller.donationTypes.map((String type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedDonationType.value =
                                        newValue;
                                  }
                                },
                              ),
                              const SizedBox(height: 20),

                              // Payment Method
                              DropdownButtonFormField<String>(
                                value: controller.selectedPaymentMethod.value,
                                decoration: InputDecoration(
                                  labelText: 'পেমেন্ট পদ্ধতি',
                                  prefixIcon: const Icon(Icons.payment),
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
                                    controller.paymentMethods.map((
                                      String method,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: method,
                                        child: Row(
                                          children: [
                                            Icon(
                                              method ==
                                                      'অনলাইন পেমেন্ট (SSLCommerz)'
                                                  ? Icons.credit_card
                                                  : method == 'নগদ'
                                                  ? Icons.money
                                                  : method == 'মোবাইল ব্যাংকিং'
                                                  ? Icons.phone_android
                                                  : method ==
                                                      'ব্যাংক ট্রান্সফার'
                                                  ? Icons.account_balance
                                                  : Icons.receipt_long,
                                              size: 20,
                                              color:
                                                  method ==
                                                          'অনলাইন পেমেন্ট (SSLCommerz)'
                                                      ? Colors.green
                                                      : const Color(0xFFD4AF37),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(method)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedPaymentMethod.value =
                                        newValue;
                                  }
                                },
                              ),

                              // Online Payment Information Card
                              Obx(() {
                                if (controller.selectedPaymentMethod.value ==
                                    'অনলাইন পেমেন্ট (SSLCommerz)') {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.green[700],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'অনলাইন পেমেন্ট তথ্য',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '• ভিসা, মাস্টারকার্ড, আমেরিকান এক্সপ্রেস কার্ড গ্রহণযোগ্য\n'
                                          '• বিকাশ, রকেট, নগদ, উপায় মোবাইল ব্যাংকিং\n'
                                          '• সকল প্রধান ব্যাংকের ইন্টারনেট ব্যাংকিং\n'
                                          '• নিরাপদ ও দ্রুত পেমেন্ট প্রক্রিয়া\n'
                                          '• তাৎক্ষণিক রসিদ ও নিশ্চিতকরণ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green[600],
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'SSL নিরাপত্তা সুরক্ষিত',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              const SizedBox(height: 20),

                              // Purpose
                              TextFormField(
                                controller: controller.purposeController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'অনুদানের উদ্দেশ্য (ঐচ্ছিক)',
                                  hintText: 'বাংলা বা ইংরেজিতে উদ্দেশ্য লিখুন',
                                  prefixIcon: const Icon(Icons.description),
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
                              const SizedBox(height: 20),

                              // Notes
                              TextFormField(
                                controller: controller.notesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'মন্তব্য (ঐচ্ছিক)',
                                  hintText: 'বাংলা বা ইংরেজিতে মন্তব্য লিখুন',
                                  prefixIcon: const Icon(Icons.note),
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
                              const SizedBox(height: 20),

                              // Anonymous Checkbox
                              CheckboxListTile(
                                title: const Text(
                                  'নাম প্রকাশ না করে অনুদান দিন',
                                ),
                                value: controller.isAnonymous.value,
                                onChanged: (bool? value) {
                                  controller.isAnonymous.value = value ?? false;
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: const Color(0xFFD4AF37),
                              ),
                              const SizedBox(height: 30),

                              // Submit Button
                              ElevatedButton(
                                onPressed: () => controller.submitDonation(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4AF37),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'অনুদান জমা দিন',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
