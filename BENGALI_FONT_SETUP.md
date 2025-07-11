# Bengali Font Setup for PDF Generation

## Problem

Bengali text appears as boxes (□□□) in the generated PDF because the PDF library doesn't have built-in support for Bengali fonts.

## Solution

We need to add a Bengali font to the project and configure the PDF generation to use it.

## Steps to Fix

### 1. Download Bengali Font

1. Go to Google Fonts: https://fonts.google.com/noto/specimen/Noto+Sans+Bengali
2. Click "Download family"
3. Extract the ZIP file
4. Find the file `NotoSansBengali-Regular.ttf`

### 2. Add Font to Project

1. Create the folder: `assets/fonts/` (if it doesn't exist)
2. Copy `NotoSansBengali-Regular.ttf` to `assets/fonts/`
3. The file should be at: `assets/fonts/NotoSansBengali-Regular.ttf`

### 3. Verify Configuration

The following files are already configured:

- ✅ `pubspec.yaml` - Assets folder is configured
- ✅ `lib/app/services/pdf_service.dart` - Bengali font loading is implemented
- ✅ `lib/app/services/pdf_service_web.dart` - Web Bengali font loading is implemented

### 4. Test

1. Run `flutter pub get` to update assets
2. Test PDF generation using the "পিডিএফ টেস্ট" button
3. Bengali text should now display correctly in the PDF

## Alternative Fonts

If Noto Sans Bengali doesn't work, you can try:

- SolaimanLipi.ttf (Bangla font)
- Any other Bengali TTF font

Just update the font filename in the code:

```dart
final fontData = await rootBundle.load('assets/fonts/YOUR_FONT_NAME.ttf');
```

## Fallback

If the font fails to load, the system will automatically fall back to Helvetica font, but Bengali text may still appear as boxes.
