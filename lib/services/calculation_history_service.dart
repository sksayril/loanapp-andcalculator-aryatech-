import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class CalculationHistoryService {
  static final CalculationHistoryService _instance = CalculationHistoryService._internal();
  factory CalculationHistoryService() => _instance;
  CalculationHistoryService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calculation_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calculation_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calculator_type TEXT NOT NULL,
        input_data TEXT NOT NULL,
        result_data TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> saveCalculation({
    required String calculatorType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  }) async {
    final db = await database;
    return await db.insert(
      'calculation_history',
      {
        'calculator_type': calculatorType,
        'input_data': jsonEncode(inputData),
        'result_data': jsonEncode(resultData),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<List<CalculationHistory>> getHistory({
    String? calculatorType,
    int? limit,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM calculation_history';
    List<dynamic> whereArgs = [];

    if (calculatorType != null) {
      query += ' WHERE calculator_type = ?';
      whereArgs.add(calculatorType);
    }

    query += ' ORDER BY timestamp DESC';

    if (limit != null) {
      query += ' LIMIT ?';
      whereArgs.add(limit);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, whereArgs);

    return List.generate(maps.length, (i) {
      return CalculationHistory(
        id: maps[i]['id'] as int,
        calculatorType: maps[i]['calculator_type'] as String,
        inputData: jsonDecode(maps[i]['input_data'] as String) as Map<String, dynamic>,
        resultData: jsonDecode(maps[i]['result_data'] as String) as Map<String, dynamic>,
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp'] as int),
      );
    });
  }

  Future<int> deleteCalculation(int id) async {
    final db = await database;
    return await db.delete(
      'calculation_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory({String? calculatorType}) async {
    final db = await database;
    if (calculatorType != null) {
      return await db.delete(
        'calculation_history',
        where: 'calculator_type = ?',
        whereArgs: [calculatorType],
      );
    }
    return await db.delete('calculation_history');
  }

  Future<int> getHistoryCount({String? calculatorType}) async {
    final db = await database;
    if (calculatorType != null) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM calculation_history WHERE calculator_type = ?',
        [calculatorType],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    }
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM calculation_history');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

class CalculationHistory {
  final int id;
  final String calculatorType;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> resultData;
  final DateTime timestamp;

  CalculationHistory({
    required this.id,
    required this.calculatorType,
    required this.inputData,
    required this.resultData,
    required this.timestamp,
  });

  String get displayTitle {
    switch (calculatorType) {
      case 'emi':
        return 'EMI Calculator';
      case 'gst':
        return 'GST Calculator';
      case 'vat':
        return 'VAT Calculator';
      case 'ppf':
        return 'PPF Calculator';
      case 'sip':
        return 'SIP Calculator';
      case 'income_tax':
        return 'Income Tax Calculator';
      default:
        return calculatorType;
    }
  }
}

