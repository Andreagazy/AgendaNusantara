import 'package:agenda_nusantara/models/toDoList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Database_helper {
  static final Database_helper instance = Database_helper._init();

  static Database? _database;

  Database_helper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase('agenda_nusantara.db');
    return _database!;
  }

  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase( path, version: 2,           // naikkan versi dari 1 ke 2
    onCreate: _createDB,
    onUpgrade: _upgradeDB);
  }
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Tambah kolom completedAt ke tabel yang sudah ada
    await db.execute(
      'ALTER TABLE todo ADD COLUMN completedAt TEXT',
    );
  }
}

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task TEXT NOT NULL,
        description TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        category TEXT NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
        completedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.insert('account', {'username': 'user', 'password': 'user'});
  }

  // CRUD ToDo List
  Future<int> insertTask(ToDo todo) async {
    final db = await instance.database;
    return await db.insert('todo', todo.toMap());
  }

  Future<List<ToDo>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('todo', orderBy: 'createdAt DESC');
    return result.map((m) => ToDo.fromMap(m)).toList();
  }

  Future<int> updateTask(ToDo todo) async {
    final db = await instance.database;
    return await db.update(
      'todo',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStatus(int id, bool isDone) async {
    final db = await instance.database;
    return await db.update(
      'todo',
      {'isDone': isDone ? 1 : 0,
      'completedAt': isDone ? DateTime.now().toIso8601String() : null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hitungTugasSelesai() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM todo WHERE isDone = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> hitungTugasBelumSelesai() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM todo WHERE isDone = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

 Future<Map<String, int>> totalTugasSelesaiperHari() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT DATE(completedAt) AS day, COUNT(*) AS count
      FROM todo
      WHERE isDone = 1
        AND completedAt IS NOT NULL
        AND completedAt != ''
      GROUP BY DATE(completedAt)
      ORDER BY day ASC
    ''');

  final Map<String, int> data = {};
  for (final row in result) {
    data[row['day'] as String] = row['count'] as int;
  }
  return data;
}

  // User
  Future<bool> validateUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'account',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getAccount(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'account',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateAccount(String username,String currentPassword, String newPassword) async {
    final db = await instance.database;
    final check = await db.query(
      'account',
      where: 'username = ? AND password = ?',
      whereArgs: [username, currentPassword],
    );
    if (check.isNotEmpty) {
      await db.update(
        'account',
        {'password': newPassword},
        where: 'username = ?',
        whereArgs: [username],
      );
    } else {
      throw Exception('Current password is incorrect');
    }
  }
}
