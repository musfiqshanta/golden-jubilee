import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'app/modules/registration/views/registration_page.dart';
import 'app/modules/registration/bindings/registration_binding.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/modules/registration/views/registered_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GoldenJubileeApp());
}

class GoldenJubileeApp extends StatelessWidget {
  const GoldenJubileeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Golden Jubilee Celebration',
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
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/registration',
          page: () => RegistrationPage(),
          binding: RegistrationBinding(),
        ),
        GetPage(name: '/registered', page: () => RegisteredPage()),
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

  // Countdown for next 4 months
  late DateTime _fourMonthsLater;
  Duration _fourMonthCountdown = Duration.zero;
  Timer? _fourMonthTimer;

  // Countdown to celebration event
  final DateTime _eventDate = DateTime(2024, 12, 15, 0, 0, 0);
  Duration _eventCountdown = Duration.zero;
  Timer? _eventTimer;

  // Countdown for 250 days
  late DateTime _twoFiftyDaysLater;
  Duration _twoFiftyCountdown = Duration.zero;
  Timer? _twoFiftyTimer;

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

    // Countdown for next 4 months
    _fourMonthsLater = DateTime.now().add(const Duration(days: 30 * 4));
    _updateFourMonthCountdown();
    _fourMonthTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateFourMonthCountdown();
    });

    // Countdown to event
    _updateEventCountdown();
    _eventTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateEventCountdown();
    });

    // Countdown for 250 days
    _twoFiftyDaysLater = DateTime.now().add(const Duration(days: 250));
    _updateTwoFiftyCountdown();
    _twoFiftyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTwoFiftyCountdown();
    });
  }

  void _updateFourMonthCountdown() {
    final now = DateTime.now();
    setState(() {
      _fourMonthCountdown =
          _fourMonthsLater.isAfter(now)
              ? _fourMonthsLater.difference(now)
              : Duration.zero;
    });
  }

  void _updateEventCountdown() {
    final now = DateTime.now();
    setState(() {
      _eventCountdown =
          _eventDate.isAfter(now) ? _eventDate.difference(now) : Duration.zero;
    });
  }

  void _updateTwoFiftyCountdown() {
    final now = DateTime.now();
    setState(() {
      _twoFiftyCountdown =
          _twoFiftyDaysLater.isAfter(now)
              ? _twoFiftyDaysLater.difference(now)
              : Duration.zero;
    });
  }

  String _formatFourMonthCountdown() {
    if (_fourMonthCountdown.inSeconds <= 0) return 'Countdown Finished';
    final days = _fourMonthCountdown.inDays;
    final hours = _fourMonthCountdown.inHours % 24;
    final minutes = _fourMonthCountdown.inMinutes % 60;
    final seconds = _fourMonthCountdown.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _fourMonthTimer?.cancel();
    _eventTimer?.cancel();
    _twoFiftyTimer?.cancel();
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
    final days = _fourMonthCountdown.inDays;
    final hours = _fourMonthCountdown.inHours % 24;
    final minutes = _fourMonthCountdown.inMinutes % 60;
    final seconds = _fourMonthCountdown.inSeconds % 60;
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
                  'সুবর্ণজয়ন্তী',
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
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/registration');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'নিবন্ধন করুন',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Total Registration Display (Styled, with live count)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    final children = [
                      // মোট নিবন্ধন
                      GestureDetector(
                        onTap: () {
                          print('Total registration tapped');
                          Get.toNamed('/registered');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
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
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'মোট নিবন্ধন: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width:
                                    48, // enough for spinner or 4-digit number
                                child: StreamBuilder<QuerySnapshot>(
                                  stream:
                                      FirebaseFirestore.instance
                                          .collectionGroup('registrations')
                                          .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        '0',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                    final total = snapshot.data!.size;
                                    return Text(
                                      '$total',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                      ),
                      // মোট সংগ্রহ
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
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
                          children: const [
                            Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'মোট সংগ্রহ: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // মোট অনুদান
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
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
                          children: const [
                            Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'মোট অনুদান: ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      );
                    } else {
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
    final days = _twoFiftyCountdown.inDays;
    final hours = _twoFiftyCountdown.inHours % 24;
    final minutes = _twoFiftyCountdown.inMinutes % 60;
    final seconds = _twoFiftyCountdown.inSeconds % 60;
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
                '১৫ ডিসেম্বর, ২০২৪',
              ),
              _buildEventCard(
                'গালা ডিনার',
                'বর্ণাঢ্য সন্ধ্যায় সুস্বাদু খাবার ও বিনোদন',
                Icons.restaurant,
                '১৬ ডিসেম্বর, ২০২৪',
              ),
              _buildEventCard(
                'সাংস্কৃতিক অনুষ্ঠান',
                'আমাদের সমৃদ্ধ ঐতিহ্য ও সাংস্কৃতিক বৈচিত্র্য উপস্থাপন',
                Icons.music_note,
                '১৭ ডিসেম্বর, ২০২৪',
              ),
              _buildEventCard(
                'সমাপনী অনুষ্ঠান',
                'সুবর্ণজয়ন্তী উদযাপনের স্মরণীয় সমাপ্তি',
                Icons.celebration,
                '১৮ ডিসেম্বর, ২০২৪',
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
    return Container(
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
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
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
        vertical: isMobile ? 40.0 : 80.0,
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
                _buildContactItem(Icons.email, 'info@goldenjubilee.com'),
                const SizedBox(height: 15),
                _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
                const SizedBox(height: 15),
                _buildContactItem(Icons.location_on, '১২৩ উদযাপন এভিনিউ'),
              ],
            )
          else
            // Desktop layout - horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactItem(Icons.email, 'info@goldenjubilee.com'),
                const SizedBox(width: 40),
                _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
                const SizedBox(width: 40),
                _buildContactItem(Icons.location_on, '123 Celebration Ave'),
              ],
            ),
          SizedBox(height: isMobile ? 20.0 : 40.0),
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
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
