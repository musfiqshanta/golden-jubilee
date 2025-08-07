import 'package:flutter/material.dart';

class PdfServiceWeb {
  static void downloadPdf(
    List<int> pdfBytes,
    String fileName,
    VoidCallback? onBeforeOpen,
  ) {
    // This is a stub for mobile platforms
    // The actual implementation is handled in the main PdfService class
    if (onBeforeOpen != null) onBeforeOpen();
  }
}
