import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/listing.dart';

/// Local SQLite storage for listings plus a tiny key/value meta table
/// (used for the first-run onboarding flag). Everything is on-device;
/// there is no account and no server.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'bookbridge.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(databasesPath, _dbName),
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE listings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT,
            subject TEXT NOT NULL,
            price REAL NOT NULL,
            condition TEXT NOT NULL,
            photo_path TEXT,
            seller_name TEXT NOT NULL,
            seller_phone TEXT NOT NULL,
            is_sold INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE meta(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<int> insertListing(Listing listing) async {
    final db = await database;
    return db.insert('listings', listing.toMap());
  }

  Future<List<Listing>> getAllListings() async {
    final db = await database;
    final rows = await db.query(
      'listings',
      orderBy: 'created_at DESC',
    );
    return rows.map(Listing.fromMap).toList();
  }

  Future<Listing?> getListing(int id) async {
    final db = await database;
    final rows = await db.query(
      'listings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return Listing.fromMap(rows.first);
  }

  Future<int> updateListing(Listing listing) async {
    final db = await database;
    return db.update(
      'listings',
      listing.toMap(),
      where: 'id = ?',
      whereArgs: [listing.id],
    );
  }

  Future<int> markSold(int id, bool sold) async {
    final db = await database;
    return db.update(
      'listings',
      {'is_sold': sold ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteListing(int id) async {
    final db = await database;
    return db.delete('listings', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasSeenOnboarding() async {
    final db = await database;
    final rows = await db.query(
      'meta',
      where: 'key = ?',
      whereArgs: ['onboarding_seen'],
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> setOnboardingSeen() async {
    final db = await database;
    await db.insert(
      'meta',
      {'key': 'onboarding_seen', 'value': '1'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
