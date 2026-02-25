# 📱 Flutter Setup Guide - GSAPP Mobile App

## 🎯 Current Status
- ✅ Flutter: 3.38.7 (Latest)
- ✅ Dart: 3.10.7 (Latest)
- ❌ Android SDK: 35.0.1 (Needs update to 36)
- ❌ Android Emulator: Not running

---

## 🔧 **FIX 1: Update Android SDK to Version 36**

### **Method 1: Command Line (FASTEST)**

Run these commands in PowerShell:

```powershell
# Navigate to Android SDK tools
cd "C:\Users\js171\AppData\Local\Android\sdk\tools\bin"

# Update SDK components
.\sdkmanager "platforms;android-36"
.\sdkmanager "build-tools;36.0.0"
.\sdkmanager "system-images;android-36;google_apis;arm64-v8a"

# Accept all licenses
.\sdkmanager --licenses
# Type: y (yes) for each license

# Verify installation
.\sdkmanager --list_installed
# Should show: build-tools;36.0.0 and platforms;android-36
```

**Expected Output:**
```
Done. Installed packages in 10s.
packages installed.
  ID                                 | Installed | Latest    | Loc.
  -------                            | -------   | -------   | ----
  build-tools;36.0.0                 |       yes |     36.0.0 | 36.0.0
  platforms;android-36               |       yes |     36.0.0 | android-36
```

---

### **Method 2: Using Android Studio (GUI)**

1. **Open Android Studio**
2. Go to: **Tools → SDK Manager**
3. Check SDK Platforms tab:
   - ✅ Android 14 (API 36) - Check the box
4. Go to SDK Tools tab:
   - ✅ Android SDK Build-Tools 36.0.0 - Check the box
5. Click **Apply** button
6. Click **OK** on confirmation dialog
7. Wait for download to complete

---

## 🚀 **FIX 2: Verify Android Setup**

After updating SDK, run:

```powershell
cd C:\MyProjects\GSAPP\mobile_app

# Verify Flutter setup
flutter doctor -v

# Expected output:
# ✓ Android toolchain - develop for Android devices (Android SDK version 36.0.0)
```

---

## 📱 **FIX 3: Create & Start Android Emulator**

### **Method 1: Android Studio GUI (EASIEST)**

1. **Open Android Studio**
2. Go to: **Tools → Device Manager**
3. Click **Create Device**
4. Select device model:
   - Choose: **Pixel 6 Pro** (or any Pixel device)
   - Click **Next**
5. Select system image:
   - Choose: **API 36** (Android 14)
   - Download if needed
   - Click **Next**
6. Give it a name:
   - Name: `Pixel6ProAPI36`
   - Click **Finish**
7. In Device Manager, click **▶ Play** button
8. **Wait 30-60 seconds** for emulator to boot

**Your emulator screen should appear showing Android home screen**

---

### **Method 2: Command Line**

```powershell
# List available emulators
emulator -list-avds

# If no emulators exist, create one using Android Studio first (Method 1)

# Start emulator (use name from list above, e.g., "Pixel6ProAPI36")
emulator -avd Pixel6ProAPI36

# Wait for boot... (emulator window opens and shows Android)
```

**You should see:**
- Emulator window opens
- Android system boots (splashscreen shows)
- Android home screen appears (takes 30-60 seconds)

---

## ✅ **VERIFICATION STEPS**

### **Step 1: Check Connected Devices**

```powershell
cd C:\MyProjects\GSAPP\mobile_app

flutter devices

# Expected output (emulator running):
# Android Emulator • emulator-5554 • android-arm64 • Android 14 (API 36)
# Chrome (web)     • chrome         • web-javascript
```

### **Step 2: Verify Full Setup**

```powershell
flutter doctor -v

# Should show all ✓ (green checkmarks)
# EXCEPT iOS (if you're on Windows, you can't build iOS)
```

### **Step 3: Clean & Get Dependencies**

```powershell
cd C:\MyProjects\GSAPP\mobile_app

flutter clean
flutter pub get

# Expected output:
# Running "flutter pub get" in mobile_app...
# Got dependencies in 15 seconds.
```

---

## 🎮 **RUN THE APP!**

After all above steps, run:

