import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app/modules/registration/views/registration_page.dart';
import 'app/modules/registration/bindings/registration_binding.dart';
import 'firebase_options.dart';
import 'config/collection_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/modules/registration/views/registered_page.dart';
import 'app/modules/registration/views/approved_users_page.dart';
import 'app/modules/registration/views/check_registration_page.dart';
import 'app/modules/donation/views/donation_home_page.dart';
import 'app/modules/donation/views/verify_user_page.dart';
import 'app/modules/donation/views/anonymous_donation_page.dart';
import 'app/modules/donation/views/check_donation_page.dart';
import 'app/modules/donation/views/donation_form_page.dart';
import 'app/modules/donation/bindings/donation_binding.dart';
import 'admin_panel/screens/login_screen.dart';
import 'admin_panel/screens/dashboard_screen.dart';

import 'admin_panel/screens/payments_screen.dart';
import 'admin_panel/screens/donations_screen.dart';
import 'admin_panel/screens/add_donation_screen.dart';
import 'admin_panel/screens/edit_donation_screen.dart';
import 'admin_panel/screens/search_user_screen.dart';
import 'admin_panel/screens/countdown_settings_screen.dart';
import 'services/countdown_service.dart';
import 'admin_panel/services/counter_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment - change this to Environment.development for testing
  CollectionConfig.setEnvironment(Environment.development);

  // Initialize Firebase (same project, different collections)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Print environment info
  if (CollectionConfig.isDevelopment) {
    print('🔥 Running in DEVELOPMENT mode - using _dev collections');
  } else {
    print('🚀 Running in PRODUCTION mode - using live collections');
  }

  // Configure GetX for clean URLs
  Get.config(defaultTransition: Transition.noTransition, enableLog: true);

  runApp(const GoldenJubileeApp());
}

class GoldenJubileeApp extends StatelessWidget {
  const GoldenJubileeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:
          CollectionConfig.isDevelopment
              ? 'Golden Jubilee (DEV)'
              : 'Golden Jubilee Celebration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Golden color
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      initialBinding: RegistrationBinding(),
      home: const GoldenJubileeHomePage(),
      debugShowCheckedModeBanner: CollectionConfig.isDevelopment,
      // Enable clean URLs without hash
      defaultTransition: Transition.noTransition,
      routingCallback: (routing) {
        if (routing?.current != null) {
          print('Current route: ${routing!.current}');
        }
      },
      // Configure for clean URLs
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const GoldenJubileeHomePage()),
        GetPage(
          name: '/registration',
          page: () => RegistrationPage(),
          binding: RegistrationBinding(),
        ),
        GetPage(name: '/registered', page: () => RegisteredPage()),
        GetPage(name: '/approved-users', page: () => ApprovedUsersPage()),
        GetPage(
          name: '/check-registration',
          page: () => CheckRegistrationPage(),
        ),
        // Donation routes
        GetPage(
          name: '/donation',
          page: () => const DonationHomePage(),
          binding: DonationBinding(),
        ),
        GetPage(
          name: '/donation/verify-user',
          page: () => const VerifyUserPage(),
          binding: DonationBinding(),
        ),
        GetPage(
          name: '/donation/anonymous',
          page: () => const AnonymousDonationPage(),
          binding: DonationBinding(),
        ),
        GetPage(
          name: '/donation/check',
          page: () => const CheckDonationPage(),
          binding: DonationBinding(),
        ),
        GetPage(
          name: '/donation/form',
          page: () => const DonationFormPage(),
          binding: DonationBinding(),
        ),
        // Admin panel routes
        GetPage(name: '/admin', page: () => const LoginScreen()),
        GetPage(name: '/admin/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/admin/payments', page: () => const PaymentsScreen()),
        GetPage(name: '/admin/donations', page: () => const DonationsScreen()),
        GetPage(
          name: '/admin/add-donation',
          page: () => const AddDonationScreen(),
        ),
        GetPage(
          name: '/admin/edit-donation',
          page: () => const EditDonationScreen(),
        ),
        GetPage(
          name: '/admin/search-user',
          page: () => const SearchUserScreen(),
        ),
        GetPage(
          name: '/admin/countdown-settings',
          page: () => const CountdownSettingsScreen(),
        ),
      ],
    );
  }
}

class GoldenJubileeHomePage extends StatefulWidget {
  const GoldenJubileeHomePage({super.key});

  @override
  State<GoldenJubileeHomePage> createState() => _GoldenJubileeHomePageState();
}

