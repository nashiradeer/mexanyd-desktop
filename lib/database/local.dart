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
    final db_path = join(dir.path, "mexanyd.db");

    sqfliteFfiInit();

    final database = await databaseFactoryFfi.openDatabase(db_path);

    await database.execute("PRAGMA foreign_keys = ON");

    await database.execute('''
      CREATE TABLE IF NOT EXISTS in_out (
        id INTEGER PRIMARY KEY,
        value REAL NOT NULL,
        creation TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    return LocalDatabase._(db_path, database);
  }

  LocalDatabase._(this.path, this._database);

  @override
  Future<void> deleteInOut(int id) async {
    await _database.delete("in_out", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<InOut?> getInOut(int id) async {
    var result = await _database.query(
      "in_out",
      columns: ["id", "value", "creation", "description"],
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return InOut.fromMap(result.first);
  }

  @override
  Future<void> insertInOut(double value, {String description = ''}) async {
    await _database.insert("in_out", {
      "creation": DateTime.now().toDateString(),
      "value": value,
      "description": description,
    });
  }

  @override
  Future<List<InOut>> listInOutByCreation(int year,
      {int? month,
      int? day,
      int limit = 10,
      int offset = 0,
      bool reversed = false}) async {
    var yearStr = year.toString().padLeft(4, '0');
    var whereArg = "$yearStr%";

    if (month != null) {
      var monthStr = month.toString().padLeft(2, '0');

      if (day != null) {
        var dayStr = day.toString().padLeft(2, '0');
        whereArg = "$yearStr-$monthStr-$dayStr";
      } else {
        whereArg = "$yearStr-$monthStr%";
      }
    }

    return await _database
        .query("in_out",
            columns: ["id", "value", "creation", "description"],
            limit: limit,
            offset: offset,
            where: "creation LIKE ?",
            orderBy: "id ${reversed ? 'DESC' : 'ASC'}",
            whereArgs: [whereArg])
        .then((value) => value.map((e) => InOut.fromMap(e)).toList());
  }
}
