# Refund Tracker Pro

A comprehensive multi-platform refund tracking application built with Flutter. Track your expenses, manage refunds, and stay organized across Android, iOS, Windows, and Linux.

## 🚀 Features

- **Multi-Platform Support**: Works on Android, iOS, Windows, and Linux
- **Local Data Storage**: Secure SQLite database with local storage
- **Smart Notifications**: Cha-ching sound notifications with badge management
- **Export Functionality**: Export data in CSV and JSON formats
- **Responsive Design**: Beautiful UI that adapts to different screen sizes
- **Offline First**: Works completely offline with local data storage
- **Modern UI**: Material Design with custom theming

## 📱 Screenshots

*Screenshots will be added here*

## 🛠️ Technology Stack

- **Framework**: Flutter 3.24.5
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Notifications**: Awesome Notifications
- **Background Tasks**: Workmanager
- **Platform Support**: Android, iOS, Windows, Linux

## 📦 Installation

### Android
1. Download the APK file from the latest release
2. Enable "Install from Unknown Sources" in your device settings
3. Install the APK file

### Windows
1. Download the MSI installer from the latest release
2. Run the installer and follow the setup wizard
3. Launch Refund Tracker Pro from the Start Menu

### Linux
1. Download the AppImage file from the latest release
2. Make it executable: `chmod +x RefundTrackerPro-x86_64.AppImage`
3. Run the AppImage: `./RefundTrackerPro-x86_64.AppImage`

### iOS
1. Download the iOS build files from the latest release
2. Open in Xcode and build for your device
3. Install via Xcode or TestFlight

## 🏗️ Development Setup

### Prerequisites
- Flutter SDK 3.32.8 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Git

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/refund-tracker-pro.git
   cd refund-tracker-pro
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   
   # For iOS (requires macOS)
   flutter run -d ios
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# iOS
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── tracking_models.dart
├── providers/                # State management
│   └── app_provider.dart
├── screens/                  # UI screens
│   ├── welcome_screen.dart
│   ├── main_screen.dart
│   ├── settings_screen.dart
│   └── ...
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── notification_service.dart
│   └── app_info_service.dart
├── utils/                    # Utilities
│   ├── theme_colors.dart
│   └── app_constants.dart
└── widgets/                  # Reusable widgets
    ├── mode_specific_dashboard.dart
    └── pool_dashboard.dart
```

## 🔧 Configuration

### Environment Setup
The app uses the following environment variables (if needed):
- `FLUTTER_TARGET`: Target platform
- `FLUTTER_BUILD_MODE`: Build mode (debug/release)

### Database Configuration
- SQLite database is automatically created in the app's local storage
- No external database setup required
- Data is stored locally on the device

## 🚀 CI/CD Pipeline

This project uses GitHub Actions for automated builds and releases:

- **Build Jobs**: Separate jobs for Android, Windows, Linux, and iOS
- **Artifact Upload**: Build artifacts are uploaded for each platform
- **Release Creation**: Automatic release creation with all platform builds
- **Quality Checks**: Code analysis and testing

### Workflow Triggers
- Push to main/master branch
- Pull requests
- Release creation

## 📋 Features in Detail

### Tracking Modes
- **Per-Item Tracking**: Track individual expenses and refunds
- **Pool Tracking**: Manage shared expenses and refunds

### Data Management
- **Local Storage**: All data stored locally using SQLite
- **Export Options**: CSV and JSON export functionality
- **Data Backup**: Manual export for data backup

### Notifications
- **Cha-ching Sound**: Custom notification sound
- **Badge Management**: Automatic badge clearing on app launch
- **Smart Alerts**: Configurable notification settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all tests pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All package authors for their contributions
- The open-source community

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/refund-tracker-pro/issues) page
2. Create a new issue with detailed information
3. Include your platform, Flutter version, and error logs

## 🔄 Version History

- **v1.0.0**: Initial release with multi-platform support
  - Basic refund tracking functionality
  - Multi-platform builds (Android, Windows, Linux, iOS)
  - Local data storage
  - Notification system

---

**Made with ❤️ by Amino148**
