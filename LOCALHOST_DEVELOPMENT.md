# 🖥️ Localhost Development Guide

## ✅ **Localhost Development Setup**

Your app now works perfectly on both **localhost** and **production** with the following configuration:

### 🔧 **Configuration Files:**

1. **`config.env`** - Production configuration (for Hostinger)
2. **`config.local.env`** - Localhost development configuration
3. **`proxy-server.js`** - Local development server (handles CORS)

---

## 🚀 **How to Run on Localhost**

### Step 1: Use Local Configuration

Rename your config file for localhost development:

```bash
# Backup production config
mv config.env config.production.env

# Use local development config
mv config.local.env config.env
```

### Step 2: Start Proxy Server

```bash
# Install dependencies (if not already done)
npm install

# Start the proxy server
npm run dev
# or
node proxy-server.js
```

The proxy server will start on `http://localhost:3001`

### Step 3: Run Flutter App

```bash
# Run Flutter web app
flutter run -d chrome
# or
flutter run -d web-server --web-port 8080
```

---

## 🌐 **How It Works on Localhost**

### Development Mode (localhost):

1. **Flutter app** → Calls proxy server (`localhost:3001`)
2. **Proxy server** → Calls SSLCommerz APIs (no CORS issues)
3. **SSLCommerz** → Returns payment page URL
4. **User pays** → On SSLCommerz sandbox payment page
5. **SSLCommerz redirects** → Back to proxy server
6. **Proxy server** → Redirects to Flutter app with payment status

### Production Mode (Hostinger):

1. **Flutter app** → Redirects to SSLCommerz hosted payment page
2. **User pays** → On SSLCommerz production payment page
3. **SSLCommerz redirects** → Back to your `payment_handler.php`
4. **PHP handler** → Redirects to Flutter app with payment status

---

## 📱 **Configuration Details**

### Localhost Configuration (`config.local.env`):

```env
SSLCOMMERZ_STORE_ID=teamx68b12058b6036
SSLCOMMERZ_STORE_PASSWORD=teamx68b12058b6036@ssl
SSLCOMMERZ_IS_SANDBOX=true
```

### Production Configuration (`config.production.env`):

```env
SSLCOMMERZ_STORE_ID=jubileejahajmarahighschoollive
SSLCOMMERZ_STORE_PASSWORD=68B0306F5F6B674036
SSLCOMMERZ_IS_SANDBOX=false
```

---

## 🔍 **Testing on Localhost**

### 1. Test Payment Flow

1. **Fill registration form**
2. **Click payment button**
3. **Should redirect to SSLCommerz sandbox payment page**
4. **Use test card**: `4111111111111111` (Visa)
5. **Complete payment**
6. **Should redirect back to your app**
7. **Should show payment result**

### 2. Check Console Logs

- **Flutter app console**: Should show payment initiation logs
- **Proxy server console**: Should show API call logs
- **No CORS errors** should appear

### 3. Test Different Scenarios

- ✅ **Successful payment**
- ❌ **Failed payment**
- ⚠️ **Cancelled payment**

---

## 🛠️ **Troubleshooting Localhost**

### If you see CORS errors:

#### 1. Check Proxy Server

```bash
# Make sure proxy server is running
curl http://localhost:3001/api/sslcommerz/initiate
```

#### 2. Check Configuration

- Ensure `SSLCOMMERZ_IS_SANDBOX=true` in `config.env`
- Verify you're using the local config file

#### 3. Check Flutter App

- Make sure Flutter app is running on `localhost:8080` or `localhost:3000`
- Check browser console for errors

#### 4. Check SSLCommerz Callbacks

The proxy server handles these URLs:

- `http://localhost:3001/payment/success`
- `http://localhost:3001/payment/fail`
- `http://localhost:3001/payment/cancel`

---

## 🔄 **Switching Between Environments**

### For Localhost Development:

```bash
mv config.production.env config.env.backup
mv config.local.env config.env
npm run dev
flutter run -d chrome
```

### For Production Deployment:

```bash
mv config.env config.local.env
mv config.production.env config.env
flutter build web
# Upload to Hostinger
```

---

## 📋 **Quick Commands**

### Start Development:

```bash
# Terminal 1: Start proxy server
npm run dev

# Terminal 2: Start Flutter app
flutter run -d chrome
```

### Build for Production:

```bash
# Switch to production config
mv config.env config.local.env
mv config.production.env config.env

# Build Flutter app
flutter build web

# Upload build/web/ contents to Hostinger
```

---

## 🎉 **Summary**

✅ **Localhost**: Uses proxy server + sandbox SSLCommerz
✅ **Production**: Uses hosted payment page + live SSLCommerz
✅ **No CORS issues** in either environment
✅ **Easy switching** between development and production

Your app now works perfectly on both localhost and Hostinger! 🚀
