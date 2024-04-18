import 'package:mexanyd_desktop/database/interface.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase extends IDatabase {
  static const version = 1;

  final String path;
  final Database _database;

  static Future<LocalDatabase> open() async {
    final dir = await getApplicationSupportDirectory();
    final dbPath = join(dir.path, "mexanyd.db");

    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(dbPath);

    await database.execute("PRAGMA foreign_keys = ON");

    await database.execute('''
      CREATE TABLE IF NOT EXISTS in_out (
        id INTEGER PRIMARY KEY,
        value REAL NOT NULL,
        creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        description TEXT NOT NULL DEFAULT '',
        type INTEGER NOT NULL DEFAULT 0
      )
    ''');

    return LocalDatabase._(dbPath, database);
  }

  LocalDatabase._(this.path, this._database);

  @override
  Future<void> deleteInOut(int id) async {
    await _database.delete("in_out", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<void> insertInOut(double value, InOutType type,
      {String description = ''}) async {
    await _database.insert("in_out", {
      "value": value,
      "description": description,
      "type": type.value,
    });
  }

  @override
  Future<List<InOut>> listInOut(
    int year,
    int month, {
    int? day,
    int limit = 50,
    int offset = 0,
    bool reversed = false,
  }) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
      whereArgs = ["$yearStr-$monthStr-$dayStr"];
    }

    final orderBy = reversed ? "creation DESC" : "creation ASC";

    return _database
        .query(
          "in_out",
          columns: ["id", "value", "creation", "description", "type"],
          where: where,
          whereArgs: whereArgs,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        )
        .then((rows) => rows.map(InOut.fromMap).toList());
  }

  @override
  Future<int> countInOut(int year, int month, {int? day}) {
    final yearStr = year.toString().padLeft(4, '0');
    final monthStr = month.toString().padLeft(2, '0');
    final dayStr = day?.toString().padLeft(2, '0');

    var where = "strftime('%Y-%m', creation, 'localtime') = ?";
    var whereArgs = ["$yearStr-$monthStr"];
    if (dayStr != null) {
      where = "strftime('%Y-%m-%d', creation, 'localtime') = ?";
      whereArgs = ["$yearStr-$monthStr-$dayStr"];
    }

    return _database
        .query(
          "in_out",
          columns: ["COUNT(*)"],
          where: where,
          whereArgs: whereArgs,
        )
        .then((rows) => rows.first.values.first as int);
  }
}
