# 🚀 Production Deployment Guide

## The Problem

- **Development**: Works with Node.js proxy server (handles CORS)
- **Production**: Hostinger doesn't support Node.js, causing CORS errors
- **Solution**: Use SSLCommerz hosted payment page for production

## 🔧 How It Works

### Development Mode (localhost):

```
Flutter App → Proxy Server (localhost:3001) → SSLCommerz Sandbox
```

### Production Mode (Hostinger):

```
Flutter App → SSLCommerz Hosted Payment Page → Your PHP Handler
```

## 📋 Deployment Steps

### Step 1: Switch to Production Mode

```bash
# Run the deployment script
deploy-production.bat

# Or manually:
# 1. Backup current config: copy config.env config.dev.env
# 2. Use production config: copy config.production.env config.env
# 3. Build Flutter: flutter build web --release
```

### Step 2: Upload to Hostinger

1. **Upload Flutter Build**: Upload contents of `build/web/` to your Hostinger hosting
2. **Upload PHP Handler**: Upload `payment_handler.php` to your domain root
3. **Verify URLs**: Make sure your domain is accessible

### Step 3: Test Production

1. **Visit your live site**: `https://jubilee.jahajmarahighschool.com`
2. **Test payment flow**: Should redirect to SSLCommerz hosted payment page
3. **Complete payment**: Should redirect back to your site

## 🔄 Switching Back to Development

```bash
# Run the development script
deploy-development.bat

# Or manually:
# 1. Use dev config: copy config.dev.env config.env
# 2. Start proxy: npm run dev
# 3. Start Flutter: flutter run -d chrome --web-port 8080
```

## ⚙️ Configuration Files

### Development (`config.env`):

```env
SSLCOMMERZ_STORE_ID=teamx68b12058b6036
SSLCOMMERZ_STORE_PASSWORD=teamx68b12058b6036@ssl
SSLCOMMERZ_IS_SANDBOX=true
```

### Production (`config.production.env`):

```env
SSLCOMMERZ_STORE_ID=jubileejahajmarahighschoollive
SSLCOMMERZ_STORE_PASSWORD=68B0306F5F6B674036
SSLCOMMERZ_IS_SANDBOX=false
```

## 🎯 Key Differences

| Mode            | Proxy Server  | SSLCommerz | Collections | Payment Method      |
| --------------- | ------------- | ---------- | ----------- | ------------------- |
| **Development** | ✅ Required   | Sandbox    | `_dev`      | Direct API calls    |
| **Production**  | ❌ Not needed | Live       | Production  | Hosted payment page |

## 🚨 Important Notes

1. **No CORS Issues**: Production uses SSLCommerz hosted payment page
2. **Real Money**: Production processes real payments
3. **PHP Handler**: Required for payment callbacks
4. **Environment**: Automatically switches based on `SSLCOMMERZ_IS_SANDBOX`

## 🔍 Troubleshooting

### If payments don't work in production:

1. Check `payment_handler.php` is uploaded correctly
2. Verify SSLCommerz credentials are correct
3. Check browser console for errors
4. Ensure your domain is accessible

### If you need to test production locally:

1. Set `SSLCOMMERZ_IS_SANDBOX=false` in `config.env`
2. Use production credentials
3. Test with real SSLCommerz (be careful with real money!)

## ✅ Success Indicators

- **Development**: "🔥 Running in DEVELOPMENT mode - using \_dev collections"
- **Production**: "🚀 Running in PRODUCTION mode - using live collections"
- **Payment**: Redirects to SSLCommerz hosted payment page (not API calls)
