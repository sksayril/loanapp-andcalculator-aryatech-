import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/loan_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('loan_profiles.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE loan_profiles (
        id $idType,
        loan_sector $textType,
        loan_company $textType,
        total_amount $realType,
        monthly_emi $realType,
        tenure_days $integerType,
        created_at $textType
      )
    ''');
  }

  Future<int> insertLoanProfile(LoanProfile profile) async {
    final db = await database;
    return await db.insert(
      'loan_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LoanProfile>> getAllLoanProfiles() async {
    final db = await database;
    final result = await db.query(
      'loan_profiles',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => LoanProfile.fromMap(map)).toList();
  }

  Future<LoanProfile?> getLoanProfileById(int id) async {
    final db = await database;
    final result = await db.query(
      'loan_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return LoanProfile.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateLoanProfile(LoanProfile profile) async {
    final db = await database;
    return await db.update(
      'loan_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteLoanProfile(int id) async {
    final db = await database;
    return await db.delete(
      'loan_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

