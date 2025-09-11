<?php
/**
 * SSLCommerz Payment Handler - Simple Version
 * Handles payment initiation and callbacks from SSLCommerz
 */

// CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Get the current URL path to determine the callback type
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);

// Determine callback type based on URL path
$callback_type = 'unknown';
if (strpos($path, '/payment/success') !== false) {
    $callback_type = 'success';
} elseif (strpos($path, '/payment/fail') !== false) {
    $callback_type = 'fail';
} elseif (strpos($path, '/payment/cancel') !== false) {
    $callback_type = 'cancel';
} elseif (strpos($path, '/payment/ipn') !== false) {
    $callback_type = 'ipn';
}

// Handle different callback types
switch ($callback_type) {
    case 'success':
        handlePaymentSuccess();
        break;
    case 'fail':
        handlePaymentFailure();
        break;
    case 'cancel':
        handlePaymentCancel();
        break;
    case 'ipn':
        handleIPN();
        break;
    default:
        handlePaymentInitiation();
        break;
}

function handlePaymentInitiation() {
    try {
        // Get credentials from the form data (sent by Flutter app)
        $store_id = $_POST['store_id'] ?? '';
        
        // Determine if this is sandbox or production based on store_id
        $is_sandbox = (strpos($store_id, 'teamx') === 0); // Sandbox store IDs start with 'teamx'
        
        // Use correct API endpoint based on environment
        $api_url = $is_sandbox 
            ? "https://sandbox.sslcommerz.com/gwprocess/v4/api.php"
            : "https://securepay.sslcommerz.com/gwprocess/v4/api.php";
        
        // Log the initiation
        error_log("Payment initiation - Store ID: $store_id, Sandbox: " . ($is_sandbox ? 'Yes' : 'No'));
        
        // Forward POST data to SSLCommerz API using cURL
        $ch = curl_init($api_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $_POST);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/x-www-form-urlencoded'
        ]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        if (curl_errno($ch)) {
            $error = curl_error($ch);
            error_log("cURL Error: $error");
            http_response_code(500);
            echo json_encode(["error" => "cURL Error: $error"]);
        } else {
            // Set proper content type
            header('Content-Type: application/json');
            http_response_code($http_code);
            echo $response;
        }
        
        curl_close($ch);
        
    } catch (Exception $e) {
        error_log("Payment initiation error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(["error" => "Server error: " . $e->getMessage()]);
    }
    
    exit();
}

function handlePaymentSuccess() {
    $response = [
        'status' => 'success',
        'message' => 'Payment successful',
        'data' => $_POST,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    // Log successful payment
    error_log("Payment Success: " . json_encode($_POST));
    
    // Redirect to success page with payment data
    $redirect_url = 'https://jubilee.jahajmarahighschool.com/?payment=success&' . http_build_query($_POST);
    header('Location: ' . $redirect_url);
    exit();
}

function handlePaymentFailure() {
    $response = [
        'status' => 'failed',
        'message' => 'Payment failed',
        'data' => $_POST,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    // Log failed payment
    error_log("Payment Failed: " . json_encode($_POST));
    
    // Redirect to failure page
    $redirect_url = 'https://jubilee.jahajmarahighschool.com/?payment=failed&' . http_build_query($_POST);
    header('Location: ' . $redirect_url);
    exit();
}

function handlePaymentCancel() {
    $response = [
        'status' => 'cancelled',
        'message' => 'Payment cancelled',
        'data' => $_POST,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    // Log cancelled payment
    error_log("Payment Cancelled: " . json_encode($_POST));
    
    // Redirect to cancel page
    $redirect_url = 'https://jubilee.jahajmarahighschool.com/?payment=cancelled&' . http_build_query($_POST);
    header('Location: ' . $redirect_url);
    exit();
}

function handleIPN() {
    // IPN (Instant Payment Notification) - server-to-server communication
    $response = [
        'status' => 'ipn_received',
        'message' => 'IPN received',
        'data' => $_POST,
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    // Log IPN
    error_log("IPN Received: " . json_encode($_POST));
    
    // Return success response to SSLCommerz
    echo json_encode(['status' => 'success']);
    exit();
}

// If we reach here, return a default response
echo json_encode([
    'status' => 'ok',
    'message' => 'Payment callback handler is working',
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
