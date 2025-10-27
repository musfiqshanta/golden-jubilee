enum Environment { development, production }

class CollectionConfig {
  static Environment _environment = Environment.production;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;

  // Collection names with environment suffix
  static String get batchesCollection =>
      isDevelopment ? 'batches_dev' : 'batches';

  static String get registrationsCollection =>
      isDevelopment ? 'registrations_dev' : 'registrations';

  static String get donationsCollection =>
      isDevelopment ? 'donations_dev' : 'donations';

  static String get paymentsCollection =>
      isDevelopment ? 'payments_dev' : 'payments';

  static String get adminCollection => isDevelopment ? 'admin_dev' : 'admin';

  static String get settingsCollection =>
      isDevelopment ? 'settings_dev' : 'settings';

  // Helper method to get collection with environment suffix
  static String getCollectionName(String baseName) {
    return isDevelopment ? '${baseName}_dev' : baseName;
  }
}
