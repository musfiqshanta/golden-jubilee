# Suborno Joyonti - Golden Jubilee Celebration

A comprehensive Flutter web application for Jahajmara High School's 50th anniversary celebration registration system.

## Features

### 🎉 User Registration System

- **Student Registration**: For current students and alumni
- **Photo Upload**: Profile picture upload functionality
- **PDF Generation**: Automatic registration certificate with Bengali text
- **Form Validation**: Comprehensive form validation
- **Responsive Design**: Works on desktop and mobile devices

### 🔧 Admin Panel

- **User Management**: View and manage all registrations
- **Payment Tracking**: Monitor registration payments
- **Donation Management**: Track and manage donations
- **Search Functionality**: Search users by various criteria
- **Data Export**: Export registration data

### 📄 PDF Features

- **Bengali Text Support**: Proper rendering of Bengali text
- **Professional Layout**: School branding and design
- **Two-Page Format**: Student copy and school authority copy
- **Automatic Generation**: Generated after successful registration

## Technology Stack

- **Framework**: Flutter 3.32.7
- **State Management**: GetX
- **Backend**: Firebase (Firestore, Auth)
- **PDF Generation**: pdf package with Bengali font support
- **UI**: Material Design 3 with custom theming

## Getting Started

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd suborno_joyonti
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Set up Firebase project
   - Update `firebase_options.dart` with your configuration
   - Enable Firestore and Authentication

4. **Run the application**
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── modules/registration/ # Registration system
│   ├── services/            # Business logic & PDF generation
│   └── widgets/             # Reusable UI components
├── admin_panel/             # Admin dashboard
└── controllers/             # GetX controllers
```

## Bengali Font Setup

The project includes proper Bengali font support for PDF generation. See `BENGALI_FONT_SETUP.md` for detailed configuration.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request

## License

This project is for Jahajmara High School's Golden Jubilee Celebration.
