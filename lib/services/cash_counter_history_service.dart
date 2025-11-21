import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class CashCounterHistoryService {
  static final CashCounterHistoryService _instance = CashCounterHistoryService._internal();
  factory CashCounterHistoryService() => _instance;
  CashCounterHistoryService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      // Ensure columns exist even if database was already initialized
      await _ensureColumnsExist(_database!);
      return _database!;
    }
    _database = await _initDatabase();
    await _ensureColumnsExist(_database!);
    return _database!;
  }

  Future<void> _ensureColumnsExist(Database db) async {
    try {
      // Try to query the columns to see if they exist
      await db.rawQuery('SELECT other_plus, other_minus FROM cash_counter_history LIMIT 1');
    } catch (e) {
      // Columns don't exist, add them
      try {
        await db.execute('ALTER TABLE cash_counter_history ADD COLUMN other_plus REAL DEFAULT 0');
      } catch (e2) {
        // Column might already exist, ignore
      }
      try {
        await db.execute('ALTER TABLE cash_counter_history ADD COLUMN other_minus REAL DEFAULT 0');
      } catch (e2) {
        // Column might already exist, ignore
      }
      
      // Update existing rows to have 0.0 for the new columns
      try {
        await db.update(
          'cash_counter_history',
          {'other_plus': 0.0, 'other_minus': 0.0},
          where: 'other_plus IS NULL OR other_minus IS NULL',
        );
      } catch (e3) {
        // Ignore update errors
      }
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cash_counter_history.db');
    
    // Close existing database connection if any
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cash_counter_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_500 INTEGER NOT NULL DEFAULT 0,
        note_200 INTEGER NOT NULL DEFAULT 0,
        note_100 INTEGER NOT NULL DEFAULT 0,
        note_50 INTEGER NOT NULL DEFAULT 0,
        note_20 INTEGER NOT NULL DEFAULT 0,
        note_10 INTEGER NOT NULL DEFAULT 0,
        other_plus REAL NOT NULL DEFAULT 0,
        other_minus REAL NOT NULL DEFAULT 0,
        total_notes INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        notes TEXT,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Check if columns already exist by trying to query them
        await db.rawQuery('SELECT other_plus, other_minus FROM cash_counter_history LIMIT 1');
      } catch (e) {
        // Columns don't exist, add them
        // SQLite doesn't support adding NOT NULL columns directly, so we add them as nullable first
        await db.execute('ALTER TABLE cash_counter_history ADD COLUMN other_plus REAL DEFAULT 0');
        await db.execute('ALTER TABLE cash_counter_history ADD COLUMN other_minus REAL DEFAULT 0');
        
        // Update existing rows to have 0.0 for the new columns
        await db.update(
          'cash_counter_history',
          {'other_plus': 0.0, 'other_minus': 0.0},
          where: 'other_plus IS NULL OR other_minus IS NULL',
        );
      }
    }
  }

  Future<int> saveCashCount({
    required int note500,
    required int note200,
    required int note100,
    required int note50,
    required int note20,
    required int note10,
    required int totalNotes,
    required double totalAmount,
    double otherPlus = 0,
    double otherMinus = 0,
    String? notes,
  }) async {
    final db = await database;
    return await db.insert(
      'cash_counter_history',
      {
        'note_500': note500,
        'note_200': note200,
        'note_100': note100,
        'note_50': note50,
        'note_20': note20,
        'note_10': note10,
        'other_plus': otherPlus,
        'other_minus': otherMinus,
        'total_notes': totalNotes,
        'total_amount': totalAmount,
        'notes': notes ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<int> updateCashCount({
    required int id,
    required int note500,
    required int note200,
    required int note100,
    required int note50,
    required int note20,
    required int note10,
    required int totalNotes,
    required double totalAmount,
    double otherPlus = 0,
    double otherMinus = 0,
    String? notes,
  }) async {
    final db = await database;
    return await db.update(
      'cash_counter_history',
      {
        'note_500': note500,
        'note_200': note200,
        'note_100': note100,
        'note_50': note50,
        'note_20': note20,
        'note_10': note10,
        'other_plus': otherPlus,
        'other_minus': otherMinus,
        'total_notes': totalNotes,
        'total_amount': totalAmount,
        'notes': notes ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CashCounterHistory>> getHistory({int? limit}) async {
    final db = await database;
    String query = 'SELECT * FROM cash_counter_history ORDER BY timestamp DESC';
    
    if (limit != null) {
      query += ' LIMIT ?';
    }

    final List<Map<String, dynamic>> maps = limit != null
        ? await db.rawQuery(query, [limit])
        : await db.rawQuery(query);

    return List.generate(maps.length, (i) {
      return CashCounterHistory(
        id: maps[i]['id'] as int,
        note500: maps[i]['note_500'] as int,
        note200: maps[i]['note_200'] as int,
        note100: maps[i]['note_100'] as int,
        note50: maps[i]['note_50'] as int,
        note20: maps[i]['note_20'] as int,
        note10: maps[i]['note_10'] as int,
        otherPlus: (maps[i]['other_plus'] as num?)?.toDouble() ?? 0.0,
        otherMinus: (maps[i]['other_minus'] as num?)?.toDouble() ?? 0.0,
        totalNotes: maps[i]['total_notes'] as int,
        totalAmount: maps[i]['total_amount'] as double,
        notes: maps[i]['notes'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp'] as int),
      );
    });
  }

  Future<CashCounterHistory?> getCashCountById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cash_counter_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return CashCounterHistory(
      id: maps[0]['id'] as int,
      note500: maps[0]['note_500'] as int,
      note200: maps[0]['note_200'] as int,
      note100: maps[0]['note_100'] as int,
      note50: maps[0]['note_50'] as int,
      note20: maps[0]['note_20'] as int,
      note10: maps[0]['note_10'] as int,
      otherPlus: (maps[0]['other_plus'] as num?)?.toDouble() ?? 0.0,
      otherMinus: (maps[0]['other_minus'] as num?)?.toDouble() ?? 0.0,
      totalNotes: maps[0]['total_notes'] as int,
      totalAmount: maps[0]['total_amount'] as double,
      notes: maps[0]['notes'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(maps[0]['timestamp'] as int),
    );
  }

  Future<int> deleteCashCount(int id) async {
    final db = await database;
    return await db.delete(
      'cash_counter_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('cash_counter_history');
  }

  Future<int> getHistoryCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cash_counter_history');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

class CashCounterHistory {
  final int id;
  final int note500;
  final int note200;
  final int note100;
  final int note50;
  final int note20;
  final int note10;
  final double otherPlus;
  final double otherMinus;
  final int totalNotes;
  final double totalAmount;
  final String notes;
  final DateTime timestamp;

  CashCounterHistory({
    required this.id,
    required this.note500,
    required this.note200,
    required this.note100,
    required this.note50,
    required this.note20,
    required this.note10,
    this.otherPlus = 0.0,
    this.otherMinus = 0.0,
    required this.totalNotes,
    required this.totalAmount,
    required this.notes,
    required this.timestamp,
  });

  Map<String, int> get noteCounts => {
    '500': note500,
    '200': note200,
    '100': note100,
    '50': note50,
    '20': note20,
    '10': note10,
  };
}

