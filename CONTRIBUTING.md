# Contributing to Refund Tracker Pro

Thank you for your interest in contributing to Refund Tracker Pro! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.5 or higher
- Dart SDK 3.2.3 or higher
- Git
- A code editor (VS Code, Android Studio, etc.)

### Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/refund-tracker-pro.git`
3. Navigate to the project: `cd refund-tracker-pro`
4. Install dependencies: `flutter pub get`
5. Create a new branch: `git checkout -b feature/your-feature-name`

## 📝 Development Guidelines

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper indentation (2 spaces)

### File Organization
- Keep related files together
- Use descriptive file names
- Follow the existing project structure
- Place new widgets in the appropriate directory

### Commit Messages
Use clear, descriptive commit messages:
```
feat: add export functionality
fix: resolve notification badge issue
docs: update README with new features
style: improve button styling
refactor: simplify database queries
test: add unit tests for provider
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Writing Tests
- Write tests for new features
- Ensure existing tests pass
- Aim for good test coverage
- Test both success and error cases

## 🔧 Building and Testing

### Local Development
```bash
# Run in debug mode
flutter run

# Run with specific device
flutter run -d windows
flutter run -d android
flutter run -d linux
```

### Building for Release
```bash
# Android
flutter build apk --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## 📋 Pull Request Process

1. **Create a Feature Branch**
   - Create a new branch from `main`
   - Use descriptive branch names: `feature/export-functionality`

2. **Make Your Changes**
   - Write clean, well-documented code
   - Add tests for new functionality
   - Update documentation if needed

3. **Test Your Changes**
   - Run all tests: `flutter test`
   - Test on multiple platforms if possible
   - Ensure the app builds successfully

4. **Submit a Pull Request**
   - Provide a clear description of changes
   - Include screenshots for UI changes
   - Reference any related issues

5. **Code Review**
   - Address review comments
   - Make requested changes
   - Ensure CI checks pass

## 🐛 Bug Reports

When reporting bugs, please include:
- Platform (Android, Windows, Linux, iOS)
- Flutter version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Error logs

## 💡 Feature Requests

When suggesting features:
- Describe the use case
- Explain the benefits
- Provide examples if possible
- Consider implementation complexity

## 📚 Documentation

### Code Documentation
- Document public APIs
- Add inline comments for complex logic
- Update README for new features
- Keep documentation up to date

### API Documentation
```dart
/// Calculates the total refunded amount for all items.
/// 
/// Returns the sum of all refund amounts across all tracking modes.
/// If no refunds exist, returns 0.0.
double get totalRefunded {
  // Implementation
}
```

## 🔒 Security

- Don't commit sensitive information
- Report security issues privately
- Follow security best practices
- Validate user inputs

## 🎯 Areas for Contribution

### High Priority
- Bug fixes
- Performance improvements
- UI/UX enhancements
- Platform-specific optimizations

### Medium Priority
- New features
- Documentation improvements
- Test coverage
- Code refactoring

### Low Priority
- Cosmetic changes
- Minor UI tweaks
- Additional platforms

## 🤝 Community Guidelines

- Be respectful and inclusive
- Help other contributors
- Provide constructive feedback
- Follow the project's code of conduct

## 📞 Getting Help

- Check existing issues and discussions
- Ask questions in issues or discussions
- Join the project's community channels
- Review the documentation

## 🏆 Recognition

Contributors will be recognized in:
- Project README
- Release notes
- GitHub contributors page

Thank you for contributing to Refund Tracker Pro! 🎉
