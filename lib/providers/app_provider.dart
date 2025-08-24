import 'package:flutter/material.dart';

import '../models/tracking_models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AppProvider extends ChangeNotifier {
  late AppSettings _settings;
  List<ExpenseItem> _perItemData = [];
  PoolTracker? _poolData;
  HybridTracker? _hybridData;
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  AppProvider() {
    _settings = AppSettings(
      trackingMode: TrackingMode.perItem,
      currency: 'TND',
      notificationsEnabled: true,
      criticalDays: 15,
    );
    _perItemData = [];
    _poolData = PoolTracker();
    _hybridData = HybridTracker();
  }

  // Getters
  AppSettings get settings => _settings;
  List<ExpenseItem> get perItemData => _perItemData;
  PoolTracker? get poolData => _poolData;
  HybridTracker? get hybridData => _hybridData;

  bool get isLoading => _isLoading;
  TrackingMode get currentMode => _settings.trackingMode;

  // Calculated getters
  double get totalOwed => _getTotalOwed();
  double get totalRefunded => _getTotalRefunded();
  double get totalRemaining => _getTotalRemaining();
  double get progressPercentage => _getProgressPercentage();

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Initialize notification service
      await _notificationService.initialize();

      _settings = await _databaseService.getSettings();
      await _loadCurrentModeData();

      // Trigger initial notification analysis
      await _notificationService.analyzeAndNotify(this);
    } catch (e) {
      debugPrint('Error initializing AppProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadCurrentModeData() async {
    switch (_settings.trackingMode) {
      case TrackingMode.perItem:
        _perItemData = await _databaseService.getPerItemData();
        break;
      case TrackingMode.pool:
        _poolData = await _databaseService.getPoolData();
        break;
      case TrackingMode.hybrid:
        _hybridData = await _databaseService.getHybridData();
        break;
    }
    notifyListeners();
  }

  // Switch tracking mode
  Future<void> switchMode(TrackingMode newMode) async {
    _settings = _settings.copyWith(trackingMode: newMode);
    await _databaseService.saveSettings(_settings);

    // Clear all data when switching modes
    await _databaseService.clearAllData();

    // Reset local data
    _perItemData = [];
    _poolData = PoolTracker();
    _hybridData = HybridTracker();

    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _databaseService.clearAllData();

    _perItemData = [];
    _poolData = PoolTracker();
    _hybridData = HybridTracker();

    notifyListeners();
  }

  // Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _databaseService.saveSettings(_settings);
    notifyListeners();
  }

  // Mark app as done (after welcome screen completion)
  Future<void> markAppAsDone() async {
    try {
      _settings = _settings.copyWith(isDone: true);
      await _databaseService.saveSettings(_settings);
      notifyListeners();
      debugPrint('App marked as done successfully');
    } catch (e) {
      debugPrint('Error marking app as done: $e');
      // Even if database save fails, update local state
      _settings = _settings.copyWith(isDone: true);
      notifyListeners();
    }
  }

  // Per-item mode operations
  Future<void> addPerItemExpense(ExpenseItem item) async {
    await _databaseService.addPerItemExpense(item);
    _perItemData = await _databaseService.getPerItemData();
    notifyListeners();

    // Trigger notification analysis
    // await _notificationService.analyzeAndNotify(this);
  }

  Future<void> updatePerItemExpense(ExpenseItem item) async {
    await _databaseService.updatePerItemExpense(item);
    _perItemData = await _databaseService.getPerItemData();
    notifyListeners();
  }

  Future<void> deletePerItemExpense(String itemId) async {
    await _databaseService.deletePerItemExpense(itemId);
    _perItemData = await _databaseService.getPerItemData();
    notifyListeners();
  }

  Future<void> addPerItemRefund(
      String itemId, double amount, String? notes) async {
    if (_settings.trackingMode != TrackingMode.perItem &&
        _settings.trackingMode != TrackingMode.hybrid) {
      return;
    }

    final itemIndex = _perItemData.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final item = _perItemData[itemIndex];
      final updatedRefunds = List<RefundEvent>.from(item.refunds);
      updatedRefunds.add(RefundEvent(
        amount: amount,
        date: DateTime.now(),
        notes: notes ?? '',
      ));

      final updatedItem = item.copyWith(refunds: updatedRefunds);
      await _databaseService.updatePerItemExpense(updatedItem);
      _perItemData = await _databaseService.getPerItemData();
      notifyListeners();

      // Trigger refund joy notification
      await _notificationService.triggerNotification(
        NotificationTrigger.refundJoy,
        customData: amount.toStringAsFixed(2),
      );
    }
  }

  // Pool mode operations
  Future<void> addPoolExpense(double amount, String description) async {
    if (amount <= 0) {
      throw Exception('Expense amount must be greater than 0');
    }

    await _databaseService.addPoolExpense(amount, description);
    _poolData = await _databaseService.getPoolData();
    notifyListeners();

    // Trigger notification analysis
    await _notificationService.analyzeAndNotify(this);
  }

  Future<void> addPoolRefund(double amount, String description) async {
    if (amount <= 0) {
      throw Exception('Refund amount must be greater than 0');
    }

    // Validate that refund doesn't exceed total remaining
    if (_poolData != null) {
      final currentRemaining = _poolData!.totalRemaining;
      if (amount > currentRemaining) {
        final maxRefundable = currentRemaining;
        throw Exception(
            'Invalid Refund! Cannot refund ${amount.toStringAsFixed(2)} TND. Maximum refundable: ${maxRefundable.toStringAsFixed(2)} TND');
      }
    }

    await _databaseService.addPoolRefund(amount, description);
    _poolData = await _databaseService.getPoolData();
    notifyListeners();

    // Trigger refund joy notification
    await _notificationService.triggerNotification(
      NotificationTrigger.refundJoy,
      customData: amount.toStringAsFixed(2),
    );
  }

  // Hybrid mode operations
  Future<void> addHybridItem(ExpenseItem item) async {
    _hybridData ??= HybridTracker();

    final updatedItems = List<ExpenseItem>.from(_hybridData!.items);
    updatedItems.add(item);

    final updatedHybrid = _hybridData!.copyWith(items: updatedItems);
    await _databaseService.saveHybridData(updatedHybrid);
    _hybridData = await _databaseService.getHybridData();
    notifyListeners();
  }

  Future<void> addHybridStandaloneExpense(
      double amount, String description) async {
    _hybridData ??= HybridTracker();

    final updatedPool = _hybridData!.standalonePool.copyWith(
      expenses: [
        ..._hybridData!.standalonePool.expenses,
        Transaction(
          amount: amount,
          date: DateTime.now(),
          description: description,
        )
      ],
    );

    final updatedHybrid = _hybridData!.copyWith(standalonePool: updatedPool);
    await _databaseService.saveHybridData(updatedHybrid);
    _hybridData = await _databaseService.getHybridData();
    notifyListeners();
  }

  Future<void> addHybridStandaloneRefund(
      double amount, String description) async {
    if (_hybridData == null) {
      throw Exception('No hybrid data found');
    }

    // Validate that refund doesn't exceed total remaining
    final currentRemaining = _hybridData!.standalonePool.totalRemaining;
    if (amount > currentRemaining) {
      final maxRefundable = currentRemaining;
      throw Exception(
          'Invalid Refund! Cannot refund ${amount.toStringAsFixed(2)} TND. Maximum refundable: ${maxRefundable.toStringAsFixed(2)} TND');
    }

    final updatedPool = _hybridData!.standalonePool.copyWith(
      refunds: [
        ..._hybridData!.standalonePool.refunds,
        Transaction(
          amount: amount,
          date: DateTime.now(),
          description: description,
        )
      ],
    );

    final updatedHybrid = _hybridData!.copyWith(standalonePool: updatedPool);
    await _databaseService.saveHybridData(updatedHybrid);
    _hybridData = await _databaseService.getHybridData();
    notifyListeners();

    // Trigger refund joy notification
    await _notificationService.triggerNotification(
      NotificationTrigger.refundJoy,
      customData: amount.toStringAsFixed(2),
    );
  }

  // Calculated getters implementation
  double _getTotalOwed() {
    switch (_settings.trackingMode) {
      case TrackingMode.perItem:
        return _perItemData.fold(0.0, (sum, item) => sum + item.owed);
      case TrackingMode.pool:
        return _poolData?.totalOwed ?? 0.0;
      case TrackingMode.hybrid:
        return _hybridData?.totalOwed ?? 0.0;
    }
  }

  double _getTotalRefunded() {
    switch (_settings.trackingMode) {
      case TrackingMode.perItem:
        return _perItemData.fold(0.0, (sum, item) => sum + item.refunded);
      case TrackingMode.pool:
        return _poolData?.totalRefunded ?? 0.0;
      case TrackingMode.hybrid:
        return _hybridData?.totalRefunded ?? 0.0;
    }
  }

  double _getTotalRemaining() {
    return (_getTotalOwed() - _getTotalRefunded()).clamp(0.0, double.infinity);
  }

  double _getProgressPercentage() {
    final totalOwed = _getTotalOwed();
    if (totalOwed <= 0) return 0.0;
    return ((_getTotalRefunded() / totalOwed) * 100).clamp(0.0, 100.0);
  }

  // Get items with aging debts (for notification purposes)
  List<ExpenseItem> getItemsWithAgingDebts(int criticalDays) {
    final now = DateTime.now();
    final criticalDate = now.subtract(Duration(days: criticalDays));

    switch (_settings.trackingMode) {
      case TrackingMode.perItem:
        return _perItemData
            .where((item) =>
                item.remaining > 0 && item.date.isBefore(criticalDate))
            .toList();
      case TrackingMode.pool:
        return []; // Pool mode doesn't have individual items
      case TrackingMode.hybrid:
        return _hybridData?.items
                .where((item) =>
                    item.remaining > 0 && item.date.isBefore(criticalDate))
                .toList() ??
            [];
    }
  }

  // Export data for backup/transfer
  Map<String, dynamic> exportData() {
    return {
      'settings': _settings.toJson(),
      'currentMode': _settings.trackingMode.toString(),
      'perItemData': _perItemData.map((item) => item.toJson()).toList(),
      'poolData': _poolData?.toJson(),
      'hybridData': _hybridData?.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  // Pool validation methods
  Map<String, dynamic> getPoolValidationStatus() {
    if (_poolData == null) {
      return {
        'error': 'No pool data available',
        'maxRefundable': 0.0,
      };
    }

    final totalOwed = _poolData!.totalOwed;
    final totalRefunded = _poolData!.totalRefunded;
    final totalRemaining = _poolData!.totalRemaining;

    if (totalOwed == 0) {
      return {
        'warning': 'No expenses recorded',
        'maxRefundable': 0.0,
      };
    }

    if (totalRemaining == 0) {
      return {
        'success': 'All expenses refunded!',
        'maxRefundable': 0.0,
      };
    }

    if (totalRefunded > totalOwed) {
      return {
        'error': 'Over-refunded!',
        'maxRefundable': 0.0,
      };
    }

    return {
      'valid': true,
      'maxRefundable': totalRemaining,
    };
  }

  double getMaxPoolRefundable() {
    return _poolData?.totalRemaining ?? 0.0;
  }
}
