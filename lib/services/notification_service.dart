import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/tracking_models.dart';
import '../providers/app_provider.dart';

// Extension methods for List operations
extension ListExtensions<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }

  double get average {
    if (isEmpty) return 0.0;
    if (T == double) {
      return (this as List<double>).reduce((a, b) => a + b) / length;
    }
    return 0.0;
  }
}

enum NotificationTrigger {
  lowBalance,
  refundDelayed,
  spreeAlert,
  refundJoy,
  weeklySummary,
  randomEncouragement,
  emergencyLowBalance,
  salaryDay,
  midnightSpending,
  smartReminder,
  patternAlert,
  achievementUnlocked,
  budgetInsight,
  refundPrediction,
  spendingAnalysis,
  motivationalBoost,
  financialTip,
  habitTracker,
  goalProgress,
  emergencyFund,
}

enum HumorStyle {
  savage,
  dadJokes,
  mascotMode,
  friendly,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final Random _random = Random();

  // Humor profile
  HumorStyle _currentHumorStyle = HumorStyle.friendly;
  int _humorScore = 50; // 0-100 scale
  final Map<HumorStyle, int> _styleScores = {};

  // AI Learning System
  final Map<String, int> _userBehaviorPatterns = {};
  final Map<String, double> _spendingHabits = {};
  final Map<String, DateTime> _lastInteractions = {};
  final List<String> _achievementHistory = [];
  int _consecutiveDays = 0;
  double _totalSavings = 0.0;
  int _refundSuccessRate = 0;

  // Smart Algorithm Variables
  double _userEngagementScore = 50.0;
  double _financialHealthScore = 50.0;
  int _notificationEffectiveness = 50;
  final List<double> _dailySpendingTrends = [];
  final List<double> _refundSuccessTrends = [];

  String _lastMood = 'neutral';
  String _currentFinancialPhase = 'stable';

  // Notification settings
  bool _notificationsEnabled = true;
  bool _lowPowerMode = false;
  DateTime? _lastNotificationTime;
  bool _permissionGranted = false;

  // Background task callback
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // Initialize awesome_notifications for background tasks
      await AwesomeNotifications().initialize(
        null, // null for default app icon
        [
          NotificationChannel(
            channelKey: 'cashflow_comedian',
            channelName: 'CashFlow Comedian',
            channelDescription:
                'Funny financial notifications from your wallet',
            defaultColor: const Color(0xFFFF6B35),
            ledColor: const Color(0xFFFF6B35),
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
            playSound: true,
          ),
        ],
      );

