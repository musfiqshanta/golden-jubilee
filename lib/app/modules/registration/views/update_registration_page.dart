import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suborno_joyonti/config/collection_names.dart';

class UpdateRegistrationPage extends StatefulWidget {
  final String batchId;
  final String phone;
  final Map<String, dynamic> registrationData;
  const UpdateRegistrationPage({
    super.key,
    required this.batchId,
    required this.phone,
    required this.registrationData,
  });

  @override
  State<UpdateRegistrationPage> createState() => _UpdateRegistrationPageState();
}

class _UpdateRegistrationPageState extends State<UpdateRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController fatherNameController;
  late TextEditingController motherNameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController occupationController;
  late TextEditingController designationController;
  late TextEditingController permanentAddressController;
  late TextEditingController presentAddressController;
  late TextEditingController tshirtSizeController;
  late TextEditingController spouseCountController;
  late TextEditingController childCountController;
  late TextEditingController sscPassingYearController;
  late TextEditingController finalClassController;
  late TextEditingController yearController;
  String? gender;
  String? nationality;
  String? religion;
  bool isRunningStudent = false;
  bool isStillStudying = false;
  bool isLoading = false;
  int spouseCount = 0;
  int childCount = 0;

  @override
  void initState() {
    super.initState();
    final d = widget.registrationData;
    nameController = TextEditingController(text: d['name'] ?? '');
    fatherNameController = TextEditingController(text: d['fatherName'] ?? '');
    motherNameController = TextEditingController(text: d['motherName'] ?? '');
    mobileController = TextEditingController(text: d['mobile'] ?? '');
    emailController = TextEditingController(text: d['email'] ?? '');
    occupationController = TextEditingController(text: d['occupation'] ?? '');
    designationController = TextEditingController(text: d['designation'] ?? '');
    permanentAddressController = TextEditingController(
      text: d['permanentAddress'] ?? '',
    );
    presentAddressController = TextEditingController(
      text: d['presentAddress'] ?? '',
    );
    tshirtSizeController = TextEditingController(text: d['tshirtSize'] ?? '');
    spouseCountController = TextEditingController(
      text: (d['spouseCount'] ?? 0).toString(),
    );
    childCountController = TextEditingController(
      text: (d['childCount'] ?? 0).toString(),
    );
    sscPassingYearController = TextEditingController(
      text: d['sscPassingYear'] ?? '',
    );
    finalClassController = TextEditingController(text: d['finalClass'] ?? '');
    yearController = TextEditingController(text: d['year'] ?? '');
    gender = d['gender'] ?? 'পুরুষ';
    nationality =
        (d['nationality'] == 'Other')
            ? 'অন্যান্য'
            : (d['nationality'] ?? 'বাংলাদেশী');
    religion =
        (d['religion'] == 'Other') ? 'অন্যান্য' : (d['religion'] ?? 'ইসলাম');
    isRunningStudent = d['isRunningStudent'] == true;
    isStillStudying = d['isStillStudying'] == true;
    spouseCount = d['spouseCount'] ?? 0;
    childCount = d['childCount'] ?? 0;
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    occupationController.dispose();
    designationController.dispose();
    permanentAddressController.dispose();
    presentAddressController.dispose();
    tshirtSizeController.dispose();
    spouseCountController.dispose();
    childCountController.dispose();
    sscPassingYearController.dispose();
    finalClassController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> _updateRegistration() async {
    print('Update registration started');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation passed, starting update...');
    setState(() => isLoading = true);
    try {
      // Calculate total payable amount
      final int baseFee = _calculateBaseFee();
      final int guestCount = spouseCount + childCount;
      final int guestFee = guestCount * 500;
      final int totalPayable = baseFee + guestFee;

      print('Calculated base fee: $baseFee');
      print('Guest count: $guestCount, Guest fee: $guestFee');
      print('Total payable: $totalPayable');

      final data = {
        'name': nameController.text.trim(),
        'fatherName': fatherNameController.text.trim(),
        'motherName': motherNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'occupation': occupationController.text.trim(),
        'designation': designationController.text.trim(),
        'permanentAddress': permanentAddressController.text.trim(),
        'presentAddress': presentAddressController.text.trim(),
        'tshirtSize': tshirtSizeController.text.trim(),
        'spouseCount': spouseCount,
        'childCount': childCount,
        'sscPassingYear': sscPassingYearController.text.trim(),
        'finalClass': finalClassController.text.trim(),
        'year': yearController.text.trim(),
        'gender': gender,
        'nationality': nationality,
        'religion': religion,
        'isRunningStudent': isRunningStudent,
        'isStillStudying': isStillStudying,
        'batch': widget.batchId,
        'totalPayable': totalPayable,
        // Keep other fields as is if needed
      };

      print('Data to update: $data');
      print('Updating Firestore document...');

      await FirebaseFirestore.instance
          .collection(CollectionConfig.batchesCollection)
          .doc(widget.batchId)
          .collection(CollectionConfig.registrationsCollection)
          .doc(widget.phone)
          .update(data)
          .then((value) {
            Get.back(result: true);
          });

      print('Firestore update completed successfully');
      setState(() => isLoading = false);

      // Go back and refresh the previous screen
      print('Returning with result: true');
      // Pass result to indicate successful update
    } catch (e) {
      print('Error during update: $e');
      setState(() => isLoading = false);
      Get.snackbar(
        'ত্রুটি',
        'তথ্য আপডেট ব্যর্থ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'তথ্য আপডেট করুন',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'নাম'),
                validator: (v) => v == null || v.isEmpty ? 'নাম আবশ্যক' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: fatherNameController,
                decoration: const InputDecoration(labelText: 'পিতার নাম'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: motherNameController,
                decoration: const InputDecoration(labelText: 'মাতার নাম'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'মোবাইল'),
                keyboardType: TextInputType.phone,
                enabled: false, // Phone number should not be changed
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'ইমেইল'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(labelText: 'লিঙ্গ'),
                      items: const [
                        DropdownMenuItem(value: 'পুরুষ', child: Text('পুরুষ')),
                        DropdownMenuItem(value: 'মহিলা', child: Text('মহিলা')),
                        DropdownMenuItem(
                          value: 'অন্যান্য',
                          child: Text('অন্যান্য'),
                        ),
                      ],
                      onChanged: (v) => setState(() => gender = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: nationality,
                      decoration: const InputDecoration(labelText: 'জাতীয়তা'),
                      items: const [
                        DropdownMenuItem(
                          value: 'বাংলাদেশী',
                          child: Text('বাংলাদেশী'),
                        ),
                        DropdownMenuItem(
                          value: 'অন্যান্য',
                          child: Text('অন্যান্য'),
                        ),
                      ],
                      onChanged: (v) => setState(() => nationality = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: religion,
                      decoration: const InputDecoration(labelText: 'ধর্ম'),
                      items: const [
                        DropdownMenuItem(value: 'ইসলাম', child: Text('ইসলাম')),
                        DropdownMenuItem(
                          value: 'হিন্দু',
                          child: Text('হিন্দু'),
                        ),
                        DropdownMenuItem(
                          value: 'খ্রিস্টান',
                          child: Text('খ্রিস্টান'),
                        ),
                        DropdownMenuItem(value: 'বৌদ্ধ', child: Text('বৌদ্ধ')),
                        DropdownMenuItem(
                          value: 'অন্যান্য',
                          child: Text('অন্যান্য'),
                        ),
                      ],
                      onChanged: (v) => setState(() => religion = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: occupationController,
                      decoration: const InputDecoration(
                        labelText: 'পেশা (ঐচ্ছিক)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: designationController,
                decoration: const InputDecoration(labelText: 'পদবী (ঐচ্ছিক)'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: isStillStudying,
                    onChanged:
                        (val) => setState(() => isStillStudying = val ?? false),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'বর্তমানে অধ্যয়নরত',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: permanentAddressController,
                decoration: const InputDecoration(labelText: 'স্থায়ী ঠিকানা'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: presentAddressController,
                decoration: const InputDecoration(labelText: 'বর্তমান ঠিকানা'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: tshirtSizeController,
                decoration: const InputDecoration(labelText: 'টি-শার্ট সাইজ'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _customNumberField(
                      label: 'স্বামী/স্ত্রী/সন্তান',
                      value: spouseCount,
                      maxValue: 3,
                      onChanged: (value) {
                        final newTotal = value + childCount;
                        if (newTotal <= 3) {
                          setState(() {
                            spouseCount = value;
                            spouseCountController.text = value.toString();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                              ),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _customNumberField(
                      label: 'অন্যান্য আতিথী',
                      value: childCount,
                      maxValue: 3,
                      onChanged: (value) {
                        final newTotal = spouseCount + value;
                        if (newTotal <= 3) {
                          setState(() {
                            childCount = value;
                            childCountController.text = value.toString();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                              ),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'মোট অতিথি: ${spouseCount + childCount} জন (সর্বোচ্চ ৩ জন)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B6914),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (isRunningStudent) ...[
                TextFormField(
                  controller: finalClassController,
                  decoration: InputDecoration(
                    labelText: 'বর্তমান শ্রেণি',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'সাল',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
              ] else ...[
                TextFormField(
                  controller: sscPassingYearController,
                  decoration: InputDecoration(
                    labelText: 'এসএসসি পাসের সাল',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  enabled: false,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _updateRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'তথ্য আপডেট করুন',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _customNumberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
    int? maxValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFFD4AF37),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B6914),
                ),
              ),
            ),
            IconButton(
              onPressed:
                  maxValue != null && value >= maxValue
                      ? null
                      : () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
              color:
                  maxValue != null && value >= maxValue
                      ? Colors.grey
                      : const Color(0xFFD4AF37),
            ),
          ],
        ),
        if (maxValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'সর্বোচ্চ: $maxValue জন',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  int _calculateBaseFee() {
    if (isRunningStudent) {
      return 500; // Running students pay 500
    } else {
      // For old students, check if they passed between 2019-2026
      final passingYear = sscPassingYearController.text.trim();
      if (passingYear.isNotEmpty) {
        final year = int.tryParse(passingYear);
        if (year != null && year >= 2019 && year <= 2026) {
          return 700; // Old students who passed 2019-2026 pay 700
        }
      }
      return 1200; // Other old students pay 1200
    }
  }
}
