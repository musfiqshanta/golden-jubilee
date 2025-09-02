const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3001;

// Enable CORS for all routes
app.use(cors());

// Don't parse any bodies globally - let the proxy handle everything raw
// But we need to parse bodies for our payment callback routes
app.use('/payment/*', express.urlencoded({ extended: true }));

// Payment callback routes - handle both GET and POST
app.all('/payment/success', (req, res) => {
  console.log('Payment Success!');
  console.log('Method:', req.method);
  console.log('Query parameters:', req.query);
  console.log('Body parameters:', req.body);

  // Extract payment info from both query parameters and body (SSLCommerz can send either)
  const allData = { ...req.query, ...req.body };
  const paymentData = {
    status: allData.status,
    tran_id: allData.tran_id,
    val_id: allData.val_id,
    amount: allData.amount,
    card_type: allData.card_type,
    store_amount: allData.store_amount,
    bank_tran_id: allData.bank_tran_id,
    card_issuer: allData.card_issuer,
    card_brand: allData.card_brand,
    card_sub_brand: allData.card_sub_brand,
    currency: allData.currency,
    // Add all other fields that might be present
    ...allData
  };

  console.log('Payment Data:', paymentData);

  // Send success response
  res.send(`
    <html>
      <head><title>Payment Success</title></head>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1 style="color: green;">✅ Payment Successful!</h1>
        <p><strong>Transaction ID:</strong> ${paymentData.tran_id}</p>
        <p><strong>Amount:</strong> ${paymentData.amount} BDT</p>
        <p><strong>Status:</strong> ${paymentData.status}</p>
        <button onclick="window.close()">Close</button>
        <script>
          // Notify parent window (Flutter app)
          if (window.opener) {
            window.opener.postMessage({
              type: 'PAYMENT_SUCCESS',
              data: ${JSON.stringify(paymentData)}
            }, '*');
          }
        </script>
      </body>
    </html>
  `);
});

app.all('/payment/fail', (req, res) => {
  console.log('Payment Failed!');
  console.log('Method:', req.method);
  console.log('Query parameters:', req.query);
  console.log('Body parameters:', req.body);

  const allData = { ...req.query, ...req.body };

  res.send(`
    <html>
      <head><title>Payment Failed</title></head>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1 style="color: red;">❌ Payment Failed!</h1>
        <p><strong>Reason:</strong> ${allData.error || allData.failedreason || 'Unknown error'}</p>
        <button onclick="window.close()">Close</button>
        <script>
          if (window.opener) {
            window.opener.postMessage({
              type: 'PAYMENT_FAILED',
              data: ${JSON.stringify(allData)}
            }, '*');
          }
        </script>
      </body>
    </html>
  `);
});

app.all('/payment/cancel', (req, res) => {
  console.log('Payment Cancelled!');
  console.log('Method:', req.method);
  console.log('Query parameters:', req.query);
  console.log('Body parameters:', req.body);

  const allData = { ...req.query, ...req.body };

  res.send(`
    <html>
      <head><title>Payment Cancelled</title></head>
      <body style="font-family: Arial; text-align: center; padding: 50px;">
        <h1 style="color: orange;">⚠️ Payment Cancelled</h1>
        <p>You cancelled the payment process.</p>
        <button onclick="window.close()">Close</button>
        <script>
          if (window.opener) {
            window.opener.postMessage({
              type: 'PAYMENT_CANCELLED',
              data: ${JSON.stringify(allData)}
            }, '*');
          }
        </script>
      </body>
    </html>
  `);
});

// Proxy middleware for SSLCommerz API routes
app.use('/api/sslcommerz/initiate', createProxyMiddleware({
  target: 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php',
  changeOrigin: true,
  pathRewrite: {
    '^/api/sslcommerz/initiate': '', // Remove the path prefix
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log('🚀 Proxying payment initiate request');
    console.log('Method:', req.method);
    console.log('Content-Type:', req.headers['content-type']);
  }
}));

app.use('/api/sslcommerz/validate', createProxyMiddleware({
  target: 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php',
  changeOrigin: true,
  pathRewrite: {
    '^/api/sslcommerz/validate': '', // Remove the path prefix
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log('🔍 Proxying payment validation request');
    console.log('Method:', req.method);
    console.log('Content-Type:', req.headers['content-type']);
  }
}));

app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
});
