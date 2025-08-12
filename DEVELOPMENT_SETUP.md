# Development Setup Guide

## 🚀 Simple Environment Management

This project uses **different collection names** for development and production to prevent affecting live users during development.

## 📋 How It Works

- **Development Mode**: Uses collections with `_dev` suffix (e.g., `batches_dev`, `registrations_dev`)
- **Production Mode**: Uses original collections (e.g., `batches`, `registrations`)
- **Same Firebase Project**: No need for separate Firebase projects!

## 🔄 Switch Between Environments

#### For Development (Safe Testing):

```bash
dart scripts/dev_mode.dart
flutter run -d chrome
```

#### For Production (Live):

```bash
dart scripts/prod_mode.dart
flutter run -d chrome
```

## 🔍 Environment Indicators

- **Development Mode**:

  - App title shows "Golden Jubilee (DEV)"
  - Debug banner shows "DEV"
  - Uses `_dev` collections
  - Console shows "🔥 Running in DEVELOPMENT mode - using \_dev collections"

- **Production Mode**:
  - App title shows "Golden Jubilee Celebration"
  - No debug banner
  - Uses live collections
  - Console shows "🚀 Running in PRODUCTION mode - using live collections"

## 📊 Collection Mapping

| Environment | Batches       | Registrations       | Donations       | Admin       |
| ----------- | ------------- | ------------------- | --------------- | ----------- |
| Development | `batches_dev` | `registrations_dev` | `donations_dev` | `admin_dev` |
| Production  | `batches`     | `registrations`     | `donations`     | `admin`     |

## ⚠️ Important Notes

1. **Always test in development mode first**
2. **Your live data is completely safe** - development uses separate collections
3. **No need for separate Firebase projects**
4. **Easy to switch between environments**

## 🛠️ Development Workflow

1. Switch to development mode: `dart scripts/dev_mode.dart`
2. Make your changes and test thoroughly
3. Switch to production mode: `dart scripts/prod_mode.dart`
4. Deploy to production

## 🔧 Benefits

- ✅ **Simple setup** - no additional Firebase projects needed
- ✅ **Safe testing** - live data never affected
- ✅ **Easy switching** - just run a script
- ✅ **Same Firebase project** - no configuration changes
- ✅ **Clear indicators** - always know which mode you're in
