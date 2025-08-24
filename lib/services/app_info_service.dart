import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppInfoService {
  static final AppInfoService _instance = AppInfoService._internal();
  factory AppInfoService() => _instance;
  AppInfoService._internal();

  PackageInfo? _packageInfo;
  String? _persistentBuildSignature;

  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    await _initializePersistentBuildSignature();
  }

  Future<void> _initializePersistentBuildSignature() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we already have a persistent build signature for this version
    final storedSignature = prefs.getString(
        'build_signature_${_packageInfo?.version}_${_packageInfo?.buildNumber}');

    if (storedSignature != null) {
      _persistentBuildSignature = storedSignature;
    } else {
      // Generate a new persistent build signature
      _persistentBuildSignature = _generatePersistentBuildSignature();

      // Store it for this specific version/build combination
      await prefs.setString(
          'build_signature_${_packageInfo?.version}_${_packageInfo?.buildNumber}',
          _persistentBuildSignature!);
    }
  }

  String _generatePersistentBuildSignature() {
    // Create a deterministic signature based on app info
    final appName = _packageInfo?.appName ?? 'RefundTracker Pro';
    final packageName =
        _packageInfo?.packageName ?? 'com.amino148.refund_tracker_pro';
    final version = _packageInfo?.version ?? '1.0.0';
    final buildNumber = _packageInfo?.buildNumber ?? '1';

    // Create a hash that will be consistent for this build
    final buildString = '$appName$packageName$version$buildNumber';
    final bytes = utf8.encode(buildString);

    // Use a simple hash algorithm for consistency
    int hash = 0;
    for (int byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash; // Convert to 32-bit integer
    }

    // Convert to hex and ensure it's always 8 characters
    final hexString = hash.abs().toRadixString(16).toUpperCase();
    return hexString.padLeft(8, '0').substring(0, 8);
  }

  String get appName => _packageInfo?.appName ?? 'RefundTracker Pro';
  String get packageName =>
      _packageInfo?.packageName ?? 'com.amino148.refund_tracker_pro';
  String get version => _packageInfo?.version ?? '1.0.0';
  String get buildNumber => _packageInfo?.buildNumber ?? '1';

  String get fullVersion => '$version+$buildNumber';

  String get buildSignature {
    // Return the persistent signature instead of generating a new one each time
    return _persistentBuildSignature ?? _generatePersistentBuildSignature();
  }

  Map<String, String> get versionInfo => {
        'appName': appName,
        'packageName': packageName,
        'version': version,
        'buildNumber': buildNumber,
        'fullVersion': fullVersion,
        'buildSignature': buildSignature,
      };

  // Method to get build info for debugging
  String get buildInfo {
    return '''
Build Information:
- App Name: $appName
- Package: $packageName
- Version: $version
- Build Number: $buildNumber
- Full Version: $fullVersion
- Build Signature: $buildSignature
- Signature Type: Persistent (Generated once per build)
''';
  }
}
