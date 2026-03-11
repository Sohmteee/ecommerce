# Premium E-commerce App

A high-performance, responsive Flutter e-commerce application featuring a modern **Glassmorphism** UI, robust state management, and full CRUD capabilities.

## ✨ Features

- 💎 **Glassmorphism UI**: Premium "Liquid Glass" aesthetic with dynamic blur, transparency, and sheen effects.
- 📱 **Fully Responsive**: Optimized for various screen sizes using `flutter_screenutil`.
- 🚀 **Full CRUD**: Add, Edit, and Delete products with real-time local state updates and remote API integration (DummyJSON).
- 🔍 **Search & Sort**: Real-time filtering and multiple sorting options (Price, Rating, Title).
- ⚡ **Skeleton Loading**: Smooth loading states using `skeletonizer`.
- 🔔 **Interactive UI**: Custom glass-themed dialogs, floating action bars, and toast notifications.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod (v3 Notifiers)](https://riverpod.dev)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Responsiveness**: [flutter_screenutil](https://pub.dev/packages/flutter_screenutil)
- **UI/UX**: [Iconsax](https://pub.dev/packages/iconsax), [Skeletonizer](https://pub.dev/packages/skeletonizer), [Toastification](https://pub.dev/packages/toastification), [Google Fonts](https://pub.dev/packages/google_fonts)
- **Local/Format**: [Intl](https://pub.dev/packages/intl)

## 📁 Project Structure

```text
lib/
├── core/               # Core utilities, theme, and common widgets
│   ├── network/        # API configuration and Dio client
│   ├── providers/      # Global application state
│   └── widgets/        # Reusable UI components (GlassContainer, etc.)
└── features/           # Feature-based modules
    └── home/           # Product catalog and management
        ├── data/       # Repositories and data sources
        ├── domain/     # Models and interfaces
        └── presentation/ # UI screens, widgets, and Riverpod providers
```

## 🚀 Getting Started

1. **Clone the repository**
2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the app**:

   ```bash
   flutter run
   ```

## 📝 Documentation

The codebase is thoroughly documented with Dart doc-comments for all core logic, models, and presentation layers to ensure high maintainability.
