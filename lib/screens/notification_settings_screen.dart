import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/theme_colors.dart';
import '../utils/app_constants.dart';
import '../models/tracking_models.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _lowPowerMode = false;
  HumorStyle _selectedHumorStyle = HumorStyle.friendly;

  // AI Learning Data
  Map<String, int> _userBehaviorPatterns = {};
  Map<String, double> _spendingHabits = {};
  double _userEngagementScore = 50.0;
  double _financialHealthScore = 50.0;
  int _notificationEffectiveness = 50;
  List<double> _dailySpendingTrends = [];
  List<double> _refundSuccessTrends = [];
  List<String> _achievementHistory = [];
  int _consecutiveDays = 0;
  double _totalSavings = 0.0;
  int _refundSuccessRate = 0;
  String _lastMood = 'neutral';
  String _currentFinancialPhase = 'stable';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _lowPowerMode = _notificationService.lowPowerMode;
      _selectedHumorStyle = _notificationService.currentHumorStyle;

      // Load AI Learning Data
      _userBehaviorPatterns = _notificationService.userBehaviorPatterns;
      _spendingHabits = _notificationService.spendingHabits;
      _userEngagementScore = _notificationService.userEngagementScore;
      _financialHealthScore = _notificationService.financialHealthScore;
      _notificationEffectiveness =
          _notificationService.notificationEffectiveness;
      _dailySpendingTrends = _notificationService.dailySpendingTrends;
      _refundSuccessTrends = _notificationService.refundSuccessTrends;
      _achievementHistory = _notificationService.achievementHistory;
      _consecutiveDays = _notificationService.consecutiveDays;
      _totalSavings = _notificationService.totalSavings;
      _refundSuccessRate = _notificationService.refundSuccessRate;
      _lastMood = _notificationService.lastMood;
      _currentFinancialPhase = _notificationService.currentFinancialPhase;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashFlow Comedian'),
        backgroundColor: ThemeColors.getModeAccent(TrackingMode.perItem),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColors.getModeAccent(TrackingMode.perItem),
              ThemeColors.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildMainSettings(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildAIAnalyticsSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildHumorStyleSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildTestSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildHumorProfile(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildAchievementsSection(),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildFinancialInsightsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            '🎤',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            'CashFlow Comedian',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge * 1.2,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Your AI-powered funny financial assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSettings() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Permission Status
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: _notificationService.permissionGranted
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
              border: Border.all(
                color: _notificationService.permissionGranted
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _notificationService.permissionGranted
                      ? Icons.check_circle
                      : Icons.warning,
                  color: _notificationService.permissionGranted
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _notificationService.permissionGranted
                            ? 'Permission Granted ✅'
                            : 'Permission Required ⚠️',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _notificationService.permissionGranted
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      Text(
                        _notificationService.permissionGranted
                            ? 'Notifications will work properly'
                            : 'Enable notifications in device settings',
                        style: TextStyle(
                          fontSize: AppConstants.textSizeSmall,
                          color: _notificationService.permissionGranted
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_notificationService.permissionGranted)
                  ElevatedButton(
                    onPressed: () async {
                      await _notificationService.checkAndRequestPermissions();
                      setState(() {}); // Refresh UI
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          ThemeColors.getModeAccent(TrackingMode.perItem),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Request'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Enable Notifications
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive funny financial alerts'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              await _notificationService.setNotificationsEnabled(value);
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: ThemeColors.getModeAccent(TrackingMode.perItem),
          ),

          // Low Power Mode
          SwitchListTile(
            title: const Text('Low Power Mode'),
            subtitle:
                const Text('Reduce notification frequency to save battery'),
            value: _lowPowerMode,
            onChanged: _notificationsEnabled
                ? (value) async {
                    await _notificationService.setLowPowerMode(value);
                    setState(() {
                      _lowPowerMode = value;
                    });
                  }
                : null,
            activeColor: ThemeColors.getModeAccent(TrackingMode.perItem),
          ),
        ],
      ),
    );
  }

  Widget _buildHumorStyleSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Humor Style',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Choose your preferred comedy style',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Humor Style Options
          ...HumorStyle.values.map((style) => _buildHumorStyleOption(style)),
        ],
      ),
    );
  }

  Widget _buildHumorStyleOption(HumorStyle style) {
    final isSelected = _selectedHumorStyle == style;
    final styleInfo = _getHumorStyleInfo(style);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isSelected
            ? ThemeColors.getModeAccent(TrackingMode.perItem)
                .withValues(alpha: 0.1)
            : ThemeColors.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        border: Border.all(
          color: isSelected
              ? ThemeColors.getModeAccent(TrackingMode.perItem)
              : ThemeColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          styleInfo.icon,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          styleInfo.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? ThemeColors.getModeAccent(TrackingMode.perItem)
                : ThemeColors.textPrimary,
          ),
        ),
        subtitle: Text(
          styleInfo.description,
          style: TextStyle(
            color: isSelected
                ? ThemeColors.getModeAccent(TrackingMode.perItem)
                    .withValues(alpha: 0.8)
                : ThemeColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: ThemeColors.getModeAccent(TrackingMode.perItem),
              )
            : null,
        onTap: () async {
          await _notificationService.setHumorStyle(style);
          setState(() {
            _selectedHumorStyle = style;
          });
        },
      ),
    );
  }

  HumorStyleInfo _getHumorStyleInfo(HumorStyle style) {
    switch (style) {
      case HumorStyle.savage:
        return HumorStyleInfo(
          icon: '🤣',
          name: 'Savage Mode',
          description: 'Brutally honest with a touch of sass',
        );
      case HumorStyle.dadJokes:
        return HumorStyleInfo(
          icon: '😆',
          name: 'Dad Jokes',
          description: 'Classic puns and cheesy humor',
        );
      case HumorStyle.mascotMode:
        return HumorStyleInfo(
          icon: '🦊',
          name: 'Mascot Mode',
          description: 'Cute mascots deliver the news',
        );
      case HumorStyle.friendly:
        return HumorStyleInfo(
          icon: '😊',
          name: 'Friendly',
          description: 'Warm and encouraging messages',
        );
    }
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Notifications',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Try different notification types',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Test Buttons
          Wrap(
            spacing: AppConstants.paddingSmall,
            runSpacing: AppConstants.paddingSmall,
            children: [
              _buildTestButton(
                '💰 Low Balance',
                NotificationTrigger.lowBalance,
                '50.00',
              ),
              _buildTestButton(
                '⏰ Refund Delayed',
                NotificationTrigger.refundDelayed,
                'Headphones',
              ),
              _buildTestButton(
                '🚨 Spending Spree',
                NotificationTrigger.spreeAlert,
                null,
              ),
              _buildTestButton(
                '🎉 Refund Joy',
                NotificationTrigger.refundJoy,
                '200.00',
              ),
              _buildTestButton(
                '💪 Encouragement',
                NotificationTrigger.randomEncouragement,
                null,
              ),
              _buildTestButton(
                '📊 Weekly Summary',
                NotificationTrigger.weeklySummary,
                '500.00 spent, 200.00 refunded',
              ),
              _buildTestButton(
                '🧠 Smart Reminder',
                NotificationTrigger.smartReminder,
                null,
              ),
              _buildTestButton(
                '🔍 Pattern Alert',
                NotificationTrigger.patternAlert,
                'spending spike',
              ),
              _buildTestButton(
                '🏆 Achievement',
                NotificationTrigger.achievementUnlocked,
                'First Refund',
              ),
              _buildTestButton(
                '💡 Budget Insight',
                NotificationTrigger.budgetInsight,
                'high daily spending',
              ),
              _buildTestButton(
                '🔮 Refund Prediction',
                NotificationTrigger.refundPrediction,
                'high success rate',
              ),
              _buildTestButton(
                '📈 Spending Analysis',
                NotificationTrigger.spendingAnalysis,
                'spending increase',
              ),
              _buildTestButton(
                '⚡ Motivational Boost',
                NotificationTrigger.motivationalBoost,
                null,
              ),
              _buildTestButton(
                '💎 Financial Tip',
                NotificationTrigger.financialTip,
                'tracking all expenses',
              ),
              _buildTestButton(
                '📋 Habit Tracker',
                NotificationTrigger.habitTracker,
                '7 days',
              ),
              _buildTestButton(
                '🎯 Goal Progress',
                NotificationTrigger.goalProgress,
                '50%',
              ),
              _buildTestButton(
                '🛡️ Emergency Fund',
                NotificationTrigger.emergencyFund,
                null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
      String title, NotificationTrigger trigger, String? customData) {
    return ElevatedButton(
      onPressed: _notificationsEnabled
          ? () async {
              try {
                await _notificationService.triggerNotification(trigger,
                    customData: customData);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test notification sent: $title'),
                      backgroundColor:
                          ThemeColors.getModeAccent(TrackingMode.perItem),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.getModeAccent(TrackingMode.perItem),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: AppConstants.textSizeSmall),
      ),
    );
  }

  // AI Analytics Section
  Widget _buildAIAnalyticsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🧠',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'AI Analytics Dashboard',
                style: TextStyle(
                  fontSize: AppConstants.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Your AI is learning and analyzing your financial patterns',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // AI Scores
          _buildAIScoreCard('User Engagement', _userEngagementScore,
              'How engaged you are with the app'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildAIScoreCard('Financial Health', _financialHealthScore,
              'Your overall financial wellness'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildAIScoreCard(
              'Notification Effectiveness',
              _notificationEffectiveness.toDouble(),
              'How well notifications work for you'),

          const SizedBox(height: AppConstants.paddingLarge),

          // Behavior Patterns
          const Text(
            'Behavior Patterns',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          ..._userBehaviorPatterns.entries
              .map((entry) => _buildBehaviorPattern(entry.key, entry.value)),

          if (_userBehaviorPatterns.isEmpty)
            const Text(
              'No behavior patterns detected yet. Keep using the app!',
              style: TextStyle(
                fontSize: AppConstants.textSizeSmall,
                color: ThemeColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIScoreCard(String title, double score, String description) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: ThemeColors.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        border: Border.all(color: ThemeColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                ),
              ),
              Text(
                '${score.round()}%',
                style: TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            description,
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: ThemeColors.progressBackground,
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorPattern(String pattern, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatPatternName(pattern),
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textPrimary,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: AppConstants.textSizeSmall,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getModeAccent(TrackingMode.perItem),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPatternName(String pattern) {
    switch (pattern) {
      case 'app_opens':
        return 'App Opens';
      case 'midnight_spending':
        return 'Midnight Spending';
      default:
        return pattern
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return ThemeColors.successColor;
    if (score >= 60) return ThemeColors.warningColor;
    return ThemeColors.errorColor;
  }

  // Achievements Section
  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🏆',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: AppConstants.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            '${_achievementHistory.length} achievements unlocked',
            style: const TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          if (_achievementHistory.isNotEmpty)
            ..._achievementHistory
                .map((achievement) => _buildAchievementItem(achievement))
          else
            const Text(
              'No achievements yet. Keep tracking your refunds to unlock achievements!',
              style: TextStyle(
                fontSize: AppConstants.textSizeSmall,
                color: ThemeColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: ThemeColors.getModeAccent(TrackingMode.perItem)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        border: Border.all(
          color: ThemeColors.getModeAccent(TrackingMode.perItem)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              _formatAchievementName(achievement),
              style: const TextStyle(
                fontSize: AppConstants.textSizeSmall,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: ThemeColors.successColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatAchievementName(String achievement) {
    switch (achievement) {
      case 'first_refund':
        return 'First Refund';
      case 'week_streak':
        return 'Week Warrior';
      case 'century_refunder':
        return 'Century Refunder';
      case 'big_refunder':
        return 'Big Refunder';
      case 'habit_former':
        return 'Habit Former';
      default:
        return achievement
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  // Financial Insights Section
  Widget _buildFinancialInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '📊',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Financial Insights',
                style: TextStyle(
                  fontSize: AppConstants.textSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'AI-powered insights about your financial patterns',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Key Metrics
          _buildFinancialMetric('Consecutive Days', '$_consecutiveDays days',
              'Days of consistent tracking'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildFinancialMetric(
              'Total Savings',
              '${_totalSavings.toStringAsFixed(2)} TND',
              'Total amount saved through refunds'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildFinancialMetric('Refund Success Rate', '$_refundSuccessRate%',
              'Percentage of successful refunds'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildFinancialMetric('Current Mood', _lastMood,
              'Your financial mood based on AI analysis'),
          const SizedBox(height: AppConstants.paddingMedium),
          _buildFinancialMetric('Financial Phase', _currentFinancialPhase,
              'Current financial situation'),

          const SizedBox(height: AppConstants.paddingLarge),

          // Spending Habits
          if (_spendingHabits.isNotEmpty) ...[
            const Text(
              'Spending Habits',
              style: TextStyle(
                fontSize: AppConstants.textSizeMedium,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ..._spendingHabits.entries
                .map((entry) => _buildSpendingHabit(entry.key, entry.value)),
          ],

          // Trends
          if (_dailySpendingTrends.isNotEmpty ||
              _refundSuccessTrends.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            const Text(
              'Trends',
              style: TextStyle(
                fontSize: AppConstants.textSizeMedium,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            if (_dailySpendingTrends.isNotEmpty)
              _buildTrendItem('Daily Spending', _dailySpendingTrends.length,
                  'days tracked'),
            if (_refundSuccessTrends.isNotEmpty)
              _buildTrendItem(
                  'Refund Success', _refundSuccessTrends.length, 'data points'),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(String title, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: ThemeColors.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeColors.radiusMedium),
        border: Border.all(color: ThemeColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.getModeAccent(TrackingMode.perItem),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            description,
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingHabit(String habit, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatHabitName(habit),
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textPrimary,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: AppConstants.textSizeSmall,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getModeAccent(TrackingMode.perItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(String title, int count, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textPrimary,
            ),
          ),
          Text(
            '$count $unit',
            style: TextStyle(
              fontSize: AppConstants.textSizeSmall,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getModeAccent(TrackingMode.perItem),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHabitName(String habit) {
    switch (habit) {
      case 'daily_average':
        return 'Daily Average Spending';
      case 'weekly_total':
        return 'Weekly Total Spending';
      default:
        return habit
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  Widget _buildHumorProfile() {
    final humorScore = _notificationService.humorScore;
    final styleScores = _notificationService.styleScores;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeColors.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: ThemeColors.shadowColor,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Humor Profile',
            style: TextStyle(
              fontSize: AppConstants.textSizeLarge,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Your AI is learning your preferences',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),

          // Overall Humor Score
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Score',
                      style: TextStyle(
                        fontSize: AppConstants.textSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    LinearProgressIndicator(
                      value: humorScore / 100,
                      backgroundColor: ThemeColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getHumorScoreColor(humorScore),
                      ),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '$humorScore/100',
                      style: const TextStyle(
                        fontSize: AppConstants.textSizeSmall,
                        color: ThemeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingLarge),

          // Style Scores
          const Text(
            'Style Preferences',
            style: TextStyle(
              fontSize: AppConstants.textSizeMedium,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          ...styleScores.entries
              .map((entry) => _buildStyleScore(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildStyleScore(HumorStyle style, int score) {
    final styleInfo = _getHumorStyleInfo(style);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          Text(
            styleInfo.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  styleInfo.name,
                  style: const TextStyle(
                    fontSize: AppConstants.textSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: ThemeColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getHumorScoreColor(score),
                  ),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: AppConstants.textSizeSmall,
              color: ThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHumorScoreColor(int score) {
    if (score >= 80) return ThemeColors.successColor;
    if (score >= 60) return ThemeColors.warningColor;
    return ThemeColors.errorColor;
  }
}

class HumorStyleInfo {
  final String icon;
  final String name;
  final String description;

  HumorStyleInfo({
    required this.icon,
    required this.name,
    required this.description,
  });
}
