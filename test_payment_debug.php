<?php
/**
 * Debug Payment Handler
 * Test the payment handler locally to identify issues
 */

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h2>Payment Handler Debug Test</h2>";

// Test 1: Check if cURL is available
echo "<h3>1. cURL Check:</h3>";
if (function_exists('curl_init')) {
    echo "✅ cURL is available<br>";
} else {
    echo "❌ cURL is NOT available<br>";
}

// Test 2: Check PHP version
echo "<h3>2. PHP Version:</h3>";
echo "PHP Version: " . phpversion() . "<br>";

// Test 3: Test cURL with a simple request
echo "<h3>3. cURL Test:</h3>";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://httpbin.org/get');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    echo "❌ cURL Error: " . curl_error($ch) . "<br>";
} else {
    echo "✅ cURL working - HTTP Code: $http_code<br>";
}

curl_close($ch);

// Test 4: Test SSLCommerz sandbox connection
echo "<h3>4. SSLCommerz Sandbox Test:</h3>";
$test_data = [
    'store_id' => 'teamx68b12058b6036',
    'store_passwd' => 'teamx68b12058b6036@ssl',
    'total_amount' => '100.00',
    'currency' => 'BDT',
    'tran_id' => 'TEST_' . time(),
    'success_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/success',
    'fail_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/fail',
    'cancel_url' => 'https://jubilee.jahajmarahighschool.com/payment_handler.php/payment/cancel',
    'cus_name' => 'Test User',
    'cus_email' => 'test@example.com',
    'cus_phone' => '01700000000',
    'cus_add1' => 'Test Address',
    'cus_city' => 'Dhaka',
    'cus_state' => 'Dhaka',
    'cus_postcode' => '1000',
    'cus_country' => 'Bangladesh',
    'ship_name' => 'Test User',
    'ship_add1' => 'Test Address',
    'ship_city' => 'Dhaka',
    'ship_state' => 'Dhaka',
    'ship_postcode' => '1000',
    'ship_country' => 'Bangladesh',
    'product_name' => 'Test Product',
    'product_category' => 'Donation',
    'product_profile' => 'general',
    'shipping_method' => 'YES',
];

$ch = curl_init('https://sandbox.sslcommerz.com/gwprocess/v4/api.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $test_data);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/x-www-form-urlencoded'
]);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    echo "❌ SSLCommerz Error: " . curl_error($ch) . "<br>";
} else {
    echo "✅ SSLCommerz Response - HTTP Code: $http_code<br>";
    echo "Response: <pre>" . htmlspecialchars($response) . "</pre>";
}

curl_close($ch);

echo "<h3>5. Test Complete</h3>";
echo "If all tests pass, the payment handler should work!<br>";
?>
