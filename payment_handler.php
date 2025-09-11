<?php
/**
 * SSLCommerz Payment Handler - Using Your Working Code
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
    // Get store_id to determine environment
    $store_id = $_POST['store_id'] ?? '';
    $is_sandbox = (strpos($store_id, 'teamx') === 0);
    
    // Use correct API endpoint based on environment
    $api_url = $is_sandbox 
        ? "https://sandbox.sslcommerz.com/gwprocess/v4/api.php"
        : "https://securepay.sslcommerz.com/gwprocess/v4/api.php";
    
    // Forward POST data to SSLCommerz API using cURL (YOUR WORKING CODE)
    $ch = curl_init($api_url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $_POST);
    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        http_response_code(500);
        echo json_encode(["error" => curl_error($ch)]);
    } else {
        echo $response;
    }

    curl_close($ch);
    exit();
}

function handlePaymentSuccess() {
    // Get the referer to redirect back to the registration page
    $referer = $_SERVER['HTTP_REFERER'] ?? 'https://jubilee.jahajmarahighschool.com/';
    
    // Create redirect URL with success parameters
    $redirect_url = $referer . '?payment=success&' . http_build_query($_POST);
    
    // Return HTML that closes the tab and redirects
    echo '<!DOCTYPE html>
<html>
<head>
    <title>Payment Successful</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: #f0f8f0;
        }
        .success { 
            color: #28a745; 
            font-size: 24px; 
            margin-bottom: 20px;
        }
        .message { 
            color: #666; 
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="success">✅ Payment Successful!</div>
    <div class="message">Redirecting back to registration...</div>
    <script>
        // Close the payment tab and redirect parent window
        if (window.opener) {
            // Redirect the parent window (registration page)
            window.opener.location.href = "' . $redirect_url . '";
            // Close this payment tab
            window.close();
        } else {
            // If no parent window, just redirect
            window.location.href = "' . $redirect_url . '";
        }
    </script>
</body>
</html>';
    exit();
}

function handlePaymentFailure() {
    // Get the referer to redirect back to the registration page
    $referer = $_SERVER['HTTP_REFERER'] ?? 'https://jubilee.jahajmarahighschool.com/';
    
    // Create redirect URL with failure parameters
    $redirect_url = $referer . '?payment=failed&' . http_build_query($_POST);
    
    // Return HTML that closes the tab and redirects
    echo '<!DOCTYPE html>
<html>
<head>
    <title>Payment Failed</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: #fff5f5;
        }
        .failed { 
            color: #dc3545; 
            font-size: 24px; 
            margin-bottom: 20px;
        }
        .message { 
            color: #666; 
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="failed">❌ Payment Failed!</div>
    <div class="message">Redirecting back to registration...</div>
    <script>
        // Close the payment tab and redirect parent window
        if (window.opener) {
            // Redirect the parent window (registration page)
            window.opener.location.href = "' . $redirect_url . '";
            // Close this payment tab
            window.close();
        } else {
            // If no parent window, just redirect
            window.location.href = "' . $redirect_url . '";
        }
    </script>
</body>
</html>';
    exit();
}

function handlePaymentCancel() {
    // Get the referer to redirect back to the registration page
    $referer = $_SERVER['HTTP_REFERER'] ?? 'https://jubilee.jahajmarahighschool.com/';
    
    // Create redirect URL with cancel parameters
    $redirect_url = $referer . '?payment=cancelled&' . http_build_query($_POST);
    
    // Return HTML that closes the tab and redirects
    echo '<!DOCTYPE html>
<html>
<head>
    <title>Payment Cancelled</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px; 
            background: #fff8e1;
        }
        .cancelled { 
            color: #ff9800; 
            font-size: 24px; 
            margin-bottom: 20px;
        }
        .message { 
            color: #666; 
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="cancelled">⚠️ Payment Cancelled!</div>
    <div class="message">Redirecting back to registration...</div>
    <script>
        // Close the payment tab and redirect parent window
        if (window.opener) {
            // Redirect the parent window (registration page)
            window.opener.location.href = "' . $redirect_url . '";
            // Close this payment tab
            window.close();
        } else {
            // If no parent window, just redirect
            window.location.href = "' . $redirect_url . '";
        }
    </script>
</body>
</html>';
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