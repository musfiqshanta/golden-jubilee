import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool isLoading = false;

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
    nationality = (d['nationality'] == 'Other') ? 'অন্যান্য' : (d['nationality'] ?? 'বাংলাদেশী');
    religion = (d['religion'] == 'Other') ? 'অন্যান্য' : (d['religion'] ?? 'ইসলাম');
    isRunningStudent = d['isRunningStudent'] == true;
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
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
        'spouseCount': int.tryParse(spouseCountController.text) ?? 0,
        'childCount': int.tryParse(childCountController.text) ?? 0,
        'sscPassingYear': sscPassingYearController.text.trim(),
        'finalClass': finalClassController.text.trim(),
        'year': yearController.text.trim(),
        'gender': gender,
        'nationality': nationality,
        'religion': religion,
        'isRunningStudent': isRunningStudent,
        'batch': widget.batchId,
        // Keep other fields as is if needed
      };
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(widget.batchId)
          .collection('registrations')
          .doc(widget.phone)
          .update(data);
      setState(() => isLoading = false);
      Get.snackbar(
        'সফল',
        'তথ্য আপডেট হয়েছে',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
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
                      decoration: const InputDecoration(labelText: 'পেশা'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: designationController,
                decoration: const InputDecoration(labelText: 'পদবী'),
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
                    child: TextFormField(
                      controller: spouseCountController,
                      decoration: const InputDecoration(
                        labelText: 'স্বামী/স্ত্রী',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: childCountController,
                      decoration: const InputDecoration(labelText: 'সন্তান'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isRunningStudent) ...[
                TextFormField(
                  controller: finalClassController,
                  decoration: const InputDecoration(
                    labelText: 'বর্তমান শ্রেণি',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'সাল'),
                ),
              ] else ...[
                TextFormField(
                  controller: sscPassingYearController,
                  decoration: const InputDecoration(
                    labelText: 'এসএসসি পাসের সাল',
                  ),
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
}
