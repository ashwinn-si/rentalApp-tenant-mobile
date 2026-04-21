# Pre-Build APK Checklist

Before building the APK for release, follow this checklist to ensure everything is configured correctly.

## Environment Configuration

### 1. Set Production Backend Endpoint

**Option A: Build with Environment Variable (Recommended)**

```bash
flutter build apk \
  --dart-define=FLUTTER_ENV=prod \
  --release
```

**Option B: Manual Configuration**

1. Open `lib/core/constants/env_config.dart`
2. Update `EnvConfig.configs[Environment.production].baseUrl` to your production backend URL
3. Verify the URL is correct: `https://backend.app.com` (with https://)

### 2. Verify Current Configuration

Check which environment will be used:

```bash
# Debug build with dev env
flutter build apk --dart-define=FLUTTER_ENV=dev --debug

# Release build with prod env
flutter build apk --dart-define=FLUTTER_ENV=prod --release
```

## Pre-Build Verification

### 3. Backend Connectivity
- [ ] Production backend is running and accessible
- [ ] Backend API endpoints match those in `lib/core/constants/api_paths.dart`
- [ ] CORS is properly configured for your app domain
- [ ] SSL certificate is valid (for production HTTPS)

### 4. Firebase Configuration
- [ ] `google-services.json` is present in `android/app/`
- [ ] Firebase project is set to production
- [ ] FCM credentials are for production environment
- [ ] Google Play Services version is compatible

### 5. Code & Dependencies
- [ ] Run `flutter pub get` to ensure all dependencies are up to date
- [ ] Run `flutter analyze` — no errors or unresolved warnings
- [ ] Run `flutter test` — all tests pass (if applicable)
- [ ] No hardcoded localhost or development URLs in code

### 6. Authentication & Tokens
- [ ] JWT secret keys are properly configured on backend
- [ ] Token expiration time matches backend config
- [ ] Session storage is not in debug mode

### 7. Version & Build Numbers
- [ ] `version` in `pubspec.yaml` is updated (e.g., `1.0.0+1`)
- [ ] `buildNumber` in `lib/core/constants/constants.dart` matches the version
- [ ] Version follows semantic versioning (major.minor.patch+buildNumber)

### 8. App Signing
- [ ] Keystore file exists and is backed up securely
- [ ] Keystore password and key password are saved securely
- [ ] `android/key.properties` has correct keystore info (do NOT commit this file)
- [ ] Signing configuration in `android/app/build.gradle.kts` points to correct keystore

### 9. Release Build Optimization
- [ ] Run `flutter clean` before building
- [ ] Build with `--release` flag for production APK
- [ ] Enable ProGuard/R8 obfuscation (check `android/app/build.gradle.kts`)
- [ ] Verify app size is reasonable (< 100MB typical)

### 10. API Endpoints Check
Verify all endpoints in `lib/core/constants/api_paths.dart` are correct:

- [ ] `/auth/tenant-mobile` — login endpoint
- [ ] `/tenant-mobile/change-password` — password change
- [ ] `/tenant-mobile/fcm-token` — FCM token registration
- [ ] `/tenant-mobile/dashboard` — dashboard data
- [ ] `/tenant-mobile/history` — rent history
- [ ] `/tenant-mobile/notifications` — notifications list
- [ ] `/tenant-mobile/documents` — documents list
- [ ] `/tenant-mobile/profile` — user profile
- [ ] `/tenant-mobile/app-version/current` — version check

### 11. Environment Variables & Secrets
- [ ] No API keys, tokens, or secrets are hardcoded in source files
- [ ] All sensitive data is fetched from secure storage at runtime
- [ ] `.env` files are in `.gitignore` and NOT committed
- [ ] Backend credentials stored in secure storage, not in shared preferences

### 12. Testing on Real Device
- [ ] APK builds successfully without errors
- [ ] APK installs on test Android device
- [ ] App launches without crash
- [ ] Login works with production credentials
- [ ] API calls connect to production backend (check logs)
- [ ] FCM notifications are received
- [ ] All screen transitions work smoothly
- [ ] Images/assets load correctly

### 13. Pre-Flight Check
- [ ] Run `flutter pub outdated` — check for critical updates
- [ ] Review git log for unintended changes
- [ ] Commit all changes before building (create a release tag)
- [ ] No uncommitted files in the repo

## Build Commands

### Development Build (Testing)
```bash
flutter clean
flutter pub get
flutter build apk \
  --dart-define=FLUTTER_ENV=dev \
  --debug
```

### Production Build (Release)
```bash
flutter clean
flutter pub get
flutter build apk \
  --dart-define=FLUTTER_ENV=prod \
  --release
```

### Production App Bundle (for Play Store)
```bash
flutter clean
flutter pub get
flutter build appbundle \
  --dart-define=FLUTTER_ENV=prod \
  --release
```

## Output Locations

- **APK (debug)**: `build/app/outputs/apk/debug/app-debug.apk`
- **APK (release)**: `build/app/outputs/apk/release/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### If backend connection fails:
1. Verify `EnvConfig.getApiUrl()` returns the correct production URL
2. Check network connectivity on device
3. Verify backend server is running: `curl https://backend.app.com/health`
4. Check server logs for errors
5. Verify CORS headers allow requests from your app

### If build fails:
1. Run `flutter clean` and try again
2. Check `android/build.gradle.kts` for version conflicts
3. Ensure Android SDK is up to date: `flutter doctor -v`
4. Check for uncommitted files: `git status`

### If APK won't install:
1. Uninstall previous version: `adb uninstall com.example.tenantmobileapp`
2. Ensure device has enough storage
3. Check Android version compatibility
4. Enable installation from unknown sources (settings → security)

## Final Checklist Before Upload

- [ ] All items above are checked
- [ ] APK has been tested on real device
- [ ] Version number is incremented
- [ ] Release notes are prepared
- [ ] Backup of keystore file is secure
- [ ] Git tag created for release: `git tag v1.0.0`
- [ ] Ready for Play Store upload

## Notes

- **Production URL**: Update `EnvConfig.configs[Environment.production].baseUrl` with your actual backend URL
- **Never commit**: Keystore files, private keys, `.env` files, or sensitive credentials
- **Always backup**: Keep keystore file in secure location; losing it prevents future APK signing
- **Version management**: Use semantic versioning and keep `buildNumber` in sync
