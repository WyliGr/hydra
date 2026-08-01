# HYDRA

> Water tracker with drink ratio regulator & homescreen widget.
> Built with Flutter.

![Hydra](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

## What is Hydra?

Hydra is a water tracking app that combines two concepts:

### 1. Sip — Visual water tracking
- Animated water bottle that fills up throughout the day
- Quick-add buttons (25cl, 33cl, 50cl)
- Tap the widget on your home screen to instantly log water
- 7-day stats with bar chart and goal line

### 2. Regulator — Drink ratio compensation
When you log a sugary or caffeinated drink, Hydra calculates how much water
you need to drink to compensate, based on ratios:

| Drink      | Volume | Ratio (water:drink) | Water to compensate |
|------------|--------|---------------------|---------------------|
| Coca-Cola  | 330ml  | 2:1                 | 660ml               |
| Holy       | 330ml  | 3:1                 | 990ml               |
| Red Bull   | 250ml  | 3:1                 | 750ml               |
| Coffee     | 120ml  | 2.5:1               | 300ml               |
| Tea        | 250ml  | 1.5:1               | 375ml               |
| Juice      | 250ml  | 1:1                 | 250ml               |
| Beer       | 330ml  | 2:1                 | 660ml               |

Uncompensated drinks create a **water debt** that's added to your daily goal.

## Features

- **Homescreen widget** — shows progress + tap to add 25cl
- **7-day stats** — bar chart, goal line, average, best day
- **Smart reminders** — configurable interval notifications
- **Auto goal** — calculates from body weight (35ml/kg)
- **Water debt tracking** — never skip compensation
- **Nothing OS theme** — monochrome black + red, dot matrix aesthetic

## Getting Started

### Prerequisites
- Flutter 3.16+
- Dart 3.2+
- Android Studio / Xcode (for building)

### Install & Run

```bash
git clone https://github.com/WyliGr/hydra.git
cd hydra
flutter pub get
flutter run
```

### Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Tech Stack

- **Framework:** Flutter (Dart)
- **State:** ChangeNotifier (built-in)
- **Storage:** SharedPreferences
- **Widget:** home_widget package + native Kotlin (Android) / Swift (iOS)
- **Notifications:** flutter_local_notifications
- **Charts:** fl_chart

## Project Structure

```
lib/
├── main.dart                    # App entry + navigation
├── models/
│   ├── water_log.dart           # Water intake log entry
│   ├── drink_ratio.dart         # Drink types, ratios, drink logs
│   └── user_profile.dart        # User profile for goal calculation
├── services/
│   ├── storage_service.dart     # SharedPreferences persistence
│   ├── hydra_state.dart         # Central app state
│   ├── widget_service.dart      # Homescreen widget bridge
│   └── notification_service.dart # Local push notifications
├── screens/
│   ├── home_screen.dart         # Bottle + quick add + regulator
│   ├── stats_screen.dart        # 7-day chart + summary cards
│   └── settings_screen.dart     # Profile, goal, reminders
├── widgets/
│   ├── water_bottle.dart        # Custom painted animated bottle
│   ├── quick_add_buttons.dart   # 25/33/50cl buttons
│   └── drink_regulator_card.dart # Drink logging + debt display
└── utils/
    ├── theme.dart               # Dark ocean theme
    └── format.dart              # ML/time formatting
```

## Roadmap

- [ ] iOS widget (Swift WidgetKit)
- [ ] Hydration streaks & achievements
- [ ] Calendar sync (skip reminders during courses)
- [ ] Custom drink presets
- [ ] Data export (CSV/JSON)
- [ ] Apple Health / Google Fit integration

## License

MIT © WyliGr