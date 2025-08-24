import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/tracking_models.dart' hide Transaction;
import '../models/tracking_models.dart' as models show Transaction;

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'refund_tracker.db';
  static const int _databaseVersion = 2;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        tracking_mode TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'TND',

        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        critical_days INTEGER NOT NULL DEFAULT 15,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Wallet manager table
    await db.execute('''
      CREATE TABLE wallet_manager (
        id TEXT PRIMARY KEY,
        solana_wallets TEXT,
        value_wallets TEXT,
        active_solana_wallet_id TEXT,
        active_value_wallet_id TEXT
      )
    ''');

    // Expense items table
    await db.execute('''
      CREATE TABLE expense_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        owed REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        mode TEXT NOT NULL
      )
    ''');

    // Refund events table
    await db.execute('''
      CREATE TABLE refund_events (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (item_id) REFERENCES expense_items (id) ON DELETE CASCADE
      )
    ''');

    // Pool transactions table
    await db.execute('''
      CREATE TABLE pool_transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        mode TEXT NOT NULL
      )
    ''');

    // Solana wallets table
    await db.execute('''
      CREATE TABLE solana_wallets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        token_name TEXT NOT NULL,
        initial_supply REAL NOT NULL,
        is_per_item_tracking INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Solana items table
    await db.execute('''
      CREATE TABLE solana_items (
        id TEXT PRIMARY KEY,
        wallet_id TEXT NOT NULL,
        title TEXT NOT NULL,
        locked_tokens REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (wallet_id) REFERENCES solana_wallets (id) ON DELETE CASCADE
      )
    ''');

    // Solana transactions table
    await db.execute('''
      CREATE TABLE solana_transactions (
        id TEXT PRIMARY KEY,
        wallet_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        item_id TEXT,
        FOREIGN KEY (wallet_id) REFERENCES solana_wallets (id) ON DELETE CASCADE
      )
    ''');

    // Value wallets table
    await db.execute('''
      CREATE TABLE value_wallets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'TND',
        current_balance REAL NOT NULL,
        is_per_item_tracking INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Value events table
    await db.execute('''
      CREATE TABLE value_events (
        id TEXT PRIMARY KEY,
        wallet_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        new_balance REAL NOT NULL,
        FOREIGN KEY (wallet_id) REFERENCES value_wallets (id) ON DELETE CASCADE
      )
    ''');

    // Value items table
    await db.execute('''
      CREATE TABLE value_items (
        id TEXT PRIMARY KEY,
        wallet_id TEXT NOT NULL,
        title TEXT NOT NULL,
        initial_value REAL NOT NULL,
        current_value REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (wallet_id) REFERENCES value_wallets (id) ON DELETE CASCADE
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'tracking_mode': 'TrackingMode.perItem',
      'currency': 'TND',
      'notifications_enabled': 1,
      'critical_days': 15,
      'is_done': 0,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add Solana and Value mode tables

      // Wallet manager table
      await db.execute('''
        CREATE TABLE wallet_manager (
          id TEXT PRIMARY KEY,
          solana_wallets TEXT,
          value_wallets TEXT,
          active_solana_wallet_id TEXT,
          active_value_wallet_id TEXT
        )
      ''');

      // Solana wallets table
      await db.execute('''
        CREATE TABLE solana_wallets (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          token_name TEXT NOT NULL,
          initial_supply REAL NOT NULL,
          is_per_item_tracking INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      // Solana items table
      await db.execute('''
        CREATE TABLE solana_items (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          title TEXT NOT NULL,
          locked_tokens REAL NOT NULL,
          date TEXT NOT NULL,
          notes TEXT,
          FOREIGN KEY (wallet_id) REFERENCES solana_wallets (id) ON DELETE CASCADE
        )
      ''');

      // Solana transactions table
      await db.execute('''
        CREATE TABLE solana_transactions (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          description TEXT NOT NULL,
          item_id TEXT,
          FOREIGN KEY (wallet_id) REFERENCES solana_wallets (id) ON DELETE CASCADE
        )
      ''');

      // Value wallets table
      await db.execute('''
        CREATE TABLE value_wallets (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          currency TEXT NOT NULL DEFAULT 'TND',
          current_balance REAL NOT NULL,
          is_per_item_tracking INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL
        )
      ''');

      // Value events table
      await db.execute('''
        CREATE TABLE value_events (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          description TEXT NOT NULL,
          new_balance REAL NOT NULL,
          FOREIGN KEY (wallet_id) REFERENCES value_wallets (id) ON DELETE CASCADE
        )
      ''');

      // Value items table
      await db.execute('''
        CREATE TABLE value_items (
          id TEXT PRIMARY KEY,
          wallet_id TEXT NOT NULL,
          title TEXT NOT NULL,
          initial_value REAL NOT NULL,
          current_value REAL NOT NULL,
          date TEXT NOT NULL,
          notes TEXT,
          FOREIGN KEY (wallet_id) REFERENCES value_wallets (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Settings operations
  Future<AppSettings> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('settings', limit: 1);

    if (maps.isEmpty) {
      return AppSettings(
        trackingMode: TrackingMode.perItem,
        currency: 'TND',
        notificationsEnabled: true,
        criticalDays: 15,
      );
    }

    final map = maps.first;
    return AppSettings(
      trackingMode: TrackingMode.values.firstWhere(
        (e) => e.toString() == map['tracking_mode'],
        orElse: () => TrackingMode.perItem,
      ),
      currency: map['currency'] ?? 'TND',
      notificationsEnabled: map['notifications_enabled'] == 1,
      criticalDays: map['critical_days'] ?? 15,
      isDone: map['is_done'] == 1,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    await db.update(
      'settings',
      {
        'tracking_mode': settings.trackingMode.toString(),
        'currency': settings.currency,
        'notifications_enabled': settings.notificationsEnabled ? 1 : 0,
        'critical_days': settings.criticalDays,
        'is_done': settings.isDone ? 1 : 0,
      },
      where: 'id = 1',
    );
  }

  // Per-item operations
  Future<List<ExpenseItem>> getPerItemData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_items',
      where: 'mode = ?',
      whereArgs: ['per_item'],
    );

    return Future.wait(maps.map((map) async {
      final refunds = await getRefundEvents(map['id']);
      return ExpenseItem.fromJson({
        'id': map['id'],
        'title': map['title'],
        'owed': map['owed'],
        'date': map['date'],
        'notes': map['notes'],
        'refunds': refunds.map((r) => r.toJson()).toList(),
      });
    }).toList());
  }

  Future<void> addPerItemExpense(ExpenseItem item) async {
    final db = await database;
    await db.insert('expense_items', {
      'id': item.id,
      'title': item.title,
      'owed': item.owed,
      'date': item.date.toIso8601String(),
      'notes': item.notes,
      'mode': 'per_item',
    });
  }

  Future<void> updatePerItemExpense(ExpenseItem item) async {
    final db = await database;
    await db.update(
      'expense_items',
      {
        'title': item.title,
        'owed': item.owed,
        'date': item.date.toIso8601String(),
        'notes': item.notes,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );

    // Update refunds
    await db
        .delete('refund_events', where: 'item_id = ?', whereArgs: [item.id]);
    for (final refund in item.refunds) {
      await db.insert('refund_events', {
        'id': refund.id,
        'item_id': item.id,
        'amount': refund.amount,
        'date': refund.date.toIso8601String(),
        'notes': refund.notes,
      });
    }
  }

  Future<void> deletePerItemExpense(String itemId) async {
    final db = await database;
    await db.delete('expense_items', where: 'id = ?', whereArgs: [itemId]);
  }

  Future<List<RefundEvent>> getRefundEvents(String itemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'refund_events',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );

    return maps.map((map) => RefundEvent.fromJson(map)).toList();
  }

  // Pool operations
  Future<PoolTracker> getPoolData() async {
    final db = await database;
    final List<Map<String, dynamic>> expenseMaps = await db.query(
      'pool_transactions',
      where: 'type = ? AND mode = ?',
      whereArgs: ['expense', 'pool'],
    );

    final List<Map<String, dynamic>> refundMaps = await db.query(
      'pool_transactions',
      where: 'type = ? AND mode = ?',
      whereArgs: ['refund', 'pool'],
    );

    final expenses =
        expenseMaps.map((map) => models.Transaction.fromJson(map)).toList();
    final refunds =
        refundMaps.map((map) => models.Transaction.fromJson(map)).toList();

    return PoolTracker(expenses: expenses, refunds: refunds);
  }

  Future<void> addPoolExpense(double amount, String description) async {
    final db = await database;
    await db.insert('pool_transactions', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'description': description,
      'type': 'expense',
      'mode': 'pool',
    });
  }

  Future<void> addPoolRefund(double amount, String description) async {
    final db = await database;
    await db.insert('pool_transactions', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'description': description,
      'type': 'refund',
      'mode': 'pool',
    });
  }

  // Hybrid operations
  Future<HybridTracker> getHybridData() async {
    final db = await database;

    // Get hybrid items
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'expense_items',
      where: 'mode = ?',
      whereArgs: ['hybrid'],
    );

    final items = await Future.wait(itemMaps.map((map) async {
      final refunds = await getRefundEvents(map['id']);
      return ExpenseItem.fromJson({
        'id': map['id'],
        'title': map['title'],
        'owed': map['owed'],
        'date': map['date'],
        'notes': map['notes'],
        'refunds': refunds.map((r) => r.toJson()).toList(),
      });
    }).toList());

    // Get standalone pool transactions
    final List<Map<String, dynamic>> expenseMaps = await db.query(
      'pool_transactions',
      where: 'type = ? AND mode = ?',
      whereArgs: ['expense', 'hybrid'],
    );

    final List<Map<String, dynamic>> refundMaps = await db.query(
      'pool_transactions',
      where: 'type = ? AND mode = ?',
      whereArgs: ['refund', 'hybrid'],
    );

    final expenses =
        expenseMaps.map((map) => models.Transaction.fromJson(map)).toList();
    final refunds =
        refundMaps.map((map) => models.Transaction.fromJson(map)).toList();

    return HybridTracker(
      items: items,
      standalonePool: PoolTracker(expenses: expenses, refunds: refunds),
    );
  }

  Future<void> addHybridItem(ExpenseItem item) async {
    final db = await database;
    await db.insert('expense_items', {
      'id': item.id,
      'title': item.title,
      'owed': item.owed,
      'date': item.date.toIso8601String(),
      'notes': item.notes,
      'mode': 'hybrid',
    });
  }

  Future<void> addHybridStandaloneExpense(
      double amount, String description) async {
    final db = await database;
    await db.insert('pool_transactions', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'description': description,
      'type': 'expense',
      'mode': 'hybrid',
    });
  }

  Future<void> addHybridStandaloneRefund(
      double amount, String description) async {
    final db = await database;
    await db.insert('pool_transactions', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'description': description,
      'type': 'refund',
      'mode': 'hybrid',
    });
  }

  Future<void> saveHybridData(HybridTracker hybridData) async {
    final db = await database;

    // Clear existing hybrid data
    await db.delete('expense_items', where: 'mode = ?', whereArgs: ['hybrid']);
    await db
        .delete('pool_transactions', where: 'mode = ?', whereArgs: ['hybrid']);

    // Save items
    for (final item in hybridData.items) {
      await addHybridItem(item);
    }

    // Save standalone pool expenses
    for (final expense in hybridData.standalonePool.expenses) {
      await addHybridStandaloneExpense(expense.amount, expense.description);
    }

    // Save standalone pool refunds
    for (final refund in hybridData.standalonePool.refunds) {
      await addHybridStandaloneRefund(refund.amount, refund.description);
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('expense_items');
    await db.delete('refund_events');
    await db.delete('pool_transactions');
  }
}
