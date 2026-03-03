# MyCashBook — Premium Expense Tracking App 💎📲

MyCashBook is a high-fidelity Android application for seamless personal cashbook management. Built with Flutter and powered by a Django REST API, it delivers a premium experience with Glassmorphism design, fluid animations, and real-time financial tracking.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 💎 **Liquid Glass UI** | Glassmorphism throughout with orange-centric gradients and subtle blur effects |
| 📊 **Real-time Balance** | Live Deposits & Withdrawals with instant balance calculation on an orange gradient card |
| 📄 **PDF Reports** | Generate and download professional PDF reports with a cinematic download animation |
| 💸 **P2P Book Transfer** | Transfer funds between books using unique Book IDs (BID) |
| 🔐 **Secure Auth** | JWT-based sessions with auto token refresh, autofill support, and daily notification reminders |
| ✏️ **Full CRUD** | Add, Edit, Delete transactions via modern animated bottom sheets |
| 🎴 **3D Card Effects** | Touch-responsive 3D tilt effect on Book and Transaction cards |
| 🔔 **Daily Notifications** | Reminds you to track expenses every morning at 8:00 AM |
| ⚡ **120Hz Optimized** | Forces the highest available display refresh rate for buttery-smooth scrolling |

---

## 🛠️ Tech Stack

- **Frontend:** Flutter & Dart
- **State Management:** Provider
- **Networking:** Dio (REST API Client)
- **Security:** Flutter Secure Storage (JWT Tokens)
- **PDF Engine:** ReportLab (Backend), Path Provider & Open Filex (Mobile)
- **Notification:** Flutter Local Notifications
- **Backend:** Django, Django REST Framework, MySQL

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.0.0+)
- Android Studio or VS Code
- An active MyCashBook Backend API

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tanvir14ahmed/mycashbook_android.git
   cd mycashbook_android
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint:**
   Update `lib/core/api/api_endpoints.dart`:
   ```dart
   static const String baseUrl = "https://your-backend-url.com/api/v1";
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Build release APK:**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols/
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🎨 Design System

- **Primary Color:** `#FF9800` (Orange) → `#FF5722` (Deep Orange) gradient
- **Background:** Dark `#121212` / `#1A1A1A`
- **Glass Opacity:** 20–25% with blur layers
- **Typography:** Google Fonts (Inter / Roboto)
- **Icons:** Material Icons + Custom Assets

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── api/          # API client, endpoints
│   └── theme/        # App theme (Light/Dark)
├── models/           # Data models
├── providers/        # State management (Auth, Books, Transactions)
├── screens/          # UI screens
│   ├── auth/         # Login, Register, OTP, Forgot Password
│   ├── book/         # Book detail screen
│   └── dashboard/    # Dashboard / Book list
├── services/         # Notification service
└── widgets/          # Reusable components (GlassContainer, HoverCard, etc.)
```

---

## 🔗 Related

- **Backend Repository:** [my_cashbook](https://github.com/tanvir14ahmed/my_cashbook)
- **Live API:** `https://app.codelab-by-tnv.top/api/v1`

---

## 📄 License

© 2026 Tanvir Ahmed. All rights reserved.
