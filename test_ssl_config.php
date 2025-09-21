<?php
/**
 * SSLCommerz Configuration Test Script
 * This script helps verify your SSLCommerz configuration for live mode
 */

// Load environment variables (if using .env file)
// require_once 'vendor/autoload.php'; // Uncomment if using Composer
// $dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
// $dotenv->load();

// SSLCommerz Configuration
$store_id = 'teamx68b12058b6036'; // Your sandbox store ID
$store_password = 'teamx68b12058b6036@ssl'; // Your sandbox store password
$is_sandbox = true; // Set to true for sandbox mode

// Determine API endpoint
$api_url = $is_sandbox 
    ? "https://sandbox.sslcommerz.com/gwprocess/v4/api.php"
    : "https://securepay.sslcommerz.com/gwprocess/v4/api.php";

echo "🔧 SSLCommerz Configuration Test\n";
echo "================================\n";
echo "Store ID: $store_id\n";
echo "Store Password: " . str_repeat('*', strlen($store_password)) . "\n";
echo "Environment: " . ($is_sandbox ? 'SANDBOX' : 'LIVE/PRODUCTION') . "\n";
echo "API URL: $api_url\n";
echo "================================\n\n";

// Test payment request data
$test_data = [
    'store_id' => $store_id,
    'store_passwd' => $store_password,
    'total_amount' => '10.00',
    'currency' => 'BDT',
    'tran_id' => 'TEST_' . time(),
    'success_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/success',
    'fail_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/fail',
    'cancel_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/cancel',
    'ipn_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/ipn',
    'cus_name' => 'Test User',
    'cus_email' => 'test@example.com',
    'cus_add1' => 'Test Address',
    'cus_city' => 'Dhaka',
    'cus_state' => 'Dhaka',
    'cus_postcode' => '1209',
    'cus_country' => 'Bangladesh',
    'cus_phone' => '01700000000',
    'cus_fax' => '01700000000',
    'ship_name' => 'Test User',
    'ship_add1' => 'Test Address',
    'ship_city' => 'Dhaka',
    'ship_state' => 'Dhaka',
    'ship_postcode' => '1209',
    'ship_country' => 'Bangladesh',
    'product_name' => 'Test Payment',
    'product_category' => 'Service',
    'product_profile' => 'general',
    'num_of_item' => '1',
    'product_amount' => '10.00',
    'multi_card_name' => 'mastercard,visacard,amexcard,mobilebank&internetbank',
    'shipping_method' => 'NO',
];

echo "🧪 Testing SSLCommerz API Connection...\n";

// Test API connection
$ch = curl_init($api_url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $test_data);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curl_error = curl_error($ch);

curl_close($ch);

echo "📡 API Response:\n";
echo "HTTP Code: $http_code\n";

if ($curl_error) {
    echo "❌ cURL Error: $curl_error\n";
} else {
    echo "✅ No cURL errors\n";
}

echo "Response: $response\n\n";

// Parse response
$response_data = json_decode($response, true);

if ($response_data) {
    echo "📊 Parsed Response:\n";
    if (isset($response_data['GatewayPageURL'])) {
        echo "✅ Gateway URL received: " . $response_data['GatewayPageURL'] . "\n";
        echo "✅ Configuration is working correctly!\n";
    } elseif (isset($response_data['error'])) {
        echo "❌ Error from SSLCommerz: " . $response_data['error'] . "\n";
        echo "❌ Check your credentials and configuration\n";
    } else {
        echo "⚠️ Unexpected response format\n";
    }
} else {
    echo "❌ Failed to parse JSON response\n";
}

echo "\n🔍 Troubleshooting Tips:\n";
echo "1. Verify your store ID and password are correct\n";
echo "2. Check if your SSLCommerz account is activated for live transactions\n";
echo "3. Ensure your domain is whitelisted in SSLCommerz merchant panel\n";
echo "4. Check SSLCommerz merchant panel for any account restrictions\n";
echo "5. Verify your callback URLs are accessible from SSLCommerz servers\n";

?>
