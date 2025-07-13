import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PdfService {
  // Remove static font fields and manual font loading

  static Future<void> generateRegistrationPdfFromData(
    Map<String, dynamic> data,
  ) async {
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
                              'সুবর্ণজয়ন্তী নিবন্ধন'.fix(),
                              style: pw.TextStyle(
                                font: useFont,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'জাহাজমারা উচ্চ বিদ্যালয়'.fix(),
                              style: pw.TextStyle(font: useFont, fontSize: 14),
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
                  padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'রেজিস্ট্রেশন তারিখঃ ${registrationDate.year}-${registrationDate.month.toString().padLeft(2, '0')}-${registrationDate.day.toString().padLeft(2, '0')}'
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
                  children: [
                    // Row 1: Personal | Academic
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
                                'নামঃ',
                                (data['name'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'পিতার নামঃ',
                                (data['fatherName'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'মাতার নামঃ',
                                (data['motherName'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'লিঙ্গঃ',
                                (data['gender'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জন্ম তারিখঃ',
                                (data['dateOfBirth'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জাতীয় পরিচয়পত্রঃ',
                                (data['nationalId'] ?? '').toString(),
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
                                isRunningStudent
                                    ? 'শিক্ষাগত তথ্য (বর্তমানে অধ্যয়নরত)'.fix()
                                    : 'শিক্ষাগত তথ্য (প্রাক্তন ছাত্র)'.fix(),
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
                                  'সালঃ',
                                  (data['year'] ?? '').toString(),
                                  useFont2,
                                  useFont,
                                ),
                              ] else ...[
                                _twoLineField(
                                  'এসএসসি পাসের সালঃ',
                                  (data['sscPassingYear'] ?? '').toString(),
                                  useFont2,
                                  useFont,
                                ),
                                _twoLineFieldEnglish(
                                  'Tshirt Size:',
                                  (data['tshirtSize'] ?? '').toString(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Row 2: Contact | Additional
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
                                'মোবাইলঃ',
                                (data['mobile'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineFieldEnglish(
                                'Email:',
                                (data['email'] ?? '').toString(),
                              ),
                              _twoLineField(
                                'স্থায়ী ঠিকানাঃ',
                                (data['permanentAddress'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'বর্তমান ঠিকানাঃ',
                                (data['presentAddress'] ?? '').toString(),
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
                                'পেশাঃ',
                                (data['occupation'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'পদবিঃ',
                                (data['designation'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'কর্মস্থলঃ',
                                (data['workplaceAddress'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'ধর্মঃ',
                                (data['religion'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),
                              _twoLineField(
                                'জাতীয়তাঃ',
                                (data['nationality'] ?? '').toString(),
                                useFont2,
                                useFont,
                              ),

                              _twoLineField(
                                'অতিথীঃ',
                                totalGuest.toString(),
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
                  margin: pw.EdgeInsets.symmetric(vertical: 20),
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
                        'প্রাপ্তি স্বীকারপত্র'.fix(),
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
                        'ফর্ম ক্রমিক নংঃ',
                        (data['formSerialNumber'] ?? '').toString(),
                        useFont2,
                      ),
                      _ackLine(
                        'নাম:',
                        (data['name'] ?? '').toString(),
                        useFont,
                      ),
                      if (isRunningStudent)
                        _ackLine(
                          'বর্তমানে শ্রেণিঃ',
                          (data['finalClass'] ?? '').toString(),
                          useFont,
                        )
                      else
                        _ackLine(
                          'এসএসসি ব্যাচঃ',
                          (data['sscPassingYear'] ?? '').toString(),
                          useFont2,
                        ),
                      _ackLine(
                        'পিতার নামঃ',
                        (data['fatherName'] ?? '').toString(),
                        useFont2,
                      ),
                      _ackLine(
                        'লিঙ্গঃ',
                        (data['gender'] ?? '').toString(),
                        useFont,
                      ),
                      _ackLine('অতিথীঃ', totalGuest.toString(), useFont2),
                      _ackLine('মোট টাকাঃ', totalAmount.toString(), useFont2),
                      _ackLineEng(
                        'Tshirt Size:',
                        (data['tshirtSize'] ?? '').toString(),
                        useFont2,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 100),
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
                          'হিসাবরক্ষক'.fix(),
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
                pw.Divider(color: PdfColors.amber700, thickness: 0.8),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'সুবর্ণজয়ন্তী - জাহাজমারা উচ্চ বিদ্যালয় '.fix(),
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
              ..setAttribute('download', 'registration_${data['mobile']}.pdf')
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
        final filePath = '${outputDir.path}/registration_${data['mobile']}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
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
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label.fix(),
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 180,
          child: pw.Text(
            value.fix(),
            style: pw.TextStyle(font: font2, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _twoLineFieldEnglish(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10)),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 180,
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static pw.Widget _ackLine(String label, String value, pw.Font font) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label.fix(),
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 180,
          child: pw.Text(
            value.fix(),
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _ackLineEng(String label, String value, pw.Font font) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(label.fix(), style: pw.TextStyle(fontSize: 10)),
        ),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 180,
          child: pw.Text(value.fix(), style: pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}
