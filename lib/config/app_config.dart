
/// Application Configuration
/// Handles environment-specific settings and development mode detection
class AppConfig {
  // ============================================================================
  // ENVIRONMENT DETECTION
  // ============================================================================

  /// Check if running in development mode
  static bool get isDevelopment {
    // Force development mode for testing
    return true; // kDebugMode || _isDevelopmentEnvironment;
  }

  /// Check if running in production mode
  static bool get isProduction {
    return !isDevelopment;
  }

  /// Manual development mode override (set to true for testing)
  static const bool _isDevelopmentEnvironment =
      true; // Set to false for production

  // ============================================================================
  // DEVELOPMENT MODE SETTINGS
  // ============================================================================

  /// Show test data instead of real Firebase data in development mode
  static bool get useTestData => isDevelopment;

  /// Show development mode indicator in UI
  static bool get showDevModeIndicator => isDevelopment;

  /// Use mock payment responses in development
  static bool get useMockPayments => isDevelopment;

  // ============================================================================
  // TEST DATA CONFIGURATION
  // ============================================================================

  /// Test data for development mode
  static const Map<String, dynamic> testData = {
    'totalRegistrations': 25,
    'totalGuests': 45,
    'totalDonationRequests': 8,
    'totalApprovedDonations': 15000.0,
    'totalCollections': 25000.0,
    'totalApprovedUsers': 20,
  };

  /// Test donation data
  static const List<Map<String, dynamic>> testDonations = [
    {
      'id': 'test_donation_1',
      'amount': 5000.0,
      'donorName': 'Test Donor 1',
      'donorEmail': 'test1@example.com',
      'donorPhone': '01711111111',
      'donationType': 'সাধারণ অনুদান',
      'status': 'approved',
      'timestamp': '2024-01-15T10:30:00Z',
    },
    {
      'id': 'test_donation_2',
      'amount': 3000.0,
      'donorName': 'Test Donor 2',
      'donorEmail': 'test2@example.com',
      'donorPhone': '01722222222',
      'donationType': 'বিশেষ অনুদান',
      'status': 'pending',
      'timestamp': '2024-01-16T14:20:00Z',
    },
    {
      'id': 'test_donation_3',
      'amount': 7000.0,
      'donorName': 'Test Donor 3',
      'donorEmail': 'test3@example.com',
      'donorPhone': '01733333333',
      'donationType': 'সাধারণ অনুদান',
      'status': 'approved',
      'timestamp': '2024-01-17T09:15:00Z',
    },
  ];

  /// Test registration data
  static const List<Map<String, dynamic>> testRegistrations = [
    {
      'id': 'test_reg_1',
      'name': 'Test User 1',
      'email': 'user1@example.com',
      'phone': '01711111111',
      'spouseCount': 1,
      'childCount': 2,
      'totalPayable': 1200.0,
      'paymentStatus': 'approved',
      'registrationDate': '2024-01-10T08:00:00Z',
    },
    {
      'id': 'test_reg_2',
      'name': 'Test User 2',
      'email': 'user2@example.com',
      'phone': '01722222222',
      'spouseCount': 0,
      'childCount': 1,
      'totalPayable': 800.0,
      'paymentStatus': 'pending',
      'registrationDate': '2024-01-12T10:30:00Z',
    },
    {
      'id': 'test_reg_3',
      'name': 'Test User 3',
      'email': 'user3@example.com',
      'phone': '01733333333',
      'spouseCount': 1,
      'childCount': 0,
      'totalPayable': 1000.0,
      'paymentStatus': 'approved',
      'registrationDate': '2024-01-14T15:45:00Z',
    },
  ];

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get test data for a specific key
  static dynamic getTestData(String key) {
    return testData[key] ?? 0;
  }

  /// Get all test data
  static Map<String, dynamic> getAllTestData() {
    return Map.from(testData);
  }

  /// Print current configuration
  static void printConfig() {
    print('🔧 App Configuration:');
    print('   Development Mode: $isDevelopment');
    print('   Use Test Data: $useTestData');
    print('   Show Dev Indicator: $showDevModeIndicator');
    print('   Use Mock Payments: $useMockPayments');
  }

  /// Test method to verify configuration is working
  static void testConfig() {
    print('🧪 TESTING APP CONFIG:');
    print('   isDevelopment: $isDevelopment');
    print('   useTestData: $useTestData');
    print('   Test data totalRegistrations: ${testData['totalRegistrations']}');
    print(
      '   getTestData("totalRegistrations"): ${getTestData("totalRegistrations")}',
    );
  }
}
