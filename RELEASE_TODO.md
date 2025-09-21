# Release Plan for Gurubaa News App

## Pre-Release Preparation

- [ ] Update application ID from com.example.gurubaa_news to a unique production ID
- [ ] Update app version in pubspec.yaml (current: 1.0.0+1)
- [ ] Update app name and description in pubspec.yaml
- [ ] Remove hardcoded keystore passwords from build.gradle.kts
- [ ] Configure proper signing certificates for Android
- [ ] Configure iOS bundle identifier and provisioning profiles
- [ ] Update app icons and splash screens
- [ ] Test app functionality on both platforms
- [ ] Run all tests to ensure stability

## Android Release Build

- [ ] Generate production keystore (if not using existing)
- [ ] Update build.gradle.kts with production signing config
- [ ] Build release APK: `flutter build apk --release`
- [ ] Build release AAB: `flutter build appbundle --release`
- [ ] Test APK installation on test device
- [ ] Prepare Google Play Store listing (screenshots, description, etc.)

## iOS Release Build

- [ ] Configure iOS bundle identifier in Xcode
- [ ] Set up Apple Developer account and certificates
- [ ] Configure provisioning profiles
- [ ] Build release IPA: `flutter build ios --release`
- [ ] Archive and export from Xcode
- [ ] Test IPA installation on test device
- [ ] Prepare App Store Connect listing

## Store Submission

- [ ] Submit Android AAB to Google Play Console
- [ ] Submit iOS IPA to App Store Connect
- [ ] Set up app store listings with descriptions, screenshots, and metadata
- [ ] Configure in-app purchases if needed
- [ ] Set pricing and availability

## Post-Release

- [ ] Monitor crash reports and user feedback
- [ ] Plan for future updates and maintenance
- [ ] Set up analytics and tracking
