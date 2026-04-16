# App Icons Setup

## Current Status ✅

### Android Icons
All Android app icons have been generated from `assets/logo.png`:
- **mdpi** (48×48) - Used by older/small phones
- **hdpi** (72×72) - Used by medium density devices  
- **xhdpi** (96×96) - Used by high density devices
- **xxhdpi** (144×144) - Used by extra high density devices
- **xxxhdpi** (192×192) - Used by extra extra high density devices

Icons are located at: `android/app/src/main/res/mipmap-{density}/ic_launcher.png`

**Status**: Ready to use ✓

### iOS Icons
iOS folder will be created when you run:
```bash
flutter create . --platforms=ios
```

Once iOS folder is created, you can regenerate icons using:
```bash
flutter pub add --dev flutter_launcher_icons
dart run flutter_launcher_icons
```

The configuration is already in `flutter_launcher_icons.yaml`

## App Icon Specs

- **Image Source**: `assets/logo.png` (609×572 JPEG)
- **Android Baseline**: mdpi (48×48)
- **iOS Standard**: 180×180
- **Adaptive Icon Foreground**: logo.png
- **Adaptive Icon Background**: White (#FFFFFF)

## Manual Icon Generation (if needed)

If you need to regenerate icons manually:
```bash
# Using flutter_launcher_icons
dart run flutter_launcher_icons

# Or manually using macOS sips command:
sips -z 48 48 assets/logo.png --out android/app/src/main/res/mipmap-mdpi/ic_launcher.png
```

## Build

The app will now display your logo as the app icon on both Android and iOS!
