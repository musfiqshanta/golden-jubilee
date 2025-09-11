const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = 3001;

// Enhanced CORS configuration for Hostinger deployment
app.use(cors({
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    // Allow your production domain
    const allowedOrigins = [
      'https://jubilee.jahajmarahighschool.com',
      'https://www.jubilee.jahajmarahighschool.com',
    ];

    // Allow any localhost port for development
    if (origin && origin.startsWith('http://localhost:')) {
      console.log('✅ Allowing localhost origin:', origin);
      return callback(null, true);
    }

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      // For production, you might want to be more restrictive
      console.log('❌ CORS blocked origin:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin',
    'Access-Control-Request-Method',
    'Access-Control-Request-Headers'
  ],
  exposedHeaders: ['Content-Length', 'X-Foo', 'X-Bar'],
  maxAge: 86400 // 24 hours
}));

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
    console.log('🚀 Proxying payment initiate request (SANDBOX)');
    console.log('Method:', req.method);
    console.log('Content-Type:', req.headers['content-type']);
    console.log('Origin:', req.headers['origin']);
    console.log('User-Agent:', req.headers['user-agent']);
    console.log('Body length:', req.headers['content-length']);
  },
  onError: (err, req, res) => {
    console.error('❌ Proxy error:', err);
    res.status(500).json({ error: 'Proxy error', details: err.message });
  }
}));

app.use('/api/sslcommerz/validate', createProxyMiddleware({
  target: 'https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php',
  changeOrigin: true,
  pathRewrite: {
    '^/api/sslcommerz/validate': '', // Remove the path prefix
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log('🔍 Proxying payment validation request (PRODUCTION)');
    console.log('Method:', req.method);
    console.log('Content-Type:', req.headers['content-type']);
  }
}));

// EMI API endpoint proxy - Return empty response since EMI is disabled
app.use('/api/sslcommerz/emi', (req, res) => {
  console.log('💳 EMI request received (EMI disabled)');
  console.log('Method:', req.method);
  console.log('Content-Type:', req.headers['content-type']);
  console.log('Origin:', req.headers['origin']);

  // Return empty EMI response since EMI is disabled
  res.json({
    status: 'SUCCESS',
    message: 'EMI is disabled for this store',
    emi_options: []
  });
});

// Catch-all route for SSLCommerz EMI requests that bypass our proxy
app.use('/securepay/api.php/get_emi', (req, res) => {
  console.log('💳 Direct EMI request intercepted (EMI disabled)');
  console.log('Method:', req.method);
  console.log('Content-Type:', req.headers['content-type']);
  console.log('Origin:', req.headers['origin']);
  console.log('User-Agent:', req.headers['user-agent']);

  // Return empty EMI response since EMI is disabled
  res.json({
    status: 'SUCCESS',
    message: 'EMI is disabled for this store',
    emi_options: []
  });
});

// Production-ready server configuration
const server = app.listen(process.env.PORT || PORT, '0.0.0.0', () => {
  const port = server.address().port;
  console.log(`🚀 Proxy server running on port ${port}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 CORS enabled for production domains`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
