import 'dart:html' as html;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PdfServiceWeb {
  static void downloadPdf(
    List<int> pdfBytes,
    String fileName,
    VoidCallback? onBeforeOpen,
  ) {
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName);
    if (onBeforeOpen != null) onBeforeOpen();
    anchor.click();
    html.Url.revokeObjectUrl(url);
    Get.snackbar(
      'সফল',
      'নিবন্ধন পিডিএফ ডাউনলোড হয়েছে',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
