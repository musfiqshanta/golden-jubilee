import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AppCountdownService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Default dates (fallback when Firebase doesn't have data)
  static final DateTime _defaultRegistrationDeadline = DateTime(2024, 12, 31);
  static final DateTime _defaultJubileeDate = DateTime(2024, 12, 15);
  static final DateTime _defaultEidThirdDay = DateTime(
    2026,
    4,
    19,
    23,
    59,
    59,
  ); // April 19, 2026 (example date)

  // Current countdown dates
  DateTime _registrationDeadline = _defaultRegistrationDeadline;
  DateTime _jubileeDate = _defaultJubileeDate;
  DateTime _eidThirdDayDate = _defaultEidThirdDay;

  // Stream controllers for countdown updates
  final StreamController<Duration> _registrationCountdownController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _jubileeCountdownController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _eidCountdownController =
      StreamController<Duration>.broadcast();

  // Timers for countdown updates
  Timer? _registrationTimer;
  Timer? _jubileeTimer;
  Timer? _eidTimer;

  // Streams for countdown updates
  Stream<Duration> get registrationCountdownStream =>
      _registrationCountdownController.stream;
  Stream<Duration> get jubileeCountdownStream =>
      _jubileeCountdownController.stream;
  Stream<Duration> get eidCountdownStream => _eidCountdownController.stream;

  // Get current countdown values
  Duration get registrationCountdown =>
      _calculateCountdown(_registrationDeadline);
  Duration get jubileeCountdown => _calculateCountdown(_jubileeDate);
  Duration get eidCountdown => _calculateCountdown(_eidThirdDayDate);

  // Initialize the service
  Future<void> initialize() async {
    await _loadCountdownDates();
    _startTimers();
  }

  // Load countdown dates from Firebase
  Future<void> _loadCountdownDates() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('countdown').get();
      if (doc.exists) {
        final data = doc.data()!;
        _registrationDeadline =
            data['registrationDeadline'] != null
                ? (data['registrationDeadline'] as Timestamp).toDate()
                : _defaultRegistrationDeadline;
        _jubileeDate =
            data['jubileeDate'] != null
                ? (data['jubileeDate'] as Timestamp).toDate()
                : _defaultJubileeDate;
        _eidThirdDayDate =
            data['eidThirdDayDate'] != null
                ? (data['eidThirdDayDate'] as Timestamp).toDate()
                : _defaultEidThirdDay;
      }

      // Update countdowns immediately
      _updateRegistrationCountdown();
      _updateJubileeCountdown();
      _updateEidCountdown();
    } catch (e) {
      print('Error loading countdown dates: $e');
      // Use default dates on error
      _updateRegistrationCountdown();
      _updateJubileeCountdown();
      _updateEidCountdown();
    }
  }

  // Start timers for countdown updates
  void _startTimers() {
    _registrationTimer?.cancel();
    _jubileeTimer?.cancel();
    _eidTimer?.cancel();

    _registrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRegistrationCountdown();
    });

    _jubileeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateJubileeCountdown();
    });

    _eidTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateEidCountdown();
    });
  }

  // Update registration countdown
  void _updateRegistrationCountdown() {
    final countdown = _calculateCountdown(_registrationDeadline);
    _registrationCountdownController.add(countdown);
  }

  // Update jubilee countdown
  void _updateJubileeCountdown() {
    final countdown = _calculateCountdown(_jubileeDate);
    _jubileeCountdownController.add(countdown);
  }

  // Update Eid countdown
  void _updateEidCountdown() {
    final countdown = _calculateCountdown(_eidThirdDayDate);
    _eidCountdownController.add(countdown);
  }

  // Calculate countdown duration
  Duration _calculateCountdown(DateTime targetDate) {
    final now = DateTime.now();
    return targetDate.isAfter(now) ? targetDate.difference(now) : Duration.zero;
  }

  // Format countdown for display
  String formatCountdown(Duration duration) {
    if (duration.inSeconds <= 0) return 'Countdown Finished';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  // Get countdown dates for admin use
  Future<Map<String, DateTime?>> getCountdownDates() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('countdown').get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'registrationDeadline':
              data['registrationDeadline'] != null
                  ? (data['registrationDeadline'] as Timestamp).toDate()
                  : null,
          'jubileeDate':
              data['jubileeDate'] != null
                  ? (data['jubileeDate'] as Timestamp).toDate()
                  : null,
          'eidThirdDayDate':
              data['eidThirdDayDate'] != null
                  ? (data['eidThirdDayDate'] as Timestamp).toDate()
                  : null,
        };
      }
      return {
        'registrationDeadline': null,
        'jubileeDate': null,
        'eidThirdDayDate': null,
      };
    } catch (e) {
      print('Error getting countdown dates: $e');
      return {
        'registrationDeadline': null,
        'jubileeDate': null,
        'eidThirdDayDate': null,
      };
    }
  }

  // Dispose resources
  void dispose() {
    _registrationTimer?.cancel();
    _jubileeTimer?.cancel();
    _eidTimer?.cancel();
    _registrationCountdownController.close();
    _jubileeCountdownController.close();
    _eidCountdownController.close();
  }
}
