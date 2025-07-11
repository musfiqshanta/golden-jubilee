import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class PdfService {
  static pw.Font? _bengaliFont;

  static Future<void> _loadBengaliFont() async {
    if (_bengaliFont == null) {
      try {
        // Load Bengali font from assets
        final fontData = await rootBundle.load(
          'assets/fonts/NotoSansBengali-Regular.ttf',
        );

        // Validate font data
        if (fontData.lengthInBytes < 10000) {
          throw Exception(
            'Font file appears to be too small (${fontData.lengthInBytes} bytes). Real TTF files are typically 100KB+',
          );
        }

        _bengaliFont = pw.Font.ttf(fontData);
        print(
          'Bengali font loaded successfully - Size: ${fontData.lengthInBytes} bytes',
        );
      } catch (e) {
        print('Could not load Bengali font: $e');
        print('Using default font - Bengali text may appear as boxes');
        // Fallback to default font
        _bengaliFont = pw.Font.helvetica();
      }
    }
  }

  // static Future<void> generatePaymentInvoice({
  //   required Map<String, dynamic> registrationData,
  //   required String photoUrl,
  // }) async {
  //   try {
  //     print('PDF Service: Starting PDF generation...');
  //     print('PDF Service: Registration data: $registrationData');
  //     print('PDF Service: Photo URL: $photoUrl');
  //     print('PDF Service: Is Web: $kIsWeb');

  //     // Set default font without loading
  //     _bengaliFont = pw.Font.helvetica();

  //     if (kIsWeb) {
  //       // For web platform, use web-specific service
  //       try {
  //         await PdfServiceWeb.generatePaymentInvoice(
  //           registrationData: registrationData,
  //           photoUrl: photoUrl,
  //         );
  //       } catch (e) {
  //         print('Web PDF service error: $e');
  //         Get.snackbar(
  //           'ত্রুটি',
  //           'ওয়েব প্ল্যাটফর্মে পিডিএফ তৈরি করতে সমস্যা হয়েছে',
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,
  //         );
  //       }
  //       return;
  //     } else {
  //       // For mobile/desktop platforms
  //       try {
  //         final pdf = pw.Document();

  //         // Generate student copy
  //         pdf.addPage(
  //           pw.Page(
  //             pageFormat: PdfPageFormat.a4,
  //             build:
  //                 (pw.Context context) => _buildInvoicePage(
  //                   registrationData: registrationData,
  //                   photoUrl: photoUrl,
  //                   isStudentCopy: true,
  //                 ),
  //           ),
  //         );

  //         // Generate school authority copy
  //         pdf.addPage(
  //           pw.Page(
  //             pageFormat: PdfPageFormat.a4,
  //             build:
  //                 (pw.Context context) => _buildInvoicePage(
  //                   registrationData: registrationData,
  //                   photoUrl: photoUrl,
  //                   isStudentCopy: false,
  //                 ),
  //           ),
  //         );

  //         // Generate PDF bytes
  //         print('PDF Service: Generating PDF bytes...');
  //         final pdfBytes = await pdf.save();
  //         print('PDF Service: PDF bytes generated, size: ${pdfBytes.length}');

  //         final output = await getTemporaryDirectory();
  //         final file = File(
  //           '${output.path}/payment_invoice_${registrationData['mobile']}.pdf',
  //         );
  //         await file.writeAsBytes(pdfBytes);

  //         // Open PDF
  //         await OpenFile.open(file.path);

  //         Get.snackbar(
  //           'সফল',
  //           'পেমেন্ট ইনভয়েস তৈরি হয়েছে',
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //         );
  //       } catch (e) {
  //         Get.snackbar(
  //           'ত্রুটি',
  //           'ফাইল খুলতে সমস্যা হয়েছে: $e',
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print('PDF Generation Error: $e');
  //     Get.snackbar(
  //       'ত্রুটি',
  //       'পিডিএফ তৈরি করতে সমস্যা হয়েছে: $e',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  static pw.Widget _buildInvoicePage({
    required Map<String, dynamic> registrationData,
    required String photoUrl,
    required bool isStudentCopy,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'জাহাজমারা উচ্চ বিদ্যালয়',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
                    font: _bengaliFont,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'সুবর্ণজয়ন্তী নিবন্ধন - পেমেন্ট ইনভয়েস',
                  style: _bengaliTextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  isStudentCopy ? 'ছাত্র/ছাত্রীর কপি' : 'স্কুল কর্তৃপক্ষের কপি',
                  style: _bengaliTextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Registration Details
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'নিবন্ধন তথ্য',
                  style: _bengaliTextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildInfoRow('নাম:', registrationData['name'] ?? ''),
                _buildInfoRow(
                  'পিতার নাম:',
                  registrationData['fatherName'] ?? '',
                ),
                _buildInfoRow(
                  'মাতার নাম:',
                  registrationData['motherName'] ?? '',
                ),
                _buildInfoRow('মোবাইল:', registrationData['mobile'] ?? ''),
                _buildInfoRow('ইমেইল:', registrationData['email'] ?? ''),
                _buildInfoRow('লিঙ্গ:', registrationData['gender'] ?? ''),
                _buildInfoRow(
                  'জন্ম তারিখ:',
                  _formatDate(registrationData['dateOfBirth']),
                ),
                _buildInfoRow(
                  'শেষ শ্রেণি:',
                  registrationData['finalClass'] ?? '',
                ),
                _buildInfoRow(
                  'এসএসসি পাসের বছর:',
                  registrationData['sscPassingYear'] ?? '',
                ),
                _buildInfoRow('চাকুরি:', registrationData['occupation'] ?? ''),
                _buildInfoRow('পদবি:', registrationData['designation'] ?? ''),
                _buildInfoRow(
                  'টি-শার্ট সাইজ:',
                  registrationData['tshirtSize'] ?? '',
                ),
                _buildInfoRow('ব্যাচ:', registrationData['batch'] ?? ''),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Payment Details
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'পেমেন্ট বিবরণ',
                  style: _bengaliTextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildInfoRow('নিবন্ধন ফি:', '৳৫০০'),
                _buildInfoRow('টি-শার্ট:', '৳২০০'),
                _buildInfoRow('মোট:', '৳৭০০'),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Text(
                    'নোট: পেমেন্ট নগদ বা মোবাইল ব্যাংকিং এর মাধ্যমে করা যাবে।',
                    style: _bengaliTextStyle(
                      fontSize: 12,
                      color: PdfColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'নিবন্ধন তারিখ: ${_formatDate(registrationData['registrationTimestamp'])}',
                  style: _bengaliTextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'নিবন্ধন আইডি: ${registrationData['mobile']}',
                  style: _bengaliTextStyle(
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'এই ইনভয়েসটি নিবন্ধন প্রক্রিয়ার জন্য প্রয়োজনীয়। অনুগ্রহ করে সংরক্ষণ করুন।',
                  style: _bengaliTextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: _bengaliTextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              style: _bengaliTextStyle(fontSize: 10, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'নির্ধারিত নয়';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static pw.TextStyle _bengaliTextStyle({
    double fontSize = 12,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? PdfColors.black,
      font: _bengaliFont ?? pw.Font.helvetica(),
    );
  }

  // static Future<void> generateAndOpenBanglaInvoice() async {
  //   try {
  //     // 1. Create a PDF document
  //     final pdf = pw.Document();

  //     // 2. Load Bangla font (Kalpurush)
  //     final fontData = await FontManager.loadFont(GetFonts.kalpurush);
  //     final ttf = pw.Font.ttf(fontData);

  //     // 3. Add content to the PDF
  //     pdf.addPage(
  //       pw.Page(
  //         build:
  //             (pw.Context context) => pw.Center(
  //               child: pw.Text(
  //                 'বেঁচে থাকার মত আনন্দ আর কিছুই নেই। ',
  //                 style: pw.TextStyle(font: ttf, fontSize: 20),
  //               ),
  //             ),
  //       ),
  //     );

  //     // 4. Generate PDF bytes
  //     final pdfBytes = await pdf.save();

  //     if (kIsWeb) {
  //       // For web platform, download the PDF
  //       final blob = html.Blob([pdfBytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor =
  //           html.AnchorElement(href: url)
  //             ..setAttribute('download', 'bangla_invoice_example.pdf')
  //             ..click();
  //       html.Url.revokeObjectUrl(url);

  //       Get.snackbar(
  //         'সফল',
  //         'বাংলা পিডিএফ ডাউনলোড হয়েছে',
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     } else {
  //       // For mobile/desktop platforms
  //       final outputDir = await getTemporaryDirectory();
  //       final file = File("${outputDir.path}/bangla_invoice_example.pdf");
  //       await file.writeAsBytes(pdfBytes);

  //       // 5. Open the PDF
  //       await OpenFile.open(file.path);

  //       Get.snackbar(
  //         'সফল',
  //         'বাংলা পিডিএফ তৈরি হয়েছে',
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     print('Bangla PDF Generation Error: $e');
  //     Get.snackbar(
  //       'ত্রুটি',
  //       'বাংলা পিডিএফ তৈরি করতে সমস্যা হয়েছে: $e',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
}
