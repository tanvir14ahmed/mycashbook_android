# MyCashBook — Premium Finance Management 💎📲

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**MyCashBook** is a high-fidelity, high-performance Android application designed for seamless personal finance tracking. It combines a stunning **Glassmorphism UI** with a robust Django-powered backend to deliver a premium, fluid experience.

---

## ✨ What's New (v1.0.3)
- 🖼️ **Local Profile Photo**: Upload and persist your profile picture locally on your device.
- 🚀 **120Hz Ultra-Smooth**: Optimized for high refresh rate displays (120Hz/144Hz) for buttery-smooth scrolling.
- 🔔 **Action Notifications**: Clear visual feedback (Toasts) for every transaction and logout.
- 🛠️ **Performance Fixes**: Removed expensive GPU filters and added `RepaintBoundary` for maximum FPS.
- 🚪 **Clean Exit**: Optimized app exit logic to prevent flickering or black screens.

---

## 💎 Key Features

| Feature | Description |
|---------|-------------|
| 🍧 **Liquid Glass UI** | Beautiful Glassmorphism with dynamic orange-silver gradients and micro-animations. |
| ⚡ **120Hz Optimized** | Hard-coded display mode selection for maximum fluidity on supported devices. |
| 📊 **Real-time Balance** | Instant calculation of Deposits, Withdrawals, and Net Balance. |
| 🖼️ **Personalized Profile** | Local avatar upload with path persistence using secure storage. |
| 📄 **Cinematic PDF Reports** | Generate professional thermal-style reports with animated progress indicators. |
| 💸 **P2P Book Transfer** | Securely transfer funds between different cashbooks using unique BIDs. |
| 🔐 **Premium Security** | JWT-based auth, secure token storage, and intelligent session management. |
| ✏️ **Animated CRUD** | Fluid bottom-sheet interactions for adding and editing transactions. |
| 🎴 **3D Hover Effects** | Responsive tilt-physics on cards for a tactile, premium feel. |

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Dart)
- **State:** [Provider](https://pub.dev/packages/provider) (Clean architecture)
- **Networking:** [Dio](https://pub.dev/packages/dio) (API Interceptors & JWT management)
- **Database:** [MySQL](https://www.mysql.com/) (Backend) / [Secure Storage](https://pub.dev/packages/flutter_secure_storage) (Local)
- **UI Gems:** [Google Fonts](https://fonts.google.com/), [Shimmer](https://pub.dev/packages/shimmer), [Image Picker](https://pub.dev/packages/image_picker)
- **Backend:** [Django REST Framework](https://www.django-rest-framework.org/)

---

## 🚀 Installation & Setup

### 1. Prerequisites
- Flutter SDK `^3.11.0`
- Android API Level 21+

### 2. Clone & Install
```bash
git clone https://github.com/tanvir14ahmed/mycashbook_android.git
cd mycashbook_android
flutter pub get
```

### 3. Build Optimized APK
For the best performance and smallest size (~19MB), build using split-ABI:
```bash
flutter build apk --split-per-abi --release
```
Locate your build at: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 🎨 Design Philosophy
- **Vibrant & Dark:** A deep metallic background (`#121212`) paired with energetic orange accents.
- **Isolate & Repaint:** Strategic use of `RepaintBoundary` to maintain 60-120 FPS even during complex scrolling.
- **Feedback First:** Every action triggers a subtle animation or notification, ensuring the user is never left guessing.

---

## 📂 Project Structure
```text
lib/
├── core/         # API Client, Theme Definitions, Endpoints
├── models/       # Data serialization (User, Book, Transaction)
├── providers/    # Business Logic & Global State
├── screens/      # Feature-based UI (Auth, Dashboard, Profile, Book)
├── services/     # Global Background Services (Notifications)
└── widgets/      # Custom GlassContainer, HoverCard, Animated Dialogs
```

---

## 🔗 Related
- **Backend Repository:** [my_cashbook](https://github.com/tanvir14ahmed/my_cashbook)
- **Live API:** `https://mycashbook.codelab-by-tnv.top/api/v1`

---

## 📄 License
© 2026 **Tanvir Ahmed**. All rights reserved. 
Built with ❤️ for high-performance finance tracking.
