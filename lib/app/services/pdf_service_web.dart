
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfServiceWeb {
  static pw.Font? _bengaliFont;

  static Future<void> _loadBengaliFont() async {
    if (_bengaliFont == null) {
      // Temporarily skip font loading to avoid the DataView error
      // TODO: Add proper Bengali font file to assets/fonts/NotoSansBengali-Regular.ttf
      print('Web: Skipping Bengali font loading - using default font');
      _bengaliFont = pw.Font.helvetica();

      // Uncomment this when you have the actual Bengali font file:
      /*
      try {
        // Try to load Bengali font from assets
        final fontData = await rootBundle.load(
          'assets/fonts/NotoSansBengali-Regular.ttf',
        );
        
        // Validate font data - real TTF files are much larger
        if (fontData.lengthInBytes < 10000) {
          throw Exception(
            'Font file appears to be too small (${fontData.lengthInBytes} bytes). Real TTF files are typically 100KB+',
          );
        }
        
        _bengaliFont = pw.Font.ttf(fontData);
        print(
          'Web Bengali font loaded successfully - Size: ${fontData.lengthInBytes} bytes',
        );
      } catch (e) {
        print('Could not load Bengali font: $e');
        print('Using default font - Bengali text may appear as boxes');
        // Fallback to default font
        _bengaliFont = pw.Font.helvetica();
      }
      */
    }
  }

  // static Future<void> generatePaymentInvoice({
  //   required Map<String, dynamic> registrationData,
  //   required String photoUrl,
  // }) async {
  //   try {
  //     print('Web PDF Service: Starting PDF generation...');

  //     // Set default font without loading
  //     _bengaliFont = pw.Font.helvetica();

  //     final pdf = pw.Document();

  //     // Generate student copy
  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4,
  //         build:
  //             (pw.Context context) => _buildInvoicePage(
  //               registrationData: registrationData,
  //               photoUrl: photoUrl,
  //               isStudentCopy: true,
  //             ),
  //       ),
  //     );

  //     // Generate school authority copy
  //     pdf.addPage(
  //       pw.Page(
  //         pageFormat: PdfPageFormat.a4,
  //         build:
  //             (pw.Context context) => _buildInvoicePage(
  //               registrationData: registrationData,
  //               photoUrl: photoUrl,
  //               isStudentCopy: false,
  //             ),
  //       ),
  //     );

  //     // Generate PDF bytes and download
  //     print('Web PDF Service: Generating PDF bytes...');
  //     final pdfBytes = await pdf.save();
  //     print('Web PDF Service: PDF bytes generated, size: ${pdfBytes.length}');

  //     // Create blob and download
  //     final blob = html.Blob([pdfBytes]);
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     final anchor =
  //         html.AnchorElement(href: url)
  //           ..setAttribute(
  //             'download',
  //             'payment_invoice_${registrationData['mobile']}.pdf',
  //           )
  //           ..click();
  //     html.Url.revokeObjectUrl(url);

  //     print('Web PDF Service: PDF download initiated');

  //     Get.snackbar(
  //       'সফল',
  //       'পেমেন্ট ইনভয়েস ডাউনলোড হয়েছে',
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //     );
  //   } catch (e) {
  //     print('Web PDF Generation Error: $e');
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
                  style: _bengaliTextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown,
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
                  style: pw.TextStyle(
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
                  style: pw.TextStyle(
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
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.brown),
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
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'নিবন্ধন আইডি: ${registrationData['mobile']}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'এই ইনভয়েসটি নিবন্ধন প্রক্রিয়ার জন্য প্রয়োজনীয়। অনুগ্রহ করে সংরক্ষণ করুন।',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
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
              style: pw.TextStyle(
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
              style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
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
}
