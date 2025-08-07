import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
// Conditional web imports
import 'pdf_service_web.dart' if (dart.library.io) 'pdf_service_mobile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PdfService {
  // Remove static font fields and manual font loading

  static Future<void> generateRegistrationPdfFromData(
    Map<String, dynamic> data, {
    VoidCallback? onBeforeOpen,
  }) async {
    try {
      // Load Bengali fonts using bangla_pdf_fixer
      final loadFont = await FontManager.loadFont(GetFonts.ruposhiBangla);
      final loadFont2 = await FontManager.loadFont(GetFonts.kalpurush);
      final useFont = pw.Font.ttf(loadFont);
      final useFont2 = pw.Font.ttf(loadFont2);

      // Load logo image
      final logoData = await rootBundle.load('assets/logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Load uploaded photo if available
      pw.MemoryImage? userPhoto;
      if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(data['photoUrl']));
          if (response.statusCode == 200) {
            userPhoto = pw.MemoryImage(response.bodyBytes);
            print('PDF: userPhoto loaded successfully.');
          } else {
            userPhoto = null;
            print(
              'PDF: userPhoto failed to load. Status: ${response.statusCode}',
            );
          }
        } catch (e) {
          userPhoto = null;
          print('PDF: userPhoto loading error: ${e.toString()}');
        }
      }

      final registrationDate =
          data['registrationTimestamp'] != null
              ? DateTime.tryParse(data['registrationTimestamp']) ??
                  DateTime.now()
              : DateTime.now();
      final isRunningStudent = data['isRunningStudent'] == true;
      final totalGuest = (data['spouseCount'] ?? 0) + (data['childCount'] ?? 0);
      final participantAmount = isRunningStudent ? 700 : 1200;
      final totalAmount = participantAmount + (totalGuest * 500);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
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
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Left: Logo
                          pw.Container(
                            width: 60,
                            height: 60,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 12),
                          // Center: Text
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'সুবর্ণ জয়ন্তী নিবন্ধন'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont,
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'জাহাজমারা উচ্চ বিদ্যালয়'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: User Photo (if available)
                          if (userPhoto != null) ...[
                            pw.SizedBox(width: 12),
                            pw.Container(
                              width: 60,
                              height: 60,
                              decoration: pw.BoxDecoration(
                                // shape: pw.BoxShape.circle,
                                border: pw.Border.all(
                                  color: PdfColors.amber300,
                                  width: 3,
                                ),
                              ),

                              child: pw.Image(userPhoto, fit: pw.BoxFit.cover),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(color: PdfColors.amber700, thickness: 1),

                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'ফরম ক্রমিক নং: ${data['formSerialNumber'] ?? ''}'
                                .fix(),
                            style: pw.TextStyle(font: useFont, fontSize: 11),
                          ),

                          pw.Text(
                            'রেজিস্ট্রেশন তারিখ: ${registrationDate.year}-${registrationDate.month.toString().padLeft(2, '0')}-${registrationDate.day.toString().padLeft(2, '0')}'
                                .fix(),
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
                    // Two-row, two-column table
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey200,
                        width: 0.5,
                      ),
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      columnWidths: {
                        0: pw.FixedColumnWidth(250),
                        1: pw.FixedColumnWidth(250),
                      },
                      children: [
                        // Row 1: Personal | Academic
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey50),
                          verticalAlignment: pw.TableCellVerticalAlignment.top,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),

                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'ব্যক্তিগত তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  _twoLineField(
                                    'নাম:',
                                    (data['name'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'পিতার নাম:',
                                    (data['fatherName'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'মাতার নাম:',
                                    (data['motherName'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'লিঙ্গ:',
                                    (data['gender'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),

                                  // _twoLineField(
                                  //   'জাতীয় পরিচয়পত্র:',
                                  //   (data['nationalId'] ?? '').toString(),
                                  //   useFont2,
                                  //   useFont,
                                  // ),
                                ],
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),

                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    isRunningStudent
                                        ? 'শিক্ষাগত তথ্য (বর্তমানে অধ্যয়নরত)'
                                            .fix()
                                        : 'শিক্ষাগত তথ্য (প্রাক্তন ছাত্র)'
                                            .fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  if (isRunningStudent) ...[
                                    _twoLineField(
                                      'বর্তমানে শ্রেণি:',
                                      (data['finalClass'] ?? '').toString(),
                                      useFont2,
                                      useFont,
                                    ),
                                    _twoLineField(
                                      'সাল:',
                                      (data['year'] ?? '').toString(),
                                      useFont2,
                                      useFont,
                                    ),
                                  ] else ...[
                                    _twoLineField(
                                      'এসএসসি ব্যাচ:',
                                      (data['sscPassingYear'] ?? '').toString(),
                                      useFont2,
                                      useFont,
                                    ),
                                    _twoLineFieldEnglish(
                                      'Tshirt Size:',
                                      (data['tshirtSize'] ?? '').toString(),
                                    ),
                                    _twoLineField(
                                      'জাতীয়তা:',
                                      (data['nationality'] ?? '').toString(),
                                      useFont2,
                                      useFont,
                                    ),
                                    _twoLineField(
                                      'জন্ম তারিখ:',
                                      _formatDateOfBirth(data['dateOfBirth']),
                                      useFont2,
                                      useFont,
                                    ),
                                    _twoLineFieldEnglish(
                                      'Blood Group:',
                                      (data['bloodGroup'] ?? '').toString(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Row 2: Contact | Additional
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          verticalAlignment: pw.TableCellVerticalAlignment.top,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'যোগাযোগের তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  _twoLineField(
                                    'মোবাইল:',
                                    (data['mobile'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineFieldEnglish(
                                    'Email:',
                                    (data['email'] ?? '').toString(),
                                  ),
                                  _twoLineField(
                                    'স্থায়ী ঠিকানা:',
                                    (data['permanentAddress'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'বর্তমান ঠিকানা:',
                                    (data['presentAddress'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),

                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'পেশাগত তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  _twoLineField(
                                    'পেশা:  ',
                                    (data['occupation'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'পদবি:',
                                    (data['designation'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'কর্মস্থল:',
                                    (data['workplaceAddress'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'ধর্ম:',
                                    (data['religion'] ?? '').toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'অতিথি:',
                                    totalGuest.toString(),
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'মোট টাকা:',
                                    totalAmount.toString(),
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
                    pw.SizedBox(height: 30),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'গ্রহণকারীর নাম'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'আহবায়ক'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'আবেদনকারী'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Column(
                  // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
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
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'প্রাপ্তি স্বীকারপত্র / টোকেন'.fix(),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 18,
                                  color: PdfColors.amber800,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              _ackLine(
                                'ফরম ক্রমিক নং:',
                                (data['formSerialNumber'] ?? '').toString(),
                                useFont2,
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Divider(color: PdfColors.amber300, thickness: 0.8),
                          pw.SizedBox(height: 3),
                          // Replace the acknowledgment section with:
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Left column
                              pw.SizedBox(
                                width: 250,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    _ackLine(
                                      'নাম:',
                                      (data['name'] ?? '').toString(),
                                      useFont,
                                    ),

                                    _ackLine(
                                      'পিতার নাম:',
                                      (data['fatherName'] ?? '').toString(),
                                      useFont2,
                                    ),

                                    _ackLine(
                                      'মোবাইল:',
                                      (data['mobile'] ?? '').toString(),
                                      useFont2,
                                    ),
                                    _ackLine(
                                      'লিঙ্গ:',
                                      (data['gender'] ?? '').toString(),
                                      useFont,
                                    ),
                                  ],
                                ),
                              ),
                              // Right column
                              pw.SizedBox(
                                width: 250,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    if (isRunningStudent)
                                      _ackLine(
                                        'বর্তমানে শ্রেণি:',
                                        (data['finalClass'] ?? '').toString(),
                                        useFont,
                                      )
                                    else
                                      _ackLine(
                                        'এসএসসি ব্যাচ:',
                                        (data['sscPassingYear'] ?? '')
                                            .toString(),
                                        useFont2,
                                      ),
                                    _ackLine(
                                      'অতিথি:',
                                      totalGuest.toString(),
                                      useFont2,
                                    ),
                                    _ackLineEng(
                                      'Tshirt Size:',
                                      (data['tshirtSize'] ?? '').toString(),
                                    ),
                                    _ackLine(
                                      'মোট টাকা:',
                                      totalAmount.toString(),
                                      useFont2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 30),
                    pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'গ্রহণকারীর নাম'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'আহবায়ক'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'আবেদনকারী'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        pw.Divider(color: PdfColors.amber700, thickness: 0.8),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'সুবর্ণ জয়ন্তী - জাহাজমারা উচ্চ বিদ্যালয় '.fix(),
                            style: pw.TextStyle(
                              font: useFont,
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        PdfServiceWeb.downloadPdf(
          pdfBytes,
          'registration_${data['mobile']}.pdf',
          onBeforeOpen,
        );
      } else {
        final outputDir = await getTemporaryDirectory();
        final filePath = '${outputDir.path}/registration_${data['mobile']}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        if (onBeforeOpen != null) onBeforeOpen();
        await OpenFile.open(filePath);
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

  static pw.Widget _twoLineField(
    String label,
    String value,
    pw.Font font,
    pw.Font font2,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label.fix(),
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            value.fix(),
            style: pw.TextStyle(font: font2, fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  static pw.Widget _twoLineFieldEnglish(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 14)),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 140,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  static pw.Widget _ackLine(String label, String value, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label.fix(),
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            value.fix(),
            style: pw.TextStyle(font: font, fontSize: 14),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  static pw.Widget _ackLineEng(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(label.fix(), style: pw.TextStyle(fontSize: 14)),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 140,
          child: pw.Text(value.fix(), style: pw.TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  static String _formatDateOfBirth(dynamic date) {
    if (date == null) return '';
    String dateString = date.toString();
    try {
      final parsed = DateTime.parse(dateString);
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (e) {
      return dateString;
    }
  }

  static Future<void> generateDonationReceiptPdf(
    Map<String, dynamic> data, {
    VoidCallback? onBeforeOpen,
  }) async {
    try {
      // Load Bengali fonts using bangla_pdf_fixer
      final loadFont = await FontManager.loadFont(GetFonts.ruposhiBangla);
      final loadFont2 = await FontManager.loadFont(GetFonts.kalpurush);
      final useFont = pw.Font.ttf(loadFont);
      final useFont2 = pw.Font.ttf(loadFont2);

      // Load logo image
      final logoData = await rootBundle.load('assets/logo.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Load user photo if available
      pw.MemoryImage? userPhoto;
      if (data['donorPhotoUrl'] != null &&
          data['donorPhotoUrl'].toString().isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(data['donorPhotoUrl']));
          if (response.statusCode == 200) {
            userPhoto = pw.MemoryImage(response.bodyBytes);
            print('PDF: userPhoto loaded successfully.');
          } else {
            userPhoto = null;
            print(
              'PDF: userPhoto failed to load. Status: ${response.statusCode}',
            );
          }
        } catch (e) {
          userPhoto = null;
          print('PDF: userPhoto loading error: ${e.toString()}');
        }
      }

      final donationDate =
          data['date'] != null
              ? DateTime.tryParse(data['date']) ?? DateTime.now()
              : DateTime.now();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
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
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Left: Logo
                          pw.Container(
                            width: 60,
                            height: 60,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 12),
                          // Center: Text
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'সুবর্ণ জয়ন্তী - জাহাজমারা উচ্চ বিদ্যালয়'
                                      .fix(),
                                  style: pw.TextStyle(
                                    font: useFont,
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'অনুদানের রসিদ'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: User Photo (if available)
                          if (userPhoto != null) ...[
                            pw.SizedBox(width: 12),
                            pw.Container(
                              width: 60,
                              height: 60,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.amber300,
                                  width: 3,
                                ),
                              ),
                              child: pw.Image(userPhoto, fit: pw.BoxFit.cover),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(color: PdfColors.amber700, thickness: 1),

                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'রসিদ নং: ${data['receiptNumber']}'.fix(),
                            style: pw.TextStyle(font: useFont, fontSize: 11),
                          ),
                          pw.Text(
                            'তারিখ: ${_formatDateOfBirth(donationDate)}'.fix(),
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

                    // Two-row, two-column table
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey200,
                        width: 0.5,
                      ),
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      columnWidths: {
                        0: pw.FixedColumnWidth(250),
                        1: pw.FixedColumnWidth(250),
                      },
                      children: [
                        // Row 1: Donor Info | Donation Info
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey50),
                          verticalAlignment: pw.TableCellVerticalAlignment.top,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'দাতার তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  _twoLineField(
                                    'নাম:',
                                    data['donorName'] ?? '',
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'মোবাইল:',
                                    data['donorPhone'] ?? '',
                                    useFont2,
                                    useFont,
                                  ),
                                  if (data['donorEmail']?.isNotEmpty == true)
                                    _twoLineFieldEnglish(
                                      'Email:',
                                      data['donorEmail'] ?? '',
                                    ),
                                  if (data['donorAddress']?.isNotEmpty == true)
                                    _twoLineField(
                                      'ঠিকানা:',
                                      data['donorAddress'] ?? '',
                                      useFont2,
                                      useFont,
                                    ),
                                ],
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'অনুদানের তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  _twoLineField(
                                    'পরিমাণ:',
                                    '${data['amount']} টাকা',
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'ধরন:',
                                    data['donationType'] ?? '',
                                    useFont2,
                                    useFont,
                                  ),
                                  _twoLineField(
                                    'পেমেন্ট পদ্ধতি:',
                                    data['paymentMethod'] ?? '',
                                    useFont2,
                                    useFont,
                                  ),
                                  if (data['purpose']?.isNotEmpty == true)
                                    _twoLineField(
                                      'উদ্দেশ্য:',
                                      data['purpose'] ?? '',
                                      useFont2,
                                      useFont,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Row 2: Additional Info | Notes
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                          ),
                          verticalAlignment: pw.TableCellVerticalAlignment.top,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'অতিরিক্ত তথ্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),

                                  _twoLineField(
                                    'তারিখ:',
                                    _formatDateOfBirth(donationDate),
                                    useFont2,
                                    useFont,
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'মন্তব্য'.fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  if (data['notes']?.isNotEmpty == true)
                                    _twoLineField(
                                      'মন্তব্য:',
                                      data['notes'] ?? '',
                                      useFont2,
                                      useFont,
                                    )
                                  else
                                    _twoLineField(
                                      'মন্তব্য:',
                                      'কোন মন্তব্য নেই',
                                      useFont2,
                                      useFont,
                                    ),
                                  pw.SizedBox(height: 20),
                                  pw.Text(
                                    'ধন্যবাদ! আপনার অনুদান আমাদের জন্য অত্যন্ত মূল্যবান।'
                                        .fix(),
                                    style: pw.TextStyle(
                                      font: useFont2,
                                      fontSize: 12,
                                      color: PdfColors.amber800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 30),

                    // Signature Section
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'গ্রহণকারীর নাম'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'আহবায়ক'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 120,
                              height: 1,
                              color: PdfColors.grey600,
                              margin: pw.EdgeInsets.only(bottom: 4),
                            ),
                            pw.Text(
                              'দাতা'.fix(),
                              style: pw.TextStyle(font: useFont2, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Column(
                  children: [
                    // Authority Receipt Section
                    pw.Container(
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
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'প্রাপ্তি স্বীকারপত্র / টোকেন'.fix(),
                                style: pw.TextStyle(
                                  font: useFont2,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 18,
                                  color: PdfColors.amber800,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              _ackLine(
                                'রসিদ নং:',
                                data['receiptNumber'] ?? '',
                                useFont2,
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Divider(color: PdfColors.amber300, thickness: 0.8),
                          pw.SizedBox(height: 3),
                          // Two-column layout for authority receipt
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Left column
                              pw.SizedBox(
                                width: 250,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    _ackLine(
                                      'দাতার নাম:',
                                      data['donorName'] ?? '',
                                      useFont,
                                    ),
                                    _ackLine(
                                      'মোবাইল:',
                                      data['donorPhone'] ?? '',
                                      useFont2,
                                    ),
                                    _ackLine(
                                      'অনুদানের ধরন:',
                                      data['donationType'] ?? '',
                                      useFont2,
                                    ),
                                  ],
                                ),
                              ),
                              // Right column
                              pw.SizedBox(
                                width: 250,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    _ackLine(
                                      'পরিমাণ:',
                                      '${data['amount']} টাকা',
                                      useFont2,
                                    ),
                                    _ackLine(
                                      'পেমেন্ট পদ্ধতি:',
                                      data['paymentMethod'] ?? '',
                                      useFont2,
                                    ),
                                    _ackLine(
                                      'তারিখ:',
                                      _formatDateOfBirth(donationDate),
                                      useFont2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 30),
                    pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'গ্রহণকারীর নাম'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'আহবায়ক'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: PdfColors.grey600,
                                  margin: pw.EdgeInsets.only(bottom: 4),
                                ),
                                pw.Text(
                                  'দাতা'.fix(),
                                  style: pw.TextStyle(
                                    font: useFont2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        pw.Divider(color: PdfColors.amber700, thickness: 0.8),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'সুবর্ণজয়ন্তী উদযাপন কমিটি - জাহাজমারা উচ্চ বিদ্যালয় '
                                .fix(),
                            style: pw.TextStyle(
                              font: useFont,
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save and open PDF
      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        PdfServiceWeb.downloadPdf(
          pdfBytes,
          'donation_receipt_${data['receiptNumber']}.pdf',
          onBeforeOpen,
        );
      } else {
        final outputDir = await getTemporaryDirectory();
        final filePath =
            '${outputDir.path}/donation_receipt_${data['receiptNumber']}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        if (onBeforeOpen != null) onBeforeOpen();
        await OpenFile.open(filePath);
        Get.snackbar(
          'সফল',
          'অনুদানের রসিদ পিডিএফ তৈরি হয়েছে',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error generating donation receipt PDF: $e');
      rethrow;
    }
  }

  static pw.Widget _donationField(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label.fix(),
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value.fix(),
              style: pw.TextStyle(font: font, fontSize: 12),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
