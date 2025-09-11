@echo off
echo 🚀 Switching to Production Mode...

REM Backup current config
if exist config.env (
    copy config.env config.dev.env
    echo ✅ Backed up development config to config.dev.env
)

REM Use production config
copy config.production.env config.env
echo ✅ Switched to production configuration

REM Build for production
echo 🔨 Building Flutter app for production...
flutter build web --release

echo ✅ Production build complete!
echo 📁 Upload the contents of build/web/ to your Hostinger hosting
echo 🌐 Your app will now use SSLCommerz hosted payment page (no CORS issues)
pause
