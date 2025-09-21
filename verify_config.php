<?php
/**
 * Quick Configuration Verification Script
 * Shows current SSLCommerz configuration status
 */

echo "🔧 SSLCommerz Configuration Status\n";
echo "==================================\n\n";

// Read config.env file
$config_file = 'config.env';
if (file_exists($config_file)) {
    $config_content = file_get_contents($config_file);
    $lines = explode("\n", $config_content);
    
    $config = [];
    foreach ($lines as $line) {
        $line = trim($line);
        if (strpos($line, '=') !== false && !str_starts_with($line, '#')) {
            list($key, $value) = explode('=', $line, 2);
            $config[trim($key)] = trim($value);
        }
    }
    
    echo "📋 Current Configuration:\n";
    echo "Store ID: " . ($config['SSLCOMMERZ_STORE_ID'] ?? 'Not set') . "\n";
    echo "Store Password: " . (isset($config['SSLCOMMERZ_STORE_PASSWORD']) ? str_repeat('*', strlen($config['SSLCOMMERZ_STORE_PASSWORD'])) : 'Not set') . "\n";
    echo "Is Sandbox: " . ($config['SSLCOMMERZ_IS_SANDBOX'] ?? 'Not set') . "\n";
    
    $is_sandbox = ($config['SSLCOMMERZ_IS_SANDBOX'] ?? 'false') === 'true';
    $api_endpoint = $is_sandbox 
        ? "https://sandbox.sslcommerz.com/gwprocess/v4/api.php"
        : "https://securepay.sslcommerz.com/gwprocess/v4/api.php";
    
    echo "API Endpoint: $api_endpoint\n";
    echo "Environment: " . ($is_sandbox ? 'SANDBOX (Test Mode)' : 'LIVE (Production Mode)') . "\n";
    
    if ($is_sandbox) {
        echo "\n✅ Configuration is set to SANDBOX mode\n";
        echo "🧪 Safe for testing - no real money transactions\n";
    } else {
        echo "\n⚠️ Configuration is set to LIVE mode\n";
        echo "💰 Real money transactions will be processed\n";
    }
    
} else {
    echo "❌ config.env file not found!\n";
    echo "Please make sure config.env exists in the project root.\n";
}

echo "\n==================================\n";
echo "To test your configuration, run:\n";
echo "php test_ssl_config.php\n";
echo "==================================\n";
?>
