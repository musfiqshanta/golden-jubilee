import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AppCountdownService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Default dates (fallback when Firebase doesn't have data)
  static final DateTime _defaultRegistrationDeadline = DateTime(2024, 12, 31);
  static final DateTime _defaultJubileeDate = DateTime(2024, 12, 15);
  
  // Current countdown dates
  DateTime _registrationDeadline = _defaultRegistrationDeadline;
  DateTime _jubileeDate = _defaultJubileeDate;
  
  // Stream controllers for countdown updates
  final StreamController<Duration> _registrationCountdownController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _jubileeCountdownController = StreamController<Duration>.broadcast();
  
  // Timers for countdown updates
  Timer? _registrationTimer;
  Timer? _jubileeTimer;
  
  // Streams for countdown updates
  Stream<Duration> get registrationCountdownStream => _registrationCountdownController.stream;
  Stream<Duration> get jubileeCountdownStream => _jubileeCountdownController.stream;
  
  // Get current countdown values
  Duration get registrationCountdown => _calculateCountdown(_registrationDeadline);
  Duration get jubileeCountdown => _calculateCountdown(_jubileeDate);
  
  // Initialize the service
  Future<void> initialize() async {
    await _loadCountdownDates();
    _startTimers();
  }
  
  // Load countdown dates from Firebase
  Future<void> _loadCountdownDates() async {
    try {
      final doc = await _firestore.collection('settings').doc('countdown').get();
      if (doc.exists) {
        final data = doc.data()!;
        _registrationDeadline = data['registrationDeadline'] != null
            ? (data['registrationDeadline'] as Timestamp).toDate()
            : _defaultRegistrationDeadline;
        _jubileeDate = data['jubileeDate'] != null
            ? (data['jubileeDate'] as Timestamp).toDate()
            : _defaultJubileeDate;
      }
      
      // Update countdowns immediately
      _updateRegistrationCountdown();
      _updateJubileeCountdown();
    } catch (e) {
      print('Error loading countdown dates: $e');
      // Use default dates on error
      _updateRegistrationCountdown();
      _updateJubileeCountdown();
    }
  }
  
  // Start timers for countdown updates
  void _startTimers() {
    _registrationTimer?.cancel();
    _jubileeTimer?.cancel();
    
    _registrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRegistrationCountdown();
    });
    
    _jubileeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateJubileeCountdown();
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
      final doc = await _firestore.collection('settings').doc('countdown').get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'registrationDeadline': data['registrationDeadline'] != null
              ? (data['registrationDeadline'] as Timestamp).toDate()
              : null,
          'jubileeDate': data['jubileeDate'] != null
              ? (data['jubileeDate'] as Timestamp).toDate()
              : null,
        };
      }
      return {'registrationDeadline': null, 'jubileeDate': null};
    } catch (e) {
      print('Error getting countdown dates: $e');
      return {'registrationDeadline': null, 'jubileeDate': null};
    }
  }
  
  // Dispose resources
  void dispose() {
    _registrationTimer?.cancel();
    _jubileeTimer?.cancel();
    _registrationCountdownController.close();
    _jubileeCountdownController.close();
  }
}
