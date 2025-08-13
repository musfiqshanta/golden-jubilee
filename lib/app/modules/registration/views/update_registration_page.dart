import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suborno_joyonti/config/collection_names.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

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

  // Controllers
  late TextEditingController nameController;
  late TextEditingController fatherNameController;
  late TextEditingController motherNameController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController occupationController;
  late TextEditingController designationController;
  late TextEditingController permanentAddressController;
  late TextEditingController presentAddressController;
  late TextEditingController workplaceAddressController;
  late TextEditingController nationalIdController;

  // Photo related
  PlatformFile? selectedPhoto;
  String? photoError;
  String? currentPhotoUrl;

  // Dropdown values
  String? gender;
  String? nationality;
  String? religion;
  String? bloodGroup;
  String? tshirtSize;
  String? finalClass;
  String? year;
  String? sscPassingYear;

  // Checkboxes
  bool isRunningStudent = false;
  bool isStillStudying = false;

  // Guest counts
  int spouseCount = 0;
  int childCount = 0;

  // Guest details
  List<String> guestNames = [];
  List<String> guestRelationships = [];

  // Loading state
  bool isLoading = false;
  bool isDeleting = false;

  // Dropdown lists
  final List<String> tshirtSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> religions = [
    'ইসলাম',
    'হিন্দু',
    'খ্রিস্টান',
    'বৌদ্ধ',
    'অন্যান্য',
  ];
  final List<String> nationalities = ['বাংলাদেশী', 'অন্যান্য'];
  final List<String> bloodGroups = [
    'জানি না / জানা নেই',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> finalClasses = [
    '৬ষ্ঠ শ্রেণি',
    '৭ম শ্রেণি',
    '৮ম শ্রেণি',
    '৯ম শ্রেণি',
    '১০ম শ্রেণি',
  ];
  final List<String> years = [
    '1972',
    '1973',
    '1974',
    '1975',
    '1976',
    '1977',
    '1978',
    '1979',
    '1980',
    '1981',
    '1982',
    '1983',
    '1984',
    '1985',
    '1986',
    '1987',
    '1988',
    '1989',
    '1990',
    '1991',
    '1992',
    '1993',
    '1994',
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
    '2006',
    '2007',
    '2008',
    '2009',
    '2010',
    '2011',
    '2012',
    '2013',
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
  ];
  final List<String> sscPassingYears = [
    'None',
    '1972',
    '1973',
    '1974',
    '1975',
    '1976',
    '1977',
    '1978',
    '1979',
    '1980',
    '1981',
    '1982',
    '1983',
    '1984',
    '1985',
    '1986',
    '1987',
    '1988',
    '1989',
    '1990',
    '1991',
    '1992',
    '1993',
    '1994',
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
    '2006',
    '2007',
    '2008',
    '2009',
    '2010',
    '2011',
    '2012',
    '2013',
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
  ];

  // Guest relationship options
  final List<String> guestRelationshipOptions = [
    'স্বামী',
    'স্ত্রী',
    'সন্তান',
    'পিতা',
    'মাতা',
    'ভাই',
    'বোন',
    'অন্যান্য',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeGuestDetails();
  }

  void _initializeControllers() {
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
    workplaceAddressController = TextEditingController(
      text: d['workplaceAddress'] ?? '',
    );
    nationalIdController = TextEditingController(text: d['nationalId'] ?? '');

    // Photo
    currentPhotoUrl = d['photoUrl'];

    // Dropdowns
    gender = d['gender'] ?? 'পুরুষ';
    nationality =
        (d['nationality'] == 'Other')
            ? 'অন্যান্য'
            : (d['nationality'] ?? 'বাংলাদেশী');
    religion =
        (d['religion'] == 'Other') ? 'অন্যান্য' : (d['religion'] ?? 'ইসলাম');
    bloodGroup = d['bloodGroup'] ?? 'জানি না / জানা নেই';
    tshirtSize = d['tshirtSize'] ?? '';
    finalClass = d['finalClass'] ?? '';
    year = d['year'] ?? '2024';
    sscPassingYear = d['sscPassingYear'] ?? 'None';

    // Checkboxes
    isRunningStudent = d['isRunningStudent'] == true;
    isStillStudying = d['isStillStudying'] == true;

    // Guest counts
    spouseCount = d['spouseCount'] ?? 0;
    childCount = d['childCount'] ?? 0;

    // Guest details
    guestNames = List<String>.from(d['guestNames'] ?? []);
    guestRelationships = List<String>.from(d['guestRelationships'] ?? []);
  }

  void _initializeGuestDetails() {
    final totalGuests = spouseCount + childCount;

    // Ensure guest lists have the right length
    while (guestNames.length < totalGuests) {
      guestNames.add('');
    }
    while (guestRelationships.length < totalGuests) {
      guestRelationships.add('স্বামী');
    }

    // Trim lists if they're too long
    if (guestNames.length > totalGuests) {
      guestNames = guestNames.take(totalGuests).toList();
    }
    if (guestRelationships.length > totalGuests) {
      guestRelationships = guestRelationships.take(totalGuests).toList();
    }
  }

  void _updateGuestDetails() {
    final totalGuests = spouseCount + childCount;
    _initializeGuestDetails();
    setState(() {});
  }

  Future<void> _pickPhoto() async {
    try {
      print('Starting photo picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Important: This ensures bytes are available on web
      );

      print('Photo picker result: $result');

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('Selected file: ${file.name}');
        print('File size: ${file.size} bytes');

        if (file.size > 3 * 1024 * 1024) {
          // 3MB limit
          print('File too large: ${file.size} bytes');
          setState(() {
            photoError = 'File size must be less than 3MB';
            selectedPhoto = null;
          });
          return;
        }

        setState(() {
          selectedPhoto = file;
          photoError = null;
        });
        print('Photo selected successfully');
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error in photo picker: $e');
      setState(() {
        photoError = 'Error selecting photo: $e';
        selectedPhoto = null;
      });
    }
  }

  Future<String?> _uploadPhoto(File imageFile) async {
    try {
      print('Uploading photo...');
      print('Selected photo: $selectedPhoto');

      http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse('https://jubilee.jahajmarahighschool.com/api/upload.php'),
      );

      // Add the same fields as the working registration process
      request.fields['phone'] = mobileController.text.trim();
      request.fields['year'] = sscPassingYear ?? '';

      // Use bytes for web, use file path for mobile/desktop (same logic as registration)
      if (selectedPhoto != null && selectedPhoto!.bytes != null) {
        print('Uploading using bytes (from memory)');
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            selectedPhoto!.bytes!,
            filename: selectedPhoto!.name,
          ),
        );
      } else if (!kIsWeb &&
          selectedPhoto != null &&
          selectedPhoto!.path != null &&
          selectedPhoto!.path!.isNotEmpty) {
        print('Uploading using file path');
        request.files.add(
          await http.MultipartFile.fromPath('file', selectedPhoto!.path!),
        );
      } else {
        print('No valid file to upload');
        Get.snackbar(
          'ছবি আপলোড ব্যর্থ',
          'কোনো বৈধ ছবি পাওয়া যায়নি।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return null;
      }

      var res = await request.send();
      print('Upload response status: ${res.statusCode}');
      final body = await res.stream.bytesToString();
      print('Upload response body: \n$body');

      if (res.statusCode == 200) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map && decoded['url'] != null) {
            return decoded['url'];
          } else {
            print('No url in response!');
            Get.snackbar(
              'ছবি আপলোড ব্যর্থ',
              'সার্ভার থেকে সঠিক লিংক পাওয়া যায়নি।',
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
            return null;
          }
        } catch (e) {
          print('JSON decode error: $e');
          Get.snackbar(
            'ছবি আপলোড ব্যর্থ',
            'সার্ভার থেকে সঠিক তথ্য পাওয়া যায়নি।',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          return null;
        }
      } else {
        print('Upload failed with status: ${res.statusCode}');
        Get.snackbar(
          'ছবি আপলোড ব্যর্থ',
          'ছবি আপলোড করা যায়নি (স্ট্যাটাস: ${res.statusCode})',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      Get.snackbar(
        'ছবি আপলোড ব্যর্থ',
        'ত্রুটি: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    }
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
    workplaceAddressController.dispose();
    nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _updateRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // Calculate total payable amount
      final int baseFee = _calculateBaseFee();
      final int guestCount = spouseCount + childCount;
      final int guestFee = guestCount * 500;
      final int totalPayable = baseFee + guestFee;

      // Handle photo upload
      String? photoUrl = currentPhotoUrl;
      if (selectedPhoto != null) {
        try {
          print('Photo selected: ${selectedPhoto!.name}');
          print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');

          // Simple validation - check if photo is selected
          if (selectedPhoto == null) {
            setState(() => isLoading = false);
            Get.snackbar(
              'ত্রুটি',
              'ছবি নির্বাচন করুন',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          // Upload photo using the same method as registration
          photoUrl = await _uploadPhoto(File(''));

          if (photoUrl == null) {
            setState(() => isLoading = false);
            Get.snackbar(
              'ত্রুটি',
              'ছবি আপলোড ব্যর্থ হয়েছে',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        } catch (e) {
          print('Photo upload error: $e');
          setState(() => isLoading = false);
          Get.snackbar(
            'ত্রুটি',
            'ছবি আপলোডে সমস্যা: $e',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

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
        'workplaceAddress': workplaceAddressController.text.trim(),
        'nationalId': nationalIdController.text.trim(),
        'gender': gender,
        'nationality': nationality,
        'religion': religion,
        'bloodGroup': bloodGroup,
        'tshirtSize': tshirtSize,
        'spouseCount': spouseCount,
        'childCount': childCount,
        'guestNames': guestNames,
        'guestRelationships': guestRelationships,
        'sscPassingYear': sscPassingYear,
        'finalClass': finalClass,
        'year': year,
        'isRunningStudent': isRunningStudent,
        'isStillStudying': isStillStudying,
        'batch': widget.batchId,
        'totalPayable': totalPayable,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (photoUrl != null) {
        data['photoUrl'] = photoUrl;
      }

      await FirebaseFirestore.instance
          .collection(CollectionConfig.batchesCollection)
          .doc(widget.batchId)
          .collection(CollectionConfig.registrationsCollection)
          .doc(widget.phone)
          .update(data)
          .then((value) {
            Get.back(result: true);
          });

      setState(() => isLoading = false);

      Get.snackbar(
        'সফল',
        'তথ্য সফলভাবে আপডেট হয়েছে',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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

  Future<void> _deleteRegistration() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('নিবন্ধন মুছে ফেলুন'),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনি এই নিবন্ধনটি মুছে ফেলতে চান? এই কাজটি অপরিবর্তনীয়।',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('না'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('হ্যাঁ, মুছে ফেলুন'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection(CollectionConfig.batchesCollection)
          .doc(widget.batchId)
          .collection(CollectionConfig.registrationsCollection)
          .doc(widget.phone)
          .delete()
          .then((onValue) {
            Get.back(result: true);
          });

      setState(() => isDeleting = false);

      Get.snackbar(
        'সফল',
        'নিবন্ধন সফলভাবে মুছে ফেলা হয়েছে',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: 'deleted');
    } catch (e) {
      setState(() => isDeleting = false);
      Get.snackbar(
        'ত্রুটি',
        'নিবন্ধন মুছে ফেলা ব্যর্থ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  int _calculateBaseFee() {
    if (isRunningStudent) {
      return 500; // Running students pay 500
    } else {
      // For old students, check if they passed between 2019-2026
      final passingYear = sscPassingYear ?? 'None';
      if (passingYear != 'None') {
        final year = int.tryParse(passingYear);
        if (year != null && year >= 2019 && year <= 2026) {
          return 700; // Old students who passed 2019-2026 pay 700
        }
      }
      return 1200; // Other old students pay 1200
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
        actions: [
          // Delete button
          IconButton(
            onPressed: isDeleting ? null : _deleteRegistration,
            icon:
                isDeleting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'নিবন্ধন মুছে ফেলুন',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4AF37), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Information Section
                _sectionCard('ব্যক্তিগত তথ্য', Icons.person, [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'নাম *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? 'নাম আবশ্যক' : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fatherNameController,
                          decoration: InputDecoration(
                            labelText: 'পিতার নাম',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: motherNameController,
                          decoration: InputDecoration(
                            labelText: 'মাতার নাম',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField('লিঙ্গ *', gender, [
                          'পুরুষ',
                          'মহিলা',
                          'অন্যান্য',
                        ], (value) => setState(() => gender = value)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _dropdownField(
                          'জাতীয়তা *',
                          nationality,
                          nationalities,
                          (value) => setState(() => nationality = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField(
                          'ধর্ম *',
                          religion,
                          religions,
                          (value) => setState(() => religion = value),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _dropdownField(
                          'রক্তের গ্রুপ',
                          bloodGroup,
                          bloodGroups,
                          (value) => setState(() => bloodGroup = value),
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // Contact Information Section
                _sectionCard('যোগাযোগের তথ্য', Icons.contact_phone, [
                  TextFormField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      labelText: 'মোবাইল *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: false, // Phone number should not be changed
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'ইমেইল',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: nationalIdController,
                    decoration: InputDecoration(
                      labelText: 'জাতীয় পরিচয়পত্র নম্বর',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 20),

                // Address Information Section
                _sectionCard('ঠিকানার তথ্য', Icons.location_on, [
                  TextFormField(
                    controller: permanentAddressController,
                    decoration: InputDecoration(
                      labelText: 'স্থায়ী ঠিকানা *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'স্থায়ী ঠিকানা আবশ্যক'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: presentAddressController,
                    decoration: InputDecoration(
                      labelText: 'বর্তমান ঠিকানা *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                    validator:
                        (v) =>
                            v == null || v.isEmpty
                                ? 'বর্তমান ঠিকানা আবশ্যক'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: workplaceAddressController,
                    decoration: InputDecoration(
                      labelText: 'কর্মস্থলের ঠিকানা',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ]),

                const SizedBox(height: 20),

                // Professional Information Section
                _sectionCard('পেশাগত তথ্য', Icons.work, [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: occupationController,
                          decoration: InputDecoration(
                            labelText: 'পেশা',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          controller: designationController,
                          decoration: InputDecoration(
                            labelText: 'পদবী',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // Educational Information Section
                _sectionCard('শিক্ষাগত তথ্য', Icons.school, [
                  // Note about educational details being read-only
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'শিক্ষাগত তথ্য শুধুমাত্র দেখার জন্য - পরিবর্তন করা যাবে না',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: isRunningStudent,
                        onChanged: null, // Disabled
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'বর্তমানে অধ্যয়নরত',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors
                                    .grey[600], // Dimmed text to show it's disabled
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isRunningStudent) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _dropdownField(
                            'বর্তমান শ্রেণি',
                            finalClass,
                            finalClasses,
                            (value) {}, // Disabled - no action
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _dropdownField(
                            'সাল',
                            year,
                            years,
                            (value) {}, // Disabled - no action
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _dropdownField(
                      'এসএসসি পাসের সাল',
                      sscPassingYear,
                      sscPassingYears,
                      (value) {}, // Disabled - no action
                      enabled: false,
                    ),
                  ],
                ]),

                const SizedBox(height: 20),

                // Guest Information Section
                _sectionCard('অতিথির তথ্য', Icons.people, [
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
                                _updateGuestDetails();
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
                                _updateGuestDetails();
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
                  const SizedBox(height: 15),

                  // Guest Details Input Fields
                  if (spouseCount + childCount > 0) ...[
                    Text(
                      'অতিথির বিবরণ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B6914),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(spouseCount + childCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'অতিথি ${index + 1} এর নাম',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (index < guestNames.length) {
                                    guestNames[index] = value;
                                  }
                                },
                                controller: TextEditingController(
                                  text:
                                      index < guestNames.length
                                          ? guestNames[index]
                                          : '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'সম্পর্ক',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                value:
                                    index < guestRelationships.length
                                        ? guestRelationships[index]
                                        : 'স্বামী',
                                items:
                                    guestRelationshipOptions.map((
                                      relationship,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: relationship,
                                        child: Text(relationship),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null &&
                                      index < guestRelationships.length) {
                                    guestRelationships[index] = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ]),

                const SizedBox(height: 20),

                // T-shirt Size Section
                _sectionCard('টি-শার্ট সাইজ', Icons.checkroom, [
                  _dropdownField(
                    'টি-শার্ট সাইজ *',
                    tshirtSize,
                    tshirtSizes,
                    (value) => setState(() => tshirtSize = value),
                  ),
                ]),

                const SizedBox(height: 20),

                // Photo Upload Section
                _sectionCard('ছবি আপলোড', Icons.camera_alt, [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              photoError != null
                                  ? Colors.red
                                  : const Color(0xFFD4AF37),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child:
                          (selectedPhoto != null &&
                                  selectedPhoto!.bytes != null)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  selectedPhoto!.bytes!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                              : (currentPhotoUrl != null &&
                                  currentPhotoUrl!.isNotEmpty)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  currentPhotoUrl!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPhotoPlaceholder();
                                  },
                                ),
                              )
                              : _buildPhotoPlaceholder(),
                    ),
                  ),

                  if (photoError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        photoError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  if (selectedPhoto != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'File: ${selectedPhoto!.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Size: ${(selectedPhoto!.size / 1024).toStringAsFixed(1)} KB',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Beautiful note about photo requirements
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4AF37).withOpacity(0.1),
                          const Color(0xFFD4AF37).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF8B6914),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ছবির গুণগত মান সম্পর্কে বিশেষ নির্দেশনা',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8B6914),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'আপনার ছবিটি পত্রিকায় প্রকাশের জন্য ব্যবহৃত হবে। অনুগ্রহ করে একটি সুন্দর, স্পষ্ট এবং আনুষ্ঠানিক ছবি আপলোড করুন। ছবিতে আপনার মুখমণ্ডল স্পষ্টভাবে দৃশ্যমান হওয়া উচিত এবং পটভূমি পরিষ্কার হওয়া উচিত।',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF8B6914,
                                  ).withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    // Delete Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isDeleting ? null : _deleteRegistration,
                        icon:
                            isDeleting
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.delete_forever),
                        label: Text(
                          isDeleting ? 'মুছে ফেলছি...' : 'নিবন্ধন মুছে ফেলুন',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Update Button
                    Expanded(
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
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 40, color: Color(0xFFD4AF37)),
        const SizedBox(height: 8),
        const Text(
          'ছবি আপলোড করুন',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'সর্বোচ্চ সাইজ: ৩ এমবি',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B6914),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _dropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged, {
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: enabled ? onChanged : null,
      style: TextStyle(color: enabled ? null : Colors.grey[600]),
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
}
