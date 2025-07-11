import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PdfServiceMobile {
  static pw.Font? _bengaliFont;

  static Future<void> _loadBengaliFont() async {
    if (_bengaliFont == null) {
      // Temporarily skip font loading to avoid the DataView error
      // TODO: Add proper Bengali font file to assets/fonts/NotoSansBengali-Regular.ttf
      print('Mobile: Skipping Bengali font loading - using default font');
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
          'Mobile Bengali font loaded successfully - Size: ${fontData.lengthInBytes} bytes',
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

  static Future<void> generatePaymentInvoice({
    required Map<String, dynamic> registrationData,
    required String photoUrl,
  }) async {
    try {
      print('Mobile PDF Service: Starting PDF generation...');

      // Set default font without loading
      _bengaliFont = pw.Font.helvetica();

      final pdf = pw.Document();

      // Generate student copy
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => _buildInvoicePage(
                registrationData: registrationData,
                photoUrl: photoUrl,
                isStudentCopy: true,
              ),
        ),
      );

      // Generate school authority copy
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (pw.Context context) => _buildInvoicePage(
                registrationData: registrationData,
                photoUrl: photoUrl,
                isStudentCopy: false,
              ),
        ),
      );

      // Generate PDF bytes
      print('Mobile PDF Service: Generating PDF bytes...');
      final pdfBytes = await pdf.save();
      print(
        'Mobile PDF Service: PDF bytes generated, size: ${pdfBytes.length}',
      );

      // For mobile, we'll just return success - the main service handles file operations
      print('Mobile PDF Service: PDF generation completed successfully');

      Get.snackbar(
        'সফল',
        'পেমেন্ট ইনভয়েস তৈরি হয়েছে',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Mobile PDF Generation Error: $e');
      Get.snackbar(
        'ত্রুটি',
        'পিডিএফ তৈরি করতে সমস্যা হয়েছে: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
                    color: PdfColors.black,
                    font: _bengaliFont,
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
                  'চূড়ান্ত শ্রেণি:',
                  registrationData['finalClass'] ?? '',
                ),
                _buildInfoRow(
                  'এসএসসি পাসের বছর:',
                  registrationData['sscPassingYear'] ?? '',
                ),
                _buildInfoRow('পেশা:', registrationData['occupation'] ?? ''),
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
                    color: PdfColors.black,
                    font: _bengaliFont,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildInfoRow('নিবন্ধন ফি:', '৳৫০০'),
                _buildInfoRow('টি-শার্ট:', '৳৩০০'),
                pw.Divider(color: PdfColors.grey),
                _buildInfoRow('মোট:', '৳৮০০', isTotal: true),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'দ্রষ্টব্য: এই ইনভয়েসটি নিবন্ধন প্রক্রিয়া সম্পন্ন করার জন্য প্রয়োজনীয়।',
                  style: _bengaliTextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'জেনারেটের তারিখ: ${_formatDate(registrationData['registrationTimestamp'])}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    font: _bengaliFont,
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

  static pw.Widget _buildInfoRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColors.black,
                font: _bengaliFont,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.black,
              font: _bengaliFont,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColors.black,
                font: _bengaliFont,
              ),
            ),
          ),
        ],
      ),
    );
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
      font: _bengaliFont,
    );
  }

  static String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