```powershell
cd C:\MyProjects\GSAPP\mobile_app

flutter run

# Expected output:
# Launching lib/main.dart on Android Emulator in debug mode...
# Built build/app/outputs/flutter-apk/app-debug.apk
# Installing and launching... on emulator-5554
# D/Flutter  (12345): Engine run time in milliseconds: 1234
```

**Your app should now appear in the emulator! 🎉**

---

## 📸 **Screenshots Reference**

### **Android Studio - Device Manager**
```
┌─────────────────────────────────┐
│ Device Manager                  │
├─────────────────────────────────┤
│ ▢ Pixel 6 Pro                   │
│   System Image: Android 14      │
│   API: 36                       │
│   Memory: 2GB                   │
│   Storage: 40GB                 │
│                                 │
│   [▶ Play]  [Edit]  [Delete]    │
└─────────────────────────────────┘
```

### **Android Studio - SDK Manager**
```
┌─────────────────────────────────┐
│ SDK Manager                     │
├─────────────────────────────────┤
│ SDK Platforms:                  │
│ ☑ Android 14 (API 36)          │
│ ☑ Android 13 (API 33)          │
│                                 │
│ SDK Tools:                      │
│ ☑ Build-Tools 36.0.0           │
│ ☑ Android SDK Platform Tools   │
│                                 │
│ [Apply] [OK]                    │
└─────────────────────────────────┘
```

### **PowerShell - flutter devices**
```
3 connected device:

Android Emulator • emulator-5554 • android-arm64 • Android 14 (API 36)
Chrome (web)     • chrome         • web-javascript
Edge (web)       • edge           • web-javascript
```

---

## 🐛 **Troubleshooting**

### **Problem: "emulator: command not found"**
**Solution:** Add Android tools to PATH
```powershell
# Run this once:
$env:PATH += ";C:\Users\js171\AppData\Local\Android\sdk\tools\bin"

# Verify:
emulator -list-avds
```

### **Problem: "Android SDK version 36 not found"**
**Solution:** Run the sdkmanager commands again (they sometimes fail first time)
```powershell
cd "C:\Users\js171\AppData\Local\Android\sdk\tools\bin"
.\sdkmanager "platforms;android-36" "build-tools;36.0.0"
```

### **Problem: Emulator won't start**
**Solution:** Delete emulator and recreate via Android Studio
1. Device Manager → Right-click emulator → Delete
2. Create Device again (use Method 1 above)

### **Problem: Flutter run fails with "No connected devices"**
**Solution:** Make sure emulator is fully booted
1. Look for emulator window (might be in background)
2. Wait 60 seconds for full boot
3. Run `flutter devices` to verify

---

## ✅ **Complete Setup Checklist**

- [ ] Android SDK 36 installed
- [ ] Build-Tools 36.0.0 installed
- [ ] Android Emulator created (Pixel 6 Pro recommended)
- [ ] Emulator starts and boots successfully
- [ ] `flutter doctor -v` shows ✓ for all items
- [ ] `flutter devices` shows emulator
- [ ] `flutter pub get` completes successfully
- [ ] `flutter run` builds and deploys to emulator
- [ ] App appears in emulator screen

---

## 🚀 **Quick Command Reference**

```powershell
# Setup (run once)
cd C:\MyProjects\GSAPP\mobile_app
flutter clean
flutter pub get

# Development (run every time)
flutter run

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (rebuild app state)
# Press 'R' in terminal

# Check setup
flutter doctor -v
flutter devices

# Stop app
# Press 'q' in terminal
```

---

## 🎓 **Learning Resources**

- Flutter Official: https://flutter.dev/docs
- Android Setup: https://flutter.dev/docs/development/build-runner-on-android
- Dart Programming: https://dart.dev/guides

---

## 📞 **Need Help?**

If you encounter issues:
1. Run `flutter doctor -v` to see detailed error
2. Copy the error message
3. Search on Stack Overflow
4. Or ask me for help!

---

## ✨ **Next Steps After Setup**

Once everything is working:
1. Phase 1: Create app_constants.dart (Supabase config)
2. Phase 2: Create Models (data structures)
3. Phase 3: Create Services (database layer)
4. Phase 4: Create Providers (state management)
5. Phase 5: Create Screens (UI)
6. Phase 6: Create Widgets (components)
7. Phase 7: Polish & Deploy

**Ready to fix your setup?** 👉
