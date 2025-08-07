import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/donation_controller.dart';

class AnonymousDonationPage extends StatefulWidget {
  const AnonymousDonationPage({super.key});

  @override
  State<AnonymousDonationPage> createState() => _AnonymousDonationPageState();
}

class _AnonymousDonationPageState extends State<AnonymousDonationPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DonationController>();

    // Set anonymous to true for this page
    controller.isAnonymous.value = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('সাধারণ দাতা', style: TextStyle(color: Colors.white)),
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.volunteer_activism,
                              size: 50,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'সাধারণ দাতা',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'সাধারণ দাতা হিসেবে অনুদান দিন',
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Donor Name (General)
                                TextFormField(
                                  controller: controller.donorNameController,
                                  decoration: InputDecoration(
                                    labelText: 'দাতার নাম *',
                                    hintText: 'বাংলায় আপনার নাম লিখুন',
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
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'আপনার নাম লিখুন'
                                              : null,
                                ),
                                const SizedBox(height: 20),

                                // Phone
                                TextFormField(
                                  controller: controller.donorPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'মোবাইল নম্বর *',
                                    hintText:
                                        'ইংরেজিতে মোবাইল নম্বর লিখুন (উদাহরণ: 01XXXXXXXXX)',
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
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'আপনার মোবাইল নম্বর লিখুন'
                                              : null,
                                ),
                                const SizedBox(height: 20),

                                // Email
                                TextFormField(
                                  controller: controller.donorEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'ইমেইল (ঐচ্ছিক)',
                                    hintText:
                                        'ইংরেজিতে ইমেইল ঠিকানা লিখুন (ঐচ্ছিক)',
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
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'অনুদানের পরিমাণ লিখুন'
                                              : null,
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
                                      controller.donationTypes.map((
                                        String type,
                                      ) {
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
                                          child: Text(method),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      controller.selectedPaymentMethod.value =
                                          newValue;
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Purpose
                                TextFormField(
                                  controller: controller.purposeController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'অনুদানের উদ্দেশ্য (ঐচ্ছিক)',
                                    hintText: 'বাংলা উদ্দেশ্য লিখুন',
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
                                    hintText: 'বাংলা মন্তব্য লিখুন',
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
                                const SizedBox(height: 30),

                                // Info Box
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
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
                                            color: Colors.orange[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'গুরুত্বপূর্ণ তথ্য',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '• সাধারণ দাতা হিসেবে অনুদান করা হবে\n'
                                        '• নাম, মোবাইল নম্বর এবং অনুদানের পরিমাণ বাধ্যতামূলক\n'
                                        '• অন্যান্য তথ্য ঐচ্ছিক',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Submit Button
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.submitDonation();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
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
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