class _GoldenJubileeHomePageState extends State<GoldenJubileeHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Countdown service
  final AppCountdownService _countdownService = AppCountdownService();

  // Countdown durations
  Duration _registrationCountdown = Duration.zero;
  Duration _jubileeCountdown = Duration.zero;

  // Statistics data - loaded once when page loads
  int _totalRegistrations = 0;
  double _totalCollections = 0.0;
  int _totalApprovedUsers = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();

    // Initialize countdown service
    _countdownService.initialize();

    // Listen to countdown updates
    _countdownService.registrationCountdownStream.listen((duration) {
      setState(() {
        _registrationCountdown = duration;
      });
    });

    _countdownService.jubileeCountdownStream.listen((duration) {
      setState(() {
        _jubileeCountdown = duration;
      });
    });

    // Load statistics once when page loads
    _loadStatistics();
  }

  // Load statistics data once
  Future<void> _loadStatistics() async {
    try {
      final futures = await Future.wait([
        CounterService().getTotalRegistrationsCount(),
        CounterService().getTotalCollectionsAmount(),
        CounterService().getTotalApprovedUsersCount(),
      ]);

      setState(() {
        _totalRegistrations = futures[0] as int;
        _totalCollections = futures[1] as double;
        _totalApprovedUsers = futures[2] as int;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _countdownService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section (with countdown)
            _buildHeroSection(),

            // 250 Days Countdown Section
            _buildTwoFiftyCountdownSection(),

            // Events Section
            _buildEventsSection(),

            // About Section
            _buildAboutSection(),

            // Contact Section
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final days = _registrationCountdown.inDays;
    final hours = _registrationCountdown.inHours % 24;
    final minutes = _registrationCountdown.inMinutes % 60;
    final seconds = _registrationCountdown.inSeconds % 60;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD4AF37), Color(0xFFB8860B), Color(0xFF8B6914)],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  // height: MediaQuery.of(context).size.width > 600 ? 70 : 70,
                ),
                const SizedBox(width: 16),
                Text(
                  'সুবর্ণ জয়ন্তী',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 64 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'জাহাজমারা উচ্চ বিদ্যালয়',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '৫০ বছর পূর্তি উদযাপনে আমাদের সাথে যোগ দিন',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 18,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Calendar-style Countdown (white background, golden text)
                _buildCalendarCountdownRow(days, hours, minutes, seconds, true),
                const SizedBox(height: 30),
                // Buttons Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isVerySmall = constraints.maxWidth < 400;
                    final isMobile = constraints.maxWidth < 500;
                    final buttonPadding =
                        isMobile
                            ? const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            )
                            : const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            );
                    final buttonFontSize = isMobile ? 16.0 : 20.0;
                    if (isVerySmall) {
                      // Stack vertically for very small screens
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/registration');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFD4AF37),
                              padding: buttonPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'নিবন্ধন করুন',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/check-registration');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B6914),
                              foregroundColor: Colors.white,
                              padding: buttonPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'নিবন্ধন যাচাই করুন',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/donation');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: buttonPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'আনুদান করুন',
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Use Row with Expanded for normal screens
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('/registration');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFD4AF37),
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'নিবন্ধন করুন',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('/check-registration');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B6914),
                                foregroundColor: Colors.white,
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'নিবন্ধন যাচাই করুন',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('/donation');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  0,
                                  119,
                                  109,
                                ),
                                foregroundColor: Colors.white,
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'আনুদান করুন',
                                style: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 30),
                // Total Registration Display (Styled, with live count)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    final isBigScreen = constraints.maxWidth > 1200;

                    final children = [
                      // মোট নিবন্ধন
                      Tooltip(
                        message: 'নিবন্ধিত ব্যক্তিদের তালিকা দেখুন',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              print('Total registration tapped');
                              Get.toNamed('/registered');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'মোট নিবন্ধন: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40, // reduced from 48
                                    child:
                                        _isLoadingStats
                                            ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : Text(
                                              '$_totalRegistrations',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // মোট সংগ্রহ
                      Tooltip(
                        message: 'অনুমোদিত ব্যক্তিদের তালিকা দেখুন',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              print('Total collection tapped');
                              Get.toNamed('/approved-users');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'মোট সংগ্রহ: ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60, // reduced from 70
                                        child:
                                            _isLoadingStats
                                                ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : Text(
                                                  '৳$_totalCollections',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4), // reduced from 5
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 14, // reduced from 16
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ), // reduced from 5
                                      const Text(
                                        'অনুমোদিত: ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11, // reduced from 12
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25, // reduced from 30
                                        child:
                                            _isLoadingStats
                                                ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : Text(
                                                  '$_totalApprovedUsers',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // মোট অনুদান
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'মোট অনুদান: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 60, // reduced from 70
                              child: FutureBuilder<QuerySnapshot>(
                                future:
                                    FirebaseFirestore.instance
                                        .collection('donations')
                                        .where('status', isEqualTo: 'approved')
                                        .get(),
                                builder: (context, snapshot) {
                                  double totalDonation = 0;
                                  if (snapshot.hasData) {
                                    for (var doc in snapshot.data!.docs) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      totalDonation +=
                                          (data['amount'] ?? 0) as num;
                                    }
                                  }
                                  return Text(
                                    '৳$totalDonation',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];

                    if (isMobile) {
                      // Mobile: Stack vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      );
                    } else {
                      // Medium and Big screens: All 3 in same row
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: children,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoFiftyCountdownSection() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final isMobile = MediaQuery.of(context).size.width < 400;
    final cardWidth = isMobile ? 60.0 : (isWide ? 120.0 : 80.0);
    final cardHeight = isMobile ? 60.0 : (isWide ? 120.0 : 80.0);
    final textSize = isMobile ? 16.0 : (isWide ? 32.0 : 24.0);
    final labelSize = isMobile ? 10.0 : (isWide ? 14.0 : 12.0);
    final spacing = isMobile ? 8.0 : 20.0;
    final titleSize = isMobile ? 18.0 : (isWide ? 32.0 : 22.0);
    final days = _jubileeCountdown.inDays;
    final hours = _jubileeCountdown.inHours % 24;
    final minutes = _jubileeCountdown.inMinutes % 60;
    final seconds = _jubileeCountdown.inSeconds % 60;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 30.0 : 40.0,
        horizontal: 20,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'সুবর্ণজয়ন্তী উদযাপন',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B6914),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 20.0 : 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownCard(
                'দিন',
                days.toString(),
                cardWidth,
                cardHeight,
                textSize,
                labelSize,
                const Color(0xFFD4AF37),
                Colors.white,
                Colors.white70,
              ),
              SizedBox(width: spacing),
              _buildCountdownCard(
                'ঘন্টা',
                hours.toString().padLeft(2, '0'),
                cardWidth,
                cardHeight,
                textSize,
                labelSize,
                const Color(0xFFD4AF37),
                Colors.white,
                Colors.white70,
              ),
              SizedBox(width: spacing),
              _buildCountdownCard(
                'মিনিট',
                minutes.toString().padLeft(2, '0'),
                cardWidth,
                cardHeight,
                textSize,
                labelSize,
                const Color(0xFFD4AF37),
                Colors.white,
                Colors.white70,
              ),
              SizedBox(width: spacing),
              _buildCountdownCard(
                'সেকেন্ড',
                seconds.toString().padLeft(2, '0'),
                cardWidth,
                cardHeight,
                textSize,
                labelSize,
                const Color(0xFFD4AF37),
                Colors.white,
                Colors.white70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCountdownRow(
    int days,
    int hours,
    int minutes,
    int seconds,
    bool isHero,
  ) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final isMobile = MediaQuery.of(context).size.width < 400;
    final cardWidth = isMobile ? 60.0 : (isWide ? 120.0 : 80.0);
    final cardHeight = isMobile ? 60.0 : (isWide ? 120.0 : 80.0);
    final textSize = isMobile ? 16.0 : (isWide ? 32.0 : 24.0);
    final labelSize = isMobile ? 10.0 : (isWide ? 14.0 : 12.0);
    final spacing = isMobile ? 8.0 : 16.0;
    final bgColor = isHero ? Colors.white : const Color(0xFFD4AF37);
    final valueColor = isHero ? const Color(0xFFD4AF37) : Colors.white;
    final labelColor = isHero ? const Color(0xFFD4AF37) : Colors.white70;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCountdownCard(
          'দিন',
          days.toString(),
          cardWidth,
          cardHeight,
          textSize,
          labelSize,
          bgColor,
          valueColor,
          labelColor,
        ),
        SizedBox(width: spacing),
        _buildCountdownCard(
          'ঘন্টা',
          hours.toString().padLeft(2, '0'),
          cardWidth,
          cardHeight,
          textSize,
          labelSize,
          bgColor,
          valueColor,
          labelColor,
        ),
        SizedBox(width: spacing),
        _buildCountdownCard(
          'মিনিট',
          minutes.toString().padLeft(2, '0'),
          cardWidth,
          cardHeight,
          textSize,
          labelSize,
          bgColor,
          valueColor,
          labelColor,
        ),
        SizedBox(width: spacing),
        _buildCountdownCard(
          'সেকেন্ড',
          seconds.toString().padLeft(2, '0'),
          cardWidth,
          cardHeight,
          textSize,
          labelSize,
          bgColor,
          valueColor,
          labelColor,
        ),
      ],
    );
  }

  Widget _buildCountdownCard(
    String label,
    String value,
    double width,
    double height,
    double valueSize,
    double labelSize,
    Color bgColor,
    Color valueColor,
    Color labelColor,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          Text(
            'উদযাপনের অনুষ্ঠানসমূহ',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B6914),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildEventCard(
                'উদ্বোধনী অনুষ্ঠান',
                '৫০ বছর পূর্তি উদযাপনের জাঁকজমকপূর্ণ উদ্বোধন',
                Icons.event,
                ' ফেব্রুয়ারি , ২০২৬',
              ),
              _buildEventCard(
                'গালা লাঞ্চ',
                ' লাঞ্চ, সুস্বাদু খাবার ও বিনোদন',
                Icons.restaurant,
                'ফেব্রুয়ারি , ২০২৬',
              ),
              _buildEventCard(
                'সাংস্কৃতিক অনুষ্ঠান',
                'আমাদের সমৃদ্ধ ঐতিহ্য ও সাংস্কৃতিক বৈচিত্র্য উপস্থাপন',
                Icons.music_note,
                'ফেব্রুয়ারি, ২০২৬',
              ),
              _buildEventCard(
                'সমাপনী অনুষ্ঠান',
                'সুবর্ণজয়ন্তী উদযাপনের স্মরণীয় সমাপ্তি',
                Icons.celebration,
                'ফেব্রুয়ারি, ২০২৬',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    IconData icon,
    String date,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // You can add navigation or show details here
          Get.snackbar(
            title,
            description,
            backgroundColor: const Color(0xFFD4AF37),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width > 600 ? 300 : 280,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B6914),
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'আমাদের যাত্রা',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B6914),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              if (MediaQuery.of(context).size.width > 600)
                Expanded(
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.history_edu,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (MediaQuery.of(context).size.width > 600)
                const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '৫০ বছরের শ্রেষ্ঠত্ব',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6914),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'অর্ধশতাব্দী ধরে আমরা উদ্ভাবন, শ্রেষ্ঠত্ব ও সমাজসেবার অগ্রভাগে রয়েছি। আমাদের যাত্রা শুরু হয়েছিল অসাধারণ কিছু গড়ার স্বপ্ন নিয়ে, আজ আমরা শুধু আমাদের অর্জন নয়, অসংখ্য মানুষের জীবনে ছোঁয়া ও আমাদের উত্তরাধিকার উদযাপন করছি।',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildAchievementCard('৫০+', 'বছর'),
                        const SizedBox(width: 20),
                        _buildAchievementCard('১০০০+', 'স্পর্শকৃত জীবন'),
                        const SizedBox(width: 20),
                        _buildAchievementCard('১০০+', 'পুরস্কার'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20.0 : 80.0,
        horizontal: 20,
      ),
      color: const Color(0xFF8B6914),
      child: Column(
        children: [
          Text(
            'যোগাযোগ করুন',
            style: TextStyle(
              fontSize: isMobile ? 24.0 : 36.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 20.0 : 40.0),
          if (isMobile)
            // Mobile layout - vertical stack
            Column(
              children: [
                _buildContactItem(
                  Icons.email,
                  'jhsgoldenjubilee2026@gmail.com',
                ),
                const SizedBox(height: 15),
                _buildContactItem(
                  Icons.phone,
                  '০১৮২২৯৯৯৯৭১ (আহবায়ক),\n০১৩০৯১০৭৬৩৬ (প্রধান শিক্ষক),\n০১৭৩৯৪৬৬৮৯০ (সচিব)',
                ),
                const SizedBox(height: 15),
                _buildContactItem(
                  Icons.location_on,
                  'জাহাজমারা উচ্চ বিদ্যালয়,জাহাজমারা,হাতিয়া,নোয়াখালী',
                ),
              ],
            )
          else
            // Desktop layout - horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactItem(
                  Icons.email,
                  'jhsgoldenjubilee2026@gmail.com',
                ),
                const SizedBox(width: 40),
                _buildContactItem(
                  Icons.phone,
                  '০১৮২২৯৯৯৯৭১ (আহবায়ক), ০১৩০৯১০৭৬৩৬ (প্রধান শিক্ষক), ০১৭৩৯৪৬৬৮৯০ (সচিব)',
                ),
                const SizedBox(width: 40),
                _buildContactItem(
                  Icons.location_on,
                  'জাহাজমারা উচ্চ বিদ্যালয়,জাহাজমারা,হাতিয়া,নোয়াখালী',
                ),
              ],
            ),
          SizedBox(height: isMobile ? 20.0 : 40.0),
          Divider(),
          const Text(
            '© ২০২৪ সুবর্ণজয়ন্তী উদযাপন। সর্বস্বত্ব সংরক্ষিত।',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    // Special handling for email
    if (icon == Icons.email) {
      return Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final uri = Uri(scheme: 'mailto', path: text);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Tooltip(
                message: 'ক্লিক করুন ইমেইল পাঠাতে বা কপি করতে',
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    // Removed underline
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      );
    }
  }
}