      // Show background notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'cashflow_comedian',
          title: '💰 Refund Reminder',
          body: 'Don\'t forget to track your refunds!',
          notificationLayout: NotificationLayout.Default,
        ),
      );

      return Future.value(true);
    });
  }

  Future<void> initialize() async {
    // Initialize Awesome Notifications with app icon
    await AwesomeNotifications().initialize(
      null, // null for default app icon
      [
        NotificationChannel(
          channelKey: 'cashflow_comedian',
          channelName: 'CashFlow Comedian',
          channelDescription: 'Funny financial notifications from your wallet',
          defaultColor: const Color(0xFFFF6B35),
          ledColor: const Color(0xFFFF6B35),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          playSound: true,
          soundSource: 'resource://raw/cha_ching',
        ),
      ],
    );

    // Set up notification action listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationTapped,
    );

    // Check and request permissions
    await _checkAndRequestPermissions();

    // Initialize WorkManager for background tasks
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'cashflow_comedian',
      'notificationTask',
      frequency: const Duration(hours: 2),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
      ),
    );

    // Load humor profile
    await _loadHumorProfile();

    // Load notification settings
    await _loadSettings();
  }

  // Check and request notification permissions
  Future<void> _checkAndRequestPermissions() async {
    // Check current permission status
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Request permission
      status = await Permission.notification.request();
    }

    _permissionGranted = status.isGranted;

    if (!_permissionGranted) {
      debugPrint(
          '⚠️ Notification permission not granted. Notifications will not work!');
      // Show a dialog to guide user to settings
      _showPermissionDialog();
    } else {
      debugPrint('✅ Notification permission granted!');
    }
  }

  // Show permission request dialog
  void _showPermissionDialog() {
    if (_navigatorKey.currentContext != null) {
      showDialog(
        context: _navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🔔 Notification Permission Required'),
            content: const Text(
              'The CashFlow Comedian needs notification permission to send you funny alerts! '
              'Without this permission, you\'ll miss out on all the humor. 😢\n\n'
              'Please enable notifications in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadHumorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _currentHumorStyle = HumorStyle
        .values[prefs.getInt('humor_style') ?? 3]; // Default to friendly
    _humorScore = prefs.getInt('humor_score') ?? 50;

    // Load style scores
    for (final style in HumorStyle.values) {
      _styleScores[style] = prefs.getInt('style_score_${style.name}') ?? 50;
    }

    // Load AI Learning Data
    _loadAILearningData(prefs);
  }

  void _loadAILearningData(SharedPreferences prefs) {
    // Load behavior patterns
    final behaviorJson = prefs.getString('user_behavior_patterns');
    if (behaviorJson != null) {
      final Map<String, dynamic> data = json.decode(behaviorJson);
      _userBehaviorPatterns.clear();
      data.forEach((key, value) => _userBehaviorPatterns[key] = value as int);
    }

    // Load spending habits
    final spendingJson = prefs.getString('spending_habits');
    if (spendingJson != null) {
      final Map<String, dynamic> data = json.decode(spendingJson);
      _spendingHabits.clear();
      data.forEach((key, value) => _spendingHabits[key] = value as double);
    }

    // Load other AI data
    _consecutiveDays = prefs.getInt('consecutive_days') ?? 0;
    _totalSavings = prefs.getDouble('total_savings') ?? 0.0;
    _refundSuccessRate = prefs.getInt('refund_success_rate') ?? 0;
    _userEngagementScore = prefs.getDouble('user_engagement_score') ?? 50.0;
    _financialHealthScore = prefs.getDouble('financial_health_score') ?? 50.0;
    _notificationEffectiveness =
        prefs.getInt('notification_effectiveness') ?? 50;
    _lastMood = prefs.getString('last_mood') ?? 'neutral';
    _currentFinancialPhase =
        prefs.getString('current_financial_phase') ?? 'stable';

    // Load trends
    final trendsJson = prefs.getString('daily_spending_trends');
    if (trendsJson != null) {
      final List<dynamic> data = json.decode(trendsJson);
      _dailySpendingTrends.clear();
      _dailySpendingTrends.addAll(data.map((e) => e as double));
    }

    final refundTrendsJson = prefs.getString('refund_success_trends');
    if (refundTrendsJson != null) {
      final List<dynamic> data = json.decode(refundTrendsJson);
      _refundSuccessTrends.clear();
      _refundSuccessTrends.addAll(data.map((e) => e as double));
    }

    // Load achievements
    final achievementsJson = prefs.getString('achievement_history');
    if (achievementsJson != null) {
      final List<dynamic> data = json.decode(achievementsJson);
      _achievementHistory.clear();
      _achievementHistory.addAll(data.map((e) => e as String));
    }
  }

  Future<void> _saveHumorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('humor_style', _currentHumorStyle.index);
    await prefs.setInt('humor_score', _humorScore);

    for (final entry in _styleScores.entries) {
      await prefs.setInt('style_score_${entry.key.name}', entry.value);
    }

    // Save AI Learning Data
    await _saveAILearningData(prefs);
  }

  Future<void> _saveAILearningData(SharedPreferences prefs) async {
    // Save behavior patterns
    await prefs.setString(
        'user_behavior_patterns', json.encode(_userBehaviorPatterns));

    // Save spending habits
    await prefs.setString('spending_habits', json.encode(_spendingHabits));

    // Save other AI data
    await prefs.setInt('consecutive_days', _consecutiveDays);
    await prefs.setDouble('total_savings', _totalSavings);
    await prefs.setInt('refund_success_rate', _refundSuccessRate);
    await prefs.setDouble('user_engagement_score', _userEngagementScore);
    await prefs.setDouble('financial_health_score', _financialHealthScore);
    await prefs.setInt(
        'notification_effectiveness', _notificationEffectiveness);
    await prefs.setString('last_mood', _lastMood);
    await prefs.setString('current_financial_phase', _currentFinancialPhase);

    // Save trends
    await prefs.setString(
        'daily_spending_trends', json.encode(_dailySpendingTrends));
    await prefs.setString(
        'refund_success_trends', json.encode(_refundSuccessTrends));

    // Save achievements
    await prefs.setString(
        'achievement_history', json.encode(_achievementHistory));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _lowPowerMode = prefs.getBool('low_power_mode') ?? false;

    final lastNotification = prefs.getString('last_notification_time');
    if (lastNotification != null) {
      _lastNotificationTime = DateTime.parse(lastNotification);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('low_power_mode', _lowPowerMode);

    if (_lastNotificationTime != null) {
      await prefs.setString(
          'last_notification_time', _lastNotificationTime!.toIso8601String());
    }
  }

  // Set humor style
  Future<void> setHumorStyle(HumorStyle style) async {
    _currentHumorStyle = style;
    await _saveHumorProfile();
  }

  // Update humor score based on user reaction
  Future<void> updateHumorScore(bool liked) async {
    if (liked) {
      _humorScore = (_humorScore + 10).clamp(0, 100);
      _styleScores[_currentHumorStyle] =
          (_styleScores[_currentHumorStyle] ?? 50 + 10).clamp(0, 100);
    } else {
      _humorScore = (_humorScore - 15).clamp(0, 100);
      _styleScores[_currentHumorStyle] =
          (_styleScores[_currentHumorStyle] ?? 50 - 15).clamp(0, 100);
    }

    // Rotate style if score is too low
    if (_styleScores[_currentHumorStyle]! < 30) {
      final availableStyles = HumorStyle.values
          .where((style) => _styleScores[style]! > 40)
          .toList();

      if (availableStyles.isNotEmpty) {
        _currentHumorStyle =
            availableStyles[_random.nextInt(availableStyles.length)];
      }
    }

    await _saveHumorProfile();
  }

  // Generate funny message based on trigger and humor style
  String _generateMessage(NotificationTrigger trigger, {String? customData}) {
    final jokes = _getJokeDatabase();
    final triggerJokes = jokes[trigger] ?? [];

    if (triggerJokes.isEmpty) return _getDefaultMessage(trigger);

    final selectedJoke = triggerJokes[_random.nextInt(triggerJokes.length)];
    return _personalizeMessage(selectedJoke, customData);
  }

  Map<NotificationTrigger, List<String>> _getJokeDatabase() {
    return {
      NotificationTrigger.lowBalance: [
        "Cha-ching! Your wallet's singing: 'All by myself...' 🎤 Add funds?",
        "Cha-ching! Balance lower than a snake's belly! 🔻 Feed me!",
        "Cha-ching! 🆘 Wallet hunger strike! Only {amount} left. #FeedMe",
        "Cha-ching! Your balance is so low, even a penny feels rich! 🪙",
        "Cha-ching! Wallet status: Crying in the corner 😭 Need a hug (and money)",
        "Cha-ching! 🚨 Your wallet is having a 'The Walking Dead' moment - it's barely alive!",
        "Cha-ching! 💸 Your balance is so low, it's doing the limbo under a bar!",
        "Cha-ching! 🆘 Emergency: Your wallet is sending SOS signals!",
      ],

      NotificationTrigger.refundDelayed: [
        "Cha-ching! Your refund's vacationing in Bermuda 🏝️ Chase it!",
        "Cha-ching! That refund? Still doing yoga in limbo 🧘‍♂️",
        "Cha-ching! ⌛ Your {item} refund is ghosting you. Send a memo!",
        "Cha-ching! Refund delayed? Even snails mock your patience 🐌",
        "Cha-ching! Why was the refund late? It took the *chill* pill! ❄️",
        "Cha-ching! 🔍 Your refund is playing hide and seek - and it's winning!",
        "Cha-ching! 🐌 Your refund is moving slower than a sloth on a Sunday!",
        "Cha-ching! 🕵️‍♂️ Refund detective needed! Your money is MIA!",
      ],

      NotificationTrigger.spreeAlert: [
        "Cha-ching! 🚨 Slow down, big spender! Your wallet needs CPR.",
        "Cha-ching! 3 AM shopping? Your wallet needs therapy 😅",
        "Cha-ching! Spending spree detected! Your wallet's having a panic attack 😱",
        "Cha-ching! Easy there, money bags! Your wallet's getting dizzy 💸",
        "Cha-ching! 🚨 Shopping alert: Your wallet is calling 911!",
        "Cha-ching! 💸 Your wallet is having a 'Fast & Furious' moment - too fast!",
        "Cha-ching! 🎢 Spending rollercoaster detected! Your wallet needs Dramamine!",
        "Cha-ching! 🚨 Code Red: Your wallet is in a spending emergency!",
      ],

      NotificationTrigger.refundJoy: [
        "Cha-ching! 🎉 {amount} unlocked! Treat yourself?",
        "Cha-ching! Refund received! Your wallet's doing a happy dance 💃",
        "Cha-ching! 💰 Money back! Time to celebrate (responsibly) 🎊",
        "Cha-ching! Refund success! Your wallet's smiling again 😊",
        "Cha-ching! 🎉 Refund ninja strikes again! {amount} recovered!",
        "Cha-ching! 🎊 Your wallet just won the lottery! {amount} back!",
        "Cha-ching! 💰 Refund success! Your wallet is doing the Macarena!",
        "Cha-ching! 🎉 Money back! Your wallet is having a party!",
      ],

      NotificationTrigger.weeklySummary: [
        "Cha-ching! 📊 Week recap: Spent {spent}, Refunded {refunded}",
        "Cha-ching! Weekly report: Your wallet's been busy! 📈",
        "Cha-ching! 📊 This week: {spent} out, {refunded} back in",
        "Cha-ching! Weekly summary: Your money's been on quite a journey! 🗺️",
        "Cha-ching! 📊 Week stats: Spending {spent}, Refunding {refunded}",
        "Cha-ching! 📈 Weekly financial report: Your money's been on an adventure!",
        "Cha-ching! 📊 Money movement summary: {spent} out, {refunded} in!",
        "Cha-ching! 📈 Weekly wrap-up: Your wallet's been working overtime!",
      ],

      NotificationTrigger.randomEncouragement: [
        "Cha-ching! 💪 You're a refund ninja! Keep slaying!",
        "Cha-ching! 🌟 Financial wizard in the making!",
        "Cha-ching! 💪 Your wallet management skills are legendary!",
        "Cha-ching! 🌟 Refund master! You've got this!",
        "Cha-ching! 💪 Money management pro! Keep it up!",
        "Cha-ching! 🦸‍♂️ You're the superhero your wallet deserves!",
        "Cha-ching! 🎯 Financial goals? You're hitting them like a boss!",
        "Cha-ching! ⚡ Your money management skills are electrifying!",
      ],

      NotificationTrigger.emergencyLowBalance: [
        "Cha-ching! 🚨 EMERGENCY: Seriously... I'm emptier than a politician's promise 🗳️",
        "Cha-ching! 🚨 CRITICAL: Your wallet's on life support!",
        "Cha-ching! 🚨 ALERT: Balance so low, even dust feels rich!",
        "Cha-ching! 🚨 URGENT: Wallet needs immediate attention!",
        "Cha-ching! 🚨 CRISIS: Your balance is having an existential crisis!",
        "Cha-ching! 🚨 CODE RED: Your wallet is in critical condition!",
        "Cha-ching! 🚨 EMERGENCY: Your balance is on life support!",
        "Cha-ching! 🚨 CRISIS: Your wallet needs an emergency fund transfusion!",
      ],

      NotificationTrigger.salaryDay: [
        "Cha-ching! Payday! Wallet status: Flexing 💪",
        "Cha-ching! 💰 Salary day! Your wallet's getting a makeover!",
        "Cha-ching! 🎉 Payday! Time to feed the wallet!",
        "Cha-ching! 💰 Salary received! Your wallet's happy again!",
        "Cha-ching! 🎊 Payday! Your wallet's doing a victory dance!",
        "Cha-ching! 💰 Payday! Your wallet is doing the happy dance!",
        "Cha-ching! 🎉 Salary day! Your wallet is celebrating!",
        "Cha-ching! 💰 Payday! Your wallet is having a party!",
      ],

      NotificationTrigger.midnightSpending: [
        "Cha-ching! 3 AM shopping? Your wallet needs therapy 😅",
        "Cha-ching! 🌙 Midnight shopping spree? Your wallet's confused!",
        "Cha-ching! 🦉 Night owl shopping detected! Your wallet's tired!",
        "Cha-ching! 🌙 3 AM purchase? Your wallet's questioning life choices!",
        "Cha-ching! 🦉 Late night spending? Your wallet needs sleep!",
        "Cha-ching! 🌙 Midnight shopping? Your wallet is having a nightmare!",
        "Cha-ching! 🦉 Night owl alert: Your wallet is confused about time!",
        "Cha-ching! 🌙 3 AM purchase? Your wallet needs a bedtime story!",
      ],

      // New Enhanced Triggers
      NotificationTrigger.smartReminder: [
        "Cha-ching! 🧠 AI detected: You usually check refunds now!",
        "Cha-ching! 🤖 Smart reminder: Your refunds miss you!",
        "Cha-ching! 🧠 AI says: Time for your daily refund check!",
        "Cha-ching! 🤖 Smart alert: Your wallet needs attention!",
        "Cha-ching! 🧠 AI detected pattern: You're due for a refund check!",
      ],

      NotificationTrigger.patternAlert: [
        "Cha-ching! 🔍 Pattern detected: You always spend on {day}!",
        "Cha-ching! 📊 AI found: You're a {time} shopper!",
        "Cha-ching! 🔍 Pattern alert: Your spending has a rhythm!",
        "Cha-ching! 📊 AI detected: You have a shopping schedule!",
        "Cha-ching! 🔍 Pattern found: Your wallet has a routine!",
      ],

      NotificationTrigger.achievementUnlocked: [
        "Cha-ching! 🏆 Achievement unlocked: {achievement}!",
        "Cha-ching! 🎖️ New badge earned: {achievement}!",
        "Cha-ching! 🏅 Achievement: {achievement} unlocked!",
        "Cha-ching! 🎯 Goal reached: {achievement}!",
        "Cha-ching! 🏆 Milestone achieved: {achievement}!",
      ],

      NotificationTrigger.budgetInsight: [
        "Cha-ching! 💡 Insight: You save {amount} by tracking refunds!",
        "Cha-ching! 🧠 AI insight: Your refund strategy is working!",
        "Cha-ching! 💡 Smart tip: You could save more by {tip}!",
        "Cha-ching! 🧠 AI analysis: Your spending pattern shows {insight}!",
        "Cha-ching! 💡 Budget insight: You're {percentage} better than average!",
      ],

      NotificationTrigger.refundPrediction: [
        "Cha-ching! 🔮 AI predicts: {item} refund coming soon!",
        "Cha-ching! 🔮 Prediction: You'll get {amount} back this week!",
        "Cha-ching! 🔮 AI forecast: Refund season is approaching!",
        "Cha-ching! 🔮 Prediction: Your patience will pay off!",
        "Cha-ching! 🔮 AI says: Good news is on the horizon!",
      ],

      NotificationTrigger.spendingAnalysis: [
        "Cha-ching! 📈 Analysis: You're {trend} this month!",
        "Cha-ching! 📊 Spending report: You're doing {better/worse} than usual!",
        "Cha-ching! 📈 Trend alert: Your spending is {trend}!",
        "Cha-ching! 📊 Analysis: Your wallet behavior is {pattern}!",
        "Cha-ching! 📈 Insight: Your spending shows {characteristic}!",
      ],

      NotificationTrigger.motivationalBoost: [
        "Cha-ching! ⚡ Motivational boost: You're crushing your financial goals!",
        "Cha-ching! 💪 Energy boost: Your wallet management is inspiring!",
        "Cha-ching! ⚡ Power up: You're a financial superhero!",
        "Cha-ching! 💪 Motivation: Your refund skills are legendary!",
        "Cha-ching! ⚡ Boost: You're making money moves like a boss!",
      ],

      NotificationTrigger.financialTip: [
        "Cha-ching! 💎 Pro tip: {tip} will save you money!",
        "Cha-ching! 💎 Financial wisdom: {tip}!",
        "Cha-ching! 💎 Money hack: {tip} for better savings!",
        "Cha-ching! 💎 Smart advice: {tip} for financial success!",
        "Cha-ching! 💎 Expert tip: {tip} to grow your wealth!",
      ],

      NotificationTrigger.habitTracker: [
        "Cha-ching! 📋 Habit check: You've tracked {days} days in a row!",
        "Cha-ching! 📋 Streak alert: {days} days of financial tracking!",
        "Cha-ching! 📋 Habit tracker: You're building great money habits!",
        "Cha-ching! 📋 Consistency check: {days} days of financial discipline!",
        "Cha-ching! 📋 Habit alert: You're forming excellent financial routines!",
      ],

      NotificationTrigger.goalProgress: [
        "Cha-ching! 🎯 Goal progress: {percentage} to your target!",
        "Cha-ching! 🎯 Progress update: You're {percentage} there!",
        "Cha-ching! 🎯 Goal tracker: {percentage} complete!",
        "Cha-ching! 🎯 Progress alert: You're {percentage} of the way!",
        "Cha-ching! 🎯 Goal check: {percentage} achieved!",
      ],

      NotificationTrigger.emergencyFund: [
        "Cha-ching! 🛡️ Emergency fund alert: Build your safety net!",
        "Cha-ching! 🛡️ Safety net reminder: Emergency fund needed!",
        "Cha-ching! 🛡️ Protection alert: Your emergency fund needs attention!",
        "Cha-ching! 🛡️ Security check: Emergency fund status critical!",
        "Cha-ching! 🛡️ Safety alert: Protect yourself with emergency savings!",
      ],
    };
  }

  String _getDefaultMessage(NotificationTrigger trigger) {
    switch (trigger) {
      case NotificationTrigger.lowBalance:
        return "Cha-ching! Your wallet needs attention! 💰";
      case NotificationTrigger.refundDelayed:
        return "Cha-ching! A refund is overdue! ⏰";
      case NotificationTrigger.spreeAlert:
        return "Cha-ching! Spending spree detected! 🚨";
      case NotificationTrigger.refundJoy:
        return "Cha-ching! Refund received! 🎉";
      case NotificationTrigger.weeklySummary:
        return "Cha-ching! Weekly summary available! 📊";
      case NotificationTrigger.randomEncouragement:
        return "Cha-ching! You're doing great! 💪";
      case NotificationTrigger.emergencyLowBalance:
        return "Cha-ching! CRITICAL: Low balance! 🚨";
      case NotificationTrigger.salaryDay:
        return "Cha-ching! Payday! 💰";
      case NotificationTrigger.midnightSpending:
        return "Cha-ching! Late night spending! 🌙";
      case NotificationTrigger.smartReminder:
        return "Cha-ching! Smart reminder activated! 🧠";
      case NotificationTrigger.patternAlert:
        return "Cha-ching! Pattern detected! 🔍";
      case NotificationTrigger.achievementUnlocked:
        return "Cha-ching! Achievement unlocked! 🏆";
      case NotificationTrigger.budgetInsight:
        return "Cha-ching! Budget insight! 💡";
      case NotificationTrigger.refundPrediction:
        return "Cha-ching! Refund prediction! 🔮";
      case NotificationTrigger.spendingAnalysis:
        return "Cha-ching! Spending analysis! 📈";
      case NotificationTrigger.motivationalBoost:
        return "Cha-ching! Motivational boost! ⚡";
      case NotificationTrigger.financialTip:
        return "Cha-ching! Financial tip! 💎";
      case NotificationTrigger.habitTracker:
        return "Cha-ching! Habit tracker! 📋";
      case NotificationTrigger.goalProgress:
        return "Cha-ching! Goal progress! 🎯";
      case NotificationTrigger.emergencyFund:
        return "Cha-ching! Emergency fund alert! 🛡️";
    }
  }

  String _personalizeMessage(String message, String? customData) {
    if (customData != null) {
      message = message.replaceAll('{amount}', customData);
      message = message.replaceAll('{item}', customData);
      message = message.replaceAll('{spent}', customData);
      message = message.replaceAll('{refunded}', customData);
    }

    // Apply humor style personalization
    switch (_currentHumorStyle) {
      case HumorStyle.savage:
        return _makeSavage(message);
      case HumorStyle.dadJokes:
        return _makeDadJoke(message);
      case HumorStyle.mascotMode:
        return _addMascot(message);
      case HumorStyle.friendly:
        return message; // Keep as is
    }
  }

  String _makeSavage(String message) {
    final savageAdditions = [
      " (No offense, but...)",
      " (Just saying...)",
      " (Sorry not sorry)",
      " (Truth hurts)",
      " (Reality check)",
    ];
    return message + savageAdditions[_random.nextInt(savageAdditions.length)];
  }

  String _makeDadJoke(String message) {
    final dadJokeAdditions = [
      " 😂",
      " (Dad joke alert!)",
      " *ba-dum-tss*",
      " (I'll see myself out)",
      " (Dad mode activated)",
    ];
    return message + dadJokeAdditions[_random.nextInt(dadJokeAdditions.length)];
  }

  String _addMascot(String message) {
    final mascots = ["🦊", "🐢", "🦥", "🦊", "🐢"];
    return "${mascots[_random.nextInt(mascots.length)]} says: $message";
  }

  // Clear notification badges when app is opened
  Future<void> clearNotificationBadges() async {
    await AwesomeNotifications().cancelAll();
    debugPrint('🔔 Notification badges cleared');
  }

  // Get notification count for badge
  Future<int> getNotificationCount() async {
    // This would return the count of unread notifications
    // For now, we'll return 0 since we clear all notifications when app opens
    return 0;
  }

  // Show system notification
  Future<void> showNotification({
    required NotificationTrigger trigger,
    required String title,
    String? customData,
    String? payload,
  }) async {
    if (!_notificationsEnabled || !_permissionGranted) return;

    // Check if we should throttle notifications
    if (_shouldThrottle()) return;

    final message = _generateMessage(trigger, customData: customData);

    // Log to console for debugging
    debugPrint('🎤 CashFlow Comedian: $title - $message');

    // Show system notification
    await _showSystemNotification(title, message, payload);

    _lastNotificationTime = DateTime.now();
    await _saveSettings();
  }

  // Show system notification using awesome_notifications
  Future<void> _showSystemNotification(
      String title, String message, String? payload) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _random.nextInt(1000000),
        channelKey: 'cashflow_comedian',
        title: title,
        body: message,
        payload: {'data': payload ?? ''},
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Message,
      ),
    );
  }

  bool _shouldThrottle() {
    if (_lastNotificationTime == null) return false;

    final timeSinceLast = DateTime.now().difference(_lastNotificationTime!);

    // Don't show notifications more than once every 30 minutes
    if (timeSinceLast.inMinutes < 30) return true;

    // In low power mode, be more conservative
    if (_lowPowerMode && timeSinceLast.inHours < 2) return true;

    return false;
  }

  // Manual trigger for testing
  Future<void> triggerNotification(NotificationTrigger trigger,
      {String? customData}) async {
    final titles = {
      NotificationTrigger.lowBalance: "💰 Cha-ching! Wallet Alert",
      NotificationTrigger.refundDelayed: "⏰ Cha-ching! Refund Reminder",
      NotificationTrigger.spreeAlert: "🚨 Cha-ching! Spending Alert",
      NotificationTrigger.refundJoy: "🎉 Cha-ching! Refund Success",
      NotificationTrigger.weeklySummary: "📊 Cha-ching! Weekly Report",
      NotificationTrigger.randomEncouragement: "💪 Cha-ching! Motivation",
      NotificationTrigger.emergencyLowBalance: "🚨 Cha-ching! CRITICAL ALERT",
      NotificationTrigger.salaryDay: "💰 Cha-ching! Payday!",
      NotificationTrigger.midnightSpending: "🌙 Cha-ching! Late Night",
      NotificationTrigger.smartReminder: "🧠 Cha-ching! Smart Reminder",
      NotificationTrigger.patternAlert: "🔍 Cha-ching! Pattern Detected",
      NotificationTrigger.achievementUnlocked: "🏆 Cha-ching! Achievement!",
      NotificationTrigger.budgetInsight: "💡 Cha-ching! Budget Insight",
      NotificationTrigger.refundPrediction: "🔮 Cha-ching! Refund Prediction",
      NotificationTrigger.spendingAnalysis: "📈 Cha-ching! Spending Analysis",
      NotificationTrigger.motivationalBoost: "⚡ Cha-ching! Motivational Boost",
      NotificationTrigger.financialTip: "💎 Cha-ching! Financial Tip",
      NotificationTrigger.habitTracker: "📋 Cha-ching! Habit Tracker",
      NotificationTrigger.goalProgress: "🎯 Cha-ching! Goal Progress",
      NotificationTrigger.emergencyFund: "🛡️ Cha-ching! Emergency Fund",
    };

    await showNotification(
      trigger: trigger,
      title: titles[trigger] ?? "Notification",
      customData: customData,
    );
  }

  // Notification tap handler
  static Future<void> _onNotificationTapped(
      ReceivedAction receivedAction) async {
    // Handle notification taps
    // This could open specific screens based on the notification type
    debugPrint('Notification tapped: ${receivedAction.payload}');

    // Navigate to appropriate screen based on payload
    // Note: In static context, we can't access _navigatorKey directly
    // You can add navigation logic here based on the notification type
    // For example, navigate to dashboard, settings, etc.
  }

  // Settings methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setLowPowerMode(bool enabled) async {
    _lowPowerMode = enabled;
    await _saveSettings();
  }

  // Manually check and request permissions
  Future<void> checkAndRequestPermissions() async {
    await _checkAndRequestPermissions();
  }

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get lowPowerMode => _lowPowerMode;
  HumorStyle get currentHumorStyle => _currentHumorStyle;
  int get humorScore => _humorScore;
  Map<HumorStyle, int> get styleScores => Map.unmodifiable(_styleScores);
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  bool get permissionGranted => _permissionGranted;

  // AI Learning Data Getters
  Map<String, int> get userBehaviorPatterns =>
      Map.unmodifiable(_userBehaviorPatterns);
  Map<String, double> get spendingHabits => Map.unmodifiable(_spendingHabits);
  double get userEngagementScore => _userEngagementScore;
  double get financialHealthScore => _financialHealthScore;
  int get notificationEffectiveness => _notificationEffectiveness;
  List<double> get dailySpendingTrends =>
      List.unmodifiable(_dailySpendingTrends);
  List<double> get refundSuccessTrends =>
      List.unmodifiable(_refundSuccessTrends);
  List<String> get achievementHistory => List.unmodifiable(_achievementHistory);
  int get consecutiveDays => _consecutiveDays;
  double get totalSavings => _totalSavings;
  int get refundSuccessRate => _refundSuccessRate;
  String get lastMood => _lastMood;
  String get currentFinancialPhase => _currentFinancialPhase;

  // Enhanced AI-powered notification analysis
  Future<void> analyzeAndNotify(AppProvider provider) async {
    if (!_notificationsEnabled) return;

    // Update AI learning data
    await _updateAILearningData(provider);

    // Run complex notification algorithms
    await _runSmartNotificationAlgorithms(provider);

    // Check traditional triggers with enhanced logic
    await _checkEnhancedLowBalance(provider);
    await _checkEnhancedDelayedRefunds(provider);
    await _checkEnhancedSpendingSpree(provider);
    await _checkEnhancedRefundJoy(provider);
    await _checkEnhancedSalaryDay();
    await _checkEnhancedMidnightSpending(provider);

    // AI-powered smart notifications
    await _checkSmartReminders(provider);
    await _checkPatternAlerts(provider);
    await _checkAchievements(provider);
    await _checkBudgetInsights(provider);
    await _checkRefundPredictions(provider);
    await _checkSpendingAnalysis(provider);
    await _checkMotivationalBoosts(provider);
    await _checkFinancialTips(provider);
    await _checkHabitTracking(provider);
    await _checkGoalProgress(provider);
    await _checkEmergencyFund(provider);

    // Adaptive notification frequency
    await _adjustNotificationFrequency();
  }

  // Update AI learning data based on user behavior
  Future<void> _updateAILearningData(AppProvider provider) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Track daily app usage
    _userBehaviorPatterns['app_opens'] =
        (_userBehaviorPatterns['app_opens'] ?? 0) + 1;
    _lastInteractions['last_app_open'] = now;

    // Track spending patterns
    final todaySpending = provider.perItemData
        .where((item) => item.date.isAfter(today))
        .fold(0.0, (sum, item) => sum + item.owed);

    _spendingHabits['daily_average'] =
        (_spendingHabits['daily_average'] ?? 0.0) * 0.9 + todaySpending * 0.1;
    _spendingHabits['weekly_total'] =
        (_spendingHabits['weekly_total'] ?? 0.0) + todaySpending;

    // Track refund success
    final totalRefunded = provider.totalRefunded;
    final totalOwed = provider.totalOwed;
    if (totalOwed > 0) {
      _refundSuccessRate = ((totalRefunded / totalOwed) * 100).round();
    }

    // Update trends
    _dailySpendingTrends.add(todaySpending);
    if (_dailySpendingTrends.length > 30) {
      _dailySpendingTrends.removeAt(0);
    }

    _refundSuccessTrends.add(_refundSuccessRate.toDouble());
    if (_refundSuccessTrends.length > 30) {
      _refundSuccessTrends.removeAt(0);
    }

    // Update engagement score
    _updateEngagementScore();

    // Update financial health score
    _updateFinancialHealthScore(provider);

    await _saveHumorProfile();
  }

  void _updateEngagementScore() {
    final appOpens = _userBehaviorPatterns['app_opens'] ?? 0;
    final consecutiveDays = _consecutiveDays;

    // Calculate engagement based on app usage and consistency
    _userEngagementScore =
        (appOpens * 0.4 + consecutiveDays * 2.0).clamp(0.0, 100.0);
  }

  void _updateFinancialHealthScore(AppProvider provider) {
    final totalOwed = provider.totalOwed;
    final totalRefunded = provider.totalRefunded;
    final totalRemaining = provider.totalRemaining;

    if (totalOwed > 0) {
      final refundRate = totalRefunded / totalOwed;
      final remainingRatio = totalRemaining / totalOwed;

      // Financial health based on refund success and remaining balance
      _financialHealthScore =
          (refundRate * 60 + (1 - remainingRatio) * 40).clamp(0.0, 100.0);
    }
  }

  // Run complex smart notification algorithms
  Future<void> _runSmartNotificationAlgorithms(AppProvider provider) async {
    // Time-based smart reminders
    await _checkTimeBasedReminders();

    // Pattern recognition
    await _checkSpendingPatterns(provider);

    // Predictive analytics
    await _runPredictiveAnalytics(provider);

    // Behavioral analysis
    await _analyzeUserBehavior(provider);

    // Contextual notifications
    await _checkContextualNotifications(provider);
  }

  Future<void> _checkTimeBasedReminders() async {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;

    // Check if user usually opens app at this time
    final lastOpen = _lastInteractions['last_app_open'];
    if (lastOpen != null) {
      final lastHour = lastOpen.hour;
      final lastDay = lastOpen.weekday;

      // If user usually opens app around this time, send smart reminder
      if ((hour - lastHour).abs() <= 2 && dayOfWeek == lastDay) {
        if (_random.nextDouble() < 0.3) {
          // 30% chance
          await triggerNotification(NotificationTrigger.smartReminder);
        }
      }
    }
  }

  Future<void> _checkSpendingPatterns(AppProvider provider) async {
    if (_dailySpendingTrends.length < 7) return;

    // Analyze spending patterns
    final recentSpending = _dailySpendingTrends.takeLast(7).average;
    final historicalSpending = _dailySpendingTrends
        .take(_dailySpendingTrends.length - 7)
        .toList()
        .average;

    if (recentSpending > historicalSpending * 1.5) {
      // Spending spike detected
      await triggerNotification(NotificationTrigger.patternAlert,
          customData: 'spending spike');
    } else if (recentSpending < historicalSpending * 0.5) {
      // Spending drop detected
      await triggerNotification(NotificationTrigger.patternAlert,
          customData: 'spending drop');
    }
  }

  Future<void> _runPredictiveAnalytics(AppProvider provider) async {
    // Predict refund likelihood based on historical data
    if (_refundSuccessTrends.length >= 14) {
      final recentSuccessRate = _refundSuccessTrends.takeLast(7).average;
      final historicalSuccessRate = _refundSuccessTrends
          .take(_refundSuccessTrends.length - 7)
          .toList()
          .average;

      if (recentSuccessRate > historicalSuccessRate * 1.2) {
        // High refund success rate - predict more refunds
        await triggerNotification(NotificationTrigger.refundPrediction,
            customData: 'high success rate');
      }
    }

    // Predict spending based on patterns
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final hour = now.hour;

    // Check if this is a typical spending time
    if ((dayOfWeek == 5 || dayOfWeek == 6) && hour >= 18 && hour <= 22) {
      // Weekend evening - typical spending time
      if (_random.nextDouble() < 0.2) {
        await triggerNotification(NotificationTrigger.spendingAnalysis,
            customData: 'weekend evening');
      }
    }
  }

  Future<void> _analyzeUserBehavior(AppProvider provider) async {
    // Analyze user engagement patterns
    if (_userEngagementScore > 80) {
      // High engagement user - send motivational content
      if (_random.nextDouble() < 0.15) {
        await triggerNotification(NotificationTrigger.motivationalBoost);
      }
    } else if (_userEngagementScore < 30) {
      // Low engagement user - send encouragement
      if (_random.nextDouble() < 0.25) {
        await triggerNotification(NotificationTrigger.randomEncouragement);
      }
    }

    // Analyze financial health
    if (_financialHealthScore > 80) {
      // Good financial health - send tips for optimization
      if (_random.nextDouble() < 0.1) {
        await triggerNotification(NotificationTrigger.financialTip,
            customData: 'optimization');
      }
    } else if (_financialHealthScore < 30) {
      // Poor financial health - send emergency fund reminder
      if (_random.nextDouble() < 0.2) {
        await triggerNotification(NotificationTrigger.emergencyFund);
      }
    }
  }

  Future<void> _checkContextualNotifications(AppProvider provider) async {
    // Check for specific contextual situations
    final now = DateTime.now();

    // Monday motivation
    if (now.weekday == 1 && now.hour == 9) {
      if (_random.nextDouble() < 0.4) {
        await triggerNotification(NotificationTrigger.motivationalBoost);
      }
    }

    // End of month summary
    if (now.day >= 28 && now.hour == 18) {
      if (_random.nextDouble() < 0.3) {
        await triggerNotification(NotificationTrigger.weeklySummary);
      }
    }

    // Weekend financial planning
    if (now.weekday == 6 && now.hour == 10) {
      if (_random.nextDouble() < 0.25) {
        await triggerNotification(NotificationTrigger.financialTip,
            customData: 'weekend planning');
      }
    }
  }

  Future<void> _adjustNotificationFrequency() async {
    // Adjust notification frequency based on user engagement and effectiveness
    final baseEffectiveness = _notificationEffectiveness;
    final engagementFactor = _userEngagementScore / 100.0;

    // Calculate optimal notification frequency
    final optimalFrequency =
        (baseEffectiveness * engagementFactor).clamp(10, 90);
    _notificationEffectiveness = optimalFrequency.round();

    // Save the updated effectiveness
    await _saveHumorProfile();
  }

  // Enhanced notification check methods
  Future<void> _checkEnhancedLowBalance(AppProvider provider) async {
    double currentBalance = 0;
    double initialBalance = 0;

    switch (provider.currentMode) {
      case TrackingMode.perItem:
        currentBalance = provider.totalRemaining;
        initialBalance = provider.totalOwed;
        break;
      case TrackingMode.pool:
        if (provider.poolData != null) {
          currentBalance = provider.poolData!.totalRemaining;
          initialBalance = provider.poolData!.totalOwed;
        }
        break;
      case TrackingMode.hybrid:
        if (provider.hybridData != null) {
          currentBalance = provider.hybridData!.totalRemaining;
          initialBalance = provider.hybridData!.totalOwed;
        }
        break;
    }

    if (initialBalance > 0) {
      final percentage = (currentBalance / initialBalance) * 100;

      // Enhanced logic with AI consideration
      final urgency = _calculateUrgency(percentage, _financialHealthScore);

      if (percentage < 5 && urgency > 0.8) {
        await triggerNotification(
          NotificationTrigger.emergencyLowBalance,
          customData: currentBalance.toStringAsFixed(2),
        );
      } else if (percentage < 10 && urgency > 0.6) {
        await triggerNotification(
          NotificationTrigger.lowBalance,
          customData: currentBalance.toStringAsFixed(2),
        );
      }
    }
  }

  double _calculateUrgency(double percentage, double healthScore) {
    // Calculate urgency based on balance percentage and financial health
    final balanceUrgency = (100 - percentage) / 100;
    final healthUrgency = (100 - healthScore) / 100;
    return (balanceUrgency * 0.7 + healthUrgency * 0.3).clamp(0.0, 1.0);
  }

  Future<void> _checkEnhancedDelayedRefunds(AppProvider provider) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Enhanced logic with pattern recognition
    for (final item in provider.perItemData) {
      if (item.remaining > 0 && item.date.isBefore(sevenDaysAgo)) {
        // Check if this is a pattern or one-time delay
        final similarDelays = provider.perItemData
            .where((i) => i.title
                .toLowerCase()
                .contains(item.title.toLowerCase().split(' ').first))
            .length;

        if (similarDelays > 1) {
          await triggerNotification(
            NotificationTrigger.patternAlert,
            customData: 'delayed refunds pattern',
          );
        } else {
          await triggerNotification(
            NotificationTrigger.refundDelayed,
            customData: item.title,
          );
        }
        break;
      }
    }
  }

  Future<void> _checkEnhancedSpendingSpree(AppProvider provider) async {
    final recentItems = provider.perItemData
        .where((item) => item.date
            .isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .length;

    if (recentItems >= 3) {
      // Enhanced logic with spending analysis
      final totalSpent = provider.perItemData
          .where((item) => item.date
              .isAfter(DateTime.now().subtract(const Duration(hours: 1))))
          .fold(0.0, (sum, item) => sum + item.owed);

      final averageSpending = _spendingHabits['daily_average'] ?? 0.0;

      if (totalSpent > averageSpending * 2) {
        await triggerNotification(NotificationTrigger.spendingAnalysis,
            customData: 'high spending spree');
      } else {
        await triggerNotification(NotificationTrigger.spreeAlert);
      }
    }
  }

  Future<void> _checkEnhancedRefundJoy(AppProvider provider) async {
    final totalRefunded = provider.totalRefunded;
    if (totalRefunded > 100) {
      // Enhanced logic with achievement tracking
      if (totalRefunded > 500 &&
          !_achievementHistory.contains('big_refunder')) {
        _achievementHistory.add('big_refunder');
        await triggerNotification(NotificationTrigger.achievementUnlocked,
            customData: 'Big Refunder');
      }

      await triggerNotification(
        NotificationTrigger.refundJoy,
        customData: totalRefunded.toStringAsFixed(2),
      );
    }
  }

  Future<void> _checkEnhancedSalaryDay() async {
    final now = DateTime.now();
    if (now.day >= 25 && now.day <= 31) {
      // Enhanced logic with user behavior
      final lastSalaryCheck = _lastInteractions['salary_check'];
      if (lastSalaryCheck == null ||
          now.difference(lastSalaryCheck).inDays > 7) {
        _lastInteractions['salary_check'] = now;
        await triggerNotification(NotificationTrigger.salaryDay);
      }
    }
  }

  Future<void> _checkEnhancedMidnightSpending(AppProvider provider) async {
    final now = DateTime.now();
    if (now.hour >= 23 || now.hour <= 4) {
      final recentItems = provider.perItemData
          .where((item) => item.date
              .isAfter(DateTime.now().subtract(const Duration(hours: 2))))
          .length;

      if (recentItems > 0) {
        // Enhanced logic with habit tracking
        _userBehaviorPatterns['midnight_spending'] =
            (_userBehaviorPatterns['midnight_spending'] ?? 0) + 1;

        if (_userBehaviorPatterns['midnight_spending']! > 5) {
          await triggerNotification(NotificationTrigger.habitTracker,
              customData: 'midnight spending habit');
        } else {
          await triggerNotification(NotificationTrigger.midnightSpending);
        }
      }
    }
  }

  // AI-powered smart notification methods
  Future<void> _checkSmartReminders(AppProvider provider) async {
    // Smart reminders based on user patterns
    final lastOpen = _lastInteractions['last_app_open'];
    if (lastOpen != null) {
      final timeSinceLastOpen = DateTime.now().difference(lastOpen);

      if (timeSinceLastOpen.inHours > 24 && _userEngagementScore > 50) {
        await triggerNotification(NotificationTrigger.smartReminder);
      }
    }
  }

  Future<void> _checkPatternAlerts(AppProvider provider) async {
    // Pattern detection based on spending habits
    if (_dailySpendingTrends.length >= 7) {
      final recentTrend = _dailySpendingTrends.takeLast(7);
      final trend = _calculateTrend(recentTrend);

      if (trend.abs() > 0.3) {
        await triggerNotification(
          NotificationTrigger.patternAlert,
          customData: trend > 0 ? 'increasing spending' : 'decreasing spending',
        );
      }
    }
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < values.length; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }

    final n = values.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  Future<void> _checkAchievements(AppProvider provider) async {
    // Check for various achievements
    final totalRefunded = provider.totalRefunded;
    final consecutiveDays = _consecutiveDays;

    // First refund achievement
    if (totalRefunded > 0 && !_achievementHistory.contains('first_refund')) {
      _achievementHistory.add('first_refund');
      await triggerNotification(NotificationTrigger.achievementUnlocked,
          customData: 'First Refund');
    }

    // 7-day streak achievement
    if (consecutiveDays >= 7 && !_achievementHistory.contains('week_streak')) {
      _achievementHistory.add('week_streak');
      await triggerNotification(NotificationTrigger.achievementUnlocked,
          customData: 'Week Warrior');
    }

    // 100 TND refunded achievement
    if (totalRefunded >= 100 &&
        !_achievementHistory.contains('century_refunder')) {
      _achievementHistory.add('century_refunder');
      await triggerNotification(NotificationTrigger.achievementUnlocked,
          customData: 'Century Refunder');
    }
  }

  Future<void> _checkBudgetInsights(AppProvider provider) async {
    // Provide budget insights based on spending patterns
    if (_dailySpendingTrends.length >= 14) {
      final averageSpending = _dailySpendingTrends.average;
      final totalOwed = provider.totalOwed;

      if (averageSpending > totalOwed * 0.1) {
        await triggerNotification(
          NotificationTrigger.budgetInsight,
          customData: 'high daily spending',
        );
      }
    }
  }

  Future<void> _checkRefundPredictions(AppProvider provider) async {
    // Predict refund likelihood based on historical data
    if (_refundSuccessTrends.length >= 7) {
      final recentSuccessRate = _refundSuccessTrends.takeLast(7).average;

      if (recentSuccessRate > 70) {
        await triggerNotification(
          NotificationTrigger.refundPrediction,
          customData: 'high success rate',
        );
      }
    }
  }

  Future<void> _checkSpendingAnalysis(AppProvider provider) async {
    // Analyze spending patterns and provide insights
    if (_dailySpendingTrends.length >= 7) {
      final recentSpending = _dailySpendingTrends.takeLast(7).average;
      final historicalSpending = _dailySpendingTrends
          .take(_dailySpendingTrends.length - 7)
          .toList()
          .average;

      if (recentSpending > historicalSpending * 1.5) {
        await triggerNotification(
          NotificationTrigger.spendingAnalysis,
          customData: 'spending increase',
        );
      }
    }
  }

  Future<void> _checkMotivationalBoosts(AppProvider provider) async {
    // Send motivational content based on user behavior
    if (_userEngagementScore > 80 && _financialHealthScore > 70) {
      if (_random.nextDouble() < 0.1) {
        await triggerNotification(NotificationTrigger.motivationalBoost);
      }
    }
  }

  Future<void> _checkFinancialTips(AppProvider provider) async {
    // Provide financial tips based on user situation
    final tips = [
      'tracking all expenses',
      'setting refund goals',
      'reviewing spending patterns',
      'building emergency fund',
      'negotiating better deals',
    ];

    if (_random.nextDouble() < 0.05) {
      final tip = tips[_random.nextInt(tips.length)];
      await triggerNotification(NotificationTrigger.financialTip,
          customData: tip);
    }
  }

  Future<void> _checkHabitTracking(AppProvider provider) async {
    // Track and encourage good financial habits
    final appOpens = _userBehaviorPatterns['app_opens'] ?? 0;

    if (appOpens >= 7 && !_achievementHistory.contains('habit_former')) {
      _achievementHistory.add('habit_former');
      await triggerNotification(NotificationTrigger.habitTracker,
          customData: '7 days');
    }
  }

  Future<void> _checkGoalProgress(AppProvider provider) async {
    // Track progress towards financial goals
    final totalRefunded = provider.totalRefunded;
    final totalOwed = provider.totalOwed;

    if (totalOwed > 0) {
      final progress = (totalRefunded / totalOwed) * 100;

      if (progress >= 50 && progress < 60) {
        await triggerNotification(
          NotificationTrigger.goalProgress,
          customData: '50%',
        );
      } else if (progress >= 80 && progress < 90) {
        await triggerNotification(
          NotificationTrigger.goalProgress,
          customData: '80%',
        );
      }
    }
  }

  Future<void> _checkEmergencyFund(AppProvider provider) async {
    // Remind about emergency fund based on financial health
    if (_financialHealthScore < 40) {
      if (_random.nextDouble() < 0.1) {
        await triggerNotification(NotificationTrigger.emergencyFund);
      }
    }
  }

  // Weekly summary notification
  Future<void> showWeeklySummary(AppProvider provider) async {
    final spent = provider.totalOwed;
    final refunded = provider.totalRefunded;

    await triggerNotification(
      NotificationTrigger.weeklySummary,
      customData:
          "${spent.toStringAsFixed(2)} TND spent, ${refunded.toStringAsFixed(2)} TND refunded",
    );
  }
}
