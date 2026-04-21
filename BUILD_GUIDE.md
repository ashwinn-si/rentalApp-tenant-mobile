# Build Guide — Tenant Mobile App

Quick reference for building APK with correct environment configuration.

## Setup (One-Time)

### 1. Update Production URL

Edit `lib/core/constants/env_config.dart`:

```dart
Environment.production: EnvConfigData(
  baseUrl: 'https://your-production-backend.com', // ← UPDATE THIS
  androidEmulatorUrl: 'https://your-production-backend.com',
  // ...
),
```

### 2. Configure Android Signing

Create `android/key.properties` (do NOT commit):

```properties
storeFile=/path/to/your/keystore.jks
storePassword=your_store_password
keyAlias=your_key_alias
keyPassword=your_key_password
```

## Build Commands

### Dev Build (Local Testing)
```bash
flutter clean && flutter pub get
flutter build apk --dart-define=FLUTTER_ENV=dev --debug
```
**Output**: `build/app/outputs/apk/debug/app-debug.apk`

### Prod APK (Release)
```bash
flutter clean && flutter pub get
flutter build apk --dart-define=FLUTTER_ENV=prod --release
```
**Output**: `build/app/outputs/apk/release/app-release.apk`

### Prod App Bundle (for Play Store)
```bash
flutter clean && flutter pub get
flutter build appbundle --dart-define=FLUTTER_ENV=prod --release
```
**Output**: `build/app/outputs/bundle/release/app-release.aab`

## Verify Environment

When app starts, check console for:

```
═════════════════════════════════════
ENVIRONMENT: Production
BASE URL: https://your-backend.com
API URL: https://your-backend.com/api
═════════════════════════════════════
```

## Install & Test

```bash
# Install APK
adb install build/app/outputs/apk/release/app-release.apk

# View logs
adb logcat | grep "ENVIRONMENT\|API"
```

## Before Upload to Play Store

- [ ] Built with `--dart-define=FLUTTER_ENV=prod`
- [ ] Version in `pubspec.yaml` is incremented
- [ ] APK tested on real device
- [ ] Git tag created: `git tag v1.0.0`
- [ ] Keystore file backed up securely

See `PRE_BUILD_CHECKLIST.md` for full checklist.
