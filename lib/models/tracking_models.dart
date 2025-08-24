import 'package:uuid/uuid.dart';

enum TrackingMode { perItem, pool, hybrid }

class AppSettings {
  final TrackingMode trackingMode;
  final String currency;

  final bool notificationsEnabled;
  final int criticalDays;
  final bool isDone;

  AppSettings({
    required this.trackingMode,
    this.currency = 'TND',

    this.notificationsEnabled = true,
    this.criticalDays = 15,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'trackingMode': trackingMode.toString(),
      'currency': currency,

      'notificationsEnabled': notificationsEnabled,
      'criticalDays': criticalDays,
      'isDone': isDone,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      trackingMode: TrackingMode.values.firstWhere(
        (e) => e.toString() == json['trackingMode'],
        orElse: () => TrackingMode.perItem,
      ),
      currency: json['currency'] ?? 'TND',

      notificationsEnabled: json['notificationsEnabled'] ?? true,
      criticalDays: json['criticalDays'] ?? 15,
      isDone: json['isDone'] ?? false,
    );
  }

  AppSettings copyWith({
    TrackingMode? trackingMode,
    String? currency,

    bool? notificationsEnabled,
    int? criticalDays,
    bool? isDone,
  }) {
    return AppSettings(
      trackingMode: trackingMode ?? this.trackingMode,
      currency: currency ?? this.currency,

      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      criticalDays: criticalDays ?? this.criticalDays,
      isDone: isDone ?? this.isDone,
    );
  }
}





class RefundEvent {
  final String id;
  final double amount;
  final DateTime date;
  final String notes;

  RefundEvent({
    String? id,
    required this.amount,
    required this.date,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory RefundEvent.fromJson(Map<String, dynamic> json) {
    return RefundEvent(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
    );
  }

  RefundEvent copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return RefundEvent(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}

class ExpenseItem {
  final String id;
  final String title;
  final double owed;
  final DateTime date;
  final String notes;
  final List<RefundEvent> refunds;

  ExpenseItem({
    String? id,
    required this.title,
    required this.owed,
    required this.date,
    this.notes = '',
    List<RefundEvent>? refunds,
  })  : id = id ?? const Uuid().v4(),
        refunds = refunds ?? [];

  double get refunded => refunds.fold(0.0, (sum, refund) => sum + refund.amount);
  double get remaining => (owed - refunded).clamp(0.0, double.infinity);
  double get progressPercentage => owed > 0 ? ((refunded / owed) * 100).clamp(0.0, 100.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'owed': owed,
      'date': date.toIso8601String(),
      'notes': notes,
      'refunds': refunds.map((r) => r.toJson()).toList(),
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'],
      title: json['title'],
      owed: (json['owed'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
      refunds: (json['refunds'] as List<dynamic>?)
              ?.map((r) => RefundEvent.fromJson(r))
              .toList() ??
          [],
    );
  }

  ExpenseItem copyWith({
    String? id,
    String? title,
    double? owed,
    DateTime? date,
    String? notes,
    List<RefundEvent>? refunds,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      owed: owed ?? this.owed,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      refunds: refunds ?? this.refunds,
    );
  }
}

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    String? id,
    required this.amount,
    required this.date,
    required this.description,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}

class PoolTracker {
  final List<Transaction> expenses;
  final List<Transaction> refunds;

  PoolTracker({
    List<Transaction>? expenses,
    List<Transaction>? refunds,
  })  : expenses = expenses ?? [],
        refunds = refunds ?? [];

  double get totalOwed => expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  double get totalRefunded => refunds.fold(0.0, (sum, refund) => sum + refund.amount);
  double get totalRemaining => (totalOwed - totalRefunded).clamp(0.0, double.infinity);
  double get progressPercentage => totalOwed > 0 ? ((totalRefunded / totalOwed) * 100).clamp(0.0, 100.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'refunds': refunds.map((r) => r.toJson()).toList(),
    };
  }

  factory PoolTracker.fromJson(Map<String, dynamic> json) {
    return PoolTracker(
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e))
              .toList() ??
          [],
      refunds: (json['refunds'] as List<dynamic>?)
              ?.map((r) => Transaction.fromJson(r))
              .toList() ??
          [],
    );
  }

  PoolTracker copyWith({
    List<Transaction>? expenses,
    List<Transaction>? refunds,
  }) {
    return PoolTracker(
      expenses: expenses ?? this.expenses,
      refunds: refunds ?? this.refunds,
    );
  }
}

class HybridTracker {
  final List<ExpenseItem> items;
  final PoolTracker standalonePool;

  HybridTracker({
    List<ExpenseItem>? items,
    PoolTracker? standalonePool,
  })  : items = items ?? [],
        standalonePool = standalonePool ?? PoolTracker();

  double get itemsTotalOwed => items.fold(0.0, (sum, item) => sum + item.owed);
  double get itemsTotalRefunded => items.fold(0.0, (sum, item) => sum + item.refunded);
  double get itemsTotalRemaining => (itemsTotalOwed - itemsTotalRefunded).clamp(0.0, double.infinity);

  double get totalOwed => itemsTotalOwed + standalonePool.totalOwed;
  double get totalRefunded => itemsTotalRefunded + standalonePool.totalRefunded;
  double get totalRemaining => (totalOwed - totalRefunded).clamp(0.0, double.infinity);
  double get progressPercentage => totalOwed > 0 ? ((totalRefunded / totalOwed) * 100).clamp(0.0, 100.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'standalonePool': standalonePool.toJson(),
    };
  }

  factory HybridTracker.fromJson(Map<String, dynamic> json) {
    return HybridTracker(
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => ExpenseItem.fromJson(i))
              .toList() ??
          [],
      standalonePool: json['standalonePool'] != null
          ? PoolTracker.fromJson(json['standalonePool'])
          : PoolTracker(),
    );
  }

  HybridTracker copyWith({
    List<ExpenseItem>? items,
    PoolTracker? standalonePool,
  }) {
    return HybridTracker(
      items: items ?? this.items,
      standalonePool: standalonePool ?? this.standalonePool,
    );
  }
}
