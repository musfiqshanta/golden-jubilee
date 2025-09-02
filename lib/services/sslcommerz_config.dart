/// Professional SSLCommerz Configuration
/// Handles all SSLCommerz payment gateway configuration and settings
class SSLCommerzConfig {
  // ============================================================================
  // STORE CREDENTIALS
  // ============================================================================

  /// SSLCommerz Store ID (Sandbox)
  static const String storeId = "teamx68b12058b6036";

  /// SSLCommerz Store Password (Sandbox)
  static const String storePassword = "teamx68b12058b6036@ssl";

  // ============================================================================
  // ENVIRONMENT CONFIGURATION
  // ============================================================================

  /// Environment flag - set to false for production
  static const bool isSandbox = true;

  /// Currency code for transactions
  static const String currency = "BDT";

  // ============================================================================
  // CALLBACK URLS
  // ============================================================================

  /// Success callback URL - called when payment succeeds
  static const String successUrl = "http://localhost:3001/payment/success";

  /// Failure callback URL - called when payment fails
  static const String failUrl = "http://localhost:3001/payment/fail";

  /// Cancel callback URL - called when payment is cancelled
  static const String cancelUrl = "http://localhost:3001/payment/cancel";

  /// IPN (Instant Payment Notification) URL for server-to-server notifications
  static const String ipnUrl = "http://localhost:3001/payment/ipn";

  // ============================================================================
  // STORE INFORMATION
  // ============================================================================

  /// Store display name
  static const String storeName = "জাহাজমারা উচ্চ বিদ্যালয় সুবর্ণজয়ন্তী";

  /// Store description
  static const String storeDescription = "Golden Jubilee Celebration Donation";

  /// Store logo URL
  static const String storeLogo =
      "https://jubilee.jahajmarahighschool.com/assets/logo.png";

  // ============================================================================
  // CONTACT INFORMATION
  // ============================================================================

  /// Store physical address
  static const String storeAddress = "জাহাজমারা, হাতিয়া, নোয়াখালী";

  /// Store city
  static const String storeCity = "নোয়াখালী";

  /// Store postal code
  static const String storePostcode = "3800";

  /// Store country
  static const String storeCountry = "Bangladesh";

  /// Store contact phone
  static const String storePhone = "01767122407";

  // ============================================================================
  // PAYMENT SETTINGS
  // ============================================================================

  /// Default product category for donations
  static const String productCategory = "donation";

  /// EMI option (0 = disabled, 1 = enabled)
  static const int emiOption = 0;

  /// Supported payment methods
  static const String supportedCards = "mastercard,visacard,amexcard";

  /// Shipping method flag
  static const String shippingMethod = "YES";

  // ============================================================================
  // PROXY SERVER CONFIGURATION (for CORS handling in web)
  // ============================================================================

  /// Local proxy server URL for handling CORS issues
  static const String proxyServerUrl = "http://localhost:3001";

  /// Proxy endpoint for payment initiation
  static const String proxyInitiateEndpoint = "/api/sslcommerz/initiate";

  /// Proxy endpoint for payment validation
  static const String proxyValidateEndpoint = "/api/sslcommerz/validate";

  /// Whether to use proxy server (recommended for web deployment)
  static bool get useProxy => true;

  // ============================================================================
  // DYNAMIC URLS
  // ============================================================================

  /// Get the payment initiation URL based on environment and proxy settings
  static String get paymentInitiateUrl {
    if (useProxy) {
      return '$proxyServerUrl$proxyInitiateEndpoint';
    }
    return isSandbox
        ? 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php'
        : 'https://securepay.sslcommerz.com/gwprocess/v4/api.php';
  }

  /// Get the payment validation URL based on environment and proxy settings
  static String get paymentValidateUrl {
    if (useProxy) {
      return '$proxyServerUrl$proxyValidateEndpoint';
    }
    return isSandbox
        ? 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php'
        : 'https://securepay.sslcommerz.com/validator/api/validationserverAPI.php';
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get basic store configuration as a map
  static Map<String, String> getStoreConfig() {
    return {
      'store_id': storeId,
      'store_passwd': storePassword,
      'currency': currency,
      'success_url': successUrl,
      'fail_url': failUrl,
      'cancel_url': cancelUrl,
      'ipn_url': ipnUrl,
    };
  }

  /// Get default customer information for testing
  static Map<String, String> getDefaultCustomerInfo() {
    return {
      'cus_name': 'Test Customer',
      'cus_email': 'test@example.com',
      'cus_add1': storeAddress,
      'cus_add2': storeCity,
      'cus_city': storeCity,
      'cus_state': storeCity,
      'cus_postcode': storePostcode,
      'cus_country': storeCountry,
      'cus_phone': storePhone,
      'cus_fax': storePhone,
    };
  }

  /// Get default shipping information for testing
  static Map<String, String> getDefaultShippingInfo() {
    return {
      'ship_name': 'Test Customer',
      'ship_add1': storeAddress,
      'ship_add2': storeCity,
      'ship_city': storeCity,
      'ship_state': storeCity,
      'ship_postcode': storePostcode,
      'ship_country': storeCountry,
    };
  }

  /// Get payment method configuration
  static Map<String, String> getPaymentConfig() {
    return {
      'multi_card_name': supportedCards,
      'shipping_method': shippingMethod,
      'emi_option': emiOption.toString(),
    };
  }
}
