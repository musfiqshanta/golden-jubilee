import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suborno_joyonti/app/services/pdf_service.dart';

class CheckRegistrationPage extends StatefulWidget {
  const CheckRegistrationPage({super.key});

  @override
  State<CheckRegistrationPage> createState() => _CheckRegistrationPageState();
}

class _CheckRegistrationPageState extends State<CheckRegistrationPage> {
  String? selectedBatch;
  final TextEditingController phoneController = TextEditingController();
  List<String> availableBatches = [];
  Map<String, dynamic>? foundRegistration;
  bool isLoading = false;
  bool hasSearched = false;
  bool isLoadingBatches = true;
  bool _isPdfLoading = false; // Add loading state for PDF

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    try {
      // Use collectionGroup to get all registrations and extract batch IDs
      final registrationsSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('registrations')
              .get();

      final Set<String> batchIds = {};
      for (var doc in registrationsSnapshot.docs) {
        final batchId = doc.reference.parent.parent?.id;
        if (batchId != null) {
          batchIds.add(batchId);
        }
      }

      final List<String> batches = batchIds.toList();

      // Define the natural order for running classes
      final List<String> runningClassOrder = [
        '৬ষ্ঠ শ্রেণি',
        '৭ম শ্রেণি',
        '৮ম শ্রেণি',
        '৯ম শ্রেণি',
        '১০ম শ্রেণি',
      ];

      // Sort batches: running classes first (in order), then years, then others
      final runningClasses =
          runningClassOrder
              .where((className) => batches.contains(className))
              .toList();
      final years = batches.where((id) => int.tryParse(id) != null).toList();
      years.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      final others =
          batches
              .where(
                (id) =>
                    !runningClassOrder.contains(id) && int.tryParse(id) == null,
              )
              .toList();
      others.sort();

      setState(() {
        availableBatches = [...runningClasses, ...years, ...others];
        isLoadingBatches = false;
      });
    } catch (e) {
      print('Error loading batches: $e');
      // Add some default batches if loading fails
      setState(() {
        availableBatches = [
          '৬ষ্ঠ শ্রেণি',
          '৭ম শ্রেণি',
          '৮ম শ্রেণি',
          '৯ম শ্রেণি',
          '১০ম শ্রেণি',
          '2020',
          '2021',
          '2022',
          '2023',
          '2024',
        ];
        isLoadingBatches = false;
      });
    }
  }

  Future<void> _checkRegistration() async {
    if (selectedBatch == null || phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'ত্রুটি',
        'অনুগ্রহ করে ব্যাচ এবং মোবাইল নম্বর নির্বাচন করুন',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
      foundRegistration = null;
      hasSearched = true;
    });

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('batches')
              .doc(selectedBatch)
              .collection('registrations')
              .doc(phoneController.text.trim())
              .get();

      setState(() {
        foundRegistration = doc.exists ? doc.data() : null;
        isLoading = false;
      });

      if (!doc.exists) {
        Get.snackbar(
          'ফলাফল',
          'এই মোবাইল নম্বরটি এই ব্যাচে পাওয়া যায়নি',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'ত্রুটি',
        'নিবন্ধন যাচাই করতে সমস্যা হয়েছে: $e',
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
          'নিবন্ধন যাচাই করুন',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD4AF37), Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Container(
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
                      children: [
                        const Icon(
                          Icons.search,
                          size: 50,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'নিবন্ধন যাচাই করুন',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B6914),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'ব্যাচ এবং মোবাইল নম্বর দিয়ে নিবন্ধন খুঁজুন',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Section
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ফিল্টার',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B6914),
                              ),
                            ),
                            if (!isLoadingBatches)
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoadingBatches = true;
                                    });
                                    _loadBatches();
                                  },
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  tooltip: 'ব্যাচ রিফ্রেশ করুন',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Batch Dropdown
                        isLoadingBatches
                            ? Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'ব্যাচ লোড হচ্ছে...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : DropdownButtonFormField<String>(
                              value: selectedBatch,
                              decoration: InputDecoration(
                                labelText: 'ব্যাচ নির্বাচন করুন',
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
                                prefixIcon: const Icon(
                                  Icons.school,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              items:
                                  availableBatches.isEmpty
                                      ? [
                                        const DropdownMenuItem<String>(
                                          value: null,
                                          child: Text(
                                            'কোন ব্যাচ পাওয়া যায়নি',
                                          ),
                                        ),
                                      ]
                                      : availableBatches.map((batch) {
                                        return DropdownMenuItem<String>(
                                          value: batch,
                                          child: Text(batch),
                                        );
                                      }).toList(),
                              onChanged:
                                  availableBatches.isEmpty
                                      ? null
                                      : (value) {
                                        setState(() {
                                          selectedBatch = value;
                                        });
                                      },
                            ),
                        const SizedBox(height: 15),

                        // Phone Number Field
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'মোবাইল নম্বর',
                            hintText: '01XXXXXXXXX',
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
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Search Button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (isLoading ||
                                          isLoadingBatches ||
                                          availableBatches.isEmpty)
                                      ? null
                                      : _checkRegistration,
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
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'নিবন্ধন খুঁজুন',
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
                  const SizedBox(height: 20),

                  // Results Section
                  if (hasSearched) ...[
                    Container(
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
                          const Text(
                            'ফলাফল',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B6914),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (foundRegistration != null) ...[
                            _buildRegistrationCard(foundRegistration!),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text(
                                      'ডাউনলোড পিডিএফ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF8B6914),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed:
                                        () => _downloadRegistrationPdf(
                                          foundRegistration!,
                                        ),
                                  ),
                                ),
                                // const SizedBox(width: 16),
                                // MouseRegion(
                                //   cursor: SystemMouseCursors.click,
                                //   child: ElevatedButton.icon(
                                //     icon: const Icon(Icons.edit),
                                //     label: const Text(
                                //       'তথ্য আপডেট করুন',
                                //       style: TextStyle(
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //     style: ElevatedButton.styleFrom(
                                //       backgroundColor: Color(0xFFD4AF37),
                                //       foregroundColor: Colors.white,
                                //       padding: const EdgeInsets.symmetric(
                                //         horizontal: 24,
                                //         vertical: 14,
                                //       ),
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(10),
                                //       ),
                                //     ),
                                //     onPressed: () {
                                //       Get.to(
                                //         () => UpdateRegistrationPage(
                                //           batchId: selectedBatch!,
                                //           phone: phoneController.text.trim(),
                                //           registrationData: foundRegistration!,
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ),
                              ],
                            ),
                          ] else if (!isLoading) ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'কোন নিবন্ধন পাওয়া যায়নি। অনুগ্রহ করে সঠিক ব্যাচ এবং মোবাইল নম্বর দিয়ে আবার চেষ্টা করুন।',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isPdfLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "পিডিএফ তৈরি হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(Map<String, dynamic> registration) {
    final photoUrl = registration['photoUrl'] as String?;
    final spouseCount = registration['spouseCount'] ?? 0;
    final childCount = registration['childCount'] ?? 0;
    final totalGuests = spouseCount + childCount;
    final paymentStatus = registration['paymentStatus'] ?? 'pending';
    final totalPayable = registration['totalPayable'] ?? 0;

    // Determine payment status color and text
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (paymentStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'অনুমোদিত';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'অপেক্ষমান';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'প্রত্যাখ্যাত';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'অজানা';
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Download PDF button at the top
          Align(
            alignment: Alignment.centerRight,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'ডাউনলোড পিডিএফ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B6914),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _downloadRegistrationPdf(registration),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 10),
              const Text(
                'নিবন্ধন পাওয়া গেছে!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Payment Status Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'পেমেন্ট স্ট্যাটাস: $statusText',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '৳$totalPayable',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (photoUrl != null && photoUrl.isNotEmpty)
            Center(
              child: Image.network(
                photoUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 15),
          _buildInfoRow('নাম', registration['name'] ?? ''),
          _buildInfoRow('পিতার নাম', registration['fatherName'] ?? ''),
          _buildInfoRow('মাতার নাম', registration['motherName'] ?? ''),
          _buildInfoRow('মোবাইল', registration['mobile'] ?? ''),
          _buildInfoRow('ইমেইল', registration['email'] ?? ''),
          _buildInfoRow('লিঙ্গ', registration['gender'] ?? ''),
          _buildInfoRow('জন্ম তারিখ', _formatDate(registration['dateOfBirth'])),
          _buildInfoRow('পেশা', registration['occupation'] ?? ''),
          _buildInfoRow('পদবী', registration['designation'] ?? ''),
          _buildInfoRow('জাতীয়তা', registration['nationality'] ?? ''),
          _buildInfoRow('ধর্ম', registration['religion'] ?? ''),
          _buildInfoRow(
            'স্থায়ী ঠিকানা',
            registration['permanentAddress'] ?? '',
          ),
          _buildInfoRow('বর্তমান ঠিকানা', registration['presentAddress'] ?? ''),
          _buildInfoRow('টি-শার্ট সাইজ', registration['tshirtSize'] ?? ''),
          _buildInfoRow('ব্যাচ', registration['batch'] ?? ''),
          if (registration['isRunningStudent'] == true) ...[
            _buildInfoRow('বর্তমান শ্রেণি', registration['finalClass'] ?? ''),
            _buildInfoRow('সাল', registration['year'] ?? ''),
          ] else ...[
            _buildInfoRow(
              'এসএসসি পাসের সাল',
              registration['sscPassingYear'] ?? '',
            ),
          ],
          _buildInfoRow(
            'নিবন্ধনের তারিখ',
            _formatDate(registration['registrationTimestamp']),
          ),
          const Divider(),
          const Text(
            'অতিথি তথ্য',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B6914),
            ),
          ),
          _buildInfoRow('স্বামী/স্ত্রী', spouseCount.toString()),
          _buildInfoRow('সন্তান', childCount.toString()),
          _buildInfoRow('মোট অতিথি', totalGuests.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B6914),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'নির্ধারিত নয়' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'নির্ধারিত নয়';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'নির্ধারিত নয়';
    }
  }

  void _downloadRegistrationPdf(Map<String, dynamic> registration) async {
    setState(() {
      _isPdfLoading = true;
    });
    try {
      await PdfService.generateRegistrationPdfFromData(registration);
    } finally {
      setState(() {
        _isPdfLoading = false;
      });
    }
  }
}
