# Environment Setup Guide

This guide explains how to set up environment variables for the SSLCommerz payment gateway credentials.

## ⚠️ Security Notice

**Never commit your actual SSLCommerz credentials to version control!** The `config.env` file is already added to `.gitignore` to prevent accidental commits.

## Setup Instructions

### 1. Copy the Example File

Copy the example environment file to create your actual configuration:

```bash
cp env.example config.env
```

### 2. Edit Your Configuration

Open `config.env` and replace the placeholder values with your actual SSLCommerz credentials:

```env
# SSLCommerz Configuration
# Store Credentials (Production/Live)
SSLCOMMERZ_STORE_ID=jubileejahajmarahighschoollive
SSLCOMMERZ_STORE_PASSWORD=68B0306F5F6B674036

# Environment
SSLCOMMERZ_IS_SANDBOX=false
```

### 3. For Testing (Sandbox Mode)

If you need to test with sandbox credentials, you can switch to sandbox mode:

```env
# SSLCommerz Configuration
# Store Credentials (Sandbox for Testing)
SSLCOMMERZ_STORE_ID=your_sandbox_store_id
SSLCOMMERZ_STORE_PASSWORD=your_sandbox_store_password

# Environment
SSLCOMMERZ_IS_SANDBOX=true
```

## File Structure

```
├── env.example          # Example file (safe to commit)
├── config.env           # Your actual credentials (ignored by git)
├── .gitignore          # Contains config.env to prevent commits
└── lib/services/
    ├── env_service.dart # Environment service
    └── sslcommerz_config.dart # Updated to use environment variables
```

## How It Works

1. **Environment Service**: `lib/services/env_service.dart` loads and manages environment variables
2. **SSLCommerz Config**: `lib/services/sslcommerz_config.dart` now uses environment variables instead of hardcoded values
3. **Main App**: `lib/main.dart` initializes the environment service on startup

## Verification

You can verify your environment setup by checking the console output when the app starts. The environment service will log the status of your configuration.

## Troubleshooting

### Common Issues

1. **"Environment not initialized" error**: Make sure `EnvService.initialize()` is called in `main()`
2. **Credentials not working**: Check that your `config.env` file exists and has the correct values
3. **File not found**: Ensure `config.env` is in the root directory of your project

### Debug Environment

You can debug your environment setup by calling:

```dart
print(EnvService.getEnvironmentStatus());
```

This will show you the status of all environment variables.

## Security Best Practices

1. ✅ Use environment variables for sensitive data
2. ✅ Keep `config.env` in `.gitignore`
3. ✅ Use different credentials for development and production
4. ✅ Regularly rotate your SSLCommerz credentials
5. ❌ Never commit credentials to version control
6. ❌ Don't share your `config.env` file

## Deployment

### Web Deployment

For Flutter Web deployment:

1. **Assets Configuration**: The `config.env` file is included in `pubspec.yaml` assets section
2. **Build Process**: Run `flutter build web` to include the environment file
3. **Hosting**: Upload the built files to your web hosting platform
4. **Security**: The `config.env` file will be publicly accessible, so use sandbox credentials for web deployment

### Production Deployment

When deploying to production:

1. Set up environment variables on your hosting platform
2. Use production SSLCommerz credentials
3. Set `SSLCOMMERZ_IS_SANDBOX=false`
4. Ensure your hosting platform supports environment variables

### Important Web Security Note

⚠️ **For Flutter Web**: The `config.env` file becomes part of the built assets and is publicly accessible. For production web deployment, consider:

1. Using sandbox credentials for web builds
2. Implementing server-side environment variable handling
3. Using a backend API to handle sensitive credentials

## Support

If you encounter issues with the environment setup, check:

1. The console output for error messages
2. That all required environment variables are set
3. That the `flutter_dotenv` package is properly installed
4. That your `config.env` file is in the correct location
