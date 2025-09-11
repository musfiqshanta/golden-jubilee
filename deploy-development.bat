@echo off
echo 🔧 Switching to Development Mode...

REM Use development config
copy config.dev.env config.env
echo ✅ Switched to development configuration

echo 🚀 Starting development environment...
echo 1. Start proxy server: npm run dev
echo 2. Start Flutter app: flutter run -d chrome --web-port 8080
pause
