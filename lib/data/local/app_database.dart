import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _databaseName = 'countdown_reminder.db';
  static const _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, _databaseName);
    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE achievement_entries(
              id TEXT PRIMARY KEY,
              countdown_id TEXT NOT NULL,
              entry_date TEXT NOT NULL,
              content TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE countdowns ADD COLUMN reminder_enabled INTEGER NOT NULL DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE countdowns ADD COLUMN reminder_hour INTEGER NOT NULL DEFAULT 9
          ''');
          await db.execute('''
            ALTER TABLE countdowns ADD COLUMN reminder_minute INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );

    return _database!;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE countdowns(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        reminder_hour INTEGER NOT NULL DEFAULT 9,
        reminder_minute INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        is_pinned INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE achievement_entries(
        id TEXT PRIMARY KEY,
        countdown_id TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}
