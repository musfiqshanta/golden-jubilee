import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:html' if (dart.library.io) 'dart:io' as html;
import 'package:suborno_joyonti/app/services/pdf_service.dart';

class RegistrationController extends GetxController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final presentAddressController = TextEditingController();
  final occupationController = TextEditingController();
  final designationController = TextEditingController();
  final workplaceAddressController = TextEditingController();
  final nationalIdController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  // Reactive fields
  var selectedGender = 'পুরুষ'.obs;
  var selectedReligion = 'ইসলাম'.obs;
  var selectedNationality = 'বাংলাদেশী'.obs;
  var selectedFinalClass = ''.obs;
  var selectedYear = '2024'.obs;
  var selectedSscPassingYear = 'None'.obs;
  var selectedDateOfBirth = Rxn<DateTime>();
  var spouseCount = 0.obs;
  var childCount = 0.obs;
  var parentCount = 0.obs;
  var selectedPhoto = Rxn<PlatformFile>();
  var photoError = RxnString();
  var isRunningStudent = false.obs;
  var selectedTshirtSize = RxnString();

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

  // Registration deadline countdown
  final registrationDeadline = DateTime(2024, 12, 1, 23, 59, 59);
  var regTimeLeft = Duration.zero.obs;
  Timer? regTimer;

  final isLoading = false.obs;

  // Add this near the top of the controller class
  int totalAmount = 0;

  @override
  void onInit() {
    super.onInit();
    _updateRegCountdown();
    regTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRegCountdown(),
    );
  }

  void _updateRegCountdown() {
    final now = DateTime.now();
    regTimeLeft.value =
        registrationDeadline.isAfter(now)
            ? registrationDeadline.difference(now)
            : Duration.zero;
  }

  @override
  void onClose() {
    regTimer?.cancel();
    nameController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    permanentAddressController.dispose();
    presentAddressController.dispose();
    occupationController.dispose();
    designationController.dispose();
    workplaceAddressController.dispose();
    nationalIdController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.onClose();
  }

  String formatRegCountdown() {
    if (regTimeLeft.value.inSeconds <= 0) return 'নিবন্ধন বন্ধ';
    final days = regTimeLeft.value.inDays;
    final hours = regTimeLeft.value.inHours % 24;
    final minutes = regTimeLeft.value.inMinutes % 60;
    final seconds = regTimeLeft.value.inSeconds % 60;
    return '$days দিন $hours ঘণ্টা $minutes মিনিট $seconds সেকেন্ড';
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDateOfBirth.value = picked;
    }
  }

  Future<void> pickPhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.size > 3 * 1024 * 1024) {
          photoError.value = 'File size must be less than 3MB';
          selectedPhoto.value = null;
          return;
        }
        selectedPhoto.value = file;
        photoError.value = null;
      }
    } catch (e) {
      photoError.value = 'Error selecting photo: $e';
      selectedPhoto.value = null;
    }
  }

  Future<String?> uploadPhoto(File imageFile) async {
    try {
      print('Uploading photo...');
      print('Selected photo: \\${selectedPhoto.value}');
      http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse('https://jahajmarahighschool.com/api/upload.php'),
      );
      request.fields['phone'] = mobileController.text.trim();
      request.fields['year'] = selectedSscPassingYear.value ?? '';
      // Use bytes for web, use file path for mobile/desktop
      if (selectedPhoto.value != null && selectedPhoto.value!.bytes != null) {
        print('Uploading using bytes (from memory)');
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            selectedPhoto.value!.bytes!,
            filename: selectedPhoto.value!.name,
          ),
        );
      } else if (!kIsWeb &&
          selectedPhoto.value != null &&
          selectedPhoto.value!.path != null &&
          selectedPhoto.value!.path!.isNotEmpty) {
        print('Uploading using file path');
        request.files.add(
          await http.MultipartFile.fromPath('file', selectedPhoto.value!.path!),
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
      print('Upload response status: \\${res.statusCode}');
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
        print('Upload failed with status: \\${res.statusCode}');
        Get.snackbar(
          'ছবি আপলোড ব্যর্থ',
          'ছবি আপলোড করা যায়নি (স্ট্যাটাস: \\${res.statusCode})',
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

  void clearForm() {
    nameController.text = '';
    fatherNameController.text = '';
    motherNameController.text = '';
    permanentAddressController.text = '';
    presentAddressController.text = '';
    occupationController.text = '';
    designationController.text = '';
    workplaceAddressController.text = '';
    nationalIdController.text = '';
    mobileController.text = '';
    emailController.text = '';
    selectedGender.value = '';
    selectedReligion.value = '';
    selectedNationality.value = '';
    selectedFinalClass.value = '';
    selectedYear.value = '';
    selectedSscPassingYear.value = '';
    selectedDateOfBirth.value = null;
    spouseCount.value = 0;
    childCount.value = 0;
    parentCount.value = 0;
    selectedTshirtSize.value = '';
    isRunningStudent.value = false;
    photoError.value = null;
    selectedPhoto.value = null;
  }

  Future<void> saveRegistration() async {
    // Validate photo upload
    if (selectedPhoto.value == null) {
      photoError.value = 'ছবি আপলোড করা বাধ্যতামূলক';
      Get.snackbar(
        'ত্রুটি',
        'ছবি আপলোড করা বাধ্যতামূলক',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final isRunning = isRunningStudent.value;
    final batch =
        isRunning ? selectedFinalClass.value : selectedSscPassingYear.value;
    final phone = mobileController.text.trim();

    // Check if phone number already exists in the same batch
    try {
      final existingDoc =
          await FirebaseFirestore.instance
              .collection('batches')
              .doc(batch)
              .collection('registrations')
              .doc(phone)
              .get();

      if (existingDoc.exists) {
        Get.snackbar(
          'ত্রুটি',
          'এই মোবাইল নম্বরটি ইতিমধ্যে এই ব্যাচে নিবন্ধিত হয়েছে। অনুগ্রহ করে অন্য নম্বর ব্যবহার করুন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'নিবন্ধন যাচাইকরণে সমস্যা হয়েছে। আবার চেষ্টা করুন।',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
              SizedBox(height: 24),
              Text(
                'তথ্য সংরক্ষণ হচ্ছে এবং PDF জেনারেট হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B6914),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    String? photoUrl;
    // If a photo is selected, upload it (handle web/mobile differences)
    if (selectedPhoto.value != null) {
      try {
        // Only use File(path) if not web and path is not null/empty
        if (!kIsWeb &&
            selectedPhoto.value!.path != null &&
            selectedPhoto.value!.path!.isNotEmpty) {
          photoUrl = await uploadPhoto(File(selectedPhoto.value!.path!));
        } else {
          // On web, just call uploadPhoto with a dummy File (it will use bytes internally)
          photoUrl = await uploadPhoto(File(''));
        }
        if (photoUrl == null) {
          Get.back(); // Dismiss loading
          Get.snackbar(
            'ছবি আপলোড ব্যর্থ',
            'ছবি আপলোড করা যায়নি। আবার চেষ্টা করুন।',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      } catch (e) {
        Get.back(); // Dismiss loading
        Get.snackbar(
          'ছবি আপলোড ব্যর্থ',
          'ছবি আপলোড করা যায়নি। আবার চেষ্টা করুন।',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }
    }

    // Now run the Firestore transaction for the serial number and save registration
    final data = _collectRegistrationData(batch);
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }
    final counterRef = FirebaseFirestore.instance
        .collection('counters')
        .doc('registration');
    int formSerialNumber = 1;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);
      if (snapshot.exists) {
        formSerialNumber = (snapshot.data()?['value'] ?? 0) + 1;
        transaction.update(counterRef, {'value': formSerialNumber});
      } else {
        transaction.set(counterRef, {'value': 1});
        formSerialNumber = 1;
      }
    });
    data['formSerialNumber'] = formSerialNumber;
    try {
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(batch)
          .collection('registrations')
          .doc(phone)
          .set(data);

      // Fetch the saved registration document to get the correct formSerialNumber
      final doc =
          await FirebaseFirestore.instance
              .collection('batches')
              .doc(batch)
              .collection('registrations')
              .doc(phone)
              .get();

      // Only call PDF generation (dialog will be shown inside that method)
      try {
        if (doc.exists) {
          final registrationData = doc.data() ?? <String, dynamic>{};
          await PdfService.generateRegistrationPdfFromData(
            registrationData,
            onBeforeOpen: () {
              if (Get.isDialogOpen ?? false) Get.back();
            },
          );
        }
      } catch (e) {
        print('PDF generation error: $e');
        Get.snackbar(
          'সতর্কতা',
          'নিবন্ধন সফল হয়েছে কিন্তু পিডিএফ তৈরি করতে সমস্যা হয়েছে',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      clearForm();
    } catch (error) {
      Get.back(); // Dismiss loading on error
      Get.snackbar('Error', 'Registration failed: $error');
    }
    isLoading.value = false;
  }

  Map<String, dynamic> _collectRegistrationData(String batch) {
    return {
      'name': nameController.text.trim(),
      'fatherName': fatherNameController.text.trim(),
      'motherName': motherNameController.text.trim(),
      'gender': selectedGender.value,
      'dateOfBirth': selectedDateOfBirth.value?.toIso8601String(),
      'nationalId': nationalIdController.text.trim(),
      'mobile': mobileController.text.trim(),
      'email': emailController.text.trim(),
      'permanentAddress': permanentAddressController.text.trim(),
      'presentAddress': presentAddressController.text.trim(),
      'occupation': occupationController.text.trim(),
      'designation': designationController.text.trim(),
      'workplaceAddress': workplaceAddressController.text.trim(),
      'nationality': selectedNationality.value,
      'religion': selectedReligion.value,
      'finalClass': selectedFinalClass.value,
      'year': selectedYear.value,
      'sscPassingYear': selectedSscPassingYear.value,
      'isRunningStudent': isRunningStudent.value,
      'spouseCount': spouseCount.value,
      'childCount': childCount.value,
      'parentCount': parentCount.value,
      'tshirtSize': selectedTshirtSize.value,
      'batch': batch,
      'registrationTimestamp': DateTime.now().toIso8601String(),
    };
  }

  // Add this method for demo/testing
  void fillDemoData() {
    nameController.text = 'রহিম উদ্দিন';
    fatherNameController.text = 'করিম উদ্দিন';
    motherNameController.text = 'আসমা বেগম';
    permanentAddressController.text =
        'গ্রাম: উদাহরণ, উপজেলা: টেস্ট, জেলা: ঢাকা';
    presentAddressController.text = 'গ্রাম: বর্তমান, উপজেলা: টেস্ট, জেলা: ঢাকা';
    occupationController.text = 'ইঞ্জিনিয়ার';
    designationController.text = 'সহকারী প্রকৌশলী';
    workplaceAddressController.text = 'ঢাকা, বাংলাদেশ';
    nationalIdController.text = '1234567890';
    mobileController.text = '01700000000';
    emailController.text = 'demo@example.com';
    selectedGender.value = 'পুরুষ';
    selectedReligion.value = 'ইসলাম';
    selectedNationality.value = 'বাংলাদেশী';
    selectedFinalClass.value = '১০ম শ্রেণি';
    selectedYear.value = '2024';
    selectedSscPassingYear.value = '2020';
    selectedDateOfBirth.value = DateTime(2000, 1, 1);
    spouseCount.value = 1;
    childCount.value = 1;
    parentCount.value = 1;
    selectedTshirtSize.value = 'M';
    isRunningStudent.value = false;
    photoError.value = null;
    selectedPhoto.value = null;
  }

  // Test PDF generation method
  Future<void> generateAndOpenInvoice() async {
    // 1. Create a PDF document
    final pdf = pw.Document();
    // 2. Set Bangla Font for pdf
    final loadFont = await FontManager.loadFont(GetFonts.ruposhiBangla);
    final loadFont2 = await FontManager.loadFont(GetFonts.kalpurush);
    final useFont = pw.Font.ttf(loadFont);
    final useFont2 = pw.Font.ttf(loadFont2);
    // 2. Add content to the PDF
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'গ্রাহকের নাম: রহিম শিক্ষাগত  '.fix(),
                  style: pw.TextStyle(font: useFont2),
                ),
                pw.Text('hello world', style: pw.TextStyle()),
                pw.Text(
                  'পুরুষ ${DateTime.now().toLocal()}'.fix(),
                  style: pw.TextStyle(font: useFont),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.Text(
                          'পণ্য'.fix(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: useFont,
                          ),
                        ),
                        pw.Text(
                          'পরিমাণ'.fix(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: useFont,
                          ),
                        ),
                        pw.Text(
                          'মূল্য'.fix(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: useFont,
                          ),
                        ),
                        pw.Text(
                          'মোট'.fix(),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: useFont,
                          ),
                        ),
                      ],
                    ),
                    ...[
                      ['কফি', '2', '\$10', '\$20'],
                      ['চা', '1', '\$15', '\$15'],
                      ['স্বর্ণপত্র', '3', '\$5', '\$15'],
                    ].map(
                      (item) => pw.TableRow(
                        verticalAlignment: pw.TableCellVerticalAlignment.middle,
                        children:
                            item
                                .map(
                                  (cell) => pw.Text(
                                    cell.fix(),
                                    style: pw.TextStyle(font: useFont),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'মোট \$50'.fix(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: useFont,
                  ),
                ),
              ],
            ),
      ),
    );

    if (kIsWeb) {
      // For web, create a download
      final pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', 'invoice.pdf')
            ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop platforms
      final outputDir = await getTemporaryDirectory();
      final filePath = '${outputDir.path}/invoice.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // 4. Open the PDF file
      OpenFile.open(filePath);
    }
  }

  // Generate Registration PDF with proper Bengali support
  Future<void> generateRegistrationPdf() async {
    try {
      if (nameController.text.isEmpty ||
          fatherNameController.text.isEmpty ||
          mobileController.text.isEmpty) {
        Get.snackbar(
          'ত্রুটি',
          'অনুগ্রহ করে নাম, পিতার নাম এবং মোবাইল নম্বর পূরণ করুন',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final pdf = pw.Document();

      // Load Bengali fonts with proper fallback
      final loadFont = await FontManager.loadFont(GetFonts.ruposhiBangla);
      final loadFont2 = await FontManager.loadFont(GetFonts.kalpurush);
      final useFont = pw.Font.ttf(loadFont);
      final useFont2 = pw.Font.ttf(loadFont2);

      // Load logo image
      final logoData = await rootBundle.load('assets/logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Load uploaded photo if available
      pw.MemoryImage? userPhoto;
      if (selectedPhoto.value != null && selectedPhoto.value!.bytes != null) {
        userPhoto = pw.MemoryImage(selectedPhoto.value!.bytes!);
      }

      final registrationDate = DateTime.now();
      final batch =
          isRunningStudent.value ? 'Running' : selectedSscPassingYear.value;
      final regTimestamp = registrationDate.toIso8601String();

      // Calculate total guest and total amount before PDF generation
      int totalGuest = spouseCount.value + childCount.value;
      int participantAmount = isRunningStudent.value ? 700 : 1200;
      totalAmount = participantAmount + (totalGuest * 500);

      // Get the current form serial number (total registrations + 1)
      int formSerialNumber = 0;
      try {
        final totalRegistrations =
            await FirebaseFirestore.instance
                .collectionGroup('registrations')
                .get();
        formSerialNumber = totalRegistrations.size + 1;
      } catch (e) {
        print('Error getting total registrations: $e');
        formSerialNumber = 1; // Fallback to 1 if error
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header with colored background
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    border: pw.Border.all(
                      color: PdfColors.amber300,
                      width: 1.2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 60,
                        height: 60,
                        child: pw.Image(logoImage),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _safeFix('সুবর্ণজয়ন্তী নিবন্ধন'),
                            style: pw.TextStyle(
                              font: useFont,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            _safeFix('জাহাজমারা উচ্চ বিদ্যালয়'),
                            style: pw.TextStyle(font: useFont, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                // Divider
                pw.Divider(color: PdfColors.amber700, thickness: 1),
                // Details Section
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        _safeFix(
                          'রেজিস্ট্রেশন তারিখঃ ${registrationDate.year}-${registrationDate.month.toString().padLeft(2, '0')}-${registrationDate.day.toString().padLeft(2, '0')}',
                        ),
                        style: pw.TextStyle(font: useFont, fontSize: 11),
                      ),

                      pw.Text(
                        'https://jahajmarahighschool.com',
                        style: pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                // Body Rows
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    // First Row: Personal | Academic
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: 140,
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColors.grey50,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                _safeFix('ব্যক্তিগত তথ্য'),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                  color: PdfColors.amber800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              _twoLineField(
                                'নামঃ',
                                nameController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'পিতার নামঃ',
                                fatherNameController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'মাতার নামঃ',
                                motherNameController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'লিঙ্গঃ',
                                selectedGender.value,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জন্ম তারিখঃ',
                                selectedDateOfBirth.value != null
                                    ? '${selectedDateOfBirth.value!.day.toString().padLeft(2, '0')}-${selectedDateOfBirth.value!.month.toString().padLeft(2, '0')}-${selectedDateOfBirth.value!.year}'
                                    : 'নির্ধারিত নয়',
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জাতীয় পরিচয়পত্রঃ',
                                nationalIdController.text,
                                useFont2,
                                useFont,
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          height: 140,
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColors.grey100,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                _safeFix(
                                  isRunningStudent.value
                                      ? 'শিক্ষাগত তথ্য (বর্তমানে অধ্যয়নরত)'
                                      : 'শিক্ষাগত তথ্য (প্রাক্তন ছাএ)',
                                ),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                  color: PdfColors.amber800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              if (isRunningStudent.value) ...[
                                _twoLineField(
                                  'বর্তমানে শ্রেণি:',
                                  selectedFinalClass.value,
                                  useFont2,
                                  useFont,
                                ),
                                _twoLineField(
                                  'সালঃ',
                                  selectedYear.value,
                                  useFont2,
                                  useFont,
                                ),
                              ] else ...[
                                _twoLineField(
                                  'এসএসসি পাসের সালঃ',
                                  selectedSscPassingYear.value,
                                  useFont2,
                                  useFont,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Second Row: Contact | Additional
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: 140,
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColors.grey50,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                _safeFix('যোগাযোগের তথ্য'),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                  color: PdfColors.amber800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              _twoLineField(
                                'মোবাইলঃ',
                                mobileController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineFieldEnglish(
                                'Email:',
                                emailController.text,
                              ),
                              _twoLineField(
                                'স্থায়ী ঠিকানাঃ',
                                permanentAddressController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'বর্তমান ঠিকানাঃ',
                                presentAddressController.text,
                                useFont2,
                                useFont,
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          height: 140,
                          padding: const pw.EdgeInsets.all(8),
                          color: PdfColors.grey100,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                _safeFix('অতিরিক্ত তথ্য'),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                  color: PdfColors.amber800,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              _twoLineField(
                                'পেশাঃ',
                                occupationController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'পদবিঃ',
                                designationController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'কর্মস্থলঃ',
                                workplaceAddressController.text,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'ধর্মঃ',
                                selectedReligion.value,
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জাতীয়তাঃ',
                                selectedNationality.value,
                                useFont2,
                                useFont,
                              ),
                              _twoLineFieldEnglish(
                                'Tshirt Size:',
                                selectedTshirtSize.value ?? '',
                              ),
                              _twoLineField(
                                'অতিথী (স্বামী/স্ত্রী ও সন্তান):',
                                totalGuest.toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'পিতামাতা সংখ্যাঃ',
                                parentCount.value.toString(),
                                useFont2,
                                useFont,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 12),
                  padding: pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    border: pw.Border.all(
                      color: PdfColors.amber200,
                      width: 1.2,
                    ),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _safeFix('প্রাপ্তি স্বীকারপত্র'),
                        style: pw.TextStyle(
                          font: useFont2,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 18,
                          color: PdfColors.amber800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.amber300, thickness: 0.8),
                      pw.SizedBox(height: 8),
                      _ackLine(
                        'ফর্ম ক্রমিক নং',
                        formSerialNumber.toString(),
                        useFont2,
                      ),
                      _ackLine('নাম:', nameController.text, useFont2),
                      ...[
                        if (isRunningStudent.value)
                          _ackLine(
                            'বিদ্যালয়ে পড়িত শ্রেণি:',
                            selectedFinalClass.value,
                            useFont2,
                          )
                        else
                          _ackLine(
                            'এসএসসি ব্যাচ:',
                            selectedSscPassingYear.value,
                            useFont2,
                          ),
                      ],
                      _ackLine(
                        'পিতার নাম:',
                        fatherNameController.text,
                        useFont2,
                      ),
                      _ackLine('লিঙ্গঃ', selectedGender.value, useFont),
                      _ackLine('অতিথী:', totalGuest.toString(), useFont2),
                      _ackLine('মোট টাকাঃ', totalAmount.toString(), useFont2),
                      pw.Text(
                        "Tshirst Size : ${selectedTshirtSize.value}",
                        textAlign: pw.TextAlign.left,
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                // Signature Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Accountant
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey600,
                          margin: pw.EdgeInsets.only(bottom: 4),
                        ),
                        pw.Text(
                          _safeFix('হিসাবরক্ষক'),
                          style: pw.TextStyle(font: useFont2, fontSize: 12),
                        ),
                      ],
                    ),
                    // Applicant
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey600,
                          margin: pw.EdgeInsets.only(bottom: 4),
                        ),
                        pw.Text(
                          _safeFix('আবেদনকারী'),
                          style: pw.TextStyle(font: useFont2, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                // Footer
                pw.Divider(color: PdfColors.amber700, thickness: 0.8),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    _safeFix('সুবর্ণজয়ন্তী - জাহাজমারা উচ্চ বিদ্যালয় '),
                    style: pw.TextStyle(
                      font: useFont,
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute(
                'download',
                'registration_${mobileController.text}.pdf',
              )
              ..click();
        html.Url.revokeObjectUrl(url);
        Get.snackbar(
          'সফল',
          'নিবন্ধন পিডিএফ ডাউনলোড হয়েছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final outputDir = await getTemporaryDirectory();
        final filePath =
            '${outputDir.path}/registration_${mobileController.text}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        OpenFile.open(filePath);
        Get.snackbar(
          'সফল',
          'নিবন্ধন পিডিএফ তৈরি হয়েছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Registration PDF generation error: $e');
      Get.snackbar(
        'ত্রুটি',
        'পিডিএফ তৈরি করতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  pw.Widget _twoLineField(
    String label,
    String value,
    pw.Font labelFont,
    pw.Font valueFont,
  ) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: label.fix(),
            style: pw.TextStyle(
              font: labelFont,
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
          ),
          pw.TextSpan(
            text: ' ',
            style: pw.TextStyle(font: valueFont, fontSize: 11),
          ),
          pw.TextSpan(
            text: value.fix(),
            style: pw.TextStyle(font: valueFont, fontSize: 11),
          ),
        ],
      ),
    );
  }

  pw.Widget _twoLineFieldEnglish(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: label.fix(),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.TextSpan(text: ' ', style: pw.TextStyle(fontSize: 11)),
          pw.TextSpan(text: value.fix(), style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // Helper method for PDF info rows
  pw.Widget _buildPdfInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(_safeFix(label), style: pw.TextStyle(font: font)),
          ),
          pw.Text(': ${_safeFix(value)}', style: pw.TextStyle(font: font)),
        ],
      ),
    );
  }

  // Safe fix method to handle potential errors
  String _safeFix(String text) {
    try {
      // Use bangla_pdf_fixer to properly handle Bengali text
      return text.fix();
    } catch (e) {
      print('Warning: bangla_pdf_fixer failed for text: $text, error: $e');
      // Fallback to original text if fix() fails
      return text;
    }
  }

  // Test Bengali PDF generation method
  Future<void> testBengaliPdfGeneration() async {
    try {
      print('Starting Bengali PDF test generation...');

      // Test font loading first
      pw.Font testFont;
      try {
        // Load Bengali font from assets - try Kalpurush first
        final fontData = await rootBundle.load('assets/fonts/kalpurush.ttf');
        testFont = pw.Font.ttf(fontData);
        print('✅ Kalpurush font loaded successfully for testing');
      } catch (e) {
        print('❌ Kalpurush font loading error: $e');
        try {
          // Try Noto Sans Bengali as fallback
          final fontData = await rootBundle.load(
            'assets/fonts/NotoSansBengali-Regular.ttf',
          );
          testFont = pw.Font.ttf(fontData);
          print('✅ Noto Sans Bengali font loaded successfully for testing');
        } catch (e2) {
          print('❌ Noto Sans Bengali font loading error: $e2');
          // Last resort - use default font but warn about Bengali text
          testFont = pw.Font.helvetica();
          print(
            '⚠️ Using Helvetica font - Bengali text may not display correctly',
          );
        }
      }

      // Create a simple test PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build:
              (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'বাংলা টেস্ট',
                    style: pw.TextStyle(fontSize: 24, font: testFont),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'রহিম উদ্দিন',
                    style: pw.TextStyle(fontSize: 16, font: testFont),
                  ),
                  pw.Text(
                    'করিম উদ্দিন',
                    style: pw.TextStyle(fontSize: 16, font: testFont),
                  ),
                  pw.Text(
                    'আসমা বেগম',
                    style: pw.TextStyle(fontSize: 16, font: testFont),
                  ),
                ],
              ),
        ),
      );

      // Save the PDF
      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'bengali_test.pdf')
              ..click();
        html.Url.revokeObjectUrl(url);

        Get.snackbar(
          'সফল',
          'বাংলা পিডিএফ টেস্ট ডাউনলোড হয়েছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final outputDir = await getTemporaryDirectory();
        final filePath = '${outputDir.path}/bengali_test.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        await OpenFile.open(filePath);

        Get.snackbar(
          'সফল',
          'বাংলা পিডিএফ টেস্ট তৈরি হয়েছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      print('✅ Bengali PDF test generation completed successfully');
    } catch (e) {
      print('❌ Bengali PDF test generation error: $e');
      Get.snackbar(
        'ত্রুটি',
        'বাংলা পিডিএফ টেস্ট ব্যর্থ: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  pw.Widget _ackLine(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            label.fix(),
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Text(value.fix(), style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }
}
