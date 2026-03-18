# 📋 LifeBoard — Your Personal Life OS



A beautifully crafted all-in-one personal productivity app — track habits, manage tasks, journal your thoughts, monitor health, manage finances, and stay focused. Everything in one place, fully offline.

---

## ✨ Features

-  **Dashboard** — Bird's eye view of your entire life at a glance
-  **Tasks** — Manage your daily to-dos with priorities
-  **Habits** — Build and track daily habits with streaks
-  **Goals** — Set long-term goals and track progress
-  **Journal** — Write daily journal entries with mood tracking
-  **Focus** — Pomodoro-style focus timer to stay productive
-  **Health** — Track workouts, water intake, and sleep
-  **Finance** — Monitor income, expenses, and budgets
-  **Analytics** — Beautiful charts showing your life stats
-  **Biometric Lock** — Secure your data with fingerprint/face unlock
-  **Local Notifications** — Smart reminders for habits and tasks
-  **Fully Offline** — All data stored locally, no account needed

---

## 🛠️ Tech Stack

| Package | Purpose |
|---|---|
| `provider` | State management |
| `hive` + `hive_flutter` | Local offline database |
| `shared_preferences` | App settings storage |
| `go_router` | Navigation |
| `google_fonts` | Syne font family |
| `fl_chart` | Analytics charts |
| `percent_indicator` | Progress indicators |
| `animated_text_kit` | Text animations |
| `lottie` | Lottie animations |
| `glassmorphism` | Glass UI effects |
| `flutter_local_notifications` | Habit & task reminders |
| `local_auth` | Biometric authentication |
| `shimmer` | Loading shimmer effects |
| `intl` | Date & number formatting |

---

## 📁 Project Structure

```
lib/
├── main.dart                      # Entry point, Hive + routing init
├── theme/
│   └── app_theme.dart             # Colors, typography, theme
├── models/
│   └── models.dart                # All data models (Hive)
├── services/
│   └── app_state.dart             # Global state with Provider
├── widgets/
│   └── shared_widgets.dart        # Reusable UI components
└── screens/
    ├── main_shell.dart            # Bottom nav shell
    ├── dashboard/
    │   └── dashboard_screen.dart  # Home dashboard
    ├── tasks/
    │   └── tasks_screen.dart      # Task manager
    ├── habits/
    │   └── habits_screen.dart     # Habit tracker
    ├── goals/
    │   └── goals_screen.dart      # Goals tracker
    ├── journal/
    │   └── journal_screen.dart    # Daily journal
    ├── focus/
    │   └── focus_screen.dart      # Focus/Pomodoro timer
    ├── health/
    │   └── health_screen.dart     # Health tracker
    ├── finance/
    │   └── finance_screen.dart    # Finance tracker
    └── analytics/
        └── analytics_screen.dart  # Charts & insights
```

---

## 🚀 Getting Started

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Generate Hive adapters
```bash
dart run build_runner build
```

### 3. Run on device
```bash
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
```

> APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Permissions Required

| Permission | Purpose |
|---|---|
| `USE_BIOMETRIC` | Fingerprint/face unlock |
| `VIBRATE` | Haptic feedback |
| `RECEIVE_BOOT_COMPLETED` | Restore notifications on reboot |
| `POST_NOTIFICATIONS` | Habit & task reminders |

---


## 👩‍💻 Developer

**Akanksha** — Built with ❤️ using Flutter
